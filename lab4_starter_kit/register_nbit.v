module register_nbit (clk, ld, Din, reset, Dout);
	parameter SIZE = 9; // x input is 9 bits, y input is 8 bits
	input clk, ld, reset;
	input [SIZE - 1 : 0] Din;
	output reg [SIZE - 1 : 0] Dout;
	always @(posedge clk or posedge reset) begin
		if (rst) begin
			Dout <= (SIZE)'b0;
		end
		else if (ld) begin
			Dout <= Din;
		end
		else begin
			Dout <= Dout;
		end
	end
	
endmodule
