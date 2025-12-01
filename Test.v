module Test;
    reg clk;
    reg rst;

    integer i;
    integer simSteps = 0;

    initial begin
        forever
        begin
            clk = 0;
            #1;
            simSteps = simSteps + 1;

            clk = 1;
            #1;
            simSteps = simSteps + 1;
        end
    end

    IO uut(clk, rst);

    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, Test);
        //for(i = 0; i <= 4096; i += 1)
            //$dumpvars(0, Test, Test.uut.memory[i]);
        rst = 1;
        #10;
        rst = 0;

        #2200;
    $finish;
    end
endmodule