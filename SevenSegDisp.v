`timescale 1ns / 1ps
`default_nettype none

module SevenSegDisp(input wire clk, input wire rst, input wire [7:0]data);
    
    localparam MAX_DISP = 3'd1;

    reg [7:0]seg;
    reg [5:0]disp;

    reg [3:0]currDisp;
    always @(posedge clk)
    begin
        if(rst == 0)
        begin
            currDisp <= 0;
            disp <= 6'b111_111;
            seg <= 8'b1111_1111; 
        end

        else
        begin
            currDisp <= currDisp + 1;

            if(currDisp >= MAX_DISP)
                currDisp <= 0;

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
                case (data[3:0])
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
                case (data[7:4])
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