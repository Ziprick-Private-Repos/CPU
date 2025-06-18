`timescale 1ns / 1ps
`default_nettype none

module Register(input wire clk, input wire rst, input wire [7:0]dataIn, output reg [7:0]dataOut, input wire en);
	reg [7:0]data;
	
	always @(posedge clk, posedge rst)
	begin
		if(rst)
		begin
			data <= 0;
		end
		
		else
		begin
			if(en)
				data <= dataIn;
				
			dataOut <= data;
		end
	end
endmodule
