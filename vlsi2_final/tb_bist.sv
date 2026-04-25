module tb_bist;

    logic start, rst, clk, csin, rwbarin, opr;
    logic [5:0] address;
    logic [7:0] datain, dataout;
    logic fail;

    bist dut (
        .start(start), .rst(rst), .clk(clk),
        .csin(csin), .rwbarin(rwbarin), .opr(opr),
        .address(address), .datain(datain),
        .dataout(dataout), .fail(fail)
    );

    always #5 clk = ~clk;

    task TB_FAIL;
        begin
            $display("@@@FAIL");
            $finish;
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        csin = 0;
        rwbarin = 1;
        opr = 1;
        address = 0;
        datain = 0;

        repeat (3) @(posedge clk);
        rst = 0;
        repeat (3) @(posedge clk);

        // Start BIST
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait until BIST begins reading pattern 0:
        // q[6] == 1 means read phase, q[5:0] is address.
        wait (dut.NbarT === 1'b1 && dut.q[6] === 1'b1);

        // Corrupt an SRAM location that BIST is about to read.
        // Correct BIST should detect this and assert fail.
        dut.u_sram.ram[6'd10] = 8'h00;

        // Wait until BIST reads address 10 or shortly after
        repeat (80) begin
            @(posedge clk);
            #1;
            if (fail === 1'b1) begin
                $display("@@@PASS");
                $finish;
            end
        end

        // If fail never asserted, buggy BIST was not detected
        TB_FAIL();
    end

endmodule
