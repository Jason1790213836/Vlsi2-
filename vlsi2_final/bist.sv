module bist #(
    parameter size   = 6,
    parameter length = 8
)(
    input  logic               start,
    input  logic               rst,
    input  logic               clk,
    input  logic               csin,
    input  logic               rwbarin,
    input  logic               opr,
    input  logic [size-1:0]    address,
    input  logic [length-1:0]  datain,
    output logic [length-1:0]  dataout,
    output logic               fail
);

    logic NbarT, ld;
    logic [9:0] q;
    logic cout;

    logic [length-1:0] data_t;
    logic [size-1:0]   ramaddr_sel;
    logic [length-1:0] ramin_sel;

    logic rwbar_sel;
    logic cs_sel;

    logic [length-1:0] ramout;
    logic gt, eq, lt;

    logic [length-1:0] data_t_d;
    logic              rwbar_d;
    logic              NbarT_d;
    logic              opr_d;

    controller u_controller (
        .start (start),
        .rst   (rst),
        .clk   (clk),
        .cout  (cout),
        .NbarT (NbarT),
        .ld    (ld)
    );

    counter #(.length(10)) u_counter (
        .d_in (10'b0),
        .clk  (clk),
        .ld   (ld),
        .u_d  (1'b1),
        .cen  (1'b1),
        .q    (q),
        .cout (cout)
    );

    decoder u_decoder (
        .q      (q[9:7]),
        .data_t (data_t)
    );

    multiplexer #(.WIDTH(size)) u_addr_mux (
        .normal_in (address),
        .bist_in   (q[size-1:0]),
        .NbarT     (NbarT),
        .out       (ramaddr_sel)
    );

    multiplexer #(.WIDTH(length)) u_data_mux (
        .normal_in (datain),
        .bist_in   (data_t),
        .NbarT     (NbarT),
        .out       (ramin_sel)
    );

    assign rwbar_sel = (NbarT) ? q[6] : rwbarin;
    assign cs_sel    = (NbarT) ? 1'b1 : csin;

    sram u_sram (
        .ramaddr (ramaddr_sel),
        .ramin   (ramin_sel),
        .rwbar   (rwbar_sel),
        .clk     (clk),
        .cs      (cs_sel),
        .ramout  (ramout)
    );

    comparator u_comparator (
        .data_t (data_t),
        .ramout (ramout),
        .gt     (gt),
        .eq     (eq),
        .lt     (lt)
    );

    assign dataout = ramout;

    always_ff @(posedge clk) begin
        if (rst) begin
            data_t_d <= '0;
            rwbar_d  <= 1'b0;
            NbarT_d  <= 1'b0;
            opr_d    <= 1'b0;
            fail     <= 1'b0;
        end else begin
            data_t_d <= data_t;
            rwbar_d  <= rwbar_sel;
            NbarT_d  <= NbarT;
            opr_d    <= opr;

            if (NbarT_d && opr_d && rwbar_d && (ramout !== data_t_d))
                fail <= 1'b1;
            else
                fail <= 1'b0;
        end
    end

endmodule
