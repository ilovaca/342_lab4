module line_drawing_datapath (
	clk,
	swap,
	reset,
	X, Y
	);
	
	input clk, swap, reset;
	input [8 : 0] X;
	input [7 : 0] Y;

	// register_nbit #(.SIZE(9)) x0 ();
	// register_nbit #(.SIZE(9)) x1 ();
	// register_nbit #(.SIZE(8)) y0 ();
	// register_nbit #(.SIZE(8)) y1 ();
	
	// register_nbit #(.SIZE(9)) delta_x ();
	// register_nbit #(.SIZE(8)) delta_y ();
	// register_nbit #(.SIZE(9)) error ();

	/* x, y coordinates */
	reg [8 : 0] x0, x1, delta_x, error;
	reg [7 : 0] y0, y1, y, delta_y, y_step;

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
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			y <= 8'b0;
		end
		else if (ld_y) begin
			y <= y0;
		end
		else 
			y <= y;
	end

	/* */
	always @(posedge clk or posedge rst) begin
		if (reset) begin
			
		end
		else if () begin
			
		end
	end
endmodule