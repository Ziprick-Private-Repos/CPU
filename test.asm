org $0
offset @0

lod #$b6
mov r4,r1
lod #1
mov r2,r1
lod #$b8

Start:
	sub r2
	call Test

	push r1
	mov r1,r3
	pop r1
	cmp r4
	beq Port
	bra Start

Port:
	stb #$FFFFFA
	halt

Test:
	push r1
	push r2
	mov r1,r3
	inc
	mov r3,r1
	pop r2
	pop r1
	rts


	



	;;;;;;
;	org $0
;offset @0

;lod #0

;Start:
;	nop
;	call Count
;	bra Start

;Count:
;	inc
;	rts