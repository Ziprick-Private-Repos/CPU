`timescale 1ns / 1ps
`default_nettype none

module Test;
    reg clk;
    reg clkIn;
    reg [3:0]clkCnt;
    reg rst;

    // External data lines
    wire [7:0] data;
    wire [23:0] address;
    wire wrt;

    // Tri-state ports
    tri [7:0] portA;
    tri [7:0] portB;
    reg drivePortA;
    reg [7:0] portA_in;
    assign portA = drivePortA ? portA_in : 8'bz;

    reg drivePortB;
    reg [7:0] portB_in;
    assign portB = drivePortB ? portB_in : 8'bz;

    reg [3:0] hardInterrupt;

    // Instantiate IO module
    IO uut (
        .clk(clkIn),
        .rstIn(rst),
        .wrt(wrt),
        .data(data),
        .address(address),
        .portA(portA),
        .portB(portB),
        .hardInterrupt(hardInterrupt)
    );

    // Instantiate block memory and connect it to the data bus
    wire [7:0] dataFromMem;
    wire [7:0] dataToMem;

    assign dataToMem = data;
    assign data = (wrt == 1'b0) ? dataFromMem : 8'bz; // read mode: drive data from memory

    blk_mem_gen_0 memory (
        .clka(clk),
        .wea({wrt}), // ? bundle wrt as a 1-bit vector
        .addra(address[16:0]), // ? safe to feed full 17 bits
        .dina(dataToMem),
        .douta(dataFromMem)
    );


    // Clock
    initial begin
        clk = 0;
        clkIn = 0;
        clkCnt = 0;
        
        forever
        begin
            clk = ~clk;
            clkCnt = clkCnt + 1;
            if(clkCnt >= 2)
            begin
                clkCnt = 0;
                clkIn = ~clkIn;
            end
            #1;
        end
    end


    // Stimulus
    initial begin
        rst = 1;
        drivePortA = 0;
        drivePortB = 0;
        portA_in = 8'h00;
        portB_in = 8'h00;
        hardInterrupt = 4'b0000;

        #20;
        rst = 0;

        // Optional: set a port high to simulate I/O input
        //#100 drivePortA = 1; portA_in = 8'h42;
        //#50 drivePortB = 1; portB_in = 8'h99;
        //#50 hardInterrupt = 4'b0001;

        #500;
        $finish;
    end

endmodule
