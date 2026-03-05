`include "fsm_pkg.svh"
import fsm10_pkg::*;

module fsm_tb;

  // DUT I/O
  logic   rst_n;
  logic   clk;
  logic   jmp;
  logic   go;
  logic   y;
  state_e state;

  // Instantiate DUT (black-box: only connect ports)
  fsm dut (
    .rst_n(rst_n),
    .clk  (clk),
    .jmp  (jmp),
    .go   (go),
    .y    (y),
    .state(state)
  );

  // Clock
  localparam int TCLK = 10;
  initial clk = 1'b0;
  always #(TCLK/2) clk = ~clk;

  // Expected model
  state_e exp_state;

  function automatic state_e next_state_model(state_e s, logic go_i, logic jmp_i);
    unique case (s)
      S0: begin
        if (!go_i)       next_state_model = S0;
        else if (!jmp_i) next_state_model = S1;
        else             next_state_model = S3; // go & jmp
      end
      S1: next_state_model = (jmp_i ? S3 : S2);
      S2: next_state_model = S3;
      S3: next_state_model = (jmp_i ? S3 : S4);
      S4: next_state_model = (jmp_i ? S3 : S5);
      S5: next_state_model = (jmp_i ? S3 : S6);
      S6: next_state_model = (jmp_i ? S3 : S7);
      S7: next_state_model = (jmp_i ? S3 : S8);
      S8: next_state_model = (jmp_i ? S3 : S9);
      S9: next_state_model = (jmp_i ? S3 : S0);
      default: next_state_model = S0;
    endcase
  endfunction

  task automatic fail(string msg);
    $display("@@@FAIL");
    // Optional debug (autograder ignores other strings) :contentReference[oaicite:6]{index=6}
    $display("FAIL: %s | time=%0t rst_n=%0b go=%0b jmp=%0b state=%0d exp_state=%0d y=%0b",
             msg, $time, rst_n, go, jmp, state, exp_state, y);
    $finish();
  endtask

  task automatic check_outputs(string tag);
    // state must match expected
    if (state !== exp_state) begin
      fail({tag, ": state mismatch"});
    end

    // Moore output: y == 1 only in S3, else 0 :contentReference[oaicite:7]{index=7}
    if (exp_state == S3) begin
      if (y !== 1'b1) fail({tag, ": y should be 1 in S3"});
    end else begin
      if (y !== 1'b0) fail({tag, ": y should be 0 outside S3"});
    end
  endtask

  // Drive inputs well before rising edge, then sample/check after edge
  task automatic apply_and_tick(logic go_i, logic jmp_i, string tag);
    go  = go_i;
    jmp = jmp_i;
    // ensure stable before posedge
    @(negedge clk);
    @(posedge clk);
    // update expected after clock edge (synchronous state update)
    if (!rst_n) exp_state = S0;
    else        exp_state = next_state_model(exp_state, go_i, jmp_i);

    // small delay for NBA updates to settle
    #1;
    check_outputs(tag);
  endtask

  initial begin
    // init
    rst_n = 1'b0;
    go    = 1'b0;
    jmp   = 1'b0;
    exp_state = S0;

    // Hold reset for a bit (async active-low) :contentReference[oaicite:8]{index=8}
    #3;
    // While reset asserted, state should be S0 and y=0
    #1;
    if (state !== S0) fail("reset asserted: state not S0");
    if (y !== 1'b0)   fail("reset asserted: y not 0");

    // Deassert reset
    rst_n = 1'b1;

    // Wait for a clean edge and check we remain in S0 if go=0
    apply_and_tick(1'b0, 1'b0, "S0 hold (go=0)");

    // S0 -> S1 (go=1, jmp=0)
    apply_and_tick(1'b1, 1'b0, "S0->S1");

    // S1 -> S2 (jmp=0)
    apply_and_tick(1'b0, 1'b0, "S1->S2");

    // S2 -> S3 (unconditional)
    apply_and_tick(1'b0, 1'b0, "S2->S3");

    // In S3, y must be 1
    // S3 -> S4 when !jmp
    apply_and_tick(1'b0, 1'b0, "S3->S4 (!jmp)");

    // Walk S4->S5->S6->S7->S8->S9->S0 using !jmp
    apply_and_tick(1'b0, 1'b0, "S4->S5 (!jmp)");
    apply_and_tick(1'b0, 1'b0, "S5->S6 (!jmp)");
    apply_and_tick(1'b0, 1'b0, "S6->S7 (!jmp)");
    apply_and_tick(1'b0, 1'b0, "S7->S8 (!jmp)");
    apply_and_tick(1'b0, 1'b0, "S8->S9 (!jmp)");
    apply_and_tick(1'b0, 1'b0, "S9->S0 (!jmp)");

    // S0 -> S3 directly when go=1 & jmp=1
    apply_and_tick(1'b1, 1'b1, "S0->S3 (go&jmp)");

    // Stay in S3 if jmp=1
    apply_and_tick(1'b0, 1'b1, "S3 stay (jmp)");

    // Jump back to S3 from mid-states: go to S4 then assert jmp
    apply_and_tick(1'b0, 1'b0, "S3->S4");
    apply_and_tick(1'b0, 1'b1, "S4->S3 (jmp)");

    // Async reset overrides all other signals (assert reset mid-cycle) :contentReference[oaicite:9]{index=9}
    go  = 1'b1;
    jmp = 1'b1;
    @(negedge clk);
    #1;
    rst_n = 1'b0;  // assert asynchronously
    #1;
    exp_state = S0;
    if (state !== S0) fail("async reset mid-cycle: state not S0");
    if (y !== 1'b0)   fail("async reset mid-cycle: y not 0");
    rst_n = 1'b1;

    // Randomized stress (helps catch buggy designs)
    repeat (200) begin
      logic r_go, r_jmp;
      r_go  = $urandom_range(0,1);
      r_jmp = $urandom_range(0,1);
      apply_and_tick(r_go, r_jmp, "random");
    end

    // Exactly one PASS at end :contentReference[oaicite:10]{index=10}
    $display("@@@PASS");
    $finish();
  end

endmodule
