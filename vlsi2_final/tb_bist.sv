
module tb_bist;

    logic        start, rst, clk, csin, rwbarin, opr;
    logic [5:0]  address;
    logic [7:0]  datain;
    logic [7:0]  dataout;
    logic        fail;

    // 实例化被测设计
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

    // 时钟生成: 100MHz
    always #5 clk = ~clk;

    // Autograder 识别的 FAIL 任务
    task FAIL(input string msg);
        begin
            $display("@@@FAIL");
            $display("Reason: %s", msg);
            $finish;
        end
    endtask

    // 用于统计 Pattern 出现的次数
    int count_AA, count_55, count_F0, count_0F, count_FF;

    initial begin
        // =======================================
        // 1. 系统初始化
        // =======================================
        clk = 0; rst = 1; start = 0; csin = 0; rwbarin = 1; opr = 0; address = 0; datain = 0;
        repeat (3) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);

        // =======================================
        // 2. 验证 Normal 模式通路
        // =======================================
        // 写入测试数据
        csin = 1; rwbarin = 0; address = 6'd10; datain = 8'hA5; 
        @(posedge clk); #1;
        // 读取测试数据
        csin = 1; rwbarin = 1; address = 6'd10; datain = 8'h00; 
        @(posedge clk); 
        @(posedge clk); #1; // 等待 1 拍 SRAM 延迟
        if (dataout !== 8'hA5) FAIL("Buggy BIST: Normal mode read failed");
        csin = 0;

        // =======================================
        // 3. 启动 BIST 进行特征统计
        // =======================================
        opr = 1;
        repeat(2) @(posedge clk);
        
        start = 1;
        @(posedge clk);
        start = 0;

        count_AA = 0; count_55 = 0; count_F0 = 0; count_0F = 0; count_FF = 0;

        // 监控 BIST 运行过程 (大约耗时 1024 周期，我们监控 1100 周期)
        for (int i = 0; i < 1100; i++) begin
            @(posedge clk); 
            #2; // 避开时钟沿的毛刺

            // 统计 SRAM 吐出的测试数据
            if (dataout === 8'hAA) count_AA++;
            if (dataout === 8'h55) count_55++;
            if (dataout === 8'hF0) count_F0++;
            if (dataout === 8'h0F) count_0F++;
            if (dataout === 8'hFF) count_FF++;

            // 如果在一个“没被注入错误的 SRAM”里，fail 居然亮了，说明此设计比较器损坏！
            if (fail === 1'b1) FAIL("Buggy BIST: Fail asserted on a healthy memory");
        end

        // =======================================
        // 4. 分析统计结果，击杀 Buggy 设计
        // =======================================
        // 健康的设计，每种数据正好读取 64 次。我们设定 55~75 为宽容判定区间。
        if (count_AA < 55 || count_AA > 75) FAIL("Buggy BIST: AA pattern missing or stuck");
        if (count_55 < 55 || count_55 > 75) FAIL("Buggy BIST: 55 pattern missing or stuck");
        if (count_F0 < 55 || count_F0 > 75) FAIL("Buggy BIST: F0 pattern missing or stuck");
        if (count_0F < 55 || count_0F > 75) FAIL("Buggy BIST: 0F pattern missing or stuck");
        if (count_FF < 55 || count_FF > 75) FAIL("Buggy BIST: FF pattern missing or stuck");

        // 如果程序能运行到这里，说明设计完美！
        $display("@@@PASS");
        $finish;
    end

endmodule
