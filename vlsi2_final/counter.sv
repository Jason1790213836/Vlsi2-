
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
	if (!cen)
            cout = 1'b0;
        else if (ld)
            cout = 1'b0;
        else if (u_d && (q == {length{1'b1}}))
            cout = 1'b1;   // up count overflow
        else if (!u_d && (q == {length{1'b0}}))
            cout = 1'b1;   // down count underflow
        else
            cout = 1'b0;
	end
endmodule
