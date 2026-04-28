module tb_bist;

    logic        start, rst, clk, csin, rwbarin, opr;
    logic [5:0]  address;
    logic [7:0]  datain;
    logic [7:0]  dataout;
    logic        fail;

    bist #(.size(6), .length(8)) dut (
        .start(start),
        .rst(rst),
        .clk(clk),
        .csin(csin),
        .rwbarin(rwbarin),
        .opr(opr),
        .address(address),
        .datain(datain),
        .dataout(dataout),
        .fail(fail)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer k;
    logic seen_fail;

    initial begin
        rst = 1; start = 0; csin = 0; rwbarin = 0;
        opr = 0; address = 0; datain = 0;
        @(posedge clk); @(posedge clk);
        rst = 0;
        @(posedge clk); #1;

        csin = 1; rwbarin = 0;
        address = 6'd5; datain = 8'hBE;
        @(posedge clk); #1;

        rwbarin = 1; address = 6'd5;
        @(posedge clk); #1;
        if (dataout !== 8'hBE) begin $display("@@@FAIL"); $finish; end

        rwbarin = 0; csin = 0;
        @(posedge clk);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk); #1;

        start = 1; opr = 1;
        @(posedge clk); #1;
        start = 0;

        seen_fail = 0;
        for (k = 0; k < 1030; k++) begin
            @(posedge clk); #1;
            if (fail) seen_fail = 1;
        end

        if (seen_fail) begin $display("@@@FAIL"); $finish; end

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        csin = 1; rwbarin = 1; opr = 0;
        address = 6'd0;
        @(posedge clk); #1;

        $display("@@@PASS");
        $finish;
    end

endmodule

