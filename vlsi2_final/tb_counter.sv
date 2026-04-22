module tb_counter;

    logic [9:0] d_in;
    logic clk, ld, u_d, cen;
    logic [9:0] q;
    logic cout;

    counter #(10) dut (
        .d_in(d_in),
        .clk(clk),
        .ld(ld),
        .u_d(u_d),
        .cen(cen),
        .q(q),
        .cout(cout)
    );

    always #5 clk = ~clk;

    task fail_now;
    begin
        $display("@@@FAIL");
        $finish();
    end
    endtask

    initial begin
        clk = 1'b0;
        d_in = 10'd0;
        ld = 1'b0;
        u_d = 1'b1;
        cen = 1'b0;

        // 1. load
        cen = 1'b1;
        ld  = 1'b1;
        d_in = 10'd5;
        @(posedge clk);
        #1;
        if (q !== 10'd5 || cout !== 1'b0) fail_now();

        // 2. count up
        ld  = 1'b0;
        u_d = 1'b1;
        @(posedge clk);
        #1;
        if (q !== 10'd6 || cout !== 1'b0) fail_now();

        // 3. hold when cen = 0
        cen = 1'b0;
        @(posedge clk);
        #1;
        if (q !== 10'd6 || cout !== 1'b0) fail_now();

        // 4. count down
        cen = 1'b1;
        u_d = 1'b0;
        @(posedge clk);
        #1;
        if (q !== 10'd5 || cout !== 1'b0) fail_now();

        // 5. overflow test
        ld   = 1'b1;
        d_in = 10'b1111111111;
        @(posedge clk);
        #1;
        if (q !== 10'b1111111111 || cout !== 1'b0) fail_now();

        ld  = 1'b0;
        u_d = 1'b1;
        @(posedge clk);
        #1;
        if (q !== 10'b0000000000 || cout !== 1'b1) fail_now();

        // next cycle should continue normally
        @(posedge clk);
        #1;
        if (q !== 10'b0000000001 || cout !== 1'b0) fail_now();

        // 6. underflow test
        ld   = 1'b1;
        d_in = 10'b0000000000;
        @(posedge clk);
        #1;
        if (q !== 10'b0000000000 || cout !== 1'b0) fail_now();

        ld  = 1'b0;
        u_d = 1'b0;
        @(posedge clk);
        #1;
        if (q !== 10'b1111111111 || cout !== 1'b1) fail_now();

        // next cycle should continue normally
        @(posedge clk);
        #1;
        if (q !== 10'b1111111110 || cout !== 1'b0) fail_now();

        $display("@@@PASS");
        $finish();
    end

endmodule
