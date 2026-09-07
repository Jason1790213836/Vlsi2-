`timescale 1ns/1ps

module lfsr_tb_1;

    logic clk;
    logic reset;
    logic load;
    logic enable;
    logic [6:0] seed;
    logic [6:0] lfsr_out;

    // Instantiate DUT
    lfsr dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .enable(enable),
        .seed(seed),
        .lfsr_out(lfsr_out)
    );

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initial values
        reset = 0;
        load = 0;
        enable = 0;
        seed = 7'b1100111;


        // -------------------------
        // Test 1: reset
        // -------------------------
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        if (lfsr_out !== 7'b1111111) begin
            $display("@@@FAIL");
            $finish;
        end


        // -------------------------
        // Test 2: load seed
        // -------------------------
        @(negedge clk);
        reset = 0;
        load = 1;
        seed = 7'b1100111;

        @(posedge clk);
        #1;

        if (lfsr_out !== 7'b1100111) begin
            $display("@@@FAIL");
            $finish;
        end


        // -------------------------
        // Test 3: first LFSR shift
        // -------------------------
        @(negedge clk);
        load = 0;
        enable = 1;

        @(posedge clk);
        #1;

        if (lfsr_out !== 7'b1001110) begin
            $display("@@@FAIL");
            $finish;
        end


        // -------------------------
        // Test 4: second shift
        // -------------------------
        @(posedge clk);
        #1;

        if (lfsr_out !== 7'b0011101) begin
            $display("@@@FAIL");
            $finish;
        end


        // Everything passed
        $display("@@@PASS");
        $finish;

    end

endmodule
