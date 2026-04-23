module tb_controller;

    logic start, rst, clk, cout;
    logic NbarT, ld;

    controller dut (
        .start(start), .rst(rst), .clk(clk), .cout(cout), .NbarT(NbarT), .ld(ld)
    );

    always #5 clk = ~clk;

    task fail_now;
    begin
        $display("@@@FAIL");
        $finish();
    end
    endtask

    task check_outputs(input logic expNbarT, input logic expLd);
    begin
        #1;
        if (NbarT !== expNbarT || ld !== expLd) fail_now();
    end
    endtask

    initial begin
        clk   = 0;
        start = 0;
        rst   = 0;
        cout  = 0;

        // reset -> RESET
        @(negedge clk);
        rst = 1;
        @(posedge clk);
        check_outputs(0,1);

        // keep reset asserted, outputs must stay RESET
        @(posedge clk);
        check_outputs(0,1);

        // release reset, start=0 => stay RESET
        @(negedge clk);
        rst   = 0;
        start = 0;
        cout  = 0;
        @(posedge clk);
        check_outputs(0,1);

        // RESET + cout=1 should still stay RESET
        @(negedge clk);
        cout = 1;
        @(posedge clk);
        check_outputs(0,1);

        // start=1 from RESET => go TEST
        @(negedge clk);
        start = 1;
        cout  = 0;
        @(posedge clk);
        check_outputs(1,0);

        // In TEST, even if start drops, should remain TEST when cout=0
        @(negedge clk);
        start = 0;
        cout  = 0;
        @(posedge clk);
        check_outputs(1,0);

        // In TEST, even if start stays high, cout=0 should still remain TEST
        @(negedge clk);
        start = 1;
        cout  = 0;
        @(posedge clk);
        check_outputs(1,0);

        // In TEST, cout=1 => back RESET
        @(negedge clk);
        start = 0;
        cout  = 1;
        @(posedge clk);
        check_outputs(0,1);

        // Once back in RESET, cout alone must not send it to TEST
        @(negedge clk);
        cout  = 1;
        start = 0;
        @(posedge clk);
        check_outputs(0,1);

        $display("@@@PASS");
        $finish();
    end
endmodule
