offset @512
sbp #$1000
nsb
bra #596
fooo:
ssfp
lod #1
rtsv
foo:
ssfp
gsfp #0
push r3
push r2
push r1
call #521
pop r4
pop r1
pop r2
pop r3
ssfpr
lod #1
spdrfr
push r4
pop r1
stosb
lod #4
mov r2,r1
ldspi
push r1
lod #3
mov r2,r1
ldspi
pop r3
xchg r1,r3
mul r3
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
rtsv
main:
ssfpm
gsfp #0
push r3
push r2
push r1
lod #7
push r1
lod #2
push r1
lod #50
push r1
lod #1
push r1
call #525
pop r4
pop r1
pop r1
pop r1
pop r1
pop r1
pop r2
pop r3
ssfpr
spdrfr
pop r1
stosb
halt