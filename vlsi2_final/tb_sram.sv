module tb_sram;

    logic [5:0] ramaddr;
    logic [7:0] ramin;
    logic       rwbar;
    logic       clk;
    logic       cs;
    logic [7:0] ramout;

    sram dut (
        .ramaddr(ramaddr),
        .ramin(ramin),
        .rwbar(rwbar),
        .clk(clk),
        .cs(cs),
        .ramout(ramout)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 1'b0;
        cs      = 1'b0;
        rwbar   = 1'b1;
        ramaddr = 6'd0;
        ramin   = 8'h00;

        #1;
        if (ramout !== 8'h00) begin
            $display("@@@FAIL");
            $finish;
        end

        // write 0xA5 to address 10
        cs      = 1'b1;
        rwbar   = 1'b0;
        ramaddr = 6'd10;
        ramin   = 8'hA5;
        @(posedge clk);
        #1;

        if (ramout !== 8'h00) begin
            $display("@@@FAIL");
            $finish;
        end

        // read address 10
        rwbar   = 1'b1;
        ramaddr = 6'd10;
        @(posedge clk);
        #1;

        if (ramout !== 8'hA5) begin
            $display("@@@FAIL");
            $finish;
        end

        // write 0x3C to address 25
        rwbar   = 1'b0;
        ramaddr = 6'd25;
        ramin   = 8'h3C;
        @(posedge clk);
        #1;

        if (ramout !== 8'h00) begin
            $display("@@@FAIL");
            $finish;
        end

        // read address 25
        rwbar   = 1'b1;
        ramaddr = 6'd25;
        @(posedge clk);
        #1;

        if (ramout !== 8'h3C) begin
            $display("@@@FAIL");
            $finish;
        end

        // cs off should force output 0
        cs = 1'b0;
        #1;

        if (ramout !== 8'h00) begin
            $display("@@@FAIL");
            $finish;
        end

        $display("@@@PASS");
        $finish;
    end

endmodule
