org $0
offset @512

lod #$1
mov r4,r1
lod #$ff
Start:
	sub r4
	;call Delay
	;lod #0
	;call Delay
	bra Start

;Delay:
	;pusha
	;lod #0
;.Loop:
	;inc
	;cmp r4
	;bne Delay.Loop
	;popa
	;rts