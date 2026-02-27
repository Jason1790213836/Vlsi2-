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

  // Instantiate DUT (ports match names, so wildcard is OK)
  processor DUT(.*);

  // -------------------------
  // Clock generator
  // -------------------------
  initial clk = 0;
  always #5 clk = ~clk;

  // -------------------------
  // Helpers: FAIL/ASSERT
  // -------------------------
  task automatic fail(string msg);
    $display("@@@FAIL");
    $display("FAIL: %s", msg);
    $finish;
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

  // Expected Q for 8->3 priority encoder (bit7 highest)
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

  // Build expected status according to mapping
  function automatic logic [7:0] status_exp(
    input logic int_en,
    input logic zero,
    input logic carry,
    input logic neg,
    input logic [1:0] parity
  );
    status_exp = {int_en, 2'b11, zero, carry, neg, parity};
  endfunction

  // -------------------------
  // Test sequence
  // -------------------------
  initial begin
    // init drives: start in reset to avoid X
    rstN         = 1'b0;
    data_in      = 32'h0;
    i_data       = 32'h0;
    data_select  = 1'b0;
    status_flags = 16'h0;

    // ========== 1) SYNC RESET TEST ==========
    // Hold reset for 2 clocks (very robust for sync reset)
    repeat (2) @(posedge clk);
    #1; // allow nonblocking updates to settle

    check8("reset status", status, 8'h00);
    check3("reset Q (from flags[15:8]=0)", Q, 3'd0);

    // ========== 2) RELEASE RESET ==========
    rstN = 1'b1;
    @(posedge clk);
    #1;

    // ========== 3) MUX32 TESTS ==========
    data_in = 32'hAAAA_0001;
    i_data  = 32'h5555_0002;

    data_select = 1'b1; #1;
    check32("mux sel=1 selects data_in", data_out, data_in);

    data_select = 1'b0; #1;
    check32("mux sel=0 selects i_data", data_out, i_data);

    // ========== 4) STATUS_REG MAPPING TEST ==========
    // drive lower 8 bits of status_flags (used by status_reg)
    status_flags[7]   = 1'b1;
    status_flags[4]   = 1'b0;
    status_flags[3]   = 1'b1;
    status_flags[2]   = 1'b0;
    status_flags[1:0] = 2'b10;

    @(posedge clk);
    #1;

    check8("status mapping #1", status,
           status_exp(1'b1, 1'b0, 1'b1, 1'b0, 2'b10));

    if (status[6:5] !== 2'b11) fail("unused bits [6:5] not statically 11");

    // change flags again
    status_flags[7]   = 1'b0;
    status_flags[4]   = 1'b1;
    status_flags[3]   = 1'b0;
    status_flags[2]   = 1'b1;
    status_flags[1:0] = 2'b01;

    @(posedge clk);
    #1;

    check8("status mapping #2", status,
           status_exp(1'b0, 1'b1, 1'b0, 1'b1, 2'b01));

    // ========== 5) PRIORITY ENCODER TESTS ==========
    // Pri_En input is status_flags[15:8]

    status_flags[15:8] = 8'b0001_0000; // bit4
    #1;
    check3("PriEn single bit4", Q, pe_exp(status_flags[15:8]));

    status_flags[15:8] = 8'b0010_1101; // highest is bit5
    #1;
    check3("PriEn multi bits (expect 5)", Q, pe_exp(status_flags[15:8]));

    status_flags[15:8] = 8'b1000_0000; // bit7
    #1;
    check3("PriEn bit7", Q, 3'd7);

    status_flags[15:8] = 8'b0000_0000;
    #1;
    check3("PriEn all zero", Q, 3'd0);

    $display("@@@PASS");
    $finish;
  end

endmodule
