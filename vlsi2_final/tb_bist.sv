module sram_fault_injector (
    input  logic       clk,
    input  logic       cs,
    input  logic       rwbar,
    input  logic [5:0] ramaddr,
    ref    logic [7:0] ram_ref [0:63],
    output logic       injected
);

    initial injected = 1'b0;

    always @(posedge clk) begin
        if (!injected && cs === 1'b1 && rwbar === 1'b0 && ramaddr === 6'd20) begin
            #1;
            force ram_ref[6'd20] = 8'h00;
            injected = 1'b1;
        end
    end

endmodule


module tb_bist;

    logic        start, rst, clk, csin, rwbarin, opr;
    logic [5:0]  address;
    logic [7:0]  datain;
    logic [7:0]  dataout;
    logic        fail;
    logic        injected;

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

    task PASS;
        begin
            $display("@@@PASS");
            $finish;
        end
    endtask

    task FAIL;
        begin
            $display("@@@FAIL");
            $finish;
        end
    endtask

    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        start   = 1'b0;
        csin    = 1'b0;
        rwbarin = 1'b0;
        opr     = 1'b1;
        address = 6'd0;
        datain  = 8'h00;

        repeat (3) @(posedge clk);
        rst = 1'b0;
        repeat (3) @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        repeat (600) begin
            @(posedge clk);
            #1;

            if (injected === 1'b1 && fail === 1'b1) begin
                $display("@@@PASS");
                $finish;
            end
        end

        FAIL();
    end

endmodule


bind sram sram_fault_injector FI (
    .clk      (clk),
    .cs       (cs),
    .rwbar    (rwbar),
    .ramaddr  (ramaddr),
    .ram_ref  (ram),
    .injected (tb_bist.injected)
);
