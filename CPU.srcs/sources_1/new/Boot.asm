org $0
offset @0
bra Start

equ UART_SEND #$FFFF;
equ UART_STORE #$FFFE;

equ MemCount0 #$2000
equ MemCount1 #$2001
equ MemCount2 #$2002

equ MemStart #$2003
equ MemEnd #$10000

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
	call MedDelay

	spir BootupStr
	call LoadStr
	stb UART_SEND
	call MedDelay

	bra MemChk

Continue:
	call MedDelay
	spir TestStr
	call LoadStr
	stb UART_SEND

End:
	bra End

PrintMem:
    pusha                       ;preserve registers while printing progress

    ldm MemCount2               ;load high byte of 24-bit memory counter
    call PrintHex

    ldm MemCount1               ;load middle byte of memory counter
    call PrintHex

    ldm MemCount0               ;load low byte of memory counter
    call PrintHex

    lod #$A                     ;newline
    stb UART_STORE
    lod #$D                     ;carriage return
    stb UART_STORE
    stb UART_SEND               ;send complete progress string over UART

    popa                        ;restore registers
    rts


MemChk:
    lod #$0                     ;clear 24-bit memory test counter
    stb MemCount0
    stb MemCount1
    stb MemCount2

    call MedDelay

    spir TestingMem             ;print memory test startup message
    call LoadStr
    stb UART_SEND
    call MedDelay

    spdr MemStart               ;set destination pointer to first test address
    spir MemStart               ;set source pointer to first test address
    sspr MemEnd                 ;set memory test end address

    lod #$55                    ;test pattern written to each memory location

    call PrintMem               ;print initial counter value 000000


MemChkCount:
    mov r1,r4                   ;save $55 test pattern for comparison
    stosb                       ;write test pattern to current memory address
    lodsb                       ;read test pattern back from same address
    cmp r4                      ;compare read value against expected $55
    bne MemChkBad               ;memory failed if values do not match

    pusha                       ;preserve test state while updating counter

    lod #$FF                    ;value used to detect byte rollover
    mov r2,r1

    ldm MemCount0               ;load low byte of 24-bit counter
    cmp r2                      ;check if low byte has reached $FF
    beq MemChkRoll0             ;roll into middle byte if low byte is full

    inc                         ;increment low counter byte normally
    stb MemCount0

    popa                        ;restore $55 test pattern and registers

    sdequal                     ;check whether memory test reached end address
    sdbeq MemChkDone            ;finish test when end address is reached

    bra MemChkCount             ;test next memory location


MemChkRoll0:
    inc                         ;roll MemCount0 from $FF to $00
    stb MemCount0

    ldm MemCount1               ;load middle byte of 24-bit counter
    cmp r2                      ;check if middle byte must also roll over
    beq MemChkRoll1             ;carry into high byte if middle byte is $FF

    inc                         ;increment middle counter byte
    stb MemCount1

    popa                        ;restore $55 test pattern and registers

    call PrintMem               ;print progress once every $100 bytes

    sdequal                     ;check whether memory test reached end address
    sdbeq MemChkDone

    bra MemChkCount             ;continue testing


MemChkRoll1:
    inc                         ;roll MemCount1 from $FF to $00
    stb MemCount1

    ldm MemCount2               ;carry into high byte of 24-bit counter
    inc
    stb MemCount2

    popa                        ;restore $55 test pattern and registers

    call PrintMem               ;print progress at each $10000 boundary

    sdequal                     ;check whether memory test reached end address
    sdbeq MemChkDone

    bra MemChkCount             ;continue testing


MemChkDone:
    call MedDelay
    call MedDelay

    spir MemStr                 ;memory test completed successfully
    call LoadStr
    stb UART_SEND

    bra Continue


MemChkBad:
    call PrintMem               ;print exact offset of failed memory location

    call MedDelay
    call MedDelay

    spir MemBadStr              ;report memory test failure
    call LoadStr
    stb UART_SEND

    bra Continue

; ============================================================================
; Utility Routines
; ============================================================================

PrintHex:
	mov r4,r1       ; save value

	lod #$0F
	mov r3,r1       ; mask = 0x0F

	mov r1,r4       ; restore value
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

LongDelay:
	pusha
	lod #$0
	mov r2,r1
	lod #$FF
	nop
	nop
	nop
	nop

	.loop:
		call MedDelay
		dec
		cmp r2
		beq LongDelay.loop.done
		bra LongDelay.loop

	.done:
		popa
		rts

MedDelay:
	pusha
	lod #$0
	mov r2,r1
	lod #$30
	nop
	nop
	nop
	nop

	.loop:
		call Delay
		dec
		cmp r2
		beq MedDelay.loop.done
		bra MedDelay.loop

	.done:
		popa
		rts

Delay:
	pusha
	lod #$0
	mov r2,r1
	lod #$FF
	.loop:
		nop
		nop
		nop
		nop
		dec
		cmp r2
		bne Delay.loop
	.done:
		popa
		rts

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

BootupStr:
dbc "Booting..."
dbh A,D,0

TestingMem:
dbc "Testing memory"
dbh A,D,0

MemStr:
dbh A,D
dbc "Memory OK!"
dbh A,D,0

MemBadStr:
dbc "Memory error :("
dbh A,D,0

Space:
dbc " "
dbh 0

TestStr:
dbc "Testing for crash"
dbh A,D,0

HexTable:
dbc "0123456789ABCDEF"