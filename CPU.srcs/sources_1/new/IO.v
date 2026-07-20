//
//HARDWARE
//
//`ifdef SYNTHESIS
`timescale 1ns / 1ps
`default_nettype none

//deviceEn => 2'b10==RAM
//deviceEn => 2'b01==ROM
module IO(input wire clkIn, input wire rst, input wire enBtn, input wire stepBtn, output wire memoryMode, output reg [1:0]deviceEn, output wire [23:0]addressOut, inout wire [7:0]data, 
input wire [3:0]hardInterrupt, output wire [7:0]seg, output wire [5:0]disp, output wire tx, input wire rx);
    wire gotoSwitch;
    assign gotoSwitch = 0;

    (* mark_debug = "true" *) reg uartStore;
    (* mark_debug = "true" *) reg uartSend;
    (* mark_debug = "true" *) wire [23:0]addressOutDbg;
    (* mark_debug = "true" *) wire [7:0]dataDbg;
    (* mark_debug = "true" *) wire [23:0]pc;
    (* mark_debug = "true" *) wire [7:0]dataInDbg;
    (* mark_debug = "true" *) wire [7:0]dataOutDbg;
    (* mark_debug = "true", keep = "true" *) reg [31:0] clkCnt = 0;
    (* mark_debug = "true" *) reg clkEn;
    (* mark_debug = "true" *) wire en;
    (* mark_debug = "true" *) wire enBtnDbg;
    (* mark_debug = "true" *) wire [7:0]r1;
    (* mark_debug = "true" *) wire [1:0]deviceEnDbg;
    (* mark_debug = "true" *) wire memoryModeDbg;
    wire step;

    assign addressOutDbg = addressOut;
    assign dataDbg = data;
    assign dataInDbg = dataIn;
    assign dataOutDbg = dataOut;
    assign enBtnDbg = enBtn;
    assign deviceEnDbg = deviceEn;
    assign memoryModeDbg = memoryMode;

    //assign hardInterrupt = intTest == 0 ? 4'b0001 : 4'b0000;
    //assign hardInterrupt = 4'b0000;
    wire exception;

    //reg [7:0]memory[0:1000];
    //wire [7:0]data;
    wire [23:0]address;
    assign address = 0;

    wire [7:0]dataIn;
    wire [7:0]dataOut;

    integer i;

    assign data = memoryMode == 1 ? 8'hZZ : dataOut;
    assign dataIn = data;

    Uart uart(.clk(clkIn), .rst(rst), .send(uartSend), .storeData(uartStore), .data(dataOut), .tx(tx), .rx(rx));
    SevenSegDisp segDisp(.clk(clkIn), .rst(rst), .data2(pc[7:0]), .data1(r1), .data0(dataIn), .seg(seg), .disp(disp));
    Debounce debounce(.clk(clkIn), .rst(rst), .btn(enBtn), .debBtn(en));
    Debounce debounce1(.clk(clkIn), .rst(rst), .btn(stepBtn), .debBtn(step));
    
    always @(posedge clkIn or negedge rst)
    begin
        if(rst == 0)
        begin
            clkCnt <= 0;
        end

        else
        begin
            //if(clkCnt >= 100000)
            if(clkCnt >= 13) //3.8mhz
            begin
                if(en == 0)
                    clkEn <= 1;
                clkCnt <= 0;
            end

            else
            begin
                clkEn <= 0;
                clkCnt <= clkCnt + 1;
            end
        end
    end

    always @(posedge clkIn)
    begin
        if(clkEn)
        begin
            if(addressOut == 16'hFFFF)
                uartSend <= 1;

            else if(addressOut == 16'hFFFE)
                uartStore <= 1;

            else
            begin
                uartSend <= 0;
                uartStore <= 0;
            end
        end
    end

    always @(*)
    begin
        if(addressOut == 16'hFFFF || addressOut == 16'hFFFE)
            deviceEn <= 2'b11;

        else
        begin
            if(addressOut < 16'd8192)
            deviceEn = 2'b01;

            else 
                deviceEn = 2'b10;
        end
    end

    //assign deviceEn = addressOut < 16'd8192 ? 2'b01 : 2'b10; //ROM : RAM

    Control control(.clk(clkIn), .rstIn(rst), .clkEn(clkEn), .step(step),
    .addrOut(addressOut),
    .addrIn(address),
    .memoryMode(memoryMode),
    .toDataBus(dataOut),
    .dataIn(dataIn),
    .hardInterrupt(hardInterrupt),
    .gotoSwitch(gotoSwitch),
    .exception(exception),
    .pcOut(pc),
    .r1Dbg(r1));
endmodule