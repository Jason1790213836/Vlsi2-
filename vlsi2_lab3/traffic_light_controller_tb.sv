
module traffic_light_controller_tb;

  // DUT I/O
  logic clk;
  logic reset;
  logic [1:0] light_NS;
  logic [1:0] light_EW;

  // Instantiate DUT (black-box)
  traffic_light_controller dut (
    .clk      (clk),
    .reset    (reset),
    .light_NS (light_NS),
    .light_EW (light_EW)
  );

  // Clock
  localparam int TCLK = 10;
  initial clk = 1'b0;
  always #(TCLK/2) clk = ~clk;

  // Encodings: 00=Red, 01=Yellow, 10=Green
  localparam logic [1:0] RED = 2'b00;
  localparam logic [1:0] YEL = 2'b01;
  localparam logic [1:0] GRN = 2'b10;

  // Expected phase since last reset deassertion, sampled on posedge
  // 0: NS_G, 1: NS_Y, 2: EW_G, 3: EW_Y
  int unsigned phase;

  task automatic fail(string msg);
    $display("@@@FAIL");
    $display("FAIL: %s | t=%0t reset=%0b NS=%b EW=%b phase=%0d",
             msg, $time, reset, light_NS, light_EW, phase);
    $finish();
  endtask

  function automatic bit is_valid_color(input logic [1:0] c);
    return (c == RED) || (c == YEL) || (c == GRN);
  endfunction

  // Safety/spec invariants (checked whenever outputs may change)
  task automatic check_invariants(string tag);
    // valid encodings
    if (!is_valid_color(light_NS)) fail({tag, ": invalid NS encoding"});
    if (!is_valid_color(light_EW)) fail({tag, ": invalid EW encoding"});

    // never both green
    if ((light_NS == GRN) && (light_EW == GRN)) fail({tag, ": both green"});

    // while one is green/yellow, the other must be red
    if ((light_NS == GRN || light_NS == YEL) && (light_EW != RED))
      fail({tag, ": NS not red implies EW must be red"});
    if ((light_EW == GRN || light_EW == YEL) && (light_NS != RED))
      fail({tag, ": EW not red implies NS must be red"});
  endtask

  task automatic check_expected_on_posedge(string tag);
    // reset behavior: async reset forces both red
    if (reset) begin
      if (light_NS !== RED || light_EW !== RED) fail({tag, ": reset but not both red"});
      phase = 0; // after reset is released, next posedge must go to NS green
    end else begin
      // After reset deasserted, next rising edge must be NS green :contentReference[oaicite:7]{index=7}
      unique case (phase)
        0: begin
          if (light_NS !== GRN || light_EW !== RED) fail({tag, ": expected NS green / EW red"});
        end
        1: begin
          if (light_NS !== YEL || light_EW !== RED) fail({tag, ": expected NS yellow / EW red"});
        end
        2: begin
          if (light_NS !== RED || light_EW !== GRN) fail({tag, ": expected NS red / EW green"});
        end
        3: begin
          if (light_NS !== RED || light_EW !== YEL) fail({tag, ": expected NS red / EW yellow"});
        end
        default: begin
          fail({tag, ": internal tb phase error"});
        end
      endcase

      // advance phase each cycle (no counter/durations; automatic transitions) :contentReference[oaicite:8]{index=8}
      phase = (phase + 1) % 4;
    end
  endtask

  initial begin
    // init
    reset = 1'b1;
    phase = 0;

    // During reset (async), outputs must be red immediately :contentReference[oaicite:9]{index=9}
    #1;
    check_invariants("init");
    if (light_NS !== RED || light_EW !== RED) fail("init: reset high but not both red");

    // Deassert reset not aligned to clock; still must stay red until next posedge produces NS green
    #(TCLK/3);
    reset = 1'b0;

    // Before next posedge, still should satisfy invariants; many correct designs remain red here
    #1;
    check_invariants("after reset deassert (pre-edge)");

    // Run a few full cycles: NS_G -> NS_Y -> EW_G -> EW_Y repeating :contentReference[oaicite:10]{index=10}
    repeat (12) begin
      @(posedge clk);
      #1;
      check_invariants("directed");
      check_expected_on_posedge("directed");
    end

    // Asynchronous reset pulse in the middle of operation (not at clock edge)
    @(negedge clk);
    #1;
    reset = 1'b1;
    #1;
    check_invariants("mid-cycle reset assert");
    if (light_NS !== RED || light_EW !== RED) fail("mid-cycle reset: not both red");

    // Release reset mid-cycle again; next posedge must go to NS green
    #(TCLK/4);
    reset = 1'b0;

    repeat (8) begin
      @(posedge clk);
      #1;
      check_invariants("post-midreset");
      check_expected_on_posedge("post-midreset");
    end

    // Random reset “glitches” to catch buggy designs
    repeat (30) begin
      // random wait 0..2 cycles
      int w = $urandom_range(0,2);
      repeat (w) begin
        @(posedge clk);
        #1;
        check_invariants("random-run");
        check_expected_on_posedge("random-run");
      end

      // random async reset pulse length 1..7 ns, 50% chance
      if ($urandom_range(0,1)) begin
        #( $urandom_range(1,7) );
        reset = 1'b1;
        #1;
        check_invariants("random reset assert");
        if (light_NS !== RED || light_EW !== RED) fail("random reset: not both red");
        #( $urandom_range(1,7) );
        reset = 1'b0;
      end
    end

    // Exactly one PASS at end :contentReference[oaicite:11]{index=11}
    $display("@@@PASS");
    $finish();
  end

endmodule
