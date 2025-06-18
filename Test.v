module Test;
    reg clk;
    reg rst;

    initial begin
        forever
        begin
            clk = 0;
            #1;
            
            clk = 1;
            #1;
        end
    end

    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, Test);
        rst = 1;
        #10;
        rst = 0;

        #1000;
    $finish;
    end

    IO uut(clk, rst);

endmodule