`timescale 1ns / 1ps
`default_nettype none

module Test;
    reg clk;
    reg rst;
    reg [3:0]hardInterrupt = 0;

    // External data lines
    //inout [7:0] data;
    //inout [23:0]address;
    wire wrt;

    reg haltSwch = 0;
    reg prgmSwch = 0;
    reg gotoSwitch = 0;
    reg [7:0]dataSwch = 0;
    reg [23:0]addrSwch = 0;
    
    inout [7:0]portA;
    inout [7:0]portB;
    reg [7:0]portAIn;
    reg [7:0]portBIn;
    wire [3:0] led;
    wire [7:0] seg;
    wire [5:0] disp;

    wire tx;
    reg rx;

    integer i;

    //assign data = 8'hZZ;
    //assign address = 24'hZZZZZZ;
    //assign data = wrt ? 8'hZZ : memory[address];
    //assign address = gotoSwitch ? addrSwch : 24'hZZZZZZ;

    // Instantiate IO module
    IO uut (
        .clkIn(clk),
        .rst(rst),
        //.data(data),
        //.address(address),
        .wrt(wrt),
        .gotoSwitch(gotoSwitch),
        .portA(portA),
        .portB(portB),
        .led(led),
        .seg(seg),
        .disp(disp),
        .hardInterrupt(hardInterrupt),
        .tx(tx),
        .rx(rx)
    );

    // Clock
    initial begin
        forever
        begin
            clk = 0;
            #1;

            clk = 1;
            #1;
        end
    end

    // Stimulus
    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, Test);
        for(i = 0; i < 20; i += 1)
            $dumpvars(0, Test, Test.uut.memory[i]);
        prgmSwch = 0;
        haltSwch = 0;
        gotoSwitch = 0;
        rst = 1;
        #5;
        rst = 0;
        #100;
        rst = 1;
        #100;

        #40000;
        // Optional: set a port high to simulate I/O input
        //#100 drivePortA = 1; portA_in = 8'h42;
        //#50 drivePortB = 1; portB_in = 8'h99;
        //#50 hardInterrupt = 4'b0001;
    $finish;
    end
endmodule