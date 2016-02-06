 module line_drawing_datapath (
	clk,
	reset,
	X, 
	Y,
	ld_initial, 
	ld_steep
	swap_1,
	swap_2,
	ld_delta_x,
	ld_delta_y, 
	ld_y, 
	ld_y_step,
	ld_err_1,
	ld_x,
	plot_EN,
	incr_err,
	incr_y,
	decr_err,
	incr_x,
	update_x0_y0,
	/* outputs */
	x_lte_x1,
	Done,
	);
	
	/* Input signals from the control FSM */
	input clk, swap_1, swap_2, reset, ld_err, ld_y, ld_delta_x, ld_delta_y, ld_y_step, plot_EN;
	
	/* Input from the Switches */
	input [8 : 0] X;
	input [7 : 0] Y;

	/* Output signals to FSM */
	output reg x_lte_x1;

	/* Outputs to vga_adapter */
	output reg vga_x, vga_y, plot_EN;
	/* Registers / local variables */
	reg [8 : 0] x0, x1, delta_x, error, x;
	reg [7 : 0] y0, y1, y, delta_y;
	reg signed [7 : 0] y_step;
	reg steep;

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
		else if (ld_initial) begin
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

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			steep <= 0;
		end
		else if (ld_steep) begin
			steep <= (( (y1 - y0) >= 0 ? y1 - y0: y0 - y1) > ((x1 - x0) ? x1 - x0 : x0 - x1));
		end
		else 
			steep <= steep;
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
		else if (incr_err) begin
			error <= error + delta_y;
		end
		else if (error > 0 && decr_err) begin
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
		else if (incr_y && (error > 0)) begin
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
			y_step <= (y0 >= y1) ? 8'b1111_1111: 8'b0000_0001;		
		end
		else 
			y_step <= y_step;
	end

	/* register x : the iteration variable */
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

	/* input to the vga adapter*/
	always @ (*) begin
		if (steep) begin
			vga_x = y;
			vga_y = x;
		end
		else begin
			vga_x = x;
			vga_y = y;
		end
	end

	/* Output signals to the FSM */
	always @ (*) begin
		x_lte_x1 = (x <= x1);

	end
endmodule