`timescale 1ns/1ps

module mux_tb();
// Declare input variables. These are values you set to control the input to the mux
logic en;
logic sel;
logic [3:0] D0;
logic [3:0] D1;
// Declare the output variable. This is the output you should check matches the expected value
// based on the specification.
logic [3:0] Y;

// Declare the design under test (DUT) and connect the inputs/outputs.
// Because each variable declared above matches the ports, we can use a wildcard connection.
mux DUT(.*);

initial begin
// Write your test sequence here
	$display("start the test");
	$display("--------------------");

	for(int i=0;i<4;i++)begin
		en=i[0];
		sel=i[1];
		D0=4'b1010;
		D1=4'b0010;

		#4;
		$display("en=%b sel=%b D0=%b D1=%b | Y=%b", en, sel, D0, D1, Y );

		if(Y==D0)begin
			if(en!=0 && sel==0)begin
				$display("case passed ");
			end else begin 
				$display("@@@FAIL");
				$finish;
				end
		end else if (Y==D1)begin
			if(en!=0 && sel==1)begin
				$display("case passed");
			end else begin 
				$display("@@@FAIL");
				$finish;
			end
		end	else if(Y==4'b0000) begin

			if(en==0)begin
                                $display("case passed");
				
			end else begin
			       	$display("@@@FAIL");
				$finish;
			end
		end else begin
				$display("@@@FAIL");
				$finish;
		end
	


	end

	

	$display("@@@PASS");
	$finish;


end

endmodule
