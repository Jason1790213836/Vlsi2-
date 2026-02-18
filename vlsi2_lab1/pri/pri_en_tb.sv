`timescale 1ns/1ps

module pri_en_tb();

    // Input
    logic [3:0] I;

    // Output
    logic [1:0] Y;

    // DUT
    pri_en DUT(.*);

    initial begin
        
        #1;

        // Test all 16 input combinations
        for (int v = 0; v < 16; v++) begin

            I = v[3:0];
            #1;

            // Expected behavior of priority encoder
            if (I[3]) begin
                if (Y !== 2'b11) begin
                    $display("@@@FAIL: I=%b Y=%b (expected 11)", I, Y);
                    $finish;
                end
            end
            else if (I[2]) begin
                if (Y !== 2'b10) begin
                    $display("@@@FAIL: I=%b Y=%b (expected 10)", I, Y);
                    $finish;
                end
            end
            else if (I[1]) begin
                if (Y !== 2'b01) begin
                    $display("@@@FAIL: I=%b Y=%b (expected 01)", I, Y);
                    $finish;
                end
            end
            else begin
                // covers 0001 and 0000
                if (Y !== 2'b00) begin
                    $display("@@@FAIL: I=%b Y=%b (expected 00)", I, Y);
                    $finish;
                end
            end

            $display("case passed: I=%b Y=%b", I, Y);

        end

        $display("@@@PASS");
        $finish;

    end

endmodule

