
module comparator(input logic [7:0]data_t,
		  input logic [7:0]ramout,
		  output logic gt,
		  output logic eq,
		  output logic lt
	  )
	  always_comb begin
		  gt=1'b0;
		  eq=1'b0;
		  lt=1'b0;

		  if(data_t>ramout)begin
			  gt=1'b1;
		  end else if(data==ranout)begin
			  eq=1'b1;
		  end else if(data<ranout)begin
			  lt=1'b1;
		  end
	  end
endmodule
