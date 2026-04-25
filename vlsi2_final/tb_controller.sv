module tb_controller();

logic clk;
logic rst;
logic start;
logic cout;    
logic NbarT;
logic ld;

controller dut(.*);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1'b1;
    start = 1'b1;
    cout = 1'b1;
        
    @(negedge clk);
    @(negedge clk);
    if (NbarT !== 1'b0 || ld !== 1'b1) begin
        $display("@@@FAIL");
        $finish();
    end

    rst = 1'b0;
    start = 1'b0;
    cout = 1'b0;
        
    @(negedge clk);
    if (NbarT !== 1'b0 || ld !== 1'b1) begin
        $display("@@@FAIL");
        $finish();
    end

    start = 1'b1;    
    @(negedge clk);
    start = 1'b0;
    if (NbarT !== 1'b1 || ld !== 1'b0) begin 
        $display("@@@FAIL");
        $finish();
    end

    @(negedge clk);
    @(negedge clk);
    if (NbarT !== 1'b1 || ld !== 1'b0) begin
        $display("@@@FAIL");
        $finish();
    end

    cout = 1'b1;    
    @(negedge clk);
    cout = 1'b0;    
    if (NbarT !== 1'b0 || ld !== 1'b1) begin
        $display("@@@FAIL");
        $finish();
    end
    
    start = 1'b1;
    @(negedge clk);
    if (NbarT !== 1'b1 || ld !== 1'b0) begin
        $display("@@@FAIL");
        $finish();
    end
        
    cout = 1'b1;
    @(negedge clk);
    cout = 1'b0;    
    if (NbarT !== 1'b0 || ld !== 1'b1) begin
        $display("@@@FAIL");
        $finish();
    end
        
    @(negedge clk);
    start = 1'b0;
    if (NbarT !== 1'b1 || ld !== 1'b0) begin
        $display("@@@FAIL");
        $finish();
    end
    
    cout = 1'b1;
    @(negedge clk);
    cout = 1'b0;

    start = 1'b1;
    cout  = 1'b1;    
    @(negedge clk);
    if (NbarT !== 1'b1 || ld !== 1'b0) begin
        $display("@@@FAIL");
        $finish();
    end
        
    @(negedge clk);
    if (NbarT !== 1'b0 || ld !== 1'b1) begin
        $display("@@@FAIL");
        $finish();
    end

    $display("@@@PASS");
    $finish();
end

endmodule
