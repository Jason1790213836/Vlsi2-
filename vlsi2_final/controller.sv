module controller(
		input logic start,
		input logic rsr,
		input logic clk,
		input logic cout,
		output logic NbarT,
		output logic ld	
);
	typedef enum logic{
		RESET,
		TEST
	}state_t;
 	state_t state,next_state;
	always_ff@(posedge clk)begin
		if(rst)begin
			state<=RESET;
		end else begin
			state<=next_state;
		end
	end
	always_comb begin
		next_state=state;

		case(state)
		  RESET:begin
		     if(start)next_state=TEST;
		     else next_state=RESET;
		  end
		  TEST:begin
		     if(cout)next_state=RESET;
		     else next_state=TEST;
		  end
	  	  default:next_state=RESET;
		endcase
	end
	always_comb begin
		ld=1'b0;
		NbarT=1'b0;
		if(state==RESET)begin
			ld=1'b1;
			NbarT=1'b0;
		end else if (state==TEST)begin
			ld=1'b0;
			NbarT=1'b1;
		end
		

	end


endmodule
