module tb_multiplexer;

    logic [7:0] normal_in;
    logic [7:0] bist_in;
    logic       NbarT;
    logic [7:0] out;

    multiplexer #(.WIDTH(8)) dut (
        .normal_in(normal_in),
        .bist_in(bist_in),
        .NbarT(NbarT),
        .out(out)
    );

    initial begin
        normal_in = 8'hA5;
        bist_in   = 8'h3C;

        NbarT = 1'b0;
        #1;
        if (out !== 8'hA5) begin
            $display("@@@FAIL");
            $finish;
        end

        NbarT = 1'b1;
        #1;
        if (out !== 8'h3C) begin
            $display("@@@FAIL");
            $finish;
        end

        normal_in = 8'h55;
        bist_in   = 8'hAA;

        NbarT = 1'b0;
        #1;
        if (out !== 8'h55) begin
            $display("@@@FAIL");
            $finish;
        end

        NbarT = 1'b1;
        #1;
        if (out !== 8'hAA) begin
            $display("@@@FAIL");
            $finish;
        end

        $display("@@@PASS");
        $finish;
    end

endmodule
