`default_nettype none

module Debounce(input wire clk, input wire rst, input wire btn, output reg debBtn);
	reg [31:0]debCnt;
	
	`ifdef SYNTHESIS
	localparam MAX_CNT = 20'd1_000_000;
	`else
	localparam MAX_CNT = 20'd10;
	`endif
	
	reg [2:0]state;
	localparam IDLE			= 3'b000;
	localparam PRESS 		= 3'b001;
	localparam RELEASE		= 3'b010;
	localparam HOLD			= 3'b011;
	
	always @(posedge clk)
	begin
		if(rst == 0)
		begin
			debCnt <= 0;
			debBtn <= 1;
			state <= IDLE;
		end
		
		else
		begin			
			case(state)
				IDLE:
				begin
					debBtn <= 1;
					debCnt <= 0;
					
					if(btn == 0)
						state <= PRESS;
				end
				
				PRESS:
				begin
					if(btn == 1)
						state <= IDLE;
					
					else if(btn == 0 && debCnt >= MAX_CNT)
						state <= HOLD;

					debCnt <= debCnt + 1;
				end
				
				HOLD:
				begin
					debBtn <= 0;
					
					if(btn == 1)
						state <= IDLE;
				end
			endcase
		end
	end
endmodule