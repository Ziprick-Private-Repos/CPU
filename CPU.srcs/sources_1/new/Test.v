`timescale 1us / 1ps
`default_nettype none

module Test;
    reg clkIn; 
    reg rst;
    reg enBtn;
    wire memoryMode;
    wire [1:0]deviceEn;
    wire [23:0]addressOut; 
    wire [7:0]data;
    wire [7:0]seg;
    wire [5:0]disp;

    reg [7:0]dataDly;

    integer i;

    reg [7:0]memory[0:17_000];

    assign data = memoryMode ? memory[addressOut] : 8'hzz;

    always @(*)
    begin
        if(memoryMode == 0)
            memory[addressOut] = data;
    end

    IO uut(
        .clkIn(clkIn), 
        .rst(rst), 
        .enBtn(enBtn),
        .memoryMode(memoryMode), 
        .deviceEn(deviceEn), 
        .addressOut(addressOut), 
        .data(data),
        .seg(seg), 
        .disp(disp));

    // Clock
    initial begin
        forever
        begin
            clkIn = 0;
            #1;

            clkIn = 1;
            #1;
        end
    end

    `ifndef SYNTHESIS
    initial begin
    
    $write("DEBUG MODE\n");

    for(i = 0; i < 65536; i = i + 1)
    begin      
        memory[i] = 8'hzz;
    end
    $readmemb("data.txt", memory);
    end
    `endif

    // Stimulus
    initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, Test);
        for(i = 24'd16374; i <= 16384; i += 1)
            $dumpvars(0, Test, Test.memory[i]);
            //$dumpvars(0, Test, Test.uut.uart.sendDataBuff[i]);

        //portAIn = 8'h3b;
        //portBIn = 8'hf8;

        //prgmSwch = 0;
        //haltSwch = 0;
        //gotoSwitch = 0;
        enBtn = 1;
        rst = 1;
        #5;
        rst = 0;
        #100;
        rst = 1;
        #100;
        enBtn = 0;

        #100000;
        #100000;
        #100000;
    $finish;
    end
endmodule