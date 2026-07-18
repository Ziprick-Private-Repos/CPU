org $0
offset @0

equ UART_SEND #$FFFF;
equ UART_STORE #$FFFE;

start:
    lod #0
    mov r4,r1
	spir str
	call LoadStr

    ;call Delay
    call Test

    lod #$b8
    lod #1
	stb UART_SEND
    lod #0
    stb UART_SEND

End:
    bra End

LoadStr:
	lodsb
	stb UART_STORE
	cmp r4
	brz LoadStr.Done
	bra LoadStr
.Done:
	rts

;Delay:
;    lod #$ff
;.loop:
;    nop
;    nop
;    nop
;    nop
;    nop
;    dec
;    cmp r2
;    beq Delay.loop.done
;    bra Delay.loop
;.done:
;    rts

Test:
    push r1
    ;call Test1
    nop
    nop
    or r1
    lod #$ab
    pop r1
    lod #$cd
    rts

Test1:
    nop
    nop
    lod #$ef
    rts

str:
dbc "OK!"
dbh 0