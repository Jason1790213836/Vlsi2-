`include ”fsm˙pkg.svh”
import fsm10˙pkg::*;
module fsm(
input logic rst˙n, // asynchronous active-low reset
input logic clk,
input logic jmp,
input logic go,
output logic y,
output state˙e state
);

	always_ff@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state<=state.S0;
			y<=0;
		end
		case(state)
			state.S0:begin
				 if(!go)begin
					state<=state.S0;
					y<=0;
				 end else if (go==1&&!jmp)begin
					state<=state.S1;
					y<=0;
				 end else if (go==1&&jmp)begin
					state<=state.S3;
					y<=1;
				 end
			end
                        state.S1:begin
                          	 if (!jmp)begin
                                        state<=state.S2;
                                        y<=0;
                                 end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                 end
                        end
                        state.S2:begin
                              
                                        state<=state.S3;
                                        y<=1;
                          
                        end
                        state.S3:begin
                                if (!jmp)begin
                                        state<=state.S4;
                                        y<=0;

                        end
                        state.S4:begin
                                if (!jmp)begin
                                        state<=state.S5;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
                        state.S5:begin
                                if (!jmp)begin
                                        state<=state.S6;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
                        state.S6:begin
                                if (!jmp)begin
                                        state<=state.S7;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
                        state.S7:begin
                               if (!jmp)begin
                                        state<=state.S8;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
                        state.S8:begin
                       		if (!jmp)begin
                                        state<=state.S9;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
                        state.S9:begin
                                if (!jmp)begin
                                        state<=state.S0;
                                        y<=0;
                                end else if (jmp)begin
                                        state<=state.S3;
                                        y<=1;
                                end
                        end
			default: begin stat3<=0; 
					y<=0
				 end

		endcase

	end
// Implement the design
endmodule
