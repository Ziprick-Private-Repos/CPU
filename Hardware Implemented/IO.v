`timescale 1ns / 1ps
`default_nettype none
    
module IO(input wire clkIn, input wire rst, output wire [7:0]data, output wire [3:0]led, output wire [7:0]seg, output wire [5:0]disp);
    //localparam ColorByte = 24'hFFFFFE;
    localparam GFXMode = 24'hFFFFFF;

    localparam KEYREGPTR = 24'hFFFFFD;
    localparam KEYSTATUSPTR = 24'hFFFFFC;

    localparam CURSX = 24'hFFFFF9;
    localparam CURSY = 24'hFFFFF8;
    localparam CURSSTATUS = 24'hFFFFF7;

    localparam SOUND_REG_PTR0 = 24'hFFFFF0;
    localparam SOUND_REG_PTR1 = 24'hFFFFF1;
    localparam SOUND_REG_PTR2 = 24'hFFFFF2;
    localparam SOUND_REG_END_PTR0 = 24'hFFFFED;
    localparam SOUND_REG_END_PTR1 = 24'hFFFFEE;
    localparam SOUND_REG_END_PTR2 = 24'hFFFFEF;
    localparam SOUND_ACTIVE_REG = 24'hFFFFF3;
    localparam SOUND_INSTRUMENT_REG = 24'hFFFFF4;
    localparam SOUND_DURATION_REG = 24'hFFFFF5;

    localparam PORTA = 24'hFFFFFA;
    localparam PORTB = 24'hFFFFFB;

    reg [31:0]clkCnt = 0;
    reg clk = 0;

    //inout wire [7:0]portA, inout wire [7:0]portB,
    //input wire [3:0]hardInterrupt);
    wire [23:0]address;
    reg [3:0]hardInterrupt = 0;

    wire [7:0]memory[0:100];

    assign led = 4'b1111;
    
    wire [23:0]pc;
    wire [7:0]r1TestOut;
    wire [7:0]r2TestOut;
    wire [7:0]accum;
    assign data = accum;
    
    //memory[0] =
    //memory[1] = 
    /*integer i;

    initial begin
        for(i = 0; i < 65536; i = i + 1)
        begin      
            memory[i] = 8'hzz;
        end

        $readmemb("data.txt", memory);
    end*/
    
    //memory modes
    localparam [1:0]
	ADDR_MODE_RD    = 2'b00, //00 reads address lines (reading 'random' locations)
	ADDR_MODE_PC    = 2'b01, //01 reads address at pc
	ADDR_MODE_WRT   = 2'b10; //10 writes to address lines

    wire [1:0]memReadWrite;
    //wire [7:0]dataInBuff;
    reg [7:0]dataIn;
    wire [7:0]dataOut;
    wire wrt;

    //reg [7:0]colorByte;
    reg gfxMode;
    reg [7:0]keyRegPtr; //key code
    reg keyStatusPtr; //key pressed
    reg [7:0]cursX;
    reg [7:0]cursY;
    reg [7:0]cursStatus; //cursor modifiers res, res, res, blockchar, fast, slow, blinking, visible

    reg [7:0] soundRegPtr0;
    reg [7:0] soundRegPtr1;
    reg [7:0] soundRegPtr2;
    reg [7:0] soundRegEndPtr0;
    reg [7:0] soundRegEndPtr1;
    reg [7:0] soundRegEndPtr2;
    reg soundActiveReg;
    reg [7:0]soundInstrumentReg;
    reg [7:0]soundDurationReg;

    //port out buffer
    reg [7:0]portAOut;
    reg [7:0]portBOut;
    wire [7:0]portA = 0;
    wire [7:0]portB = 0;

    //assign portA = address == 24'hFFFFFA && memReadWrite == ADDR_MODE_RD ? 8'bz : portAOut;
    //assign portB = address == 24'hFFFFFB && memReadWrite == ADDR_MODE_RD ? 8'bz : portBOut;

    assign wrt = memReadWrite[1];

    assign memory[0] = 8'h03;
    assign memory[1] = 8'h01;

    assign memory[2] = 8'h01;
    assign memory[3] = 8'h04;

    assign memory[4] = 8'h03;
    assign memory[5] = 8'hb8;

    assign memory[6] = 8'h88;
    assign memory[7] = 8'h01;
    assign memory[8] = 8'h48;
    assign memory[9] = 8'h06;
    assign memory[10] = 8'h00;
    assign memory[11] = 8'h00;

    /*assign memory[6] = 8'h28;
    assign memory[7] = 8'h14;
    assign memory[8] = 8'h02;
    assign memory[9] = 8'h00;
    assign memory[10] = 8'h03;
    assign memory[11] = 8'h00;
    assign memory[12] = 8'h28;
    assign memory[13] = 8'h14;
    assign memory[14] = 8'h02;
    assign memory[15] = 8'h0;
    assign memory[16] = 8'h48;
    assign memory[17] = 8'h04;
    assign memory[18] = 8'h02;
    assign memory[19] = 8'h0;
    assign memory[20] = 8'h10;
    assign memory[21] = 8'h03;
    assign memory[22] = 8'h00;
    assign memory[23] = 8'h89;
    assign memory[24] = 8'h84;
    assign memory[25] = 8'h03;
    assign memory[26] = 8'h05;
    assign memory[27] = 8'h17;
    assign memory[28] = 8'h02;
    assign memory[29] = 8'h00;
    assign memory[30] = 8'h11;
    assign memory[31] = 8'h38;*/

    SevenSegDisp segDisp(.clk(clkIn), .rst(rst), .data2(pc[7:0]), .data1(r2TestOut), .data0(r1TestOut), .seg(seg), .disp(disp));

    always @(posedge clkIn)
    begin
        /*if(rst == 0)
        begin
            clkCnt <= 0;
            clk <= 0;
        end*/

        //else
        //begin
        clkCnt <= clkCnt + 1;

        if(clkCnt >= 32'd10_000_000)
        //if(clkCnt >= 1)
        begin
            clk <= ~clk;
            clkCnt <= 0;
        end
        //end
    end

    //assign dataInBuff = memory[address];
    always @(posedge clk)
    begin
        if(rst == 0)
        begin
            //colorByte <= 0;
            gfxMode <= 0;
            keyRegPtr <= 0; 
            keyStatusPtr <= 0;
            cursX <= 0;
            cursY <= 0;
            cursStatus <= 0;
            soundRegPtr0 <= 0;
            soundRegPtr1 <= 0;
            soundRegPtr2 <= 0;
            soundRegEndPtr0 <= 0;
            soundRegEndPtr1 <= 0;
            soundRegEndPtr2 <= 0;
            soundActiveReg <= 0;
            soundInstrumentReg <= 0;
            soundDurationReg <= 0;
        end

        else
        begin
            if(memReadWrite == ADDR_MODE_RD)
            begin
                if(address == PORTA)
                    dataIn <= portA;

                else if(address == PORTB)
                    dataIn <= portB;

                else if (address == SOUND_DURATION_REG) begin
                    // Handle SOUND_DURATION_REG
                end

                else if (address == SOUND_INSTRUMENT_REG) begin
                    // Handle SOUND_INSTRUMENT_REG
                end

                else if (address == SOUND_ACTIVE_REG) begin
                    // Handle SOUND_ACTIVE_REG
                end

                else if (address == SOUND_REG_END_PTR2) begin
                    // Handle SOUND_REG_END_PTR2
                end

                else if (address == SOUND_REG_END_PTR1) begin
                    // Handle SOUND_REG_END_PTR1
                end

                else if (address == SOUND_REG_END_PTR0) begin
                    // Handle SOUND_REG_END_PTR0
                end

                else if (address == SOUND_REG_PTR2) begin
                    // Handle SOUND_REG_PTR2
                end

                else if (address == SOUND_REG_PTR1) begin
                    // Handle SOUND_REG_PTR1
                end

                else if (address == SOUND_REG_PTR0) begin
                    // Handle SOUND_REG_PTR0
                end

                else if (address == CURSSTATUS) begin
                    // Handle CURSSTATUS
                end

                else if (address == CURSY) 
                    dataIn <= cursY;

                else if (address == CURSX) 
                    dataIn <= cursX;

                else if (address == KEYSTATUSPTR)
                    dataIn <= keyStatusPtr;

                else if (address == KEYREGPTR) 
                    dataIn <= keyRegPtr;

                else if (address == GFXMode) 
                    dataIn <= gfxMode;

                //else if (address == ColorByte) 
                    //dataIn = colorByte;

                else
                    dataIn <= memory[address];    
            end

            else if(memReadWrite == ADDR_MODE_PC)
            begin
                dataIn <= memory[address];
            end
            
            else if(memReadWrite == ADDR_MODE_WRT)
            begin
                if(address == PORTA)
                    portAOut <= dataOut;

                else if(address == PORTB)
                    portBOut <= dataOut;

                else if (address == SOUND_DURATION_REG) begin
                    // Handle SOUND_DURATION_REG
                end
                
                else if (address == SOUND_INSTRUMENT_REG) begin
                    // Handle SOUND_INSTRUMENT_REG
                end

                else if (address == SOUND_ACTIVE_REG) begin
                    // Handle SOUND_ACTIVE_REG
                end

                else if (address == SOUND_REG_END_PTR2) begin
                    // Handle SOUND_REG_END_PTR2
                end

                else if (address == SOUND_REG_END_PTR1) begin
                    // Handle SOUND_REG_END_PTR1
                end

                else if (address == SOUND_REG_END_PTR0) begin
                    // Handle SOUND_REG_END_PTR0
                end

                else if (address == SOUND_REG_PTR2) begin
                    // Handle SOUND_REG_PTR2
                end

                else if (address == SOUND_REG_PTR1) begin
                    // Handle SOUND_REG_PTR1
                end

                else if (address == SOUND_REG_PTR0) begin
                    // Handle SOUND_REG_PTR0
                end

                else if (address == CURSSTATUS) 
                    cursStatus <= dataOut;

                else if (address == CURSY)
                    cursY <= dataOut;

                else if (address == CURSX) 
                    cursX <= dataOut;

                else if (address == KEYSTATUSPTR) 
                    keyStatusPtr <= dataOut;

                else if (address == KEYREGPTR) 
                    keyRegPtr <= dataOut;

                else if (address == GFXMode) 
                    gfxMode <= dataOut;

                //else if (address == ColorByte)
                    //colorByte = dataOut;

                //else
                //    memory[address] <= dataOut;
            end
        end
    end

    Control control(.clk(clk), .rstIn(rst),
    .addrOut(address),
    .memReadWrite(memReadWrite),
    .toDataBus(dataOut),
    .dataIn(dataIn),
    .hardInterrupt(hardInterrupt),
    .r1TestOut(r1TestOut),
    .r2TestOut(r2TestOut),
    .accumTest(accum),
    .pcOut(pc));
endmodule