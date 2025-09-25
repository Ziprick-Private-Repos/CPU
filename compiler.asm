offset @512
sbp #$1000
nsb
bra #550
foo:
ssfp
lod #3
mov r2,r1
ldspi
push r1
lod #2
mov r2,r1
ldspi
pop r3
add r3
push r1
lod #1
mov r2,r1
ldspi
pop r3
add r3
rts
main:
lod #7
push r1
lod #8
push r1
lod #9
push r1
call #521
stb #10000
ldm #10000
push r1
lod #4
pop r3
add r3
nop
nop