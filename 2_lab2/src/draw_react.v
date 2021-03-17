// File: draw_react.v
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

 module draw_react(
    input wire pclk,                                        // Peripheral Clock

    input wire [10:0] vcount_in,                     // input vertical count
    input wire vsync_in,                              // input vertical sync
    input wire vblnk_in,                              // input vertical blink
    input wire [10:0] hcount_in,                     // input horizontal count
    input wire hsync_in,                              // input horizontal sync
    input wire hblnk_in,                              // input horizontal blink
    input wire [11:0] rgb_in,

    output reg [10:0] vcount_out,                   // output vertical count
    output reg vsync_out,                            // output vertical sync
    output reg vblnk_out,                            // output vertical blink
    output reg [10:0] hcount_out,                   // output horizontal count
    output reg hsync_out,                            // output horizontal sync
    output reg hblnk_out,                            // output horizontal blink
    output reg [11:0] rgb_out
  );


  // Parameters
  localparam X_RECT       = 100;
  localparam Y_RECT       = 100;
  localparam WIDTH_RECT   = 50;
  localparam HEIGHT_RECT  = 50;
  localparam [11:0] RGB_RECT    = 12'h8_f_8;


  // This is a simple rectangle pattern generator.

  always @(posedge pclk)
  begin
    // Just pass these through.
    hsync_out <= hsync_in;
    vsync_out <= vsync_in;

    hblnk_out <= hblnk_in;
    vblnk_out <= vblnk_in;

    hcount_out <= hcount_in;
    vcount_out <= vcount_in;

    if (hcount_in >= X_RECT && hcount_in <= X_RECT + WIDTH_RECT 
      && vcount_in >= Y_RECT && vcount_in <= Y_RECT + HEIGHT_RECT) rgb_out <= RGB_RECT; 
    else 
      rgb_out <= rgb_in;  
  end
endmodule
