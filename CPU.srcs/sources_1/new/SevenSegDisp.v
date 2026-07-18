/*`timescale 1ns / 1ps
`default_nettype none

module SevenSegDisp(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  data0,
    input  wire [7:0]  data1,
    input  wire [7:0]  data2,
    output reg  [7:0]  seg,
    output reg  [5:0]  disp
);

    reg [7:0] clkCnt = 0;
    reg clkOut = 0;

    localparam MAX_DISP = 3'd5;
    reg [3:0] currDisp;

    // ------------------------------------------------------------
    // Segment mirror function (180° rotation)
    // Bit order: {DP, G, F, E, D, C, B, A}
    // ------------------------------------------------------------
    function automatic [7:0] mirror_seg;
        input [7:0] s;
        begin
            mirror_seg = {
                s[7],  // DP
                s[6],  // G
                s[2],  // F <- C
                s[1],  // E <- B
                s[0],  // D <- A
                s[5],  // C <- F
                s[4],  // B <- E
                s[3]   // A <- D
            };
        end
    endfunction

    // Reverse display index
    wire [2:0] disp_idx = MAX_DISP - currDisp;

    // ------------------------------------------------------------
    // Clock divider
    // ------------------------------------------------------------
    always @(posedge clk) 
    begin
        if (!rst) 
        begin
            clkOut <= 0;
            clkCnt <= 0;
        end 

        else 
        begin
            clkCnt <= clkCnt + 1;
            if (clkCnt >= 8'd255) 
            begin
                clkCnt <= 0;
                clkOut <= ~clkOut;
            end
        end
    end

    // ------------------------------------------------------------
    // Display scanning + data
    // ------------------------------------------------------------
    always @(posedge clkOut) 
    begin
        if (!rst) 
        begin
            currDisp <= 0;
            disp     <= 6'b111_111;
            seg      <= 8'b1111_1111;
        end 
        
        else 
        begin
            if (currDisp >= MAX_DISP)
                currDisp <= 0;
            else
                currDisp <= currDisp + 1;

            // -------- reversed digit enable --------
            case (disp_idx)
                0: disp <= 6'b111_110;
                1: disp <= 6'b111_101;
                2: disp <= 6'b111_011;
                3: disp <= 6'b110_111;
                4: disp <= 6'b101_111;
                5: disp <= 6'b011_111;
            endcase

            // -------- reversed data mapping --------
            case (disp_idx)
                0: seg <= mirror_seg(seg_decode(data2[7:4]));
                1: seg <= mirror_seg(seg_decode(data2[3:0]));
                2: seg <= mirror_seg(seg_decode(data1[7:4]));
                3: seg <= mirror_seg(seg_decode(data1[3:0]));
                4: seg <= mirror_seg(seg_decode(data0[7:4]));
                5: seg <= mirror_seg(seg_decode(data0[3:0]));
                default: seg <= 8'b1111_1111;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Hex digit to segment decoder (active low)
    // ------------------------------------------------------------
    function automatic [7:0] seg_decode;
        input [3:0] v;
        begin
            case (v)
                4'd0:  seg_decode = 8'b1100_0000;
                4'd1:  seg_decode = 8'b1111_1001;
                4'd2:  seg_decode = 8'b1010_0100;
                4'd3:  seg_decode = 8'b1011_0000;
                4'd4:  seg_decode = 8'b1001_1001;
                4'd5:  seg_decode = 8'b1001_0010;
                4'd6:  seg_decode = 8'b1000_0010;
                4'd7:  seg_decode = 8'b1111_1000;
                4'd8:  seg_decode = 8'b1000_0000;
                4'd9:  seg_decode = 8'b1001_0000;
                4'd10: seg_decode = 8'b1000_1000; // A
                4'd11: seg_decode = 8'b1000_0011; // b
                4'd12: seg_decode = 8'b1100_0110; // C
                4'd13: seg_decode = 8'b1010_0001; // d
                4'd14: seg_decode = 8'b1000_0110; // E
                4'd15: seg_decode = 8'b1000_1110; // F
                default: seg_decode = 8'b1111_1111;
            endcase
        end
    endfunction

endmodule*/


`timescale 1ns / 1ps
`default_nettype none

module SevenSegDisp(input wire clk, input wire rst, input wire [7:0]data0, input wire [7:0]data1, input wire [7:0]data2,
output reg [7:0]seg, output reg [5:0]disp);
    
    reg [7:0]clkCnt = 0;
    reg clkOut = 0;
    
    localparam MAX_DISP = 3'd5;

    reg [3:0]currDisp;

    always @(posedge clk)
    begin
        if(rst == 0)
        begin
            clkOut <= 0;
            clkCnt <= 0;
        end

        else
        begin
            clkCnt <= clkCnt + 1;

            if(clkCnt >= 255)
            begin
                clkCnt <= 0;
                clkOut <= ~clkOut;
            end
        end
    end

    always @(posedge clkOut)
    begin
        if(rst == 0)
        begin
            currDisp <= 0;
            disp <= 6'b111_111;
            seg <= 8'b1111_1111; 
        end

        else
        begin
            if(currDisp >= MAX_DISP)
                currDisp <= 0;

            else
                currDisp <= currDisp + 1;

            case(currDisp)
                0:
                begin
                    disp <= 6'b111_110;
                end

                1:
                begin
                    disp <= 6'b111_101;
                end

                2:
                begin
                    disp <= 6'b111_011;
                end

                3:
                begin
                    disp <= 6'b110_111;
                end

                4:
                begin
                    disp <= 6'b101_111;
                end

                5:
                begin
                    disp <= 6'b011_111;
                end
            endcase;
            
            if(currDisp == 0)
            begin
                case (data0[3:0])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end

            else if(currDisp == 1)
            begin
                case (data0[7:4])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end

            if(currDisp == 2)
            begin
                case (data1[3:0])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end

            else if(currDisp == 3)
            begin
                case (data1[7:4])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end

            if(currDisp == 4)
            begin
                case (data2[3:0])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end

            else if(currDisp == 5)
            begin
                case (data2[7:4])
                    4'd0:  seg <= 8'b1100_0000;
                    4'd1:  seg <= 8'b1111_1001;
                    4'd2:  seg <= 8'b1010_0100;
                    4'd3:  seg <= 8'b1011_0000;
                    4'd4:  seg <= 8'b1001_1001;
                    4'd5:  seg <= 8'b1001_0010;
                    4'd6:  seg <= 8'b1000_0010;
                    4'd7:  seg <= 8'b1111_1000;
                    4'd8:  seg <= 8'b1000_0000;
                    4'd9:  seg <= 8'b1001_0000;
                    4'd10: seg <= 8'b1000_1000; // A
                    4'd11: seg <= 8'b1000_0011; // b
                    4'd12: seg <= 8'b1100_0110; // C
                    4'd13: seg <= 8'b1010_0001; // d
                    4'd14: seg <= 8'b1000_0110; // E
                    4'd15: seg <= 8'b1000_1110; // F
                    default: seg <= 8'b1111_1111; // all off on invalid
                endcase
            end
        end
    end
endmodule