module processor_tb();

  logic        clk;
  logic        rstN;
  logic [31:0] data_in;
  logic [31:0] i_data;
  logic        data_select;
  logic [15:0] status_flags;

  logic [31:0] data_out;
  logic [ 7:0] status;
  logic [ 2:0] Q;

  processor DUT(.*);

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic fail(string msg);
    $display("@@@FAIL");
    $display("FAIL: %s", msg);
    $finish;
  endtask
task automatic tick2();
    @(posedge clk);
    @(posedge clk);
    #0.1;
endtask
  task automatic check32(string name, logic [31:0] got, logic [31:0] exp);
    if (got !== exp) fail($sformatf("%s got=%h exp=%h", name, got, exp));
  endtask

  task automatic check8(string name, logic [7:0] got, logic [7:0] exp);
    if (got !== exp) fail($sformatf("%s got=%b exp=%b", name, got, exp));
  endtask

  task automatic check3(string name, logic [2:0] got, logic [2:0] exp);
    if (got !== exp) fail($sformatf("%s got=%b exp=%b", name, got, exp));
  endtask

  function automatic logic [2:0] pe_exp(input logic [7:0] d);
    if      (d[7]) pe_exp = 3'd7;
    else if (d[6]) pe_exp = 3'd6;
    else if (d[5]) pe_exp = 3'd5;
    else if (d[4]) pe_exp = 3'd4;
    else if (d[3]) pe_exp = 3'd3;
    else if (d[2]) pe_exp = 3'd2;
    else if (d[1]) pe_exp = 3'd1;
    else if (d[0]) pe_exp = 3'd0;
    else           pe_exp = 3'd0;
  endfunction

  function automatic logic [7:0] status_exp(
    input logic int_en,
    input logic zero,
    input logic carry,
    input logic neg,
    input logic [1:0] parity
  );
    status_exp = {int_en, 2'b11, zero, carry, neg, parity};
  endfunction

  initial begin

    // ---------------- RESET ----------------
    rstN = 0;
    data_in = 0;
    i_data = 0;
    data_select = 0;
    status_flags = 0;

    repeat (2) @(posedge clk);
    #0.1;

    check8("reset status", status, 8'h00);
    check3("reset Q", Q, 3'd0);

    // release reset
    rstN = 1;
    @(posedge clk);
    #0.1;

    // ---------------- MUX TEST ----------------
    data_in = 32'hAAAA_0001;
    i_data  = 32'h5555_0002;

    data_select = 1;
    #0.1;   // combinational settle
    check32("mux sel=1", data_out, data_in);

    data_select = 0;
    #0.1;
    check32("mux sel=0", data_out, i_data);

    // ---------------- STATUS REG TEST ----------------
    status_flags[7]   = 1;
    status_flags[4]   = 0;
    status_flags[3]   = 1;
    status_flags[2]   = 0;
    status_flags[1:0] = 2'b10;
    
    tick2();
    
    check8("status mapping #1", status,
           status_exp(1,0,1,0,2'b10));

    if (status[6:5] !== 2'b11)
      fail("unused bits not 11");

    status_flags[7]   = 0;
    status_flags[4]   = 1;
    status_flags[3]   = 0;
    status_flags[2]   = 1;
    status_flags[1:0] = 2'b01;

    tick2();

    check8("status mapping #2", status,
           status_exp(0,1,0,1,2'b01));

    // ---------------- PRIORITY ENCODER ----------------
    status_flags[15:8] = 8'b0001_0000;
    #0.1;
    check3("PE bit4", Q, pe_exp(status_flags[15:8]));

    status_flags[15:8] = 8'b0010_1101;
    #0.1;
    check3("PE multi", Q, pe_exp(status_flags[15:8]));

    status_flags[15:8] = 8'b1000_0000;
    #0.1;
    check3("PE bit7", Q, 3'd7);

    status_flags[15:8] = 8'b0000_0000;
    #0.1;
    check3("PE zero", Q, 3'd0);

    $display("@@@PASS");
    $finish;
  end

endmodule
