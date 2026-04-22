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

    initial begin
        clk = 0;
        d_in = 10'd0;
        ld   = 1'b0;
        u_d  = 1'b1;
        cen  = 1'b0;

        // load test
        d_in = 10'd5;
        cen  = 1'b1;
        ld   = 1'b1;
        @(posedge clk);
        #1;
        if (q !== 10'd5 || cout !== 1'b0) begin
            $display("@@@FAIL");
            $finish();
        end

        // up count
        ld  = 1'b0;
        u_d = 1'b1;
        @(posedge clk);
        #1;
        if (q !== 10'd6 || cout !== 1'b0) begin
            $display("@@@FAIL");
            $finish();
        end

        // hold when cen = 0
        cen = 1'b0;
        @(posedge clk);
        #1;
        if (q !== 10'd6) begin
            $display("@@@FAIL");
            $finish();
        end

        // overflow boundary check
        cen  = 1'b1;
        ld   = 1'b1;
        d_in = 10'b1111111111;
        @(posedge clk);
        #1;
        ld = 1'b0;
        u_d = 1'b1;
        #1;
        if (cout !== 1'b1) begin
            $display("@@@FAIL");
            $finish();
        end

        @(posedge clk);
        #1;
        if (q !== 10'b0000000000) begin
            $display("@@@FAIL");
            $finish();
        end

        // underflow boundary check
        ld   = 1'b1;
        d_in = 10'b0000000000;
        @(posedge clk);
        #1;
        ld  = 1'b0;
        u_d = 1'b0;
        #1;
        if (cout !== 1'b1) begin
            $display("@@@FAIL");
            $finish();
        end

        @(posedge clk);
        #1;
        if (q !== 10'b1111111111) begin
            $display("@@@FAIL");
            $finish();
        end

        $display("@@@PASS");
        $finish();
    end

endmodule
