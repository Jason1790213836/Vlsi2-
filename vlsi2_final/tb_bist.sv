module tb_bist;

    logic        start;
    logic        rst;
    logic        clk;
    logic        csin;
    logic        rwbarin;
    logic        opr;
    logic [5:0]  address;
    logic [7:0]  datain;
    logic [7:0]  dataout;
    logic        fail;

    bist dut (
        .start   (start),
        .rst     (rst),
        .clk     (clk),
        .csin    (csin),
        .rwbarin (rwbarin),
        .opr     (opr),
        .address (address),
        .datain  (datain),
        .dataout (dataout),
        .fail    (fail)
    );

    always #5 clk = ~clk;

    task fail_now;
        begin
            $display("@@@FAIL");
            $finish;
        end
    endtask

    initial begin
        clk     = 0;
        rst     = 1;
        start   = 0;
        csin    = 0;
        rwbarin = 1;
        opr     = 0;
        address = 0;
        datain  = 0;

        repeat (2) @(posedge clk);
        rst = 0;

        // Normal write
        csin    = 1;
        rwbarin = 0;
        address = 6'd10;
        datain  = 8'hA5;
        @(posedge clk);

        // Normal read
        rwbarin = 1;
        address = 6'd10;
        @(posedge clk);
        #1;
        if (dataout !== 8'hA5) fail_now();

        // csin = 0 should disable memory in normal mode
        csin = 0;
        #1;
        if (dataout !== 8'h00) fail_now();

        // Normal mode should not assert fail
        opr = 1;
        repeat (2) @(posedge clk);
        #1;
        if (fail !== 1'b0) fail_now();

        // Enter BIST mode
        csin  = 0;
        start = 1;
        @(posedge clk);
        start = 0;
        opr   = 1;

        // Let BIST write first pattern to memory.
        repeat (66) @(posedge clk);

        // Corrupt one SRAM location after BIST write phase.
        // Pattern 000 should be 8'hAA, so 8'h00 creates mismatch.
        dut.u_sram.ram[6'd5] = 8'h00;

        // During BIST read phase, fail should become 1 when address 5 is read.
        repeat (20) begin
            @(posedge clk);
            #1;
            if (fail === 1'b1) begin
                $display("@@@PASS");
                $finish;
            end
        end

        // If fail never asserted, BIST fail logic is buggy.
        fail_now();
    end

endmodule
