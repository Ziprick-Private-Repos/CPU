org $0
offset @0

equ UART_SEND #$FFFF;
equ UART_STORE #$FFFE;

IntTable:

;...
;512

Start:
	lod #$DE
	stb #$3FF8
	lod #$ED
	stb #$3FF7
	lod #$BE
	stb #$3FF6
	lod #$EF
	stb #$3FF5
	;bra #$1000
	lod #$0F
	mov r3,r1

    lod #0
    mov r4,r1
	spir str
	call LoadStr
	call Test
	call MemoryDump
	stb UART_SEND
End:
    bra End

Test1:
	;nop
	;nop
	;nop
	;nop
	;bra MemoryDump
	rts

Test:
	pusha
	nop
	nop
	nop
	nop
	call MemoryDump
Continue:
	call Test1
	popa
	rts

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

	;Stack byte $3FFF
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFF
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

	;Stack byte $3FFE
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFE
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

	;Stack byte $3FFD
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFD
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

	;Stack byte $3FFC
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFC
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

	;Stack byte $3FFB
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFB
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

	;Stack byte $3FFA
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FFA
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

	;Stack byte $3FF9
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF9
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

	;Stack byte $3FF8
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF8
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

	;Stack byte $3FF7
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF7
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

	;Stack byte $3FF6
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF6
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

	;Stack byte $3FF5
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF5
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

	;Stack byte $3FF4
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF4
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

	;Stack byte $3FF3
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF3
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

	;Stack byte $3FF2
	lod '0'
	stb UART_STORE
	lod 'x'
	stb UART_STORE
	ldm #$3FF2
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
	;Send the complete buffered stack dump
	;stb UART_SEND
	;bra Continue
	;halt

LoadStr:
	lodsb
	stb UART_STORE
	cmp r4
	brz LoadStr.Done
	bra LoadStr
.Done:
	rts

str:
dbh 10,13
dbc "ready! "
dbh 0

Hex:
dbc "0x"
dbh 0

Space:
dbc " "
dbh 0

HexTable:
dbc "0123456789ABCDEF"

;8192
;jmp table
bra Start