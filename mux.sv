`timescale 1ns/1ps

module mux(

	input logic en,
	input logic [3:0] D0,
	input logic [3:0] D1,
	input logic sel,
	output logic [3:0] Y

);

	always_comb begin
	if(en)begin
		
		if(sel)begin
			Y=D1;
		end else begin
			Y=D0;
		end
	end else Y=4'b0000;
	end


endmodule
