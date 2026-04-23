module tb_counter;

    logic [9:0] d_in;
    logic clk, ld, u_d, cen;
    logic [9:0] q;
    logic cout;

    counter #(10) dut (
        .d_in(d_in), .clk(clk), .ld(ld), .u_d(u_d), .cen(cen), .q(q), .cout(cout)
    );

    always #5 clk = ~clk;

    task fail_now;
    begin
        $display("@@@FAIL");
        $finish();
    end
    endtask

    initial begin
        clk = 0;
        d_in = '0;
        ld   = 0;
        u_d  = 1;
        cen  = 0;

        // 先把 DUT 同步带到确定状态，不依赖初值
        @(negedge clk);
        cen  = 1;
        ld   = 1;
        d_in = 10'd5;

        @(posedge clk); #1;
        if (q !== 10'd5) fail_now();

        // normal up
        @(negedge clk);
        ld  = 0;
        u_d = 1;
        @(posedge clk); #1;
        if (q !== 10'd6) fail_now();

        // hold
        @(negedge clk);
        cen = 0;
        @(posedge clk); #1;
        if (q !== 10'd6) fail_now();

        // down
        @(negedge clk);
        cen = 1;
        u_d = 0;
        @(posedge clk); #1;
        if (q !== 10'd5) fail_now();

        // overflow
        @(negedge clk);
        ld   = 1;
        d_in = 10'h3FF;
        @(posedge clk); #1;
        if (q !== 10'h3FF) fail_now();

        @(negedge clk);
        ld  = 0;
        u_d = 1;
        @(posedge clk); #1;
        if (q !== 10'h000 || cout !== 1'b1) fail_now();

        // underflow
        @(negedge clk);
        ld   = 1;
        d_in = 10'h000;
        @(posedge clk); #1;
        if (q !== 10'h000) fail_now();

        @(negedge clk);
        ld  = 0;
        u_d = 0;
        @(posedge clk); #1;
        if (q !== 10'h3FF || cout !== 1'b1) fail_now();

        $display("@@@PASS");
        $finish();
    end
endmodule
