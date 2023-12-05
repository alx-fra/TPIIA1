breed[Hienas Hiena]
breed[Leoes Leao]
breed [Cacadores Cacador]
turtles-own [energia];
globals [energialeao energiaHiena energia-media-leoes energia-media-hienas energia-media-cacadores  hiena-killcount leao-killcount nvlhiena hienas-cacadas tempo]
Hienas-own [nvl]
Leoes-own[feito  descanso-count em-descanso]
Cacadores-own[]
to setup
  reset-ticks
  set hiena-killcount 0
  set leao-killcount 0
  set hienas-cacadas 0
  set tempo 0
  setup-patches
  setup-turtles

end

to setup-patches

  clear-all
  set-patch-size 15
  reset-ticks
  ask n-of ((alimCastanho * count patches) / 100 ) patches with [pcolor = black][set  pcolor brown]
  ask n-of ((alimVermelho * count patches) / 100 ) patches with [pcolor = black][set  pcolor red]
  ask n-of nAzul patches with [pcolor = black] [set pcolor blue]




end


to go
  set tempo tempo + 1
  MoveAgents


  morte
  if ticks = 1000
    [stop]


  update-energia-media-leoes
  update-energia-media-hienas
  update-energia-media-cacadores
  tick
end

to morte
  ask turtles[
    if energia <= 0[
      die
    ]
  ]
end

to setup-turtles
  clear-turtles
  create-Hienas nHienas[
    set shape "arrow"
    set color orange

    set nvl 1
    setxy random-xcor random-ycor

  ]
  create-Leoes nLeoes[
    set shape "arrow"
    set color white
    setxy random-xcor random-ycor
    set descanso-count 0
    set em-descanso 0

  ]
  create-Cacadores nCacadores[
    set shape "person"
    set color yellow
    setxy random-xcor random-ycor

  ]
  ask turtles [set energia energiaInicial]
end

to MoveAgents
  MoveLeoes
  MoveHienas
  MoveCacadores
end

to update-energia-media-leoes
  ifelse count(Leoes) > 0[
  let media-energia mean [energia] of Leoes / count(Leoes)
    set energia-media-leoes media-energia]
  [set energia-media-leoes 0]
end

to update-energia-media-hienas
  ifelse count(Hienas) > 0[
    let media-energia mean [energia] of Hienas / count(hienas)
    set energia-media-hienas media-energia]
  [set energia-media-hienas 0]
end

to update-energia-media-cacadores
  ifelse count(Cacadores) > 0[
    let media-energia mean [energia] of Cacadores / count(Cacadores)
    set energia-media-cacadores media-energia]
  [set energia-media-cacadores 0]
end


to Comer
  set feito 1
   (ifelse
     pcolor  = red [
          set energia energia + energiaVermelho

          set pcolor brown
      set energia energia - 1
        ]
       pcolor  = brown [
      ask one-of patches with [pcolor = black][set  pcolor brown]
          set energia energia + energiaCastanho
          set pcolor black
      set energia energia - 1
        ]
      [pcolor] of patch-ahead 1  = red[ fd 1
      set energia energia - 1
    ]
      [pcolor] of patch-right-and-ahead 90 1 = red[ rt 90
      set energia energia - 1
    ]
      [pcolor] of patch-right-and-ahead -90 1 = red[ rt -90
      set energia energia - 1
   ]
       [pcolor] of patch-ahead 1  = brown[ fd 1
    set energia energia - 1]
      [pcolor] of patch-right-and-ahead 90 1 = brown[ rt 90
    set energia energia - 1]
      [pcolor] of patch-right-and-ahead -90 1 = brown[ rt -90
    set energia energia - 1]

    [set feito 0]
)
end
to Fugir
  set feito 1
  ; Prioridade 2: Ação de movimentação especial
  let novo-heading (heading - 90) mod 360
  let hienas-esquerda count hienas in-radius 1 with [heading = novo-heading]
  set novo-heading (heading + 90) mod 360
  let hienas-direita count hienas in-radius 1 with [heading = novo-heading]
  let hienas-frente count hienas in-radius 1 with [heading = heading]
  (ifelse
  (hienas-esquerda >= 2) [
    ; Se o leão tem duas ou mais hienas à sua esquerda, salta para a célula à sua direita, perdendo duas (2) unidades de energia
    let new-patch patch-at-heading-and-distance (heading + 90) 1
    move-to new-patch
    set energia energia - 2
  ]
    (hienas-direita >= 2) [
      ; Se o leão tem duas ou mais hienas à sua direita, salta para a célula à sua esquerda, perdendo duas (2) unidades de energia
      let new-patch patch-at-heading-and-distance (heading - 90) 1
      move-to new-patch
      set energia energia - 2
    ]
    (hienas-frente >= 2) or ((hienas-esquerda >= 1) and (hienas-direita >= 1)) [
        ; Se o leão tem duas ou mais hienas à sua frente ou tem hienas nos lados esquerdo e direito, salta para a célula atrás de si, perdendo três (3) unidades de energia
        let new-patch patch-at-heading-and-distance (heading - 180) 1
        move-to new-patch
        set energia energia - 3
      ]
    (hienas-esquerda >= 1) and (hienas-frente >= 1) [
          ; Se o leão tem hienas à esquerda e à frente, salta para a célula à direita atrás de si, perdendo cinco (5) unidades de energia
          let new-patch patch-at-heading-and-distance (heading + 90) 2
          move-to new-patch
          set energia energia - 5
        ]

    (hienas-direita >= 1) and (hienas-frente >= 1) [
            ; Se o leão tem hienas à direita e à frente, salta para a célula à esquerda atrás de si, perdendo cinco (5) unidades de energia
            let new-patch patch-at-heading-and-distance (heading - 90) 2
            move-to new-patch
            set energia energia - 5
          ]
    (hienas-esquerda >= 1) and (hienas-direita >= 1) and (hienas-frente >= 1) [
              ; Se o leão tem hienas à esquerda, à direita e à frente, salta para duas células atrás de si, perdendo cinco (4) unidades de energia
              let new-patch patch-at-heading-and-distance (heading - 180) 2
              move-to new-patch
              set energia energia - 4
            ]
    [set feito 0]
  )
end



to Ataca

  set feito 1


  ifelse (count Hienas-on patch-ahead 1 + count Hienas-on patch-right-and-ahead 90 1 + count Hienas-on patch-right-and-ahead -90 1) = 1[
    (ifelse

      count Hienas-on patch-ahead 1 > 0[

      ask Hienas-on patch-ahead 1[
        set energiaHiena energia
        set pcolor brown
        die
        ]

      ]

      count Hienas-on patch-right-and-ahead 90 1 > 0[

        ask Hienas-on patch-right-and-ahead 90 1[
          set energiaHiena energia
          set pcolor brown
          die
        ]

      ]

      count Hienas-on patch-right-and-ahead -90 1 > 0[

        ask Hienas-on patch-right-and-ahead -90 1[
          set energiaHiena energia
          set pcolor brown
          die
        ]

      ]

    )
  set energia energia - (((energiaHiena) * (percentagemCombate / 100)) )

  ][
  set feito 0

  ]
end


to MoveLeoes
  ask Leoes [
    ;ve uma azul e nao esta em descanso -> entra em descanso
    if (pcolor = blue or [pcolor] of patch-ahead 1 = blue or [pcolor] of patch-left-and-ahead 90 1 = blue or [pcolor] of patch-right-and-ahead 90 1 = blue) and em-descanso = 0 and descanso-count = 0 [
       set descanso-count descanso-ticks
      set em-descanso 1
    ]
    ;acabou o descanso
    if (em-descanso = 1 and descanso-count = 0 )[
      set em-descanso 0
    set descanso-count 0
    ]


    ifelse em-descanso = 0 [

      ; Prioridade 1: Ação de alimentação
      ifelse energia < valor-energia [
        Comer
        if feito = 0 [Fugir]
      ] [
        Fugir
        if feito = 0 [Comer]
      ]
      if feito = 0 [Ataca]
      if feito = 0 [
        forward 1
        set energia energia - 1]
    ] [
      ;ve uma azul e em descanso
      if (pcolor = blue or [pcolor] of patch-ahead 1 = blue or [pcolor] of patch-left-and-ahead 90 1 = blue or [pcolor] of patch-right-and-ahead 90 1 = blue) and em-descanso = 1 and descanso-count > 0 [
        set descanso-count descanso-count - 1
      ]



    ]

    if energia <= 0 [die]
  ]

end



to MoveHienas
  ask Hienas[

    set energia energia - 1

    (ifelse ((count Hienas-on patch-ahead 1) + (count Hienas-on patch-right-and-ahead 90 1) + (count Hienas-on patch-right-and-ahead -90 1) + (count Hienas-on patch-right-and-ahead -45 1) +  (count Hienas-on patch-right-and-ahead 45 1) + (count Hienas-on patch-right-and-ahead -135 1) + (count Hienas-on patch-right-and-ahead 135 1)) > 1
    [
    set nvl ((count Hienas-on patch-ahead 1) + (count Hienas-on patch-right-and-ahead 90 1) + (count Hienas-on patch-right-and-ahead -90 1))
    set color red

        ask Hienas-on patch-ahead 1  [
          set color red
        ]
      ask Hienas-on patch-right-and-ahead 45 1  [
          set color red
        ]
    ask Hienas-on patch-right-and-ahead -45 1  [
          set color red
        ]
    ask Hienas-on patch-right-and-ahead 90 1  [
          set color red
        ]
 ask Hienas-on patch-right-and-ahead -90 1  [
          set color red
        ]
    ask Hienas-on patch-right-and-ahead -135 1  [
          set color red
        ]
    ask Hienas-on patch-right-and-ahead 135 1  [
          set color red
        ]
    ask Hienas-on patch-ahead -1  [
          set color red
        ]
    ]
    [
    set nvl 1
    set color orange
    ])

      if nvl > 1 and (count Leoes-on patch-ahead 1 + count Leoes-on patch-right-and-ahead 90 1 + count Leoes-on patch-right-and-ahead -90 1) = 1[
      (ifelse (count Leoes-on patch-ahead 1) > 0 and (sum [em-descanso] of leoes-on patch-ahead 1) = 0[ask Leoes-on patch-ahead 1[
set hiena-killcount hiena-killcount + 1
        set energialeao energia
        set pcolor red
        die
        ]
        ](count Leoes-on patch-right-and-ahead 90 1) > 0 and (sum [em-descanso] of leoes-on patch-right-and-ahead 90 1) = 0
        [ask Leoes-on patch-right-and-ahead 90 1[
          set hiena-killcount hiena-killcount + 1
        set energialeao energia
        set pcolor red
          die]

        ](count Leoes-on patch-right-and-ahead -90 1) > 0 and (sum [em-descanso] of leoes-on patch-right-and-ahead -90 1) = 0[
          ask Leoes-on patch-right-and-ahead -90 1[
            set hiena-killcount hiena-killcount + 1
        set energialeao energia
        set pcolor red
            die]

        ]
        )

        SET energia energia - (((energialeao) * (percentagemCombate / 100)) / nvl)
      ]


      (ifelse
     pcolor  = red [
          set energia energia + energiaVermelho

          set pcolor brown
        ]
       pcolor  = brown [
        ask one-of patches with [pcolor = black][set  pcolor brown]
          set energia energia + energiaCastanho
          set pcolor black
        ]
      [pcolor] of patch-ahead 1  = red[ fd 1]
      [pcolor] of patch-right-and-ahead 90 1 = red[ rt 90]
      [pcolor] of patch-right-and-ahead -90 1 = red[ rt -90]
       [pcolor] of patch-ahead 1  = brown[ fd 1]
      [pcolor] of patch-right-and-ahead 90 1 = brown[ rt 90]
      [pcolor] of patch-right-and-ahead -90 1 = brown[ rt -90]



        [
          fd 1
        ]
      )

let hienaheading heading

        ask Hienas-on patch-ahead 1  [
          set heading hienaheading
        ]
      ask Hienas-on patch-right-and-ahead 45 1  [
          set heading  hienaheading
        ]
    ask Hienas-on patch-right-and-ahead -45 1  [
          set heading  hienaheading
        ]
    ask Hienas-on patch-right-and-ahead 90 1  [
          set heading  hienaheading
        ]
 ask Hienas-on patch-right-and-ahead -90 1  [
          set heading hienaheading
        ]
    ask Hienas-on patch-right-and-ahead -135 1  [
          set heading hienaheading
        ]
    ask Hienas-on patch-right-and-ahead 135 1  [
          set heading hienaheading
        ]
    ask Hienas-on patch-ahead -1  [
          set heading hienaheading
        ]


   if energia <= 0 [die]
  ]
end

to moveCacadores
  ask Cacadores[
  let hiena-vermelha one-of Hienas-on patches in-radius 5 with [pcolor = red]
  ifelse hiena-vermelha != nobody [
     set energia energia + 5
    ask hiena-vermelha [
        set hienas-cacadas hienas-cacadas + 1
      ask patch-here [set pcolor red]
      die
    ]
    ][


      let random-turn random 360
      right random-turn
      forward 2
      set energia energia - 2

    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
197
20
700
524
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
9
22
99
77
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
124
191
157
nHienas
nHienas
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
10
83
191
116
nLeoes
nLeoes
0
100
15.0
1
1
NIL
HORIZONTAL

BUTTON
101
21
191
77
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
699
20
749
65
Leões
count Leoes
17
1
11

MONITOR
699
70
749
115
Hienas
count Hienas
17
1
11

MONITOR
871
71
940
116
Abrigos
count patches with [pcolor = blue]
17
1
11

MONITOR
754
20
866
65
Comida Castanha
count patches with[pcolor = brown]
17
1
11

SLIDER
9
202
191
235
alimCastanho
alimCastanho
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
9
242
191
275
alimVermelho
alimVermelho
0
10
10.0
1
1
NIL
HORIZONTAL

MONITOR
754
71
866
116
Comida Vermelha
count patches with [pcolor = red]
17
1
11

MONITOR
871
20
940
65
Armadilhas
count patches with[pcolor = red]
17
1
11

PLOT
699
323
940
516
Agentes
Ticks
Nº de Agentes
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Leoes" 1.0 0 -16777216 true "" "plot count leoes"
"Hienas" 1.0 0 -955883 true "" "plot count Hienas"
"Cacadores" 1.0 0 -1184463 true "" "plot count Cacadores"

SLIDER
9
282
191
315
energiaInicial
energiaInicial
0
200
1.0
1
1
NIL
HORIZONTAL

SLIDER
9
443
192
476
valor-energia
valor-energia
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
9
363
191
396
energiaCastanho
energiaCastanho
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
9
403
191
436
energiaVermelho
energiaVermelho
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
9
482
192
515
percentagemCombate
percentagemCombate
0
100
22.0
1
1
NIL
HORIZONTAL

SLIDER
10
163
191
196
nAzul
nAzul
0
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
9
323
191
356
descanso-ticks
descanso-ticks
0
100
2.0
1
1
NIL
HORIZONTAL

PLOT
698
120
940
318
Energia média
Ticks
Energia
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Leoes" 1.0 1 -16777216 true "" "plot energia-media-leoes "
"Hienas" 1.0 1 -955883 true "" "plot energia-media-hienas"
"Cacadores" 1.0 1 -1184463 true "" "plot energia-media-cacadores"

SLIDER
7
573
189
606
nCacadores
nCacadores
0
25
2.0
1
1
NIL
HORIZONTAL

MONITOR
45
521
147
566
Hienas caçadas
hienas-cacadas
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>tempo</metric>
    <metric>count Hienas</metric>
    <metric>count Leoes</metric>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
