`timescale 1ns / 1ps
`default_nettype none

//`define SYNTHESIS

module Uart(input wire clk, input wire rst, input wire send, input wire storeData, input wire [7:0]data, output reg tx, input wire rx);
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam SEND = 2'b10;
    localparam STOP = 2'b11;

    (* mark_debug = "true" *) wire [7:0]sendDataBuffDbg0;
    (* mark_debug = "true" *) wire [7:0]sendDataBuffDbg1;
    (* mark_debug = "true" *) wire [7:0]sendDataBuffDbg2;
    (* mark_debug = "true" *) wire [7:0]sendByteDbg;
    (* mark_debug = "true" *) wire [1:0]stateDbgUart;
    assign sendDataBuffDbg0 = sendDataBuff[0];
    assign sendDataBuffDbg1 = sendDataBuff[1];
    assign sendDataBuffDbg2 = sendDataBuff[2];
    assign sendByteDbg = sendByte;
    assign stateDbgUart = state;

    `ifdef SYNTHESIS
    localparam MAX_CLK_CNT = 16'd5208; //9600 baud @ 50Mhz
    `endif

    `ifndef SYNTHESIS
    localparam MAX_CLK_CNT = 16'd1;
    `endif

    reg [1:0]state;

    reg [2:0]txPos;
    reg [3:0]rxPos;

    reg [15:0]clkCnt;

    reg [7:0]sendByte; //current byte being sent
    reg [7:0]currentSendPos; //current position in send queue to transfer (ptr that sendByte will be set to)
    reg [7:0]sendBuffPos; //send buffer, current position of data queue (end marker)
    reg [7:0]sendDataBuff[0:99]; //send buffer
    reg blockDataBuff; //limit data write to only one cell, bufferData bit needs to toggle for a new write preventing constant writes with clk
    reg transfering;

    reg [7:0]recvDataBuff[0:99];

    integer i;

    always @(posedge clk)
    begin
        if(rst == 0)
        begin
            state <= 0;
            sendByte <= 0;
            currentSendPos <= 0;
            sendBuffPos <= 0;
            blockDataBuff <= 0;

            txPos <= 4'd7;
            rxPos <= 4'd7;
            clkCnt <= 0;
            transfering <= 0;

            for(i = 0; i < 100; i = i + 1)
            begin
                sendDataBuff[i] <= 0;
                recvDataBuff[i] <= 0;
            end
        end

        else
        begin
            case(state)
            IDLE:
            begin
                txPos <= 0;
                rxPos <= 7;
                clkCnt <= 0;
                tx <= 1;

                //initiate transfer
                if(send || transfering)
                begin
                    sendByte <= sendDataBuff[currentSendPos];
                    currentSendPos <= currentSendPos + 1;
                    state <= START;
                end

                //buffer data from cpu
                else if(storeData && blockDataBuff == 0)
                begin
                    blockDataBuff <= 1;
                    sendDataBuff[sendBuffPos] <= data;
                    sendBuffPos <= sendBuffPos + 1;
                end

                else if(storeData == 0)
                    blockDataBuff <= 0;
            end

            START:
            begin
                if(send)
                    state <= START;

                else
                begin
                    clkCnt <= clkCnt + 1;
                    tx <= 0;

                    if(clkCnt >= MAX_CLK_CNT)
                    begin
                        clkCnt <= 0;
                        state <= SEND;
                    end
                end
            end

            SEND:
            begin
                clkCnt <= clkCnt + 1;
                tx <= sendByte[txPos];

                if(txPos == 7 && clkCnt >= MAX_CLK_CNT)
                begin
                    clkCnt <= 0;
                    state <= STOP;
                end

                else if(clkCnt >= MAX_CLK_CNT)
                begin
                    clkCnt <= 0;
                    txPos <= txPos + 1;    
                end
            end

            STOP:
            begin
                clkCnt <= clkCnt + 1;
                tx <= 1;
                
                if(currentSendPos == sendBuffPos)
                begin
                    transfering <= 0;
                    currentSendPos <= 0;
                    sendBuffPos <= 0;
                end

                else if(currentSendPos < sendBuffPos)
                    transfering <= 1;
                    
                if(clkCnt >= MAX_CLK_CNT)
                begin
                    clkCnt <= 0;
                    state <= IDLE;
                end

                /*if(clkCnt >= MAX_CLK_CNT)
                begin
                    clkCnt <= 0;

                    if(currentSendPos < sendBuffPos)
                    begin
                        state <= START;
                        sendByte <= sendDataBuff[currentSendPos];
                        currentSendPos <= currentSendPos + 1;
                    end
                    
                    else
                        state <= IDLE;
                end*/
            end
            endcase
        end
    end
endmodule