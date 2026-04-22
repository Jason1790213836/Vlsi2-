
module counter #(parameter length=10)
	(	
		input logic[length-1:0]d_in,
		input logic clk,
		input logic ld,
		input logic u_d,
		input logic cen,
		output logic [length-1:0]q,
		output logic cout
	);
	always@(posedge clk)begin
		if(cen)begin
			if(ld) 
				q<=d_in;
			else if (u_d)begin
				q<=q+1'b1;
			end else begin
				q<=q-1'b1;
			end

		end
	end
	always_comb begin
		cout=1'b0;
                
		if(cen&&!ld)begin
			if(u_d&&(q=={length{1'b1}}))begin
				cout=1'b1;
			end else if((!u_d)&&(q=={length{1'b0}}))begin
				cout=1'b1;
			end
		end
	end
endmodule
