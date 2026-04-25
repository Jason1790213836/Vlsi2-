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

    task normal_write(input logic [5:0] addr, input logic [7:0] data);
        begin
            csin    = 1'b1;
            rwbarin = 1'b0;
            address = addr;
            datain  = data;
            @(posedge clk);
            #1;
        end
    endtask

    task normal_read_check(input logic [5:0] addr, input logic [7:0] expected);
        begin
            csin    = 1'b1;
            rwbarin = 1'b1;
            address = addr;
            @(posedge clk);
            @(posedge clk);
            #1;
            if (dataout !== expected) FAIL();
        end
    endtask

    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        start   = 1'b0;
        csin    = 1'b0;
        rwbarin = 1'b1;
        opr     = 1'b0;
        address = 6'd0;
        datain  = 8'h00;

        repeat (2) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);

        normal_write(6'd0,  8'hAA);
        normal_read_check(6'd0, 8'hAA);

        normal_write(6'd10, 8'hA5);
        normal_read_check(6'd10, 8'hA5);

        normal_write(6'd63, 8'h3C);
        normal_read_check(6'd63, 8'h3C);

        csin = 1'b0;
        #1;
        if (dataout !== 8'h00) FAIL();

        opr = 1'b1;
        repeat (3) begin
            @(posedge clk);
            #1;
            if (fail !== 1'b0) FAIL();
        end

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        repeat (1100) begin
            @(posedge clk);
            #1;
            if (fail !== 1'b0) FAIL();
        end

        $display("@@@PASS");
        $finish;
    end

endmodule
