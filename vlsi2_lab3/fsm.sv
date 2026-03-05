`include "fsm_pkg.svh"
import fsm10_pkg::*;

module fsm(
    input  logic   rst_n,   // asynchronous active-low reset
    input  logic   clk,
    input  logic   jmp,
    input  logic   go,
    output logic   y,
    output state_e state
);

    // Moore output: y depends only on state (y=1 only in S3)
    assign y = (state == S3);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
        end else begin
            unique case (state)
                S0: begin
                    if (!go)       state <= S0;
                    else if (!jmp) state <= S1;
                    else           state <= S3;  // go & jmp
                end

                S1: begin
                    if (!jmp) state <= S2;
                    else      state <= S3;
                end

                S2: begin
                    state <= S3;
                end

                S3: begin
                    if (!jmp) state <= S4;
                    else      state <= S3;  // jmp stays in S3
                end

                S4: begin
                    if (!jmp) state <= S5;
                    else      state <= S3;
                end

                S5: begin
                    if (!jmp) state <= S6;
                    else      state <= S3;
                end

                S6: begin
                    if (!jmp) state <= S7;
                    else      state <= S3;
                end

                S7: begin
                    if (!jmp) state <= S8;
                    else      state <= S3;
                end

                S8: begin
                    if (!jmp) state <= S9;
                    else      state <= S3;
                end

                S9: begin
                    if (!jmp) state <= S0;
                    else      state <= S3;
                end

                default: begin
                    state <= S0;
                end
            endcase
        end
    end

endmodule
