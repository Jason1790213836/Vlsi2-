module processor_tb();

  // -------------------------
  // DUT ports
  // -------------------------
  logic        clk;
  logic        rstN;
  logic [31:0] data_in;
  logic [31:0] i_data;
  logic        data_select;
  logic [15:0] status_flags;

  logic [31:0] data_out;
  logic [ 7:0] status;
  logic [ 2:0] Q;
  //clk initial
  initial clk=0;
  always #5 clk=~clk;//5ns fanzhuan 

  //
  processor dut(
  	.clk(clk),
	.rstN(rstN),
	.data_in(data_in),
	.i_data(i_data),
	.data_select(data_select),
	.status_flags(status_flags),
	.data_out(data_out),
	.status(status),
	.Q(Q)
  );

	task automatic fail(string msg);
		$display("@@@FAIL");
		$display("FAIL:%s",msg);
		$finish;
	endtask

  initial begin

	  rstN=0;
	  data_in=32'h0;
 	  i_data=32'h0;
	  data_select=1'b0;
	  status_flags=16'h0;
	  #1;

	  repeat(2) @(posedge clk);
	  #1;
	  if(Q!==3'b0) fail("cant initial");
	  if(data_out!==32'h00000000)fail("cant initialize");
	  if(status!==8'h00)fail("cant initialize");

	  rstN=1;
	  @(posedge clk);
	  #1;


	data_in=32'h11110000;
	i_data=32'h10101000;
	data_select=1'b1;
	 #1;

	if(data_out!==data_in)begin
		$display("@@@FAIL");
		$finish;
	end

	data_select=1'b0;
	#1;	
	if(data_out!==i_data)begin
                $display("@@@FAIL");
		$finish;
        end

	rstN=1;
	#1;
	status_flags=16'h0;
	status_flags[7]=1'b1;
	status_flags[4]=1'b0;
	status_flags[3]=1'b1;
	status_flags[2]=1'b0;
	status_flags[1:0]=2'b10;
	#1;
	@(posedge clk);
	#1;

	if(status!=={status_flags[7],2'b11,status_flags[4],status_flags[3],status_flags[2],status_flags[1:0]}) fail("the register is not good");

	#2;
	status_flags[15:8]=8'b00101010;
	#1;
        if(Q!==3'd5)fail("sth wrong with pri_en");

	$display("@@@PASS");
	$finish;
  end
endmodule
