 module line_drawing_datapath (
	clk,
	swap,
	reset,
	X, Y,
	ld, ld_err,
	ld_y, ld_delta_x,
	ld_delta_y, ld_y_step,
	update_x0_y0,
	);
	
	/* Input signals from the control */
	input clk, swap, reset, ld_err, ld_y, ld_delta_x, ld_delta_y, ld_y_step;
	
	/* Input from the H/W*/
	input [8 : 0] X;
	input [7 : 0] Y;

	/* Output Combinational signals*/
	output reg x_lte_x1, y0 < y1

	/* Registers / local variables */
	reg [8 : 0] x0, x1, delta_x, error, x;
	reg [7 : 0] y0, y1, y, delta_y;
	reg signed [7 : 0] y_step;

	always @(posedge clk or posedge reset) begin
		if (reset) 
			x0 <= 9'b0;
			x1 <= 9'b0;
			y0 <= 8'b0;
			y1 <= 8'b0;
		else if (swap_1) begin
			// need to truncate a bit 
			x0 <= {0, y0};
			y0 <= x0;
			x1 <= {0, y1};
			y1 <= x1;
		end
		else if (swap_2) begin	
			x0 <= x1;
			x1 <= x0;
			y0 <= y1;
			y1 <= y0;
		end
		else if (ld) begin
			x0 <= 9'b0;
			y0 <= 8'b0;
			x1 <= X;
			y1 <= Y;
		end
		else if (update_x0_y0) begin
			x0 <= x1;
			y0 <= y1;
		end
		/* preserve values if no signal is asserted */
		else 
			x0 <= x0;
			x1 <= x1;
			y0 <= y0;
			y1 <= y1;
	end

	/* delta x*/
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			delta_x <= 9'b0;
		end
		else if(ld_delta_x) begin
			delta_x <= (x1 - x0);
		end
		else 
			delta_x <= delta_x;
	end

	/* ld_delta_y can be combined with ld_delta_x */
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			delta_y <= 8'b0;
		end
		else if (ld_delta_y) begin
			delta_y <= ((y1 - y0) >= 0) ? (y1 - y0) : (y0 - y1);
		end
		else 
			delta_y <= delta_y;
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			error <= 9'b0;
		end
		else if (ld_err) begin
			error <= -((delta_x) >> 1); // timing issue?
		end
		else if (decr_err) begin
			error <= error - delta_x;
		end
		else 
			error <= error;
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			y <= 8'b0;
		end
		else if (ld_y) begin
			y <= y0;
		end
		else if (incr_y) begin
			y <= y + y_step;
		end
		else 
			y <= y;
	end

	/* y_step */
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			y_step <= 8'b0;
		end
		else if (ld_y_step) begin
			y_step <= (y0 >= y1) ? 8'b1111_1111: 8'b00000001;		
		end
		else 
			y_step <= y_step;
	end

	/* x */
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			x <= 9'b0;
		end
		else if (ld_x) begin
			x <= x0;
		end
		else if (incr_x) begin
			x <= x + 1;
		end
		else begin
			x <= x;
		end
	end

	always @ (*) begin
		
	end

endmodule