module tb_decoder;
	logic [2:0]q;
	logic [7:0]data_t;
	decoder dut(
		.q(q),
		.data_t(data_t)
	);

	task check_dec(
		input [2:0]sel,
		input [7:0]exp
	);
	begin
		q=sel;
		#1;
		if(data_t!==exp)begin
			$display("@@@FAIL");
			$finish();
			end
		end
	endtask

	initial begin
		check_dec(3'b000, 8'b10101010);
        	check_dec(3'b001, 8'b01010101);
        	check_dec(3'b010, 8'b11110000);
        	check_dec(3'b011, 8'b00001111);
        	check_dec(3'b100, 8'b00000000);
       		check_dec(3'b101, 8'b11111111);
		
		q = 3'b110;
       		#1;
        	if (data_t !== 8'bxxxxxxxx) begin
            		$display("@@@FAIL");
            		$finish();
        	end

        	q = 3'b111;
        	#1;
        	if (data_t !== 8'bxxxxxxxx) begin
            	   $display("@@@FAIL");
            	   $finish();
        	end

        	$display("@@@PASS");
        	$finish();
    end
endmodule
