org $0
offset @0

lod #2
mov r2,r1

Start:
	call Mult
	bra Start

Mult:
	mul r2
	rts