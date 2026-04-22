module tb_comparator;

    logic [7:0] data_t;
    logic [7:0] ramout;
    logic gt, eq, lt;

    comparator dut (
        .data_t(data_t),
        .ramout(ramout),
        .gt(gt),
        .eq(eq),
        .lt(lt)
    );

    task check_cmp(
        input [7:0] a,
        input [7:0] b,
        input exp_gt,
        input exp_eq,
        input exp_lt
    );
    begin
        data_t = a;
        ramout = b;
        #1;
        if (gt !== exp_gt || eq !== exp_eq || lt !== exp_lt) begin
            $display("@@@FAIL");
            $finish();
        end
    end
    endtask

    initial begin
        check_cmp(8'd10, 8'd5,  1'b1, 1'b0, 1'b0);  // gt
        check_cmp(8'd7,  8'd7,  1'b0, 1'b1, 1'b0);  // eq
        check_cmp(8'd3,  8'd9,  1'b0, 1'b0, 1'b1);  // lt
        check_cmp(8'd0,  8'd255,1'b0, 1'b0, 1'b1);
        check_cmp(8'd255,8'd0,  1'b1, 1'b0, 1'b0);

        $display("@@@PASS");
        $finish();
    end

endmodule
