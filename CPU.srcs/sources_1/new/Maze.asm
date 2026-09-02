org $0
offset @0
bra Start

equ UART_SEND #$FFFF
equ UART_STORE #$FFFE

equ TestRam #$2000


; ============================================================================
; External Hardware Interrupt Vectors
; ============================================================================

    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt


; ============================================================================
; Internal Exception Vectors
; ============================================================================

    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt


; ============================================================================
; Software Interrupt Vectors
; ============================================================================

    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt
    bra DefaultInt


DefaultInt:
    iret


; ============================================================================
; Main Program
; ============================================================================

offset @512

Start:

; ----------------------------------------------------------------------------
; Test 1 - UART only
; ----------------------------------------------------------------------------

    lod #$41 ;ASCII A
    stb UART_STORE

    lod #$37 ;ASCII 7
    stb UART_STORE

    lod #$A ;line feed
    stb UART_STORE

    lod #$D ;carriage return
    stb UART_STORE

    stb UART_SEND ;send literal A7


; ----------------------------------------------------------------------------
; Test 2 - Immediate value through PrintHex
; ----------------------------------------------------------------------------

    lod #$A7 ;load known value into R1
    call PrintHex ;convert R1 to ASCII hex

    lod #$A ;line feed
    stb UART_STORE

    lod #$D ;carriage return
    stb UART_STORE

    stb UART_SEND ;send converted immediate value


; ----------------------------------------------------------------------------
; Test 3 - RAM store and load
; ----------------------------------------------------------------------------

    lod #$A7 ;load known RAM test value
    stb TestRam ;store $A7 at $2000

    ldm TestRam ;read $2000 back into R1
    call PrintHex ;print value read from RAM

    lod #$A ;line feed
    stb UART_STORE

    lod #$D ;carriage return
    stb UART_STORE

    stb UART_SEND ;send RAM readback value


End:
    bra End ;stop here


; ============================================================================
; Hex Printing
; ============================================================================

PrintHex:
    mov r4,r1 ;save original byte

    lod #$0F ;load nibble mask
    mov r3,r1 ;save mask in R3

    mov r1,r4 ;restore original byte
    shr ;shift upper nibble down
    shr
    shr
    shr
    and r3 ;isolate upper nibble
    ldmreg HexTable ;convert nibble to ASCII
    stb UART_STORE ;store upper hex digit

    mov r1,r4 ;restore original byte
    and r3 ;isolate lower nibble
    ldmreg HexTable ;convert nibble to ASCII
    stb UART_STORE ;store lower hex digit

    rts


; ============================================================================
; Data
; ============================================================================

HexTable:
dbc "0123456789ABCDEF"