module tb_controller;

    logic start, rst, clk, cout;
    logic NbarT, ld;

    controller dut (
        .start(start),
        .rst(rst),
        .clk(clk),
        .cout(cout),
        .NbarT(NbarT),
        .ld(ld)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        start = 0;
        rst   = 0;
        cout  = 0;

        // apply reset
        rst = 1;
        @(posedge clk);
        #1;
        if (NbarT !== 1'b0 || ld !== 1'b1) begin
            $display("@@@FAIL");
            $finish();
        end

        // release reset, stay in RESET if start=0
        rst = 0;
        start = 0;
        cout = 0;
        @(posedge clk);
        #1;
        if (NbarT !== 1'b0 || ld !== 1'b1) begin
            $display("@@@FAIL");
            $finish();
        end

        // go to TEST when start=1
        start = 1;
        @(posedge clk);
        #1;
        if (NbarT !== 1'b1 || ld !== 1'b0) begin
            $display("@@@FAIL");
            $finish();
        end

        // remain in TEST if cout=0
        start = 0;
        cout  = 0;
        @(posedge clk);
        #1;
        if (NbarT !== 1'b1 || ld !== 1'b0) begin
            $display("@@@FAIL");
            $finish();
        end

        // back to RESET when cout=1
        cout = 1;
        @(posedge clk);
        #1;
        if (NbarT !== 1'b0 || ld !== 1'b1) begin
            $display("@@@FAIL");
            $finish();
        end

        $display("@@@PASS");
        $finish();
    end

endmodule
