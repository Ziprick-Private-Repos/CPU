`timescale 1ns/1ps
`default_nettype none

module AluTest;
    reg clk;
    reg rst;
    reg [15:0]cycle;
    reg run;
    wire divDone;
    reg [7:0]opcode;
    reg [7:0]regA;
    reg [7:0]regB;
    reg [15:0]regS0;
    reg [15:0]regS1;
    wire [7:0]accumulator;
    wire [15:0]accumulatorS;
    wire [7:0]remainder;
    wire [15:0]remainderS;
    wire greaterFlag;
    wire zeroFlag;
    wire eqFlag;
    wire overflowFlag;
    wire divZero;

    initial
    begin
        forever begin
            clk = 0;
            #1;
            clk = 1;
            #1;
        end
    end

    Alu uut(clk, rst, cycle, run, divDone, opcode, regA, regB, regS0, regS1, accumulator, accumulatorS, remainder, remainderS, greaterFlag, zeroFlag, eqFlag, overflowFlag, divZero);
    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, AluTest);
        rst = 1;
        run = 0;
        cycle = 1;
        opcode = 8'b0000_0111; //add
        regA = 8'hff;
        regB = 8'hff;
        #4;

        rst = 0;
        #4;

        run = 1;
        #2;
        run = 0;

        #4;

        regA = accumulator;
        run = 0;
        #100;
    $finish;
    end
endmodule;