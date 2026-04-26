module tb_bist;

    logic        start, rst, clk, csin, rwbarin, opr;
    logic [5:0]  address;
    logic [7:0]  datain;
    logic [7:0]  dataout;
    logic        fail;

    bist dut (
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

    always #5 clk = ~clk;

    task FAIL;
        begin
            $display("@@@FAIL");
            $finish;
        end
    endtask

    task PASS;
        begin
            $display("@@@PASS");
            $finish;
        end
    endtask

    task tick;
        begin
            @(posedge clk);
            #2;
        end
    endtask

    task normal_write(input logic [5:0] addr, input logic [7:0] data);
        begin
            csin    = 1'b1;
            rwbarin = 1'b0;
            address = addr;
            datain  = data;
            opr     = 1'b0;
            tick();
        end
    endtask

    task normal_read_check(input logic [5:0] addr, input logic [7:0] exp);
        begin
            csin    = 1'b1;
            rwbarin = 1'b1;
            address = addr;
            opr     = 1'b0;
            tick();
            if (dataout !== exp) FAIL();
        end
    endtask

    task bist_read_check(input logic [5:0] addr, input logic expected_fail, input logic opr_val);
        begin
            force dut.NbarT = 1'b1;
            force dut.q     = {3'b000, 1'b1, addr};   // pattern AA, read, addr

            csin    = 1'b0;
            rwbarin = 1'b0;
            address = 6'd63;      // should be ignored in BIST mode
            datain  = 8'h55;      // should be ignored in BIST mode
            opr     = opr_val;

            tick();               // SRAM captures address
            tick();               // fail captures comparator result

            if (fail !== expected_fail) FAIL();
        end
    endtask

    task bist_write_aa(input logic [5:0] addr);
        begin
            force dut.NbarT = 1'b1;
            force dut.q     = {3'b000, 1'b0, addr};   // pattern AA, write, addr

            csin    = 1'b0;       // should be ignored in BIST mode
            rwbarin = 1'b1;       // should be ignored in BIST mode
            address = 6'd62;      // should be ignored in BIST mode
            datain  = 8'h11;      // should be ignored in BIST mode
            opr     = 1'b0;

            tick();
        end
    endtask

    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        start   = 1'b0;
        csin    = 1'b0;
        rwbarin = 1'b0;
        opr     = 1'b0;
        address = 6'd0;
        datain  = 8'h00;

        repeat (3) tick();
        rst = 1'b0;
        repeat (2) tick();

        // Normal mode SRAM write/read through BIST top
        normal_write(6'd0,  8'hAA);
        normal_write(6'd5,  8'h00);
        normal_write(6'd10, 8'h3C);

        normal_read_check(6'd0,  8'hAA);
        normal_read_check(6'd5,  8'h00);
        normal_read_check(6'd10, 8'h3C);

        // BIST read addr 0: memory has AA, expected AA, so fail must be 0
        bist_read_check(6'd0, 1'b0, 1'b1);

        // BIST read addr 5: memory has 00, expected AA, so fail must be 1
        bist_read_check(6'd5, 1'b1, 1'b1);

        // Same mismatch, but opr=0, so fail must stay 0
        bist_read_check(6'd5, 1'b0, 1'b0);

        // BIST write should write decoder pattern AA into addr 12
        bist_write_aa(6'd12);

        release dut.NbarT;
        release dut.q;

        rst = 1'b1;
        tick();
        rst = 1'b0;
        tick();

        normal_read_check(6'd12, 8'hAA);

        PASS();
    end

endmodule
