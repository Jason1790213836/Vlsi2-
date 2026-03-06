// traffic_light_controller_tb.sv
module traffic_light_controller_tb;

  logic clk;
  logic reset;
  logic [1:0] light_NS, light_EW;

  traffic_light_controller dut (
    .clk      (clk),
    .reset    (reset),
    .light_NS (light_NS),
    .light_EW (light_EW)
  );

  // clock: 10 time units period
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // helper: fail fast
  task automatic fail(string msg);
    $display("@@@FAIL");
    $display("FAIL: %s | t=%0t reset=%0b NS=%b EW=%b", msg, $time, reset, light_NS, light_EW);
    $finish;
  endtask

  // safety invariant checks (black-box)
  task automatic check_safety();
    // NS and EW cannot be Green at the same time
    if (light_NS == 2'b10 && light_EW == 2'b10) fail("both directions GREEN");

    // While one direction is Green/Yellow, the opposite must be Red
    if ((light_NS == 2'b10 || light_NS == 2'b01) && (light_EW != 2'b00))
      fail("NS is G/Y but EW not RED");
    if ((light_EW == 2'b10 || light_EW == 2'b01) && (light_NS != 2'b00))
      fail("EW is G/Y but NS not RED");

    // Each direction must follow: Green -> Yellow -> Red (checked via sequence below)
  endtask

  // expect exact outputs
  task automatic expect_lights(input logic [1:0] expNS, input logic [1:0] expEW, string ctx);
    if (light_NS !== expNS || light_EW !== expEW) begin
      fail($sformatf("%s: expected NS=%b EW=%b", ctx, expNS, expEW));
    end
  endtask

  // step one cycle and check safety
  task automatic step_and_check();
    @(posedge clk);
    #1; // allow combinational settle
    check_safety();
  endtask

  initial begin
    // init
    reset = 1'b0;

    // Assert async reset not aligned to clk edge
    #2;
    reset = 1'b1;
    #1;
    // async reset must force both RED immediately
    expect_lights(2'b00, 2'b00, "async reset asserted");
    check_safety();

    // Deassert reset mid-cycle
    #7;
    reset = 1'b0;

    // At NEXT rising edge after reset deassert: NS must be GREEN, EW RED
    step_and_check();
    expect_lights(2'b10, 2'b00, "after reset deassert, 1st edge");

    // Then automatic cycle each clock:
    // NS_G -> NS_Y -> EW_G -> EW_Y -> NS_G -> ...
    step_and_check();
    expect_lights(2'b01, 2'b00, "NS_Y");

    step_and_check();
    expect_lights(2'b00, 2'b10, "EW_G");

    step_and_check();
    expect_lights(2'b00, 2'b01, "EW_Y");

    step_and_check();
    expect_lights(2'b10, 2'b00, "back to NS_G");

    // Run a few more cycles to ensure it keeps repeating and stays safe
    repeat (12) begin
      step_and_check();
    end

    $display("@@@PASS");
    $finish;
  end

endmodule
