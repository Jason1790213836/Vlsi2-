module traffic_light_controller (
  input  logic clk,
  input  logic reset,     // asynchronous active-high reset
  output logic [1:0] light_NS, // 00=Red, 01=Yellow, 10=Green
  output logic [1:0] light_EW
);

  typedef enum logic [1:0]{
    ST_NS_G = 2'd0,
    ST_NS_Y = 2'd1,
    ST_EW_G = 2'd2,
    ST_EW_Y = 2'd3
  } state_e;

  state_e state, state_next;
  logic   just_released;

  // Block 1: Reset and State Update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= ST_NS_G;
      just_released <= 1'b1;
    end else begin
      if (just_released) begin
        // first rising edge after reset: must be NS green
        state         <= ST_NS_G;
        just_released <= 1'b0;
      end else begin
        state <= state_next;
      end
    end
  end

  // Block 2: Next-State and Output Logic
  always_comb begin
    state_next = state;
    light_NS   = 2'b00;
    light_EW   = 2'b00;

    if (reset) begin
      light_NS = 2'b00;
      light_EW = 2'b00;
    end else begin
      unique case (state)
        ST_NS_G: begin
          light_NS   = 2'b10; // Green
          light_EW   = 2'b00; // Red
          state_next = ST_NS_Y;
        end
        ST_NS_Y: begin
          light_NS   = 2'b01; // Yellow
          light_EW   = 2'b00; // Red
          state_next = ST_EW_G;
        end
        ST_EW_G: begin
          light_NS   = 2'b00; // Red
          light_EW   = 2'b10; // Green
          state_next = ST_EW_Y;
        end
        ST_EW_Y: begin
          light_NS   = 2'b00; // Red
          light_EW   = 2'b01; // Yellow
          state_next = ST_NS_G;
        end
        default: begin
          light_NS   = 2'b00;
          light_EW   = 2'b00;
          state_next = ST_NS_G;
        end
      endcase
    end
  end

endmodule
