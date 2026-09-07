module lfsr_tb_1;

    logic clk;
    logic reset;
    logic load;
    logic enable;
    logic [6:0] seed;
    logic [6:0] lfsr_out;

    logic [6:0] expected;
    integer i;

    // -----------------------------
    // DUT
    // -----------------------------
    lfsr dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .enable(enable),
        .seed(seed),
        .lfsr_out(lfsr_out)
    );

    // -----------------------------
    // Clock
    // -----------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Expected PRBS7 next state
    function automatic [6:0] prbs7_next(input [6:0] state);
        begin
            prbs7_next = {
                state[5:0],
                state[6] ^ state[5]
            };
        end
    endfunction


    // Check output
    task automatic check_output(input [6:0] exp);
        begin
            if (lfsr_out !== exp) begin
                $display("Expected = %b, Actual = %b", exp, lfsr_out);
                $display("@@@FAIL");
                $finish;
            end
        end
    endtask


    initial begin

        // Initial inputs
        reset  = 0;
        load   = 0;
        enable = 0;
        seed   = 7'b0000000;


        // =====================================================
        // TEST 1: synchronous reset -> 1111111
        // =====================================================

        @(negedge clk);
        reset = 1;

        @(negedge clk);
        check_output(7'b1111111);


        // =====================================================
        // TEST 2: load seed
        // =====================================================

        reset = 0;
        load  = 1;
        enable = 0;
        seed = 7'b1100111;

        @(negedge clk);
        check_output(7'b1100111);


        // =====================================================
        // TEST 3: hold state when no controls asserted
        // =====================================================

        load = 0;
        enable = 0;

        repeat (3) begin
            @(negedge clk);
            check_output(7'b1100111);
        end


        // =====================================================
        // TEST 4: PRBS7 sequence
        //
        // 1100111
        // 1001110
        // 0011101
        // 0111010
        // 1110101
        // =====================================================

        enable = 1;

        @(negedge clk);
        check_output(7'b1001110);

        @(negedge clk);
        check_output(7'b0011101);

        @(negedge clk);
        check_output(7'b0111010);

        @(negedge clk);
        check_output(7'b1110101);


        // =====================================================
        // TEST 5: load has priority over enable
        // =====================================================

        load   = 1;
        enable = 1;
        seed   = 7'b1010011;

        @(negedge clk);

        // Must LOAD, not shift
        check_output(7'b1010011);


        // =====================================================
        // TEST 6: reset has priority over load AND enable
        // =====================================================

        reset  = 1;
        load   = 1;
        enable = 1;
        seed   = 7'b0000001;

        @(negedge clk);

        // reset must win
        check_output(7'b1111111);


        // =====================================================
        // TEST 7: reset must be SYNCHRONOUS
        // =====================================================

        // First load a recognizable non-reset value
        reset  = 0;
        load   = 1;
        enable = 0;
        seed   = 7'b0101010;

        @(negedge clk);
        check_output(7'b0101010);

        // Stop changing state
        load   = 0;
        enable = 0;

        // Assert reset between clock edges
        #1;
        reset = 1;

        // Before next positive clock edge,
        // synchronous reset MUST NOT have happened yet
        #1;
        check_output(7'b0101010);

        // Now allow next positive edge to occur
        @(negedge clk);

        // reset should now have taken effect
        check_output(7'b1111111);


        // =====================================================
        // TEST 8: zero seed
        // =====================================================

        reset  = 0;
        load   = 1;
        enable = 0;
        seed   = 7'b0000000;

        @(negedge clk);
        check_output(7'b0000000);

        load   = 0;
        enable = 1;

        // zero seed must remain zero
        repeat (5) begin
            @(negedge clk);
            check_output(7'b0000000);
        end


        // =====================================================
        // TEST 9: complete 127-cycle PRBS7 sequence
        // =====================================================

        load   = 1;
        enable = 0;
        seed   = 7'b1100111;

        @(negedge clk);
        check_output(7'b1100111);

        load   = 0;
        enable = 1;

        expected = 7'b1100111;

        for (i = 1; i <= 127; i = i + 1) begin

            expected = prbs7_next(expected);

            @(negedge clk);

            check_output(expected);

        end


        // After exactly 127 shifts it must return to seed
        check_output(7'b1100111);


        // =====================================================
        // ALL TESTS PASSED
        // =====================================================

        $display("@@@PASS");
        $finish;

    end

endmodule
