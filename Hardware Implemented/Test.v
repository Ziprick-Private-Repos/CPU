`timescale 1ns / 1ps
`default_nettype none

module Test;
    reg clk;
    reg rst;
    reg [3:0]hardInterrupt;

    // External data lines
    wire [7:0] data;
    wire [3:0] led;
    wire [7:0] seg;
    wire [5:0] disp;

    integer i;

    // Instantiate IO module
    IO uut (
        .clkIn(clk),
        .rst(rst),
        .data(data),
        .led(led),
        .seg(seg),
        .disp(disp),
        .hardInterrupt(hardInterrupt)
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

        hardInterrupt = 0;
        rst = 1;
        #5;
        rst = 0;
        #100;
        rst = 1;

        //#200;
        //hardInterrupt = 1;
        #10000;
        #10000;
        // Optional: set a port high to simulate I/O input
        //#100 drivePortA = 1; portA_in = 8'h42;
        //#50 drivePortB = 1; portB_in = 8'h99;
        //#50 hardInterrupt = 4'b0001;
    $finish;
    end
endmodule