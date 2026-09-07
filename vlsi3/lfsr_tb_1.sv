`timescale 1ns/1ps

module lfsr_tb_1;

    logic clk;
    logic reset;
    logic load;
    logic enable;
    logic [6:0] seed;
    logic [6:0] lfsr_out;

    lfsr dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .enable(enable),
        .seed(seed),
        .lfsr_out(lfsr_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset  = 0;
        load   = 0;
        enable = 0;
        seed   = 7'b1100111;

        // ----------------
        // Test reset
        // ----------------
        @(negedge clk);
        reset = 1;

        @(posedge clk);   // DUT executes reset here
        @(negedge clk);   // check safely afterwards

        if (lfsr_out !== 7'b1111111) begin
            $display("@@@FAIL");
            $finish;
        end


        // ----------------
        // Test load
        // ----------------
        reset = 0;
        load = 1;
        enable = 0;
        seed = 7'b1100111;

        @(posedge clk);
        @(negedge clk);

        if (lfsr_out !== 7'b1100111) begin
            $display("@@@FAIL");
            $finish;
        end


        // ----------------
        // Test first shift
        // ----------------
        load = 0;
        enable = 1;

        @(posedge clk);
        @(negedge clk);

        if (lfsr_out !== 7'b1001110) begin
            $display("@@@FAIL");
            $finish;
        end


        // ----------------
        // Test second shift
        // ----------------
        @(posedge clk);
        @(negedge clk);

        if (lfsr_out !== 7'b0011101) begin
            $display("@@@FAIL");
            $finish;
        end


        $display("@@@PASS");
        $finish;

    end

endmodule
