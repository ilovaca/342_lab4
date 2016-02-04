/* Module that outputs the absolute value of an input */
/* Note: the input is signed, and output is unsigned */

module abs_unit(A, abs_out);
	parameter SIZE = 8;
	input signed [SIZE - 1 : 0] A;
	output reg unsigned [SIZE - 1 : 0] abs_out;

	always @ (*) begin
		if (A < 0) abs_out = - (A);
		else abs_out = A;
	end

endmodule