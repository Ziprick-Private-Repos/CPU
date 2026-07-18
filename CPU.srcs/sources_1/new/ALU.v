`timescale 1ns / 1ps
`default_nettype none

module Alu(input wire clk, input wire clkEn, input wire rst, input wire refreshState,
input wire [15:0]cycle, input wire run, output reg divDone, 
input wire [7:0]opcode, 
input wire [7:0]regA, 
input wire [7:0]regB, 
input wire [15:0]regS0,
input wire [15:0]regS1,
output reg [7:0]accumulator,
output reg [15:0]accumulatorS,
output reg [7:0]remainder,
output reg [15:0]remainderS,
output reg greaterFlag, 
output reg lessFlag,
output reg zeroFlag, 
output reg eqFlag,
output reg overflowFlag,
output reg divZero);
	reg [8:0]overflow;
	reg [15:0]cycleCnt;

	reg [7:0]quotient;
	reg [7:0]dividend;
	reg [7:0]divisor;

	reg [15:0]quotientS;
	reg [15:0]dividendS;
	reg [15:0]divisorS;
	
	always @(posedge clk)
	begin
		if(rst == 0 || refreshState)
		begin
			greaterFlag <= 0;
			lessFlag <= 0;
			zeroFlag <= 0;
			eqFlag <= 0;
			overflowFlag <= 0;
			accumulator <= 0;
			accumulatorS <= 0;
			divZero <= 0;
			overflow <= 0;	
			cycleCnt <= 0;	
			divDone <= 0;
			quotient <= 0;
			dividend <= 0;
			divisor <= 0;
			quotientS <= 0;
			dividendS <= 0;
			divisorS <= 0;
			remainder <= 0;
			remainderS <= 0;
		end

		else if(clkEn)
		begin
			if(run)
			begin
				cycleCnt <= cycle;
				dividend <= regA;
				divisor <= regB;
				divDone <= 0;
				divZero <= 0;
			end

			else if(cycleCnt > 0)
			begin
				cycleCnt <= cycleCnt - 1;
				case(opcode)
					8'b1000_0000: //or
					begin
						accumulator <= regA | regB;

						if(accumulator == 0)
							zeroFlag <= 1;
					end

					8'b1000_0001: //and
					begin
						accumulator <= regA & regB;
						
						if(accumulator == 0)
							zeroFlag <= 1;
					end

					8'b1000_0010: //shl
					begin
						accumulator <= {regA[6:0], 1'b0};
					end

					8'b1000_0011: //shr
					begin
						accumulator <= {1'b0, regA[7:1]};
					end

					8'b1000_0100: //cmp
					begin
						accumulator <= regA;
						if(regA > regB)
							greaterFlag <= 1;

						else
							greaterFlag <= 0;

						if(regA < regB)
							lessFlag <= 1;

						else
							lessFlag <= 0;
			
						if(regA == regB)
							eqFlag <= 1;

						else
							eqFlag <= 0;

						if(regA == 0)
							zeroFlag <= 1;

						else
							zeroFlag <= 0;
					end

					8'b1000_0101: //not
					begin
						accumulator <= ~regA;
						
						if(accumulator == 0)
							zeroFlag <= 1;
					end

					8'b1000_0110: //xor
					begin
						accumulator <= regA ^ regB;
						
						if(accumulator == 0)
								zeroFlag <= 1;	
					end

					8'b1000_0111: //add
					begin
						accumulator <= regA + regB;
						overflow <= regA + regB;
						overflowFlag <= overflow[8];
					end

					8'b1000_1000: //sub
					begin
						accumulator <= regA - regB;
						
						if(accumulator == 0)
							zeroFlag <= 1;
					end
		
					8'b1000_1001: //inc
					begin
						accumulator <= regA + 1'b1;
						overflow <= regA + 1;
						overflowFlag <= overflow[8];
					end
					
					8'b1000_1010: //dec
					begin
						accumulator <= regA - 1'b1;

						if(regA == 0)
							zeroFlag <= 1;
					end

					8'b1000_1011: //ROL
					begin
						accumulator <= {regA[6:0], regA[7]};
					end

					8'b1000_1100: //ROR
					begin
						accumulator <= {regA[0], regA[7:1]};
					end

					8'b1000_1101: //MUL
					begin
						accumulator <= accumulator + regA;

						overflow <= regA + regB;
						overflowFlag <= overflow[8];
						
						if(accumulator == 0)
							zeroFlag <= 1;
					end

					8'b1000_1110: //DIV
					begin
						//regA == dividend, regB == divisor
						if(divisor == 0) //div by zero
						begin
							divZero <= 1;
							divDone <= 1;
						end

						else
						begin
							if(dividend >= divisor)
							begin
								dividend <= dividend - divisor;
								quotient <= quotient + 1;
							end

							else
							begin
								divDone <= 1;
								accumulator <= quotient;
								remainder <= dividend;
							end
						end
					end

					8'b1000_1111: //addS
					begin
						accumulatorS <= regS0 + regS1;
						overflow <= regS0 + regS1;
						overflowFlag <= overflow[8];
					end

					8'b1001_0000: //subS
					begin
						accumulatorS <= regS0 - regS1;
						
						if(accumulatorS == 0)
							zeroFlag <= 1;
					end

					8'b1001_0001: //incS
					begin
						accumulatorS <= regS0 + 1'b1;
						overflow <= regS0 + 1;
						overflowFlag <= overflow[8];
					end

					8'b1001_0010: //decS
					begin
						accumulatorS <= regS0 - 1'b1;

						if(regS0 == 0)
							zeroFlag <= 1;
					end

					8'b1001_0011: //ROLS
					begin
						accumulatorS <= {regS0[14:0], regS0[15]};
					end

					8'b1001_0100: //RORS
					begin
						accumulatorS <= {regS0[0], regS0[15:1]};
					end

					8'b1001_0101: //MULS
					begin
						accumulatorS <= accumulatorS + regS0;

						overflow <= regS0 + regS1;
						overflowFlag <= overflow[8];
						
						if(accumulatorS == 0)
							zeroFlag <= 1;
					end

					8'b1001_0110: //DIVS
					begin
						//regA == dividend, regB == divisor
						if(divisor == 0) //div by zero
						begin

						end

						else
						begin
							if(dividend >= divisor)
							begin
								dividendS <= dividendS - divisorS;
								quotientS <= quotientS + 1;
							end

							else
							begin
								divDone <= 1;
								accumulatorS <= quotientS;
								remainderS <= dividendS;
							end
						end
					end

					8'b1001_0111: //CMPS
					begin
						accumulator <= regS0;
						if(regS0 > regS1)
							greaterFlag <= 1;

						else
							greaterFlag <= 0;

						if(regS0 < regS1)
							lessFlag <= 1;

						else
							lessFlag <= 0;

						if(regS0 == regS1)
							eqFlag <= 1;

						else
							eqFlag <= 0;

						if(regS0 == 0)
							zeroFlag <= 1;
					end
				endcase
			end	
		end
	end

	/*always @*
	begin
		greaterFlag = 0;
		zeroFlag = 0;
        eqFlag = 0;
		overflowFlag = 0;
		accumulator = 0;
		divZero = 0;
		overflow = 0;

		case(opcode)
			4'b0000: //or
			begin
				accumulator = regA | regB;
				
				if(accumulator == 0)
					zeroFlag = 1;
			end

			4'b0001: //and
			begin
				accumulator = regA & regB;
				
				if(accumulator == 0)
					zeroFlag = 1;
			end

			4'b0010: //shl
			begin
				accumulator = {regA[6:0], 1'b0};
			end

			4'b0011: //shr
			begin
				accumulator = {1'b0, regA[7:1]};
			end

			4'b0100: //cmp
			begin
				accumulator = regA;
				if(regA > regB)
					greaterFlag = 1;
      
            	else if(regA == regB)
					eqFlag = 1;

				if(regA == 0)
					zeroFlag = 1;
			end

			4'b0101: //not
			begin
				accumulator = ~regA;
				
				if(accumulator == 0)
					zeroFlag = 1;
			end

			4'b0110: //xor
			begin
				accumulator = ((regA | regB) & (~regA | ~regB));
				
				if(accumulator == 0)
						zeroFlag = 1;	
			end

			4'b0111: //add
			begin
				accumulator = regA + regB;
                overflow = regA + regB;
                overflowFlag = overflow[8];
			end

			4'b1000: //sub
			begin
				accumulator = regA - regB;
				
				if(accumulator == 0)
					zeroFlag = 1;
			end
   
            4'b1001: //inc
            begin
                accumulator = regA + 1'b1;
                overflow = regA + 1;
                overflowFlag = overflow[8];
            end
            
            4'b1010: //dec
            begin
                accumulator = regA - 1'b1;

				if(regA == 0)
					zeroFlag = 1;
            end

			4'b1011: //ROL
			begin
				accumulator = {regA[6:0], regA[7]};
			end

			4'b1100: //ROR
			begin
				accumulator = {regA[0], regA[7:1]};
			end

			4'b1101: //MUL
			begin
				//accumulator = regA - regB;
				
				if(accumulator == 0)
					zeroFlag = 1;
			end

			default:
			begin
				zeroFlag = 0;
				overflowFlag = 0;
                eqFlag = 0;
				accumulator = 8'b0;
			end
		endcase
	end*/
endmodule