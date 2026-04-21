module decoder(
	input logic[2:0]q,
	output logic [7:0]data_t
)
 	always_comb begin
		case(q)
			3'b000:begin
				data_t=8'b10101010;
			end
			3'b001:begin
				data_t=8'b01010101;
			end
			3'b010:begin
				data_t=8'b11110000;
			end
			3'b011:begin
				data_t=8'b00001111;
			end
			3'b100:begin
				data_t=8'b00000000;
			end
			3'b101:begin
				data_t=8'b11111111;
			end
			default:begin
				data_t=8'bxxxxxxxx;
			end
		endcase
	end

endmodule
