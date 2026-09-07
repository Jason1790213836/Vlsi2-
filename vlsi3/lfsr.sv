`timescale 1ns/1ps
module lfsr (
input logic clk,
input logic reset, // active-high synchronous reset
input logic load, // load seed into LFSR
input logic enable, // enable LFSR shift
input logic [6:0] seed, // 7-bit seed value
output logic [6:0] lfsr_out // current LFSR state
);


    always_ff@(posedge clk)begin
        if(reset)begin
                lfsr_out<=7'b1111111;
        end
        else if(load)begin
                lfsr_out<=seed;
        end
	else if(enable)begin
   	lfsr_out <= {
            lfsr_out[5:0],
            lfsr_out[6] ^ lfsr_out[5]
        };
    	end
    end

endmodule
