module UI_FSM (input reset, clk, Done, GO , output ld_initial, start);
	parameter [1 : 0] S0 = 2'b00, WAIT = 2'b01, Done = 2'b10;
	reg [1 : 0] ps, ns;

	always @ (*) begin
		case (ps)
			S0: if (GO) ns = WAIT; else ns = S0; 
			WAIT: if (Done) ns = Done; else ns = WAIT;
			Done: if (GO) ns = Done; else ns = ;
			default: ns = 2'bxx;
		endcase
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			Done <= 
		end
		else if () begin
			
		end
	end
endmodule