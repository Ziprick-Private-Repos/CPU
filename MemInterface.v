`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2025 08:01:56 PM
// Design Name: 
// Module Name: MemInterface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MemInterface(input wire clk, input wire rst, output wire [7:0]testData, output wire clkIn);
    reg clkIn;
    reg [7:0]clkCnt;
    
    wire [7:0]portA;
    wire [7:0]portB;
    wire [23:0]address;
    wire wrt;
    wire [7:0]data;
    wire [7:0]dataToMem;
    wire [7:0]dataFromMem;
    assign testData = data;
    
    wire [3:0]hardInterrupt;
    assign hardInterrupt = 4'b0000;

    blk_mem_gen_0 memory (
        .clka(clk),
        .wea({wrt}),
        .addra(address[16:0]),
        .dina(dataToMem),
        .douta(dataFromMem)
    );
    
    IO io (
        .clk(clkIn),
        .rstIn(rst),
        .wrt(wrt),
        .data(data),
        .address(address),
        .portA(portA),
        .portB(portB),
        .hardInterrupt(hardInterrupt)
    );
    
    assign dataToMem = (wrt == 1'b1) ? data : 8'bz;
    assign data = (wrt == 1'b0) ? dataFromMem : 8'bz;
    
    always @(posedge clk)
    begin
        clkCnt = clkCnt + 1;
        if(clkCnt >= 98)
        begin
            clkCnt <= 0;
            clkIn <= ~clkIn;
        end
    end
endmodule
