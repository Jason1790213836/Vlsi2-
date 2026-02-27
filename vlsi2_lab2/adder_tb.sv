
module adder_tb;
	logic [15:0]a;
	logic [15:0]b;
	logic cout;
	logic cin;
	logic [15:0]s;
	logic [16:0]exp;

	rtl_16bit_adder dut(
		.cin(cin),
		.cout(cout),
		.s(s),
		.a(a),
		.b(b)

	);

	task automatic check_vec(input logic [15:0] aa,
				 input logic [15:0] bb,
				 input logic        cc);
	begin
		a=aa;
		b=bb;
		cin=cc;
		#1;
		exp={1'b0,aa}+{1'b0,bb}+cc;
		if({cout,s}!=exp)begin
		$display("@@@FAIL");
		$display("exp=%h,mismatch:a=%h b=%h cin=%0d cout=%0d s=%h",exp,aa,bb,cc,cout,s);
		$finish;
		end
	end
	endtask

	initial begin
		 // -------- directed tests (common + edge cases) --------
    check_vec(16'h0000, 16'h0000, 1'b0); // all zeros
    check_vec(16'h0000, 16'h0000, 1'b1); // only cin
    check_vec(16'h0001, 16'h0001, 1'b0); // small add
    check_vec(16'h000F, 16'h0001, 1'b0); // nibble carry
    check_vec(16'h00FF, 16'h0001, 1'b0); // byte carry
    check_vec(16'h0FFF, 16'h0001, 1'b0); // multiple carries
    check_vec(16'hFFFF, 16'h0000, 1'b0); // max + 0
    check_vec(16'hFFFF, 16'h0001, 1'b0); // overflow
    check_vec(16'hFFFF, 16'hFFFF, 1'b0); // max + max
    check_vec(16'h8000, 16'h8000, 1'b0); // MSB carry behavior
    check_vec(16'h1234, 16'h5678, 1'b0); // random-looking
    check_vec(16'h1234, 16'h5678, 1'b1); // random-looking + cin

    // -------- some random tests (directed-ish + coverage) --------
    repeat (200) begin
      check_vec($urandom, $urandom, $urandom_range(0,1));
    end
    		$display("@@@PASS");
		$finish;
	end

endmodule
