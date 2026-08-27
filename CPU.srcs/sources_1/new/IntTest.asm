org $0
offset @0
bra Start

equ UART_SEND #$FFFF;
equ UART_STORE #$FFFE;

; ============================================================================
; External Hardware Interrupt Vectors
; ============================================================================

	bra Irq1Hndlr
	bra Irq2Hndlr
	bra Irq3Hndlr
	bra Irq4Hndlr
	bra Irq5Hndlr
	bra Irq6Hndlr
	bra Irq7Hndlr
	bra Irq8Hndlr
	bra Irq9Hndlr
	bra Irq10Hndlr
	bra Irq11Hndlr
	bra Irq12Hndlr
	bra Irq13Hndlr
	bra Irq14Hndlr
	bra Irq15Hndlr

; ============================================================================
; Internal Exception Vectors
; ============================================================================

	bra Exception1Hndlr
	bra Exception2Hndlr
	bra Exception3Hndlr
	bra Exception4Hndlr
	bra Exception5Hndlr
	bra Exception6Hndlr
	bra Exception7Hndlr
	bra Exception8Hndlr
	bra Exception9Hndlr
	bra Exception10Hndlr
	bra Exception11Hndlr
	bra Exception12Hndlr
	bra Exception13Hndlr
	bra Exception14Hndlr
	bra Exception15Hndlr

; ============================================================================
; Software Interrupt Vectors
; ============================================================================

	bra SoftInt16Hndlr
	bra SoftInt17Hndlr
	bra SoftInt18Hndlr
	bra SoftInt19Hndlr
	bra SoftInt20Hndlr
	bra SoftInt21Hndlr
	bra SoftInt22Hndlr


; ============================================================================
; External Hardware Interrupt Handlers
; ============================================================================

Irq1Hndlr:
	spir Int1Str
	call LoadStr
	stb UART_SEND
	iret

Irq2Hndlr:
	spir Int2Str
	call LoadStr
	stb UART_SEND
	iret

Irq3Hndlr:
	iret

Irq4Hndlr:
	iret

Irq5Hndlr:
	iret

Irq6Hndlr:
	iret

Irq7Hndlr:
	iret

Irq8Hndlr:
	iret

Irq9Hndlr:
	iret

Irq10Hndlr:
	iret

Irq11Hndlr:
	iret

Irq12Hndlr:
	iret

Irq13Hndlr:
	iret

Irq14Hndlr:
	spir Int14Str
	call LoadStr
	stb UART_SEND
	iret

Irq15Hndlr:
	iret

; ============================================================================
; Internal Exception Handlers
; ============================================================================

Exception1Hndlr:
	spir Excp1Str
	call LoadStr
	stb UART_SEND
	halt

Exception2Hndlr:
	spir Excp2Str
	call LoadStr
	stb UART_SEND
	iret

Exception3Hndlr:
	iret

Exception4Hndlr:
	iret

Exception5Hndlr:
	iret

Exception6Hndlr:
	iret

Exception7Hndlr:
	iret

Exception8Hndlr:
	iret

Exception9Hndlr:
	iret

Exception10Hndlr:
	iret

Exception11Hndlr:
	iret

Exception12Hndlr:
	iret

Exception13Hndlr:
	iret

Exception14Hndlr:
	iret

Exception15Hndlr:
	iret


; ============================================================================
; Software Interrupt Handlers
; ============================================================================

SoftInt16Hndlr:
	iret

SoftInt17Hndlr:
	iret

SoftInt18Hndlr:
	iret

SoftInt19Hndlr:
	iret

SoftInt20Hndlr:
	iret

SoftInt21Hndlr:
	iret

SoftInt22Hndlr:
	iret


; ============================================================================
; Main Program
; ============================================================================

; Fill unused ROM space up to address 512
offset @512

Start:
	lod #0
	mov r2,r1
	;div r2

End:
	bra End

; ============================================================================
; Utility Routines
; ============================================================================

PrintHex:
	mov r4,r1
	shr
	shr
	shr
	shr
	and r3
	ldmreg HexTable
	stb UART_STORE

	mov r1,r4
	and r3
	ldmreg HexTable
	stb UART_STORE
	rts

LoadStr:
	lodsb
	stb UART_STORE
	cmp r4
	brz LoadStr.Done
	bra LoadStr

.Done:
	rts

MemoryDump:
	;Dump 15 bytes from the stack, starting at the stack top
	;and working downward from $4000 through $3FF2.

	;Stack byte $4000
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$4000
	mov r4,r1
	shr
	shr
	shr
	shr
	and r3
	ldmreg HexTable
	stb UART_STORE
	mov r1,r4
	and r3
	ldmreg HexTable
	stb UART_STORE
	lod ' '
	stb UART_STORE

; ============================================================================
; Strings and Data
; ============================================================================

Int1Str:
dbc "Int 1 called!"
dbh A,D
dbh 0

Int2Str:
dbc "Int 2 called!"
dbh A,D
dbh 0

Int14Str:
dbc "Timer Int"
dbh A,D
dbh 0

Excp1Str:
dbc "Exception, INVALID INSTRUCTION OCCURED"
dbh A,D
dbh 0

Excp2Str:
dbc "Exception, DIVIDE BY ZERO"
dbh A,D
dbh 0

Hex:
dbc "0x"
dbh 0

Space:
dbc " "
dbh 0

HexTable:
dbc "0123456789ABCDEF"