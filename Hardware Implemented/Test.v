`timescale 1ns / 1ps
`default_nettype none

module Test;
    reg clk = 0;
    reg rst;

    // External data lines
    wire [7:0] data;
    wire [3:0] led;
    integer i;

    // Instantiate IO module
    IO uut (
        .clkIn(clk),
        .rst(rst),
        .data(data),
        .led(led)
    );

    // Clock
    initial begin        
        forever
        begin
            clk = ~clk;
            #1;
        end
    end


    // Stimulus
    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, Test);
    for(i = 0; i < 20; i += 1)
        $dumpvars(0, Test, Test.uut.memory[i]);

        rst = 0;
        #5;
        rst = 1;

        #10000;

        // Optional: set a port high to simulate I/O input
        //#100 drivePortA = 1; portA_in = 8'h42;
        //#50 drivePortB = 1; portB_in = 8'h99;
        //#50 hardInterrupt = 4'b0001;
    $finish;
    end

endmodule
