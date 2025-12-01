`timescale 1ns / 1ps
`default_nettype none

module Control(input wire clk, input wire rstIn,
    output reg [23:0]addrOut,
    output reg [1:0]memReadWrite,
    output reg [7:0]toDataBus,
    input wire [7:0]dataIn,
    input wire [3:0]hardInterrupt,
    output wire [23:0]pcOut);

    assign pcOut = pc;

    //stack
    localparam DEFAULT_STACK_TOP_ADDRESS = 16'd3000; //after port out space

    //memory modes
    localparam [1:0]
	ADDR_MODE_RD    = 2'b00, //00 reads address lines (reading 'random' locations)
	ADDR_MODE_PC    = 2'b01, //01 reads address at pc
	ADDR_MODE_WRT   = 2'b10; //10 writes to address lines

    `include "Control_misc/Int_pointers.vh"

    //states
    reg [15:0]cycleCount;
    reg [3:0]state;
    localparam[3:0]
        I_IDLE = 4'b0000,
        I_FETCH = 4'b0001,
        I_DECODE = 4'b0010,
        I_ACCESS_MEM_READ = 4'b0011,
        //I_ACCESS_MEM_READ_2 = 4'b0100,
        I_ACCESS_MEM_WRITE = 4'b0101,
        I_ACCESS_MEM_WRITE_2 = 4'b0110,
        I_ACCESS_ALU = 4'b0111,
        I_ACCESS_REG_READ = 4'b1000,
        I_ACCESS_REG_READ_2 = 4'b1001,
        I_ACCESS_REG_WRITE = 4'b1010,
        I_ACCESS_REG_WRITE_2 = 4'b1011,
        I_PC_NEXT = 4'b1100;

    `include "Control_misc/Opcodes.vh"

    Register r1(.clk(clk), .rst(rstIn), .dataIn(tmpReg), .dataOut(r1Out), .en(r1En));
    Register r2(.clk(clk), .rst(rstIn), .dataIn(tmpReg), .dataOut(r2Out), .en(r2En));
    Register r3(.clk(clk), .rst(rstIn), .dataIn(tmpReg), .dataOut(r3Out), .en(r3En));
    Register r4(.clk(clk), .rst(rstIn), .dataIn(tmpReg), .dataOut(r4Out), .en(r4En));

    reg [23:0]si; //source reg.
    reg [23:0]di; //destination reg.
    reg [23:0]spr; //special reg.
    reg [23:0]stackTop;
    reg [23:0]stackPointer;
    reg [23:0]stackFramePointer;

    Alu alu(.clk(clk), .rst(rstIn), .cycle(aluCycle), .run(aluRun),
    .divDone(aluDivDone), .opcode(instruction[7:0]), 
    .regA(r1Out), .regB(tmpReg), .regS0({r1Out, r2Out}), .regS1({r3Out, r4Out}), .accumulator(accumOut), .accumulatorS(accumOutS), .remainder(remainder),
    .remainderS(remainderS), .greaterFlag(greaterFlagBus), .zeroFlag(zeroFlagBus), .eqFlag(eqFlagBus), 
    .overflowFlag(overflowFlagBus), .divZero(divZeroBus));

    reg uartWrt;
    reg uartRst;
    //UartIO uart(.clk(clk), .rst(uartRst), .uartWrt(uartWrt), .oTx(oTx));

    //-------------STATE REGISTERS------------

    //FETCH
    reg [7:0]instruction;

    //DECODE
    reg rst;

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
    wire zeroFlagBus; 
    wire eqFlagBus;
    wire overflowFlagBus;
    wire divZeroBus;

    //REG READ
    wire [7:0]r1Out;
    wire [7:0]r2Out;
    wire [7:0]r3Out;
    wire [7:0]r4Out;
    reg [7:0]tmpReg;
    reg [23:0]addressOutBuff;
    reg [23:0]stackFrameBuff;

    //REG WRITE
    reg r1En, r2En, r3En, r4En; //enables writing data to registers
    reg [7:0]swapReg; //for xchg instruction

    //INT HANDLE
    reg [7:0]intNum;
    wire pEdge;
    reg disableInt;
    reg [3:0]intLock;
    reg sigDelay;
    reg sigDelay1;

    //PC_NEXT
    reg [23:0]pc;

    //----------------------------------------

    assign pEdge = (hardInterrupt[0] | hardInterrupt[1] | hardInterrupt[2] | hardInterrupt[3]) & ~sigDelay1;

    always @(posedge clk, posedge rstIn)
    begin
        if(rstIn || rst)
        begin
            `include "Control_misc/Reset.vh"
        end

        else
        begin
            uartRst <= 1; //enable UART
            sigDelay <= (hardInterrupt[0] | hardInterrupt[1] | hardInterrupt[2] | hardInterrupt[3]);
            sigDelay1 <= sigDelay;

            if(pEdge == 1'b1)
            begin    
                intLock <= hardInterrupt;
            end

            case(state)
                I_IDLE:
                begin
                    cycleCount <= 1; //delay added to make sure all memory/registers have finished writing
                    state <= I_FETCH;
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

                        if(intLock && disableInt == 1'b0)
                        begin
                            //push pc
                            instruction <= H_INT;
                            state <= I_DECODE;
                        end

                        else if(intNum)
                        begin
                            instruction <= H_INT;
                        end

                        else if(intLock == 1'b0)
                        begin
                            instruction <= dataIn;
                            state <= I_DECODE;
                        end
                    end
                end

                I_DECODE:
                begin
                    `include "Control_Opperations/Decode.vh"
                end

                I_ACCESS_MEM_READ:
                begin
                    `include "Control_Opperations/Access_mem_read.vh"
                end

                I_ACCESS_MEM_WRITE:
                begin
                    `include "Control_Opperations/Access_mem_write.vh"
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
                    `include "Control_Opperations/Access_alu.vh"
                end

                I_ACCESS_REG_READ:
                begin
                    `include "Control_Opperations/Access_reg_read.vh"
                end

                I_ACCESS_REG_READ_2:
                begin
                    if(instruction == STOSBA)
                    begin
                        addressOutBuff <= di;
                        toDataBus <= r2Out;
                        memReadWrite <= ADDR_MODE_WRT;
                        state <= I_ACCESS_MEM_WRITE_2;
                    end
                end

                I_ACCESS_REG_WRITE:
                begin
                    `include "Control_Opperations/Access_reg_write.vh"
                end

                I_ACCESS_REG_WRITE_2:
                begin
                    if(instruction == STOSB)
                    begin
                        di <= di + 1;
                        state <= I_PC_NEXT;
                        cycleCount <= 1;
                    end
                end

                //I_INT_HNDL:
                //begin
                    //state <= I_ACCESS_MEM_READ;
                    //addressOutBuff <= pc + 1;
                    //retAddr <= pc + 2;
                    //memReadWrite <= ADDR_MODE_RD;
                //end       

                I_PC_NEXT:
                begin
                    `include "Control_Opperations/Pc_next.vh"
                end   
            endcase
        end
    end

    always @*
    begin
        if(memReadWrite == ADDR_MODE_RD)
            addrOut = addressOutBuff;

        else if(memReadWrite == ADDR_MODE_PC)
            addrOut = pc;

        else if(memReadWrite == ADDR_MODE_WRT)
            addrOut = addressOutBuff;

        else
            addrOut = pc;
    end
endmodule