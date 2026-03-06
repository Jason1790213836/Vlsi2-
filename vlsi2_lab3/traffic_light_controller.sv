// traffic_light_controller.sv
module traffic_light_controller (
  input  logic       clk,
  input  logic       reset,    // asynchronous active-high reset
  output logic [1:0] light_NS, // 00=Red, 01=Yellow, 10=Green
  output logic [1:0] light_EW  // 00=Red, 01=Yellow, 10=Green
);

  typedef enum logic [2:0] {
    ST_ALL_RED,   // NS=R, EW=R
    ST_NS_GREEN,  // NS=G, EW=R
    ST_NS_YELLOW, // NS=Y, EW=R
    ST_EW_GREEN,  // NS=R, EW=G
    ST_EW_YELLOW  // NS=R, EW=Y
  } state_e;

  state_e state, next_state;

  // Block 1: Reset and State Update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= ST_ALL_RED;
    end else begin
      state <= next_state;
    end
  end

  // Block 2: Next-State and Output Logic (Moore)
  always_comb begin
    // defaults
    next_state = state;
    light_NS   = 2'b00; // Red
    light_EW   = 2'b00; // Red

    unique case (state)
      ST_ALL_RED: begin
        light_NS   = 2'b00;
        light_EW   = 2'b00;
        // reset deasserted -> next rising edge transitions here -> NS green
        next_state = ST_NS_GREEN;
      end

      ST_NS_GREEN: begin
        light_NS   = 2'b10; // Green
        light_EW   = 2'b00; // Red
        next_state = ST_NS_YELLOW;
      end

      ST_NS_YELLOW: begin
        light_NS   = 2'b01; // Yellow
        light_EW   = 2'b00; // Red
        // switch: NS becomes Red at same time EW becomes Green (by state change)
        next_state = ST_EW_GREEN;
      end

      ST_EW_GREEN: begin
        light_NS   = 2'b00; // Red
        light_EW   = 2'b10; // Green
        next_state = ST_EW_YELLOW;
      end

      ST_EW_YELLOW: begin
        light_NS   = 2'b00; // Red
        light_EW   = 2'b01; // Yellow
        // switch: EW becomes Red at same time NS becomes Green (by state change)
        next_state = ST_NS_GREEN;
      end

      default: begin
        next_state = ST_ALL_RED;
        light_NS   = 2'b00;
        light_EW   = 2'b00;
      end
    endcase
  end

endmodule
