module rtl_4bit_adder(
input logic [3:0] a, // Input A
input logic [3:0] b, // Input B
input logic cin, // Carry in
output logic [3:0] s, // Sum
output logic cout // Carry out
);

always_comb begin
	{cout,s}=cin+a+b;
end

endmodule


module rtl_16bit_adder(

	input logic [15:0]a,
	input logic [15:0]b,
	input logic cin,
	output logic cout,
	output logic [15:0]s

);
	logic c1, c2, c3;
	       	rtl_4bit_adder u0(
		 .a (a[3:0]), // Input A
		 .b (b[3:0]), // Input B
		 .cin(cin), // Carry in
		 .s(s[3:0]), // Sum
		 .cout(c1) // Carry out
		);
		rtl_4bit_adder u1(
                 .a (a[7:4]), // Input A
                 .b (b[7:4]), // Input B
                 .cin(c1), // Carry in
                 .s(s[7:4]), // Sum
                 .cout(c2) // Carry out
                );
	        rtl_4bit_adder u2(
                 .a (a[11:8]), // Input A
                 .b (b[11:8]), // Input B
                 .cin(c2), // Carry in
                 .s(s[11:8]), // Sum
                 .cout(c3) // Carry out
                );
		rtl_4bit_adder u3(
                 .a (a[15:12]), // Input A
                 .b (b[15:12]), // Input B
                 .cin(c3), // Carry in
                 .s(s[15:12]), // Sum
                 .cout(cout) // Carry out
                );	

endmodule
