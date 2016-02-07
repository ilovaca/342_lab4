module line_drawing_FSM (
	clk, 
	start,
	reset,
	/* Inputs from the datapath */
	x_lte_x1,
	Done,
	/* Outputs to datapath */
	ld_initial, 
	ld_steep,
	swap_1,
	swap_2,
	ld_delta_x,
	ld_delta_y, 
	ld_y, 
	ld_y_step,
	ld_err,
	ld_x,
	plot_EN,
	incr_err,
	incr_y,
	decr_err,
	incr_x,
	update_x0_y0);

	
	input reset, clk, start, x_lte_x1, Done;
	output 	ld_initial, ld_steep, swap_1, swap_2, ld_delta_x, ld_delta_y,
			ld_y, ld_y_step, ld_err, ld_x, plot_EN, incr_err, incr_y, decr_err,
			incr_x, update_x0_y0;

	/* state encoding */
	parameter [3 : 0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, 
					S4 = 4'b0100, LOOP = 4'b0101, S5 = 4'b0110, S6 = 4'b0111, SD = 4'b1000;
	/* state registers */
	reg [3 : 0] ps, ns;

	/* next state logic */
	always @ (*)  begin
		case (ps)
			S0: if (start) ns = S0; else ns = S1;
			S1: ns = S2;
			S2: ns = S3;
			S3: ns = S4;
			S4: if (x_lte_x1) ns = LOOP; else ns = SD;
			S5: ns = S6;
			S6: ns = LOOP;
			SD: ns = S0;
		endcase
	end

	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			ns <= S0;			
		end
		else  begin
			ps <= ns;
		end
	end

	assign ld_steep = (ps == S0);
	assign swap_1 = (ps == S1);
	assign swap_2 = (ps == S2);
	assign ld_delta_x = (ps == S3);
	assign ld_delta_y = (ps == S3);
	assign ld_y = (ps == S3);
	assign ld_y_step = (ps == S3);
	assign ld_err = (ps == S4);
	assign ld_x = (ps == S4);
	assign Done = (ps == SD);
	assign update_x0_y0 = (ps == SD);
	assign plot_EN = (ps == LOOP);
	assign incr_err = (ps == LOOP);
	assign incr_y = (ps == S5);
	assign decr_err = (ps == S5);
	assign incr_x = (ps == S6);


endmodule 