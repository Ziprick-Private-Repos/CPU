offset @512
equ GFXMode #$FFFFFF
equ mem #$1024

equ STACK_TOP #$1000
equ VID_MEM #0
sbp STACK_TOP
nsb

spir str
spdr VID_MEM
lod #$f0
mov r2,r1
lodsb
stosba

lod #$10
mov r3,r1
lod #$00
mov r2,r1
lod #$21
spirfr

lod #2
mov r2,r1

lod #$ff
push r1

lod #$39
push r1

lod #$4
push r1
lod #0
ldspi
;stb mem
;push r1
;lod #$1
;stb GFXMode

;Start:
;    nop
;    bra Start

str:
    dbc "HELLO WORLD"
    dbh 0