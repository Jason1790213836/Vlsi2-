
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

    task check(input logic cond);
        begin
            if (!cond) begin
                $display("@@@FAIL");
                $finish;
            end
        end
    endtask

    initial begin
        clk     = 0;
        rst     = 1;
        start   = 0;
        csin    = 0;
        rwbarin = 1;
        opr     = 0;
        address = 6'd0;
        datain  = 8'd0;

        // reset
        repeat (2) @(posedge clk);
        rst = 0;

        // -----------------------------
        // Normal mode write
        // -----------------------------
        csin    = 1;
        rwbarin = 0;          // write
        address = 6'd10;
        datain  = 8'hA5;
        @(posedge clk);

        // -----------------------------
        // Normal mode read
        // -----------------------------
        rwbarin = 1;          // read
        address = 6'd10;
        @(posedge clk);
        #1;
        check(dataout == 8'hA5);

        // Normal mode should not trigger fail because NbarT = 0
        opr = 1;
        #1;
        check(fail == 1'b0);

        // -----------------------------
        // Enter BIST mode
        // -----------------------------
        start = 1;
        @(posedge clk);
        start = 0;

        // Let BIST run for some cycles
        opr = 1;

        repeat (300) begin
            @(posedge clk);
            #1;
            check(fail == 1'b0);
        end

        $display("@@@PASS");
        $finish;
    end

endmodule
