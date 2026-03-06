`include "fsm_pkg.svh"
import fsm10_pkg::*;

module fsm(
    input  logic   rst_n,   // asynchronous active-low reset
    input  logic   clk,
    input  logic   jmp,
    input  logic   go,
    output logic   y,
    output state_e state
);
    state_e next_state;
    assign y=(state==S3);
    // Moore output: y depends only on state (y=1 only in S3)
    always_comb begin

	next_state=state;

	case(state)
	      S0:begin
			if(!go)begin
				next_state=S0;
			end else if(go&&!jmp)begin
				next_state=S1;
			end else if (go&&jmp)begin
				next_state=S3;
			end
		end
             S1: begin
                if (!jmp) next_state = S2;
                else      next_state = S3;
            end

            S2: begin
                next_state = S3;
            end

            S3: begin
                if (!jmp) next_state = S4;
                else      next_state = S3;
            end

            S4: begin
                if (!jmp) next_state = S5;
                else      next_state = S3;
            end

            S5: begin
                if (!jmp) next_state = S6;
                else      next_state = S3;
            end

            S6: begin
                if (!jmp) next_state = S7;
                else      next_state = S3;
            end

            S7: begin
                if (!jmp) next_state = S8;
                else      next_state = S3;
            end

            S8: begin
                if (!jmp) next_state = S9;
                else      next_state = S3;
            end

            S9: begin
                if (!jmp) next_state = S0;
                else      next_state = S3;
            end

            default: begin
                next_state = S0;
            end
	endcase
    end
    always_ff @(posedge clk or negedge rst_n) begin
	    if(!rst_n)begin
                 state<=S0;
	    end else begin
		    state<=next_state;
	 end
    end

endmodule
