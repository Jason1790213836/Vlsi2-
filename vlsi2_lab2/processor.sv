module mux32(


	input logic [31:0] a,
	input logic [31:0] b,
	input logic sel,
	output logic [31:0] y
);


	always_comb begin
		if(sel)begin
			y=a;
		end else y=b;

	end



endmodule

module status_reg(
input logic clk,
input logic rstN, // active low reset
input logic int_en,
input logic zero,
input logic carry,
input logic neg,
input logic [1:0] parity,
output logic [7:0] status
);

always_ff @(posedge clk) begin
    if (!rstN)
        status <= 8'b0;
    else
        status <= {int_en, 2'b11, zero, carry, neg, parity};
end	

endmodule

module Pri_En(
input logic [7:0] D,
output logic [2:0] Q
);

always_comb begin

	casez(D)
		8'b1???????:Q=3'b111;
		8'b01??????:Q=3'b110;
		8'b001?????:Q=3'b101;
		8'b0001????:Q=3'b100;
		8'b00001???:Q=3'b011;
		8'b000001??:Q=3'b010;
		8'b0000001?:Q=3'b001;
		8'b00000001:Q=3'b000;
		default:Q=3'b000;

	endcase
end



endmodule

module processor(
input logic clk, // clock
input logic rstN, // active low reset signal
input logic [31:0] data_in,
input logic [31:0] i_data,
input logic data_select,
input logic [15:0] status_flags,
output logic [31:0] data_out,
output logic [ 7:0] status,
output logic [ 2:0] Q
);

	mux32 u1(
		.a(data_in),
		.b(i_data),
		.sel(data_select),
		.y(data_out)
	);

	status_reg u2(
		.rstN(rstN),
	        .clk(clk),
		.int_en(status_flags[7]),
	       	.zero(status_flags[4]),
 		.carry(status_flags[3]),
 		.neg(status_flags[2]),
	        .parity(status_flags[1:0]),
	        .status(status)
	);
	
	Pri_En u3(
		.D(status_flags[15:8]),
		.Q(Q)
	);



endmodule
