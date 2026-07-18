`timescale 1ns / 1ps
`default_nettype none

module Control(input wire clk, input wire rstIn, input wire clkEn, input wire step,
    output wire [23:0]addrOut,
    input wire [23:0]addrIn,
    output reg memoryMode,
    output reg [7:0]toDataBus,
    input wire [7:0]dataIn,
    input wire [3:0]hardInterrupt,
    input wire gotoSwitch,
    output wire exception,
    output wire [23:0]pcOut,
    output wire [7:0]r1Dbg);

    (* mark_debug = "true" *) wire [23:0]retAddrDbg;
    assign retAddrDbg = retAddr;

    assign r1Dbg = r1Out;

    assign pcOut = pc;
    assign exception = exceptNum >= 1 ? 1 : 0;

    `ifdef SYNTHESIS
        localparam IDLE_WAIT_CYCLE = 15;
    `else
        localparam IDLE_WAIT_CYCLE = 1;
    `endif

    localparam PC_START_ADDRESS_ON_POWER = 24'd0;
    //localparam PC_START_ADDRESS_ON_POWER = 24'd512;

    //stack
    //localparam DEFAULT_STACK_TOP_ADDRESS = 16'd1000; //after port out space
    localparam DEFAULT_STACK_TOP_ADDRESS = 16'd16_384; //after port out space

    //memory modes
    localparam ADDR_MODE_WRT   = 0;
    localparam ADDR_MODE_RD    = 1;

    parameter INVALID_INSTRUCTION   = 8'h01;
    parameter DIV_BY_ZERO           = 8'h02;
    parameter GENERAL_FAULT         = 8'hff;

    parameter MAX_PIT_TIMER         = 24'd200_000; //@2mhz=>100ms
    reg [23:0]PITCnt;
    reg triggerPIT;
    reg PITFlag;

    //external hardware int pointers
    parameter IRQ_1_ADDR  = 24'd4;
    parameter IRQ_2_ADDR  = 24'd8;
    parameter IRQ_3_ADDR  = 24'd12;
    parameter IRQ_4_ADDR  = 24'd16;
    parameter IRQ_5_ADDR  = 24'd20;
    parameter IRQ_6_ADDR  = 24'd24;
    parameter IRQ_7_ADDR  = 24'd28;
    parameter IRQ_8_ADDR  = 24'd32;
    parameter IRQ_9_ADDR  = 24'd36;
    parameter IRQ_10_ADDR = 24'd40;
    parameter IRQ_11_ADDR = 24'd44;
    parameter IRQ_12_ADDR = 24'd48;
    parameter IRQ_13_ADDR = 24'd52;
    parameter IRQ_14_ADDR = 24'd56;
    parameter IRQ_15_ADDR = 24'd60;

    //internal exception int pointers
    parameter EXP_1_ADDR  = 24'd64;
    parameter EXP_2_ADDR  = 24'd68;
    parameter EXP_3_ADDR  = 24'd72;
    parameter EXP_4_ADDR  = 24'd76;
    parameter EXP_5_ADDR  = 24'd80;
    parameter EXP_6_ADDR  = 24'd84;
    parameter EXP_7_ADDR  = 24'd88;
    parameter EXP_8_ADDR  = 24'd92;
    parameter EXP_9_ADDR  = 24'd96;
    parameter EXP_10_ADDR = 24'd100;
    parameter EXP_11_ADDR = 24'd104;
    parameter EXP_12_ADDR = 24'd108;
    parameter EXP_13_ADDR = 24'd112;
    parameter EXP_14_ADDR = 24'd116;
    parameter EXP_15_ADDR = 24'd120;

    //software int call pointers
    parameter SOFT_INT_16_ADDR = 24'd124;
    parameter SOFT_INT_17_ADDR = 24'd128;
    parameter SOFT_INT_18_ADDR = 24'd132;
    parameter SOFT_INT_19_ADDR = 24'd136;
    parameter SOFT_INT_20_ADDR = 24'd140;
    parameter SOFT_INT_21_ADDR = 24'd144;
    parameter SOFT_INT_22_ADDR = 24'd148;

    //states
    reg [3:0]accessTimeCycleCount;
    (* mark_debug = "true" *) reg [15:0]cycleCount;
    
    (* mark_debug = "true" *) reg [3:0]state;
    localparam[3:0]
        I_IDLE = 4'b0000,
        I_FETCH = 4'b0001,
        I_DECODE = 4'b0010,
        I_ACCESS_MEM_READ = 4'b0011,
        I_ACCESS_MEM_ACCESS_READ_TIME = 4'b0100,
        I_ACCESS_MEM_ACCESS_WRITE_TIME = 4'b0101,
        I_ACCESS_MEM_WRITE = 4'b0110,
        I_ACCESS_MEM_WRITE_2 = 4'b0111,
        I_ACCESS_ALU = 4'b1000,
        I_ACCESS_REG_READ = 4'b1001,
        I_ACCESS_REG_READ_2 = 4'b1010,
        I_ACCESS_REG_WRITE = 4'b1011,
        //I_ACCESS_REG_WRITE_2 = 4'b1100,
        I_PC_NEXT = 4'b1101;

    //opcodes
    localparam[7:0]
        NOP     = 8'h00,
        MOV     = 8'h01,
        LODSB   = 8'h02,
        LOD     = 8'h03,
        STB     = 8'h04,
        BNE     = 8'h05,
        BEQ     = 8'h06,
        BGR     = 8'h07,
        PUSH    = 8'h0F,
        POP     = 8'h1F,
        LDM     = 8'h47,
        LDMREG  = 8'h49,
        STBREG  = 8'h50,
        S_INT   = 8'h08,
        IRET    = 8'h78,
        PUSHA   = 8'h10,
        POPA    = 8'h11,
        CLI     = 8'h3E,
        STI     = 8'h09,
        HALT    = 8'h18,
        CALL    = 8'h28,
        RTS     = 8'h38,
        BRA     = 8'h48,
        NSB     = 8'h40,
        BRZ     = 8'h60,
        SPIR    = 8'h70,
        RST     = 8'h71,
        SBP     = 8'h72,
        STOSB   = 8'h32,
        SPDR    = 8'h33,
        XCHG    = 8'h73,
        SSPR    = 8'h74,
        SDEQUAL = 8'h75,
        SDBEQ   = 8'h76,
        H_INT   = 8'h7F,
        RSTOSB  = 8'h77,
        RLODSB  = 8'h79,
        LDSP    = 8'h7A,
        LDSPI   = 8'h7B,
        SPIRFR  = 8'h7C,
        SPDRFR  = 8'h7D,
        STOSBA  = 8'h43,
        SSFP    = 8'h34,
        GSFP    = 8'h35,
        SSFPR   = 8'h36,
        SSFPM   = 8'h37,
        RTSV    = 8'h39,
        PITST   = 8'h41,
        PITCLR  = 8'h42,
        BRL     = 8'h44,

        OR      = 8'h80,
        AND     = 8'h81,
        SHL     = 8'h82,
        SHR     = 8'h83,
        CMP     = 8'h84,
        NOT     = 8'h85,
        XOR     = 8'h86,
        ADD     = 8'h87,
        SUB     = 8'h88,
        INC     = 8'h89,
        DEC     = 8'h8A,
        ROL     = 8'h8B,
        ROR     = 8'h8C,
        MUL     = 8'h8D,
        DIV     = 8'h8E,
        //CMPI    = 8'h8F,
        ADDS    = 8'h8F,
        SUBS    = 8'h90,
        INCS    = 8'h91,
        DECS    = 8'h92,
        ROLS    = 8'h93,
        RORS    = 8'h94,
        MULS    = 8'h95,
        DIVS    = 8'h96,
        CMPS    = 8'h97;

    Register r1(.clk(clk), .clkEn(clkEn), .rst(rstIn), .dataIn(tmpReg), .dataOut(r1Out), .en(r1En));
    Register r2(.clk(clk), .clkEn(clkEn), .rst(rstIn), .dataIn(tmpReg), .dataOut(r2Out), .en(r2En));
    Register r3(.clk(clk), .clkEn(clkEn), .rst(rstIn), .dataIn(tmpReg), .dataOut(r3Out), .en(r3En));
    Register r4(.clk(clk), .clkEn(clkEn), .rst(rstIn), .dataIn(tmpReg), .dataOut(r4Out), .en(r4En));
    reg pit;

    reg [23:0]si; //source reg.
    reg [23:0]di; //destination reg.
    reg [23:0]spr; //special reg.
    reg [23:0]stackTop;
    
    (* mark_debug = "true" *) reg [23:0]stackPointer;
    (* mark_debug = "true" *) reg [23:0]stackFramePointer;

    Alu alu(.clk(clk), .clkEn(clkEn), .rst(rstIn), .refreshState(refreshALUState), .cycle(aluCycle), .run(aluRun),
    .divDone(aluDivDone), .opcode(instruction[7:0]), 
    .regA(r1Out), .regB(tmpReg), .regS0({r1Out, r2Out}), .regS1({r3Out, r4Out}), .accumulator(accumOut), .accumulatorS(accumOutS), .remainder(remainder),
    .remainderS(remainderS), .greaterFlag(greaterFlagBus), .lessFlag(lessFlagBus), .zeroFlag(zeroFlagBus), .eqFlag(eqFlagBus), 
    .overflowFlag(overflowFlagBus), .divZero(divZeroBus));

    //-------------STATE REGISTERS------------

    //FETCH
    (* mark_debug = "true" *) reg [7:0]instruction;

    //DECODE
    reg rst = 0;

    //MEM ACCESS READ
    reg [7:0]aluRegSel;
    reg [7:0]pushPopRegSel;
    wire [7:0]accumOut;
    wire [15:0]accumOutS;
    wire [7:0]remainder;
    wire [15:0]remainderS;
    reg [23:0]retAddr;

    //MEM ACCESS WRITE
    reg [23:0]addressLinesOutBuff;

    //ALU ACCESS
    reg refreshALUState;
    reg greaterFlag;
    reg zeroFlag; 
    reg eqFlag;
    reg overflowFlag;
    reg srFlag;
    reg divZero;
    reg [15:0]aluCycle;
    reg aluRun;
    wire aluDivDone;

    wire greaterFlagBus;
    wire lessFlagBus;
    wire zeroFlagBus; 
    wire eqFlagBus;
    wire overflowFlagBus;
    wire divZeroBus;

    //REG READ
    //wire [7:0]r1Out;
    wire [7:0]r2Out;
    wire [7:0]r3Out;
    wire [7:0]r4Out;
    reg [7:0]tmpReg;
    
    (* mark_debug = "true" *) reg [23:0]mar;
    (* mark_debug = "true" *) reg [7:0]mdr;
    (* mark_debug = "true" *) wire[7:0]r1Out;
    reg [23:0]stackFrameBuff;

    //REG WRITE
    reg r1En, r2En, r3En, r4En; //enables writing data to registers
    reg [7:0]swapReg; //for xchg instruction

    //INT HANDLE
    reg [7:0]intNum;
    (* mark_debug = "true" *) reg [7:0]exceptNum;
    wire pEdge;
    reg disableInt;
    reg [7:0]intLock;
    reg sigDelay;
    reg sigDelay1;

    //PC_NEXT
    reg [23:0]pc;

    //----------------------------------------

    assign pEdge = (hardInterrupt[0] | hardInterrupt[1] | hardInterrupt[2] | hardInterrupt[3]) & ~sigDelay1;
    assign addrOut = mar;

    always @(posedge clk or negedge rstIn or posedge gotoSwitch)
    begin
        //step state machine here
        //
        //
        //
        //
        //////////////////////////


        
        PITCnt <= PITCnt + 1;

        if(PITCnt >= MAX_PIT_TIMER)
        begin
            PITCnt <= 0;
            triggerPIT <= 0;
        end

        if(rstIn == 0 || rst || gotoSwitch)
        begin
            if(gotoSwitch)
                pc <= addrIn;

            else
            begin
                mar <= PC_START_ADDRESS_ON_POWER;
                mdr <= 0;
                pc <= PC_START_ADDRESS_ON_POWER;
            end

            rst <= 0;
            PITFlag <= 0;
            PITCnt <= 0;
            triggerPIT <= 0;
            sigDelay <= 0;
            sigDelay1 <= 0;
            disableInt <= 0;
            intLock <= 0;
            intNum <= 0;
            exceptNum <= 0; 
            tmpReg <= 0;
            pushPopRegSel <= 0;

            r1En <= 0;
            r2En <= 0;
            r3En <= 0;
            r4En <= 0;

            si <= 0;
            di <= 0;
            spr <= 0;

            stackTop <= DEFAULT_STACK_TOP_ADDRESS;
            stackPointer <= DEFAULT_STACK_TOP_ADDRESS;
            cycleCount <= IDLE_WAIT_CYCLE;
            state <= I_IDLE;
            memoryMode <= ADDR_MODE_RD;

            srFlag <= 0;
            greaterFlag <= 0;
            zeroFlag <= 0;
            eqFlag <= 0;
            overflowFlag <= 0;

            divZero <= 0;
            aluCycle <= 0;
            aluRun <= 0;
            refreshALUState <= 0;
        end

        else if(clkEn)
        begin
            sigDelay <= (hardInterrupt[0] | hardInterrupt[1] | hardInterrupt[2] | hardInterrupt[3]);
            sigDelay1 <= sigDelay;

            if(pEdge == 1'b1)
            begin    
                intLock <= hardInterrupt;
            end

            //if(memoryMode == ADDR_MODE_RD)
            //    addrOut <= addressOutBuff;

            //else if(memoryMode == ADDR_MODE_RD)
            //    addrOut <= pc;

            //else if(memoryMode == ADDR_MODE_WRT)
            //    addrOut <= addressOutBuff;

            //else
            //    addrOut <= pc;

            case(state)
                I_IDLE:
                begin
                    //mar <= pc;
                    

                    if(cycleCount == 0)
                    begin 
                        mdr <= dataIn;
                        refreshALUState <= 0;
                        cycleCount <= 1; //delay added to make sure all memory/registers have finished writing
                        state <= I_FETCH;
                    end

                    else
                        cycleCount <= cycleCount - 1;
                end

                I_FETCH:
                begin
                    if(cycleCount > 0)
                    begin
                        cycleCount <= cycleCount - 1;
                    end

                    else
                    begin
                        r1En <= 0;    
                        r2En <= 0;
                        r3En <= 0;
                        r4En <= 0;

                        /*if((intLock && disableInt == 1'b0) || exceptNum || triggerPIT)
                        begin
                            if(exceptNum)
                                intLock <= 8'hff;
                            //push pc
                            instruction <= H_INT;
                            state <= I_DECODE;
                            triggerPIT <= 0;
                        end

                        else if(intNum)
                        begin
                            instruction <= H_INT;
                        end*/

                        //else if(intLock == 1'b0)
                        //begin
                            instruction <= mdr;
                            state <= I_DECODE;
                        //end
                    end
                end

                I_DECODE:
                begin
                    //next state dependant on instruction type
                    case(instruction)
                        NOP:
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end

                        MOV:
                        begin
                            state <= I_ACCESS_MEM_READ;
                        end

                        LODSB:
                        begin
                            state <= I_ACCESS_MEM_READ;
                        end

                        RLODSB:
                        begin
                            state <= I_ACCESS_MEM_READ;
                        end

                        LOD:
                        begin
                            state <= I_ACCESS_MEM_READ;
                        end

                        STB:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        STBREG:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;  
                        end

                        BNE:
                        begin
                            if(eqFlagBus == 0)
                            begin
                                state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                                accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            end

                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        BEQ:
                        begin
                            if(eqFlagBus)
                            begin
                                state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                                accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            end

                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        BGR:
                        begin
                            if(greaterFlagBus)
                            begin
                                state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                                accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            end

                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        BRL:
                        begin
                            if(lessFlagBus)
                            begin
                                state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                                accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            end

                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        PUSH:
                        begin
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        POP:
                        begin
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 1;
                            stackPointer <= stackPointer + 1;
                            memoryMode <= ADDR_MODE_RD;
                            cycleCount <= 1;
                        end

                        LDM:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        LDMREG:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;    
                        end

                        S_INT:
                        begin
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            //state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            retAddr <= pc + 2;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        IRET:
                        begin
                            state <= I_ACCESS_MEM_READ;
                            cycleCount <= 4;
                            stackPointer <= stackPointer + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        PUSHA:
                        begin
                            state <= I_ACCESS_MEM_WRITE;
                            cycleCount <= 5;
                        end

                        POPA:
                        begin
                            memoryMode <= ADDR_MODE_RD;
                            stackPointer <= stackPointer + 1;
                            mar <= stackPointer + 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 4;
                        end

                        CLI:
                        begin
                            disableInt <= 1'b1;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end

                        STI:
                        begin
                            disableInt <= 1'b0;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end

                        HALT:
                        begin
                            state <= I_IDLE;
                        end

                        CALL:
                        begin
                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        RTS:
                        begin              
                            cycleCount <= 4;
                            stackPointer <= stackPointer + 1;
                            memoryMode <= ADDR_MODE_RD;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        RTSV:
                        begin
                            cycleCount <= 4;
                            stackPointer <= stackPointer + 1;
                            memoryMode <= ADDR_MODE_RD;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        BRA:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            retAddr <= pc + 4;
                            cycleCount <= 2;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        NSB:
                        begin
                            stackPointer <= stackTop;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end

                        BRZ:
                        begin
                            if(zeroFlagBus)
							begin
								state <= I_ACCESS_MEM_ACCESS_READ_TIME;
								accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                                cycleCount <= 3;
							end
							
                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;           
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        SPIR:
                        begin
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        RST:
                        begin
                            rst <= 1;
                        end

                        SBP:
                        begin
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD; 
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;							
                        end

                        STOSB:
                        begin
                            state <= I_ACCESS_REG_READ;
                            mar <= di;
                        end

                        STOSBA:
                        begin
                            state <= I_ACCESS_REG_READ;
                            mar <= di;
                        end

                        SSFP:
                        begin
                            stackFramePointer <= stackPointer + 3; //stack frame position would be after +3 after call statement
                            state <= I_PC_NEXT;
                        end

                        SSFPM:
                        begin
                            stackFramePointer <= stackPointer; //doesn't have offset since there is no call to main function
                            state <= I_PC_NEXT;
                        end  

                        SSFPR:
                        begin
                            stackFramePointer <= {r3Out, r2Out, r1Out}; //stack frame not offset for main function since there is no call
                            state <= I_PC_NEXT;
                        end

                        GSFP:
                        begin
                            mar <= pc + 1;
                            stackFrameBuff <= stackFramePointer;
                            memoryMode <= ADDR_MODE_RD;
                            state <= I_ACCESS_MEM_READ;
                        end

                        RSTOSB:
                        begin
                            state <= I_ACCESS_REG_READ;
                            mar <= di;   
                        end

                        SPDR:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        XCHG:
                        begin
                            state <= I_ACCESS_MEM_READ;
                        end

                        SSPR:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        SDEQUAL:
                        begin
                            if(spr == si || spr == di)
                            begin
                                srFlag <= 1;
                            end
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end

                        SDBEQ:
                        begin
                            if(srFlag)
							begin
								state <= I_ACCESS_MEM_ACCESS_READ_TIME;
								accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							end

                            else
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end

                            retAddr <= pc + 4;
                            cycleCount <= 3;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        H_INT:
                        begin
                            state <= I_ACCESS_MEM_WRITE;
                            retAddr <= pc;

                            case(intLock)
                                //hardware int
                                4'b0001:
                                    intNum <= 1;

                                4'b0010:
                                    intNum <= 2;

                                4'b0011:
                                    intNum <= 3; 

                                4'b0100:
                                    intNum <= 4;

                                4'b0101:
                                    intNum <= 5;

                                4'b0110:
                                    intNum <= 6;   

                                4'b0111:
                                    intNum <= 7;

                                4'b1000:
                                    intNum <= 8;

                                4'b1001:
                                    intNum <= 9;  

                                4'b1010:
                                    intNum <= 10;

                                4'b1011:
                                    intNum <= 11;

                                4'b1100:
                                    intNum <= 12;   

                                4'b1101:
                                    intNum <= 13;

                                4'b1110:
                                    intNum <= 14;

                                4'b1111:
                                    intNum <= 15;    

                                //exceptions
                                default:
                                    intNum <= 7'd15 + exceptNum;
                            endcase

                            cycleCount <= 4;
                        end

                        LDSP:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 1;
                            mar <= stackPointer + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        LDSPI:
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 1;
                            mar <= stackPointer + r2Out;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        SPIRFR:
                        begin
                            state <= I_ACCESS_REG_READ;
                        end

                        SPDRFR:
                        begin
                            state <= I_ACCESS_REG_READ;
                        end

                        PITST:
                        begin
                            PITFlag <= 1;
                            state <= I_PC_NEXT;
                        end

                        PITCLR:
                        begin
                            tmpReg <= {7'b0000_000, PITFlag};
                            r4En <= 1;
                            state <= I_PC_NEXT;
                        end

                        //ALU
                        OR:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        AND:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        SHL:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        SHR:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        CMP:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            cycleCount <= 4;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        NOT:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        XOR:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        ADD:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        SUB:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        INC:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        DEC:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        ROL:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        ROR:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end

                        MUL:
                        begin
                            //cycle count is determined after reading in second reg value
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        DIV:
                        begin
                            //aluCycle <= 255; //max cycles, will stop earlier based on aluDivDone line
                            state <= I_ACCESS_MEM_READ;
                            mar <= pc + 1;
                            memoryMode <= ADDR_MODE_RD;
                        end

                        ADDS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                            mar <= pc + 1;
                            //memoryMode <= ADDR_MODE_RD;
                        end

                        SUBS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                            mar <= pc + 1;
                            //memoryMode <= ADDR_MODE_RD;
                        end

                        INCS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end
                        
                        DECS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end
                        
                        ROLS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;  
                        end
                        
                        RORS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                        end
                        
                        MULS:
                        begin
                            //cycle count is determined after reading in second reg value
                            state <= I_ACCESS_ALU;
                            mar <= pc + 1;
                            //memoryMode <= ADDR_MODE_RD;
                        end
                        
                        DIVS:
                        begin
                            //aluCycle <= 255; //max cycles, will stop earlier based on aluDivDone line
                            state <= I_ACCESS_ALU;
                            mar <= pc + 1;
                            //memoryMode <= ADDR_MODE_RD;
                        end

                        CMPS:
                        begin
                            aluCycle <= 1;
                            state <= I_ACCESS_ALU;
                            mar <= pc + 1;
                        end

                        default: //invalid instruction
                        begin
                            exceptNum <= INVALID_INSTRUCTION;
                            state <= I_IDLE;
                        end
                    endcase
                end

                I_ACCESS_MEM_READ:
                begin
                    if(instruction == MOV) 
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        mar <= pc + 1;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                    end

                    else if(instruction == LODSB)
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        mar <= si;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                    end

                    else if(instruction == RLODSB)
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        mar <= si;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                    end

                    else if(instruction == LOD)
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        mar <= pc + 1;
                        state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                    end

                    else if(instruction == STB)
                    begin
                        if(cycleCount == 3)
                        begin
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= dataIn;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= dataIn;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                            addressLinesOutBuff[23:16] <= dataIn;        
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end 
						
						else
						begin
							cycleCount <= 1;
							state <= I_ACCESS_MEM_WRITE;
						end
                    end

                    else if(instruction == STBREG)
                    begin
                        if(cycleCount == 3)
                        begin
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin       
                            addressLinesOutBuff[23:16] <= mdr;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end 

                        else
                        begin
                            addressLinesOutBuff <= addressLinesOutBuff + r2Out;
                            state <= I_ACCESS_MEM_WRITE;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == PUSH)
                    begin
                        case(mdr[1:0]) //pushPopRegSel data
                            2'b00:
                                tmpReg <= r1Out;
                                
                            2'b01:
                                tmpReg <= r2Out;
                                
                            2'b10:
                                tmpReg <= r3Out;
                                
                            2'b11:
                                tmpReg <= r4Out;
                        endcase

                        state <= I_ACCESS_MEM_WRITE;
                    end

                    else if(instruction == BNE)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end 
                    end

                    else if(instruction == BEQ)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end 
                    end

                    else if(instruction == BGR)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;       
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end 
                    end

                    else if(instruction == BRL)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;       
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end 
                    end

                    else if(instruction == POP)
                    begin
                        pushPopRegSel <= mdr;
                        mar <= stackPointer;
						state <= I_ACCESS_MEM_ACCESS_READ_TIME;
						accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        cycleCount <= 0;
                    end

                    else if(instruction == LDM)
                    begin
                        if(cycleCount == 3)
                        begin
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= {mdr, addressLinesOutBuff[15:0]};
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            mar <= addressLinesOutBuff;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end
                    end

                    else if(instruction == LDMREG)
                    begin
                        if(cycleCount == 3)
                        begin
                            mar <= pc + 2;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= {mdr, addressLinesOutBuff[15:0]} + r1Out;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            memoryMode <= ADDR_MODE_RD;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end
                    end

                    else if(instruction == S_INT)
                    begin
                        intNum <= mdr;
                        cycleCount <= 4;
                        state <= I_ACCESS_MEM_WRITE;
                    end

                    else if(instruction == IRET)
                    begin
                        if(cycleCount == 4)
                        begin
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 3)
                        begin
                            tmpReg <= mdr;
                            srFlag <= mdr[5];
                            divZero <= mdr[4];
                            greaterFlag <= mdr[3];
                            zeroFlag <= mdr[2];
                            eqFlag <= mdr[1];
                            overflowFlag <= mdr[0];
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 2)
                        begin
                            retAddr[23:16] <= mdr;
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            retAddr[15:8] <= mdr;  
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else
                        begin
                            retAddr[7:0] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == POPA)
                    begin
                        if(cycleCount == 4)
                        begin
                            tmpReg <= mdr;
                            r4En <= 1;
                            stackPointer <= stackPointer + 1;
                            mar <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;  
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 3)
                        begin
                            tmpReg <= mdr;
                            r4En <= 0;
                            r3En <= 1;  
                            stackPointer <= stackPointer + 1;
                            mar <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 2)
                        begin
                            tmpReg <= mdr;
                            r3En <= 0;
                            r2En <= 1;  
                            stackPointer <= stackPointer + 1;
                            mar <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            tmpReg <= mdr;
                            r2En <= 0;
                            r1En <= 1;  
							stackPointer <= stackPointer + 1;
							mar <= stackPointer + 1;
							cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end
						
						else
						begin
							srFlag <= mdr[5];
							divZero <= mdr[4];
							greaterFlag <= mdr[3];
							zeroFlag <= mdr[2];
							eqFlag <= mdr[1];
							overflowFlag <= mdr[0];
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
						end
                    end

                    else if(instruction == RTS)
                    begin
                        if(cycleCount == 4)
                        begin          
                            retAddr <= 0;
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 3)
                        begin
                            retAddr[23:16] <= mdr;
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 2)
                        begin
                            retAddr[15:8] <= mdr;  
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 1)
                        begin
                            retAddr[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else
                        begin
                            state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == RTSV)
                    begin
                        if(cycleCount == 4)
                        begin          
                            retAddr <= 0;
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 3)
                        begin
                            retAddr[23:16] <= mdr;
                            mar <= stackPointer;
                            stackPointer <= stackPointer + 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 2)
                        begin
                            retAddr[15:8] <= mdr;  
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 1)
                        begin
                            toDataBus <= r1Out; //save r1 and push to stack for return
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            memoryMode <= ADDR_MODE_WRT;
                            retAddr[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end

                        else
                        begin
                            cycleCount <= 1;
							state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == CALL)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_ACCESS_MEM_WRITE;
                            cycleCount <= 4;
                        end
                    end

                    else if(instruction == BRA)
                    begin
                        if(cycleCount == 2)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end 
                    end

                    else if(instruction == BRZ)
                    begin
                        if(cycleCount == 3)
                        begin        
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end 

                        else
                        begin
                            state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == SPIR)
                    begin
                        if(cycleCount == 3)
                        begin
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 2)
                        begin
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 1)
                        begin
                            addressLinesOutBuff[23:16] <= mdr;
                            memoryMode <= ADDR_MODE_RD;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                        end

                        else if(cycleCount == 0)
                        begin
                            si <= addressLinesOutBuff;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == SBP)
                    begin
                        if(cycleCount == 3)
                        begin
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;	
                            mar <= pc + 2;
                            stackTop[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;	
                            mar <= pc + 3;
                            stackTop[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;	
                            stackTop[23:16] <= mdr;
                            memoryMode <= ADDR_MODE_RD;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 0)
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end  
                    end

                    else if(instruction == SPDR)
                    begin
                        if(cycleCount == 3)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            addressLinesOutBuff[23:16] <= mdr;
                            memoryMode <= ADDR_MODE_RD;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 0)
                        begin
                            di <= addressLinesOutBuff;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == XCHG) 
                    begin
						state <= I_ACCESS_MEM_ACCESS_READ_TIME;
						accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        memoryMode <= ADDR_MODE_RD;
                        mar <= pc + 1;
                    end

                    else if(instruction == SSPR)
                    begin
                        if(cycleCount == 3)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= dataIn;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= dataIn;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            state <= I_ACCESS_MEM_ACCESS_READ_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            addressLinesOutBuff[23:16] <= dataIn;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 0)
                        begin
                            spr <= addressLinesOutBuff;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == SDBEQ)
                    begin
                        if(cycleCount == 3)
                        begin  
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;						
                            mar <= pc + 2;
                            addressLinesOutBuff[7:0] <= mdr;
                            cycleCount <= cycleCount - 1;
						end
						
                        else if(cycleCount == 2)
                        begin    
							state <= I_ACCESS_MEM_ACCESS_READ_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            mar <= pc + 3;
                            addressLinesOutBuff[15:8] <= mdr;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            addressLinesOutBuff[23:16] <= mdr;         
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            cycleCount <= 1;
							state <= I_PC_NEXT;
                        end 
                    end

                    else if(instruction == GSFP)
                    begin
                        cycleCount <= 3;
                        stackFrameBuff <= stackFrameBuff + dataIn;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    /*else if(instruction == H_INT)
                    begin
                        if(exceptNum == 0)
                            intNum <= dataIn;

                        cycleCount <= 4;
                        state <= I_ACCESS_MEM_WRITE;
                    end*/

                    else if(instruction == OR)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == AND)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == CMP)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == XOR)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == ADD)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == SUB)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == MUL)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end

                    else if(instruction == DIV)
                    begin
                        aluRegSel <= dataIn;
                        state <= I_ACCESS_ALU;
                    end
                end

                I_ACCESS_MEM_WRITE:
                begin
                    if(instruction == STB)
                    begin
                        if(cycleCount == 1)
                        begin
                            toDataBus <= r1Out;
                            cycleCount <= cycleCount - 1;  
                        end

                        else
                        begin
                            mar <= addressLinesOutBuff;
                            memoryMode <= ADDR_MODE_WRT; 
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == STBREG)
                    begin
                        if(cycleCount == 1)
                        begin
                            toDataBus <= r1Out;
                            cycleCount <= cycleCount - 1;    
                        end

                        else
                        begin
                            mar <= addressLinesOutBuff;
                            memoryMode <= ADDR_MODE_WRT; 
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == PUSH)
                    begin
                        toDataBus <= tmpReg;
                        mar <= stackPointer;
                        stackPointer <= stackPointer - 1;
                        memoryMode <= ADDR_MODE_WRT;
                        state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
						accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        cycleCount <= 1;
                    end

                    else if(instruction == PUSHA)
                    begin
                        if(cycleCount == 5)
                        begin
							toDataBus <= {2'b00, srFlag, divZero, greaterFlag, zeroFlag, eqFlag, overflowFlag};
                            mar <= stackPointer;
                            stackPointer <= stackPointer - 1;                 
                            cycleCount <= cycleCount - 1;
							memoryMode <= ADDR_MODE_WRT;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end

                        else if(cycleCount == 4)
                        begin
                            toDataBus <= r1Out;
                            mar <= stackPointer;
                            stackPointer <= stackPointer - 1;                 
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end

                        else if(cycleCount == 3)
                        begin
                            toDataBus <= r2Out;
                            mar <= stackPointer;
                            stackPointer <= stackPointer - 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end

                        else if(cycleCount == 2)
                        begin
                            toDataBus <= r3Out;
                            mar <= stackPointer;
                            stackPointer <= stackPointer - 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end

                        else if(cycleCount == 1)
                        begin
                            toDataBus <= r4Out;
                            mar <= stackPointer;
                            stackPointer <= stackPointer - 1;
                            cycleCount <= cycleCount - 1;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        end
                    end

                    else if(instruction == CALL)
                    begin
                        if(cycleCount == 4)
                        begin
                            toDataBus <= retAddr[7:0];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            memoryMode <= ADDR_MODE_WRT;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 3)
                        begin
                            cycleCount <= cycleCount - 1;
                            mar <= stackPointer;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end
                        
                        else if(cycleCount == 2)
                        begin
                            toDataBus <= retAddr[15:8];
                            stackPointer <= stackPointer - 1;
                            cycleCount <= cycleCount - 1;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;   
                            mar <= stackPointer;       
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;							
                        end

                        else if(cycleCount == 0)
                        begin
                            toDataBus <= retAddr[23:16];
                            stackPointer <= stackPointer - 1;
							state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
							accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end
                    end

                    else if(instruction == STOSB)
                    begin
                        di <= di + 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == STOSBA)
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        di <= di + 1;
                        state <= I_ACCESS_REG_READ_2;
                        cycleCount <= 1;   
                    end

                    else if(instruction == RSTOSB)
                    begin
                        di <= di - 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

					else if(instruction == H_INT)
                    begin
                        //push return address
                        if(cycleCount == 4)
                        begin
                            toDataBus <= retAddr[7:0];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            memoryMode <= ADDR_MODE_WRT;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 3)
                        begin
                            toDataBus <= retAddr[15:8];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        else if(cycleCount == 2)
                        begin
                            toDataBus <= retAddr[23:16];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        //push flags
                        else if(cycleCount == 1)
                        begin
                            toDataBus <= {2'b00, srFlag, divZero, greaterFlag, zeroFlag, eqFlag, overflowFlag};
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            cycleCount <= cycleCount - 1;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        end

                        //push registers
                        else if(cycleCount == 0)
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == S_INT)
                    begin
                        //push return address
                        if(cycleCount == 4)
                        begin
                            toDataBus <= retAddr[7:0];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            memoryMode <= ADDR_MODE_WRT;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 3)
                        begin
                            toDataBus <= retAddr[15:8];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;       
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            toDataBus <= retAddr[23:16];
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        //push flags
                        else if(cycleCount == 1)
                        begin
                            toDataBus <= {2'b00, srFlag, divZero, greaterFlag, zeroFlag, eqFlag, overflowFlag};
                            stackPointer <= stackPointer - 1;
                            mar <= stackPointer;
                            state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                            accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                            cycleCount <= cycleCount - 1;
                        end

                        //push registers
                        else if(cycleCount == 0)
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end
                end

                I_ACCESS_MEM_WRITE_2:
                begin
                    if(instruction == STOSBA)
                    begin
                        di <= di + 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end
                end

                I_ACCESS_ALU:
                begin
                    if(instruction == OR)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == AND)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == SHL)
                    begin
                        aluRun <= 1;
                        tmpReg <= r1Out;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == SHR)
                    begin
                        aluRun <= 1;
                        tmpReg <= r1Out;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == CMP)
                    begin
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        if(cycleCount == 4)
                        begin
                            aluRun <= 1;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 3)
                        begin
                            aluRun <= 0;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                            cycleCount <= cycleCount - 1;

                        else if(cycleCount == 1)
                        begin
                            greaterFlag <= greaterFlagBus;
                            zeroFlag <= zeroFlagBus;
                            eqFlag <= eqFlagBus;
                            overflowFlag <= overflowFlagBus;
                            divZero <= divZeroBus;
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 0)
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == NOT)
                    begin
                        aluRun <= 1;
                        tmpReg <= 8'hZZ;
                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == XOR)
                    begin
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        aluRun <= 1;
                        aluCycle <= 1;

                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == ADD)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        overflowFlag <= overflowFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == SUB)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                            tmpReg <= r1Out;

                        else if(aluRegSel[1:0] == 2'b01)
                            tmpReg <= r2Out;

                        else if(aluRegSel[1:0] == 2'b10)
                            tmpReg <= r3Out;

                        else if(aluRegSel[1:0] == 2'b11)
                            tmpReg <= r4Out;

                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == INC)
                    begin
                        aluRun <= 1;
                        overflowFlag <= overflowFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == DEC)
                    begin
                        aluRun <= 1;
                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == ROL)
                    begin
                        aluRun <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == ROR)
                    begin
                        aluRun <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == MUL)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                        begin
                            tmpReg <= r1Out;
                            aluCycle <= r1Out;
                        end

                        else if(aluRegSel[1:0] == 2'b01)
                        begin
                            tmpReg <= r2Out;
                            aluCycle <= r2Out;
                        end

                        else if(aluRegSel[1:0] == 2'b10)
                        begin
                            tmpReg <= r3Out;
                            aluCycle <= r3Out;
                        end

                        else if(aluRegSel[1:0] == 2'b11)
                        begin
                            tmpReg <= r4Out;
                            aluCycle <= r4Out;
                        end

                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == DIV)
                    begin
                        aluRun <= 1;
                        if(aluRegSel[1:0] == 2'b00)
                        begin
                            tmpReg <= r1Out;
                        end

                        else if(aluRegSel[1:0] == 2'b01)
                        begin
                            tmpReg <= r2Out;
                        end

                        else if(aluRegSel[1:0] == 2'b10)
                        begin
                            tmpReg <= r3Out;
                        end

                        else if(aluRegSel[1:0] == 2'b11)
                        begin
                            tmpReg <= r4Out;
                        end

                        zeroFlag <= zeroFlagBus;

                        cycleCount <= 8'hFF;
                        aluCycle <= 8'hFF;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == ADDS)
                    begin
                        aluRun <= 1;
                        overflowFlag <= overflowFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == SUBS)
                    begin
                        aluRun <= 1;
                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == INCS)
                    begin
                        aluRun <= 1;
                        overflowFlag <= overflowFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == DECS)
                    begin
                        aluRun <= 1;
                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == ROLS)
                    begin
                        aluRun <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == RORS)
                    begin
                        aluRun <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == MULS)
                    begin
                        aluRun <= 1;
                        aluCycle <= {r3Out, r4Out};
                        zeroFlag <= zeroFlagBus;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == DIVS)
                    begin
                        aluRun <= 1;
                        zeroFlag <= zeroFlagBus;
                        cycleCount <= 8'hFF;
                        aluCycle <= 8'hFF;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == CMPS)
                    begin
                        aluRun <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end
                end

                I_ACCESS_REG_READ:
                begin
                    if(instruction == MOV)
                    begin                    
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                        end
                        
                        else
                        begin
                            case(mdr[1:0])
                                2'b00:
                                    tmpReg <= r1Out;
                                    
                                2'b01:
                                    tmpReg <= r2Out;
                                    
                                2'b10:
                                    tmpReg <= r3Out;
                                    
                                2'b11:
                                    tmpReg <= r4Out;
                            endcase

                            state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == XCHG)
                    begin                    
                        case(mdr[1:0])
                            2'b00:
                                tmpReg <= r1Out;
                                
                            2'b01:
                                tmpReg <= r2Out;
                                
                            2'b10:
                                tmpReg <= r3Out;
                                
                            2'b11:
                                tmpReg <= r4Out;
                        endcase

                        cycleCount <= 1;
                        state <= I_ACCESS_REG_WRITE;
                    end

                    else if(instruction == STOSB)
                    begin
                        state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        toDataBus <= r1Out;
                        memoryMode <= ADDR_MODE_WRT;
                    end

                    else if(instruction == STOSBA)
                    begin
					    state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        toDataBus <= r1Out;
                        memoryMode <= ADDR_MODE_WRT;
						cycleCount <= 0;
                    end

                    else if(instruction == RSTOSB)
                    begin
						state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
						accessTimeCycleCount <= IDLE_WAIT_CYCLE;
                        toDataBus <= r1Out;
                        memoryMode <= ADDR_MODE_WRT;
                    end

                    else if(instruction == SPIRFR)
                    begin
                        si <= {r3Out, r2Out, r1Out};
                        state <= I_PC_NEXT;
                    end

                    else if(instruction == SPDRFR)
                    begin
                        di <= {r3Out, r2Out, r1Out};
                        state <= I_PC_NEXT;
                    end
                end

                I_ACCESS_REG_READ_2:
                begin
                    if(instruction == STOSBA)
                    begin
					    state <= I_ACCESS_MEM_ACCESS_WRITE_TIME;
                        accessTimeCycleCount <= IDLE_WAIT_CYCLE;	
                        mar <= di;
                        toDataBus <= r2Out;
                        memoryMode <= ADDR_MODE_WRT;
						cycleCount <= 1;
                    end
                end

                I_ACCESS_REG_WRITE:
                begin
                    if(instruction == MOV)
                    begin
                        case(dataIn[3:2])			
                            2'b00:
                                r1En <= 1;
                                
                            2'b01:
                                r2En <= 1;
                                
                            2'b10:
                                r3En <= 1;
                                
                            2'b11:
                                r4En <= 1;
                        endcase

                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == XCHG)
                    begin
                        if(cycleCount == 1)
                        begin
                            swapReg <= r1Out;
                            r1En <= 1;
                            r2En <= 0;
                            r3En <= 0;
                            r4En <= 0;
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            r1En <= 0;
                            r2En <= 0;
                            r3En <= 0;
                            r4En <= 0;
                            tmpReg <= swapReg;

                            case(mdr[1:0])
                                2'b00:
                                    r1En <= 1;
                                    
                                2'b01:
                                    r2En <= 1;   

                                2'b10:
                                    r3En <= 1;
                                    
                                2'b11:
                                    r4En <= 1;
                            endcase

                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == LODSB)
                    begin
                        si <= si + 1;
                        tmpReg <= mdr;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == RLODSB)
                    begin
                        si <= si - 1;
                        tmpReg <= mdr;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == LOD)
                    begin
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            r1En <= 1;
                            tmpReg <= mdr;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == LDM)
                    begin
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                            tmpReg <= mdr;
                            r1En <= 1;
                        end

                        else
                        begin
                            r1En <= 0;
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end    
                    end

                    else if(instruction == LDMREG)
                    begin
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                            tmpReg <= mdr;
                            r1En <= 1;
                        end

                        else
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end    
                    end

                    else if(instruction == POP)
                    begin
                        tmpReg <= mdr;

                        case(pushPopRegSel[1:0])			
                            2'b00:
                                r1En <= 1;
                                
                            2'b01:
                                r2En <= 1;
                                
                            2'b10:
                                r3En <= 1;
                                
                            2'b11:
                                r4En <= 1;
                        endcase

                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == LDSP)
                    begin
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                            tmpReg <= mdr;
                            r1En <= 1;
                        end

                        else
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == LDSPI)
                    begin
                        if(cycleCount == 1)
                        begin
                            cycleCount <= cycleCount - 1;
                            tmpReg <= mdr;
                            r1En <= 1;
                        end

                        else
                        begin
                            state <= I_PC_NEXT;
                            cycleCount <= 1;
                        end
                    end

                    else if(instruction == GSFP)
                    begin
                        if(cycleCount == 3)
                        begin
                            r3En <= 1;            
                            tmpReg <= stackFramePointer[23:16];
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 2)
                        begin
                            r3En <= 0;
                            r2En <= 1;
                            tmpReg <= stackFramePointer[15:8];
                            cycleCount <= cycleCount - 1;
                        end

                        else if(cycleCount == 1)
                        begin
                            r2En <= 0;
                            r1En <= 1;
                            tmpReg <= stackFramePointer[7:0];
                            cycleCount <= cycleCount - 1;
                        end

                        else
                        begin
                            memoryMode <= ADDR_MODE_RD;
                            r1En <= 0;
                            state <= I_PC_NEXT;
                        end                        
                    end

                    else if(instruction == OR)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == AND)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == SHL)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == SHR)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == NOT)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;  
                        cycleCount <= 1;
                    end

                    else if(instruction == XOR)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT; 
                        cycleCount <= 2;
                    end

                    else if(instruction == ADD)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT; 
                        cycleCount <= 1;
                    end

                    else if(instruction == SUB)
                    begin
                        aluRun <= 0;             
                        state <= I_PC_NEXT; 
                        cycleCount <= 1;
                    end

                    else if(instruction == INC)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == DEC)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == ROL)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end

                    else if(instruction == ROR)
                    begin
                        aluRun <= 0;
                        r1En <= 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end 

                    else if(instruction == MUL)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT; 
                        cycleCount <= tmpReg + 1;
                    end

                    else if(instruction == DIV)
                    begin
                        aluRun <= 0;
                        cycleCount <= cycleCount - 1;
                        if(cycleCount == 0 || aluDivDone)
                        begin
                            cycleCount <= 1;
                            aluCycle <= 0;
                            state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == ADDS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT; 
                        cycleCount <= 3;
                    end

                    else if(instruction == SUBS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT; 
                        cycleCount <= 2;
                    end

                    else if(instruction == INCS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT;
                        cycleCount <= 2;
                    end

                    else if(instruction == DECS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT;
                        cycleCount <= 2;
                    end

                    else if(instruction == ROLS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT;
                        cycleCount <= 2;
                    end

                    else if(instruction == RORS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT;
                        cycleCount <= 2;
                    end 

                    else if(instruction == MULS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT; 
                        cycleCount <= {r1Out, r2Out} + 1;
                    end

                    else if(instruction == DIVS)
                    begin
                        cycleCount <= cycleCount - 1;
                        aluRun <= 0;

                        if(cycleCount == 0 || aluDivDone)
                        begin
                            cycleCount <= 2;
                            aluCycle <= 0;
                            state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == CMPS)
                    begin
                        aluRun <= 0;
                        state <= I_PC_NEXT;
                        cycleCount <= 0;
                    end
                end

                /*I_ACCESS_REG_WRITE_2:
                begin
                    if(instruction == STOSB)
                    begin
                        di <= di + 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end
                end*/    

                I_ACCESS_MEM_ACCESS_READ_TIME:
                begin
                    if(instruction == MOV)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            cycleCount <= 1;
                            mdr <= dataIn;
                            state <= I_ACCESS_REG_READ;
                        end
                    end

                    else if(instruction == LODSB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == LOD)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            cycleCount <= 1;
                            mdr <= dataIn;
                            state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == STB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == STBREG)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == S_INT)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                	else if(instruction == BNE)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                	else if(instruction == BEQ)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                	else if(instruction == BGR)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                	else if(instruction == BRL)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == BRA)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == PUSH)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == POP)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;

                            if(cycleCount == 1)
                                state <= I_ACCESS_MEM_READ;
                                
                            else if(cycleCount == 0)
                                state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == LDM)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;

                            if(cycleCount == 0)
                            begin    
                                state <= I_ACCESS_REG_WRITE;
                                cycleCount <= 1;
                            end

                            else
                            begin
                                state <= I_ACCESS_MEM_READ;
                            end
                        end
                    end

                    else if(instruction == LDMREG)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            
                            if(cycleCount > 0)
                                state <= I_ACCESS_MEM_READ;
                                
                            else if(cycleCount == 0)
                            begin
                                cycleCount <= 1;
                                state <= I_ACCESS_REG_WRITE;
                            end
                        end
                    end

                    else if(instruction == POPA)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            
                            if(cycleCount == 0)
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end
                            
                            else
                                state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == CALL)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == RTS)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == BRZ)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == SPIR)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == SBP)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == SPDR)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == XCHG)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_REG_READ;
                        end
                    end

                    else if(instruction == SSPR)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == SDBEQ)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == RLODSB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == LDSP)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == LDSPI)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							mdr <= dataIn;
							state <= I_ACCESS_REG_WRITE;
                        end
                    end

                    else if(instruction == RTSV)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end

                    else if(instruction == IRET)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
							state <= I_ACCESS_MEM_READ;
                        end
                    end
                end

                I_ACCESS_MEM_ACCESS_WRITE_TIME:
                begin
                    if(instruction == STB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == STBREG)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							state <= I_PC_NEXT;
                        end    
                    end

                    else if(instruction == S_INT)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end
                        
                        else
                        begin
                            state <= I_ACCESS_MEM_WRITE;
                        end
                    end

                    else if(instruction == PUSH)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            mdr <= dataIn;
                            state <= I_PC_NEXT;
                        end
                    end

                    else if(instruction == PUSHA)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
                            if(cycleCount == 0)
                            begin
                                state <= I_PC_NEXT;
                                cycleCount <= 1;
                            end
                            
                            else
                            begin                                    
                                state <= I_ACCESS_MEM_WRITE;
                            end
                        end
                    end

                    else if(instruction == CALL)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							if(cycleCount == 0)
							begin
                                stackPointer <= stackPointer - 1;
					            state <= I_PC_NEXT;
								cycleCount <= 1;
                            end

							else
							begin
								state <= I_ACCESS_MEM_WRITE;
							end
                        end
                    end

                    else if(instruction == STOSB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							state <= I_ACCESS_MEM_WRITE;
                        end
                    end

                    else if(instruction == RSTOSB)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							state <= I_ACCESS_MEM_WRITE;
                        end
                    end

                    else if(instruction == STOSBA)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							if(cycleCount == 0)
								state <= I_ACCESS_MEM_WRITE;
								
							else if(cycleCount == 1)
								state <= I_ACCESS_MEM_WRITE_2;
                        end
                    end

                    else if(instruction == RTSV)
                    begin
                        if(accessTimeCycleCount)
                        begin
                            accessTimeCycleCount <= accessTimeCycleCount - 1;
                        end

                        else
                        begin
							state <= I_ACCESS_MEM_READ;
                        end
                    end                   
                end

                I_PC_NEXT:
                begin
                    if(cycleCount == 4)
                    begin
                        if(instruction == ADDS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end
                    end

                    if(cycleCount == 3)
                    begin
                        if(instruction == ADDS)
                        begin
                            r1En <= 0;
                        end
                    end

                    if(cycleCount == 2)
                    begin
                        if(instruction == XOR)
                        begin
                            tmpReg <= accumOut;
                        end

                        else if(instruction == SUBS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end

                        else if(instruction == INCS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end
                        
                        else if(instruction == DECS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end

                        else if(instruction == ROLS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end

                        else if(instruction == RORS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end
                        
                        else if(instruction == DIVS)
                        begin
                            tmpReg <= remainderS[15:8];
                            r3En <= 1;
                        end

                        cycleCount <= cycleCount - 1;
                    end

                    else if(cycleCount == 1)
                    begin
                        if(instruction == LOD)
                        begin
                            r1En <= 0;
                        end

                        else if(instruction == ADDS)
                        begin
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end

                        else if(instruction == SUBS)
                        begin
                            r1En <= 0;
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end

                        else if(instruction == INCS)
                        begin
                            r1En <= 0;
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end
                        
                        else if(instruction == DECS)
                        begin
                            r1En <= 0;
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end

                        else if(instruction == ROLS)
                        begin
                            r1En <= 0;
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end

                        else if(instruction == RORS)
                        begin
                            r1En <= 0;
                            tmpReg <= accumOutS[7:0];
                            r2En <= 1;
                        end
                        
                        else if(instruction == MULS)
                        begin
                            tmpReg <= accumOutS[15:8];
                            r1En <= 1;
                        end

                        else if(instruction == XOR)
                        begin
                            r1En <= 0;
                        end

                        else if(instruction == DIV)
                        begin
                            if(divZeroBus == 1)
                                exceptNum <= DIV_BY_ZERO;

                            tmpReg <= remainder;
                            r2En <= 1;
                        end

                        else if(instruction == DIVS)
                        begin
                            r3En <= 0;
                            tmpReg <= remainderS[7:0];
                            r4En <= 1;
                        end

                        memoryMode <= ADDR_MODE_RD;
                        cycleCount <= cycleCount - 1;
                    end

                    else if(cycleCount > 1) //this shouldn't occur, just a failsafe
                    begin
                        cycleCount <= cycleCount - 1;
                    end

                    else
                    begin
                        memoryMode <= ADDR_MODE_RD;
                        state <= I_IDLE;
                        cycleCount <= IDLE_WAIT_CYCLE;

                        case(instruction)
                            NOP:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            MOV:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            LODSB:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            RLODSB:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            LOD:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            STB:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            STBREG:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            BNE:
                            begin
                                if(eqFlagBus == 0)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end
                            end

                            BEQ:
                            begin
                                if(eqFlagBus)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end
                            end

                            BGR:
                            begin
                                if(greaterFlagBus)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end
                            end

                            BRL:
                            begin
                                if(lessFlagBus)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end
                            end

                            PUSH:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            POP:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            LDM:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            LDMREG:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            S_INT:
                            begin
                                //jump to int handler
                                case(intNum)
                                    8'd16:
                                    begin
                                        pc <= SOFT_INT_16_ADDR;
                                        mar <= SOFT_INT_16_ADDR;
                                    end

                                    8'd17:
                                    begin
                                        pc <= SOFT_INT_17_ADDR;
                                        mar <= SOFT_INT_17_ADDR;
                                    end

                                    8'd18:
                                    begin
                                        pc <= SOFT_INT_18_ADDR;
                                        mar <= SOFT_INT_18_ADDR;
                                    end

                                    8'd19:
                                    begin
                                        pc <= SOFT_INT_19_ADDR;
                                        mar <= SOFT_INT_19_ADDR;
                                    end

                                    8'd20:
                                    begin
                                        pc <= SOFT_INT_20_ADDR;
                                        mar <= SOFT_INT_20_ADDR;
                                    end

                                    8'd21:
                                    begin
                                        pc <= SOFT_INT_21_ADDR;
                                        mar <= SOFT_INT_21_ADDR;
                                    end

                                    8'd22:
                                    begin
                                        pc <= SOFT_INT_22_ADDR;
                                        mar <= SOFT_INT_22_ADDR;
                                    end
                                endcase
                            end

                            IRET:
                            begin
                                pc <= retAddr;
                                mar <= retAddr;
                            end

                            PUSHA:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            POPA:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            CLI:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            STI:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            HALT:
                            begin
                                pc <= pc;
                                mar <= pc;
                            end

                            CALL:
                            begin
                                pc <= addressLinesOutBuff;
                                mar <= addressLinesOutBuff;
                            end

                            RTS:
                            begin
                                pc <= retAddr;
                                mar <= retAddr;
                            end

                            RTSV:
                            begin
                                pc <= retAddr;
                                mar <= retAddr;
                            end

                            BRA:
                            begin
                                pc <= addressLinesOutBuff;
                                mar <= addressLinesOutBuff;
                            end

                            NSB:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            BRZ:
                            begin
                                if(zeroFlagBus)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end
                            end

                            SPIR:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            RST:
                            begin
                                pc <= 0;
                                mar <= 0;
                            end

                            SBP:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            STOSB:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            STOSBA:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            RSTOSB:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SPDR:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            XCHG:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            SSPR:
                            begin
                                pc <= pc + 4;
                                mar <= pc + 4;
                            end

                            SDEQUAL:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SDBEQ:
                            begin
                                if(srFlag)
                                begin
                                    pc <= addressLinesOutBuff;
                                    mar <= addressLinesOutBuff;
                                end
                                else
                                begin
                                    pc <= pc + 4;
                                    mar <= pc + 4;
                                end

                                srFlag <= 0;
                            end

                            LDSP:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            LDSPI:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SPIRFR:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SPDRFR:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SSFP:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SSFPM:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end
                            
                            SSFPR:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            GSFP:
                            begin
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            PITST:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            PITCLR:
                            begin
                                PITFlag <= 0;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            //ALU
                            OR:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            AND:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            SHL:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SHR:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            CMP:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            NOT:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            XOR:
                            begin
                                r1En <= 0;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            H_INT:
                            begin
                                intNum <= 0;
                                intLock <= 0;
                                //jump to int handler
                                case(intNum)
                                    //hardware int
                                    8'd1:
                                    begin
                                        pc <= IRQ_1_ADDR;
                                        mar <= IRQ_1_ADDR;
                                    end

                                    8'd2:
                                    begin
                                        pc <= IRQ_2_ADDR;
                                        mar <= IRQ_2_ADDR;
                                    end

                                    8'd3:
                                    begin
                                        pc <= IRQ_3_ADDR;
                                        mar <= IRQ_3_ADDR;
                                    end

                                    8'd4:
                                    begin
                                        pc <= IRQ_4_ADDR;
                                        mar <= IRQ_4_ADDR;
                                    end

                                    8'd5:
                                    begin
                                        pc <= IRQ_5_ADDR;
                                        mar <= IRQ_5_ADDR;
                                    end

                                    8'd6:
                                    begin
                                        pc <= IRQ_6_ADDR;
                                        mar <= IRQ_6_ADDR;
                                    end

                                    8'd7:
                                    begin
                                        pc <= IRQ_7_ADDR;
                                        mar <= IRQ_7_ADDR;
                                    end
                                
                                    8'd8:
                                    begin
                                        pc <= IRQ_8_ADDR;
                                        mar <= IRQ_8_ADDR;
                                    end

                                    8'd9:
                                    begin
                                        pc <= IRQ_9_ADDR;
                                        mar <= IRQ_9_ADDR;
                                    end

                                    8'd10:
                                    begin
                                        pc <= IRQ_10_ADDR;
                                        mar <= IRQ_10_ADDR;
                                    end

                                    8'd11:
                                    begin
                                        pc <= IRQ_11_ADDR;
                                        mar <= IRQ_11_ADDR;
                                    end

                                    8'd12:
                                    begin
                                        pc <= IRQ_12_ADDR;
                                        mar <= IRQ_12_ADDR;
                                    end

                                    8'd13:
                                    begin
                                        pc <= IRQ_13_ADDR;
                                        mar <= IRQ_13_ADDR;
                                    end

                                    8'd14:
                                    begin
                                        pc <= IRQ_14_ADDR;
                                        mar <= IRQ_14_ADDR;
                                    end

                                    8'd15:
                                    begin
                                        pc <= IRQ_15_ADDR;
                                        mar <= IRQ_15_ADDR;
                                    end

                                    default: //exceptions
                                    begin
                                        case(exceptNum)
                                            INVALID_INSTRUCTION:
                                            begin
                                                exceptNum <= 0;
                                                pc <= EXP_1_ADDR;
                                                mar <= EXP_1_ADDR;
                                            end

                                            DIV_BY_ZERO:
                                            begin
                                                exceptNum <= 0;
                                                pc <= EXP_2_ADDR;
                                                mar <= EXP_2_ADDR;
                                            end
                                        endcase
                                    end
                                endcase
                            end

                            ADD:
                            begin
                                r1En <= 1;
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            SUB:
                            begin
                                r1En <= 1;
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            INC:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            DEC:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            ROL:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            ROR:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            MUL:
                            begin
                                r1En <= 1;
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            DIV:
                            begin
                                refreshALUState <= 1;
                                r1En <= 1;
                                r2En <= 0;  
                                tmpReg <= accumOut;
                                pc <= pc + 2;
                                mar <= pc + 2;
                            end

                            ADDS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            SUBS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            INCS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            DECS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            ROLS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            RORS:
                            begin
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            MULS:
                            begin
                                r1En <= 0;
                                tmpReg <= accumOutS[7:0];
                                r2En <= 1;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            DIVS:
                            begin
                                refreshALUState <= 1;
                                r1En <= 1;
                                r2En <= 0;  
                                tmpReg <= accumOutS;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end

                            CMPS:
                            begin
                                tmpReg <= accumOut;
                                pc <= pc + 1;
                                mar <= pc + 1;
                            end
                            
                            default:
                            begin
                                exceptNum <= INVALID_INSTRUCTION;
                            end
                        endcase   
                    end
                end   
            endcase
        end
    end
endmodule