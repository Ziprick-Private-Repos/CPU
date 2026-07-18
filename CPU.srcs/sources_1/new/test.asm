org $0
offset @0

equ porta #$fffffa
equ portb #$fffffb

equ UART_SEND #$FFFFED;
equ UART_STORE #$FFFFEC;

bra Start

IntVecTable:
    bra Int1
    bra Int2
    bra Int3
    bra Int4
    bra Int5
    bra Int6
    bra Int7
    bra Int8
    bra Int9
    bra Int10
    bra Int11
    bra Int12
    bra Int13
    bra Int14
    bra Int15

    bra Exp1
    bra Exp2
    bra Exp3
    bra Exp4
    bra Exp5
    bra Exp6
    bra Exp7
    bra Exp8
    bra Exp9
    bra Exp10
    bra Exp11
    bra Exp12
    bra Exp13
    bra Exp14
    bra Exp15

    bra SoftInt16
    bra SoftInt17
    bra SoftInt18
    bra SoftInt19
    bra SoftInt20
    bra SoftInt21
    bra SoftInt22

Start:
	lod #1
	mov r2,r1
	bra Main

	;lod #8
	;mov r4,r1
	;lod #0
	;mov r3,r1

	;lod #60
	;mov r2,r1
	;lod #0
	;muls
	;pusha
	;call PrintHex
	;call LongDelay
	;popa
	;mov r1,r2
	;call PrintHex
	;call LongDelay

	;lod 'H'
	;call PrintHex

	;spir doneStr
	;lod #0
	;mov r4,r1

Load:
	lodsb
	stb UART_STORE
	cmp r4
	brz Load.Done
	bra Load
.Done:
	call LongDelay
	stb UART_SEND

Main:
	;spir TickStr
	;call LoadStr
	;stb UART_SEND
	;call LongDelay
	pitclr
	mov r1,r4
	cmp r2
	beq Main.Print
	bra Main
.Print:
	lod 'H'
	stb UART_STORE
	stb UART_SEND
	bra Main

PrintHex:
	mov r4,r1 ;save a copy
	lod #$0f ;bitmask
	mov r3,r1 ;save bitmask to r3
	mov r1,r4 ;restore
	.LowNib:
		and r3
		ldmreg hexTable
		push r1

	.HighNib:
		mov r1,r4 ;restore
		shr
		shr
		shr
		shr
		and r3
		ldmreg hexTable
		stb UART_STORE
		pop r1
		stb UART_STORE
	call LongDelay
	call LongDelay
	stb UART_SEND
	rts

LongDelay:
	pusha
	lod #$10
.Loop:
	call MedDelay
	dec
	cmp r4
	brz LongDelay.Loop.Done
	bra LongDelay.Loop
.Done:
	popa
	rts

MedDelay:
	pusha
	lod #$10
.Loop:
	call Delay
	dec
	cmp r4
	brz MedDelay.Loop.Done
	bra MedDelay.Loop
.Done:
	popa
	rts

Delay:
	pusha
	lod #$0
	mov r2,r1
	lod #$ff
.Loop:
	dec
	cmp r2
	brz Delay.Loop.Done
	bra Delay.Loop
.Done:
	popa
	rts

LoadStr:
	lodsb
	stb UART_STORE
	cmp r4
	brz LoadStr.Done
	bra LoadStr
.Done:
	rts

Int1:
	cli
	lod #0
	spir HexStr
	call LoadStr
	stb UART_SEND
	call Delay

	lod #$1
	call PrintHex
	call Delay

	lod #0
	spir IntStr
	call LoadStr
	stb UART_SEND
	call Delay
	sti
    iret

Int2:
	cli
	sti
    iret

Int3:
	cli
	sti
    iret

Int4:
	cli
	sti
    iret

Int5:
	cli
	sti
    iret

Int6:
	cli
	sti
    iret

Int7:
	cli
	sti
    iret

Int8:
	cli
	sti
    iret

Int9:
	cli
	sti
    iret

Int10:
	cli
	sti
    iret

Int11:
	cli
	sti
    iret

Int12:
	cli
	sti
    iret

Int13:
	cli
	sti
    iret

Int14:
	cli
	sti
    iret

Int15:
	cli
	pitst
	sti
    iret

Exp1:
    iret

Exp2:
    iret

Exp3:
    iret

Exp4:
    iret

Exp5:
    iret

Exp6:
    iret

Exp7:
    iret

Exp8:
    iret

Exp9:
    iret

Exp10:
    iret

Exp11:
    iret

Exp12:
    iret

Exp13:
    iret

Exp14:
    iret

Exp15:
    iret

SoftInt16:
    iret

SoftInt17:
    iret

SoftInt18:
    iret

SoftInt19:
    iret

SoftInt20:
    iret

SoftInt21:
    iret

SoftInt22:
    iret

hexTable:
dbc "0123456789ABCDEF"

doneStr:
dbc "DONE"
dbh 0

HexStr:
dbc "0x"
dbh 0

IntStr:
dbc "INTERRUPT FIRED"
dbh 13,10,0

TickStr:
dbc "Tick"
dbh 13,10,0