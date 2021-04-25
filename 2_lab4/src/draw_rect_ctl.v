// File: draw_rect_ctl.v
// This module draw a rectangle on the backround.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module draw_rect_ctl (
    input wire pclk,
    input wire rst,

    input wire mouse_left,
    input wire [11:0] mouse_xpos,
    input wire [11:0] mouse_ypos,

    output reg [11:0] xpos,
    output reg [11:0] ypos
);
  reg [1:0] state, next_state;
  reg [11:0] xpos_nxt, ypos_nxt;
  reg [11:0] ypos_tmp, ypos_tmp_nxt;
  
  localparam RESET = 2'b00;
  localparam IDLE = 2'b01;
  localparam LEFT_DOWN = 2'b10;
  localparam LEFT_UP = 2'b11;

  localparam DISPLAY_HEIGHT = 600;
  localparam WIDTH_RECT   = 48;                    
  localparam HEIGHT_RECT  = 64;
  localparam CLK = 40000000;            // freq_clk = 40MHz 
  localparam REFRESH_RATE = 60;         // Screen refreshing = 60Hz
  localparam COUNTER = (CLK/REFRESH_RATE);
  localparam ACCELERATION = (981/100);

  reg[5:0] acc,acc_nxt = 1;           // register for modeling acceleration
  reg [7:0] f_time, f_time_nxt = 0;         // falling time 
  reg [20:0] refresh_counter = 0, refresh_counter_nxt = 0;

  localparam Y_DELTA = 3;             // const for falling down

// ---------------------------------------
// state register

  always @(posedge pclk) begin
    state <= next_state;
    xpos  <= xpos_nxt;
    ypos  <= ypos_nxt;
    ypos_tmp <= ypos_tmp_nxt;

    acc <= acc_nxt;
    refresh_counter <= refresh_counter_nxt;
    f_time <= f_time_nxt; 
  end

// ---------------------------------------
// next state logic
  always @(state or rst or mouse_left) begin
    case(state)
      IDLE:
        begin
          if(rst) begin
            next_state = RESET;
          end
          else begin
            if(mouse_left)
              next_state = LEFT_DOWN;
            else begin
              next_state = IDLE;
            end
          end
        end
      LEFT_DOWN: next_state = mouse_left ? LEFT_DOWN : LEFT_UP;
      LEFT_UP: next_state = IDLE;
      RESET: next_state = rst ? RESET : IDLE;
    endcase
  end

  always @* begin

    case(state)
      RESET:
        begin
          xpos_nxt = 12'b0;
          ypos_nxt = 12'b0;
          ypos_tmp_nxt = 12'b0;
        end

      LEFT_DOWN:
        begin
          xpos_nxt = mouse_xpos;
          if(refresh_counter == COUNTER) begin
            acc_nxt = acc +1;
            refresh_counter_nxt = 0;
            f_time_nxt = f_time + (1/REFRESH_RATE);
            if(ypos_tmp < DISPLAY_HEIGHT - HEIGHT_RECT - 1) begin
              ypos_tmp_nxt = ypos_tmp + (Y_DELTA*acc);
              //ypos_tmp_nxt = (f_time*f_time*ACCELERATION)/2;
              ypos_nxt = ypos_tmp;
            end
            else begin
              ypos_nxt = DISPLAY_HEIGHT - HEIGHT_RECT - 1;
              ypos_tmp_nxt = DISPLAY_HEIGHT - HEIGHT_RECT - 1;
            end
          end
          else begin
            refresh_counter_nxt = refresh_counter + 1;
            ypos_tmp_nxt = ypos_tmp;
            ypos_nxt = ypos_tmp;
          end 
        end

      LEFT_UP:
        begin
          f_time_nxt = 0;
          acc_nxt = 1;
          ypos_tmp_nxt = mouse_ypos; 
          xpos_nxt = mouse_xpos;
          ypos_nxt = mouse_ypos;
        end

      IDLE:
        begin
          ypos_tmp_nxt = mouse_ypos; 
          xpos_nxt = mouse_xpos;
          ypos_nxt = mouse_ypos;
        end

      default:          // including LEFT_UP and IDLE
        begin
          ypos_tmp_nxt = mouse_ypos; 
          xpos_nxt = mouse_xpos;
          ypos_nxt = mouse_ypos;
        end

      endcase
  end

endmodule


      

