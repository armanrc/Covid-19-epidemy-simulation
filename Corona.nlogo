globals[counter]
breed[persons person]
persons-own[age infected? age-of-infection quarantined? quarantined-out? home-x home-y reproductive-potential dead? former-infection? movement-radius personal-incubation-period incubate? infection-agent
victim-num active? illnes-long]

to setup
  ca
  reset-ticks
  set counter 0
  import-pcolors "shahrdaritehran1.gif"

  create-persons population-num
  set-default-shape persons "person"
  ask persons[ set color green set xcor random-xcor set ycor random-ycor set heading random 360
    set illnes-long random time-dealy-reveal-to-death
    set infected? 0
    set active? 0
    set incubate? 0
    set age-of-infection 0
    set quarantined? 0
    set former-infection? 0
    let gip random-normal personal-incubation-m personal-incubation-v
    ifelse exp(gip) < 20 [set personal-incubation-period round (exp(gip))][set personal-incubation-period 20]
    let t random-normal m-r-mean m-r-var
    ifelse t > 0 [set movement-radius t][set movement-radius 0]
  if pcolor = 49.9 or pcolor = 9.9 or pcolor = 39.1 [move-to one-of patches with [pcolor > 50]]
    set home-x xcor
    set home-y ycor
  ]
  ask n-of first-infection-num persons [set infected? 1 set color red set age-of-infection 1]
end

to go
  set counter counter + 1
  if not any? persons [stop]
  ask persons with[infected? = 1 and age-of-infection > personal-incubation-period][set quarantined? 1 set incubate? 0]
  ask persons with[infected? = 1 and age-of-infection < personal-incubation-period][set incubate? 1]
  age-of-infection-increase
  come-back-home
  quarantine
  move
  get-infected
  cure
  death
  ask persons[set active? 0]
tick
end

to age-of-infection-increase
  ask persons with[dead? = 0] [if infected? = 1 [set age-of-infection age-of-infection + 1]]
end

to quarantine;; senariohaye mokhtalef baraye shoro zaman moj mardomy gharantine khanegi az yek hafte ta 4 hafte bad az avalin khabar ebtela dar shahr
  if quarantine-scenario = "after-1-week" [
    if ticks = 8 [ask n-of (population-num * (Home-Quarantine / 100 )) persons [set quarantined? 1 move-to patch home-x home-y]]]
  if quarantine-scenario = "after-2-week" [
    if ticks = 15 [ask n-of (population-num * (Home-Quarantine / 100 )) persons [set quarantined? 1 move-to patch home-x home-y]]]
  if quarantine-scenario = "after-3-week" [
    if ticks = 21 [ask n-of (population-num * (Home-Quarantine / 100 )) persons [set quarantined? 1 move-to patch home-x home-y]]]
  if quarantine-scenario = "after-1-month" [
    if ticks = 30 [ask n-of (population-num * (Home-Quarantine / 100 )) persons [set quarantined? 1 move-to patch home-x home-y]]]
  if quarantine-scenario = "gradually"[
    ;;if ticks = 15 [ask n-of (population-num * (Home-Quarantine / 100 )) persons [set quarantined? 1 move-to patch home-x home-y]]
    if (counter > first-diagnosis-delay and counter < first-diagnosis-delay + horizon)[ask n-of (( ((Home-Quarantine / (horizon * horizon)) * ((2 * (counter - (first-diagnosis-delay))) + 1)) / 100) * population-num) persons with[quarantined? = 0][set quarantined? 1 move-to patch home-x home-y]]

  ]

end
to move;;afradi ke be tor ekhtiari gharantine khanegi ra shoro nakardand dar shahr taradod mikonand va mabaghi tanha baraye tamin mayahtaj az khane biron mi ayand
  ask persons with[dead? = 0] [if [pcolor] of patch-ahead 1 = 49.9 [set heading heading + 180]
    if (quarantined? = 0 and random 100 <= move-prob) [set active? 1 set heading heading + random 30 - random 30 ifelse distancexy home-x home-y < movement-radius[fd 1][move-to patch home-x home-y]]
    let x xcor let y ycor if quarantined? = 1 and random 100 < 5 [set heading heading + random 30 - random 30 fd 1 set quarantined-out? 1]

  ]


end

to come-back-home;;afrad gharantine shode ke baraye tamin mayahtaj az khane kharej shodeand ra be khane barmigardand
  ask persons with [dead? = 0][if quarantined-out? = 1 [move-to patch home-x home-y set quarantined-out? 0]]
end

to get-infected;; har fard dar sorte tams ya boodan dar nazdiki afrad mobtala khod mobtala mishavad
  ask persons with [dead? = 0 and infected? = 0 and active? = 1][ifelse former-infection? = 0
    [if any? persons in-radius (transmision-radius) with[infected? = 1 and dead? = 0 and incubate? = 1] and random 100 < attack-rate [set infected? 1 set color red
      let t one-of turtles in-radius (transmision-radius) with[infected? = 1 and dead? = 0 and incubate? = 1] let s [who] of t set infection-agent s ask t[set victim-num victim-num + 1]]]
    [
    if random 100 < 14 [if any? persons in-radius (transmision-radius) with[infected? = 1 and dead? = 0 and incubate? = 1] and random 100 < attack-rate [set infected? 1 set color red
    let t one-of turtles in-radius (transmision-radius) with[infected? = 1 and dead? = 0 and incubate? = 1] let s [who] of t set infection-agent s ask t[set victim-num victim-num + 1]]]]
  ]
  ask persons with [dead? = 0 and infected? = 0 and active? = 0][let hx home-x let hy home-y ifelse former-infection? = 0
    [if any? persons with[infected? = 1 and dead? = 0 and incubate? = 1 and home-x = hx and home-y = hy] and random 100 < attack-rate [set infected? 1 set color red
      let t one-of turtles with[infected? = 1 and dead? = 0 and incubate? = 1 and home-x = hx and home-y = hy] let s [who] of t set infection-agent s ask t[set victim-num victim-num + 1]]]
    [
    if random 100 < 1 [if any? persons with[infected? = 1 and dead? = 0 and incubate? = 1 and home-x = hx and home-y = hy] and random 100 < attack-rate [set infected? 1 set color red
    let t one-of turtles with[infected? = 1 and dead? = 0 and incubate? = 1 and home-x = hx and home-y = hy] let s [who] of t set infection-agent s ask t[set victim-num victim-num + 1]]]]
  ]
end

to death
  ask persons with [dead? = 0 and (infected? = 1)][ if (age-of-infection = ((personal-incubation-period) + illnes-long ))
    [ifelse random 100 < death-rate [set dead? 1][set infected? 0 set age-of-infection 0 set former-infection? 1 set color green]]
  ]
end

to cure
end
@#$#@#$#@
GRAPHICS-WINDOW
208
10
877
460
-1
-1
1.1
1
10
1
1
1
0
1
1
1
-300
300
-200
200
0
0
1
ticks
30.0

BUTTON
25
33
88
66
NIL
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

BUTTON
94
32
157
65
NIL
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

SLIDER
7
78
179
111
population-num
population-num
0
1000000
114650.0
1
1
NIL
HORIZONTAL

SLIDER
7
115
179
148
Home-Quarantine
Home-Quarantine
0
100
51.0
1
1
NIL
HORIZONTAL

CHOOSER
5
553
143
598
quarantine-scenario
quarantine-scenario
"after-1-week" "after-2-week" "after-3-week" "after-1-month" "gradually"
4

SLIDER
7
152
179
185
first-infection-num
first-infection-num
0
100
1.0
1
1
NIL
HORIZONTAL

MONITOR
883
11
981
56
Weeks Counter
ticks / 7
1
1
11

MONITOR
986
11
1082
56
Month Counter
ticks / 30
1
1
11

SLIDER
6
189
178
222
incubation-period
incubation-period
1
30
2.0
1
1
NIL
HORIZONTAL

SLIDER
7
225
179
258
death-rate
death-rate
0
100
2.5
0.1
1
NIL
HORIZONTAL

MONITOR
883
61
940
106
Fatality
count persons with [dead? = 1]
0
1
11

MONITOR
954
63
1066
108
Current Infecteds
count persons with[infected? = 1 and dead? = 0]
17
1
11

PLOT
1067
332
1484
574
plot 1
Time ( day by day)
People Count
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Fatality" 1.0 0 -16777216 true "" "plot count persons with[dead? = 1]"
"Healthy" 1.0 0 -11085214 true "" "plot count persons with [dead? = 0 and infected? = 0]"
"Infected" 1.0 0 -2674135 true "" "plot count persons with [dead? = 0 and infected? = 1]"

SLIDER
7
260
207
293
time-dealy-reveal-to-death
time-dealy-reveal-to-death
2
20
14.0
1
1
NIL
HORIZONTAL

SLIDER
7
298
179
331
attack-rate
attack-rate
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
8
336
180
369
transmision-radius
transmision-radius
0
1
0.38
0.01
1
NIL
HORIZONTAL

PLOT
1283
174
1483
324
plot 2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count persons with [dead? = 0 and infected? = 1]"

SLIDER
6
373
178
406
m-r-mean
m-r-mean
0
200
70.0
1
1
NIL
HORIZONTAL

SLIDER
5
409
177
442
m-r-var
m-r-var
0
100
40.0
1
1
NIL
HORIZONTAL

MONITOR
888
116
1111
161
not quarantined
count persons with[quarantined? = 0]
17
1
11

SLIDER
5
445
177
478
horizon
horizon
0
30
14.0
1
1
NIL
HORIZONTAL

SLIDER
5
479
177
512
personal-incubation-m
personal-incubation-m
1
4
1.8
0.1
1
NIL
HORIZONTAL

SLIDER
4
517
176
550
personal-incubation-v
personal-incubation-v
0
2
0.53
0.01
1
NIL
HORIZONTAL

MONITOR
891
178
956
223
Abnormal
count persons with[age-of-infection > 35]
17
1
11

MONITOR
1183
63
1296
108
reproductive-ratio
(sum [victim-num] of turtles) / (count turtles with[dead? = 1] + count turtles with[former-infection? = 1] )
2
1
11

SLIDER
199
478
371
511
first-diagnosis-delay
first-diagnosis-delay
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
378
479
550
512
move-prob
move-prob
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
EZAFE KARDAN MARAKEZ ALODEGI, TARIF SHOA HAREKAT BARAYE AFRAD. IJAD VASAYEL NAGHLIE VA TARIF EHTEMAL EBTELA

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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="90"/>
    <metric>count persons with[infected? = 1 and dead? = 0]</metric>
    <metric>count persons with[dead? = 1]</metric>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-scenario">
      <value value="&quot;gradually&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-infection-num">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home-Quarantine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-num">
      <value value="114650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubation-period">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attack-rate">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-dealy-reveal-to-death">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-rate">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-mean">
      <value value="104"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-var">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="horizon">
      <value value="7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-scenario">
      <value value="&quot;gradually&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="horizon">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-infection-num">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-num">
      <value value="114650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home-Quarantine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attack-rate">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubation-period">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-mean">
      <value value="104"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-dealy-reveal-to-death">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-rate">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-var">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="grad902w" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="120"/>
    <metric>count turtles</metric>
    <metric>count persons with[infected? = 1 and dead? = 0]</metric>
    <metric>count persons with[dead? = 1]</metric>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-m">
      <value value="1.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-infection-num">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home-Quarantine">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubation-period">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attack-rate">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-mean">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-v">
      <value value="0.53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-rate">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-var">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-scenario">
      <value value="&quot;gradually&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="horizon">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-num">
      <value value="114650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-dealy-reveal-to-death">
      <value value="14"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="realistic" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="120"/>
    <metric>count turtles with[dead? = 0 and infected? = 1]</metric>
    <metric>count turtles with[dead? = 1]</metric>
    <metric>(sum [victim-num] of turtles) / (count turtles with[dead? = 1] + count turtles with[former-infection? = 1] )</metric>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.38"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-m">
      <value value="1.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-infection-num">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home-Quarantine">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubation-period">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attack-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-v">
      <value value="0.53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-rate">
      <value value="3.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-var">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-scenario">
      <value value="&quot;gradually&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-diagnosis-delay">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="horizon">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-num">
      <value value="114650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-dealy-reveal-to-death">
      <value value="14"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="120"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="transmision-radius">
      <value value="0.38"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-m">
      <value value="1.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-infection-num">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home-Quarantine">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attack-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubation-period">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="personal-incubation-v">
      <value value="0.53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-rate">
      <value value="3.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m-r-var">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-scenario">
      <value value="&quot;gradually&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-diagnosis-delay">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="horizon">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-num">
      <value value="114650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-prob">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-dealy-reveal-to-death">
      <value value="14"/>
    </enumeratedValueSet>
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
