`timescale 1ns / 1ps
`default_nettype none

module Register(input wire clk, input wire clkEn, input wire rst, input wire [7:0]dataIn, output reg [7:0]dataOut, input wire en);
	reg [7:0]data;
	
	always @(posedge clk)
	begin
		if(rst == 0)
		begin
			data <= 0;
		end
		
		else if(clkEn)
		begin
			if(en)
				data <= dataIn;
				
			dataOut <= data;
		end
	end
endmodule
