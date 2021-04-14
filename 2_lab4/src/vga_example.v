// File: vga_example.v
// This is the top level design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_example (
  input wire clk,
  input wire rst,                         // U17 button - reset <-- look to vga_example.xdc
  output wire vs,
  output wire hs,
  output wire [3:0] r,
  output wire [3:0] g,
  output wire [3:0] b,
  output wire pclk_mirror,

  inout wire ps2_clk,
  inout wire ps2_data
  );

/*
  // Converts 100 MHz clk into 40 MHz pclk.
  // This uses a vendor specific primitive
  // called MMCME2, for frequency synthesis.

  wire clk_in;
  wire locked;
  wire clk_fb;
  wire clk_ss;
  wire clk_out;
  wire pclk;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg [7:0] safe_start = 0;


  IBUF clk_ibuf (.I(clk),.O(clk_in));

  MMCME2_BASE #(
    .CLKIN1_PERIOD(10.000),
    .CLKFBOUT_MULT_F(10.000),
    .CLKOUT0_DIVIDE_F(25.000))
  clk_in_mmcme2 (
    .CLKIN1(clk_in),
    .CLKOUT0(clk_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(clkfb),
    .CLKFBOUTB(),
    .CLKFBIN(clkfb),
    .LOCKED(locked),
    .PWRDWN(1'b0),
    .RST(1'b0)
  );

  BUFH clk_out_bufh (.I(clk_out),.O(clk_ss));
  always @(posedge clk_ss) safe_start<= {safe_start[6:0],locked};

  BUFGCE clk_out_bufgce (.I(clk_out),.CE(safe_start[7]),.O(pclk));
*/
  wire pclk;
  wire mouse_clk;
  wire locked;
  
  clk_wiz_0 my_clk_wiz_0(
      .clk(clk),
      .clk40Mhz(pclk),
      .clk100Mhz(mouse_clk),
      .locked(locked),
      .reset(rst)
  );

  // Mirrors pclk on a pin for use by the testbench;
  // not functionally required for this design to work.

  ODDR pclk_oddr (
    .Q(pclk_mirror),
    .C(pclk),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
  );

  // lock_reset 
  wire rst_lock;

  lock_reset my_lock_reset(
    .lowest_freq_clk(pclk),
    .locked(locked),
    .rst_out(rst_lock)
  );
  
  // Instantiate the vga_timing module, which is
  // the module you are designing for this lab.

  wire [10:0] vcount, hcount;
  wire vsync, hsync;
  wire vblnk, hblnk;

  vga_timing my_timing (
    .vcount(vcount),
    .vsync(vsync),
    .vblnk(vblnk),
    .hcount(hcount),
    .hsync(hsync),
    .hblnk(hblnk),

    .pclk(pclk),
    .rst(rst_lock)
  );

  // Instantiate the draw_background module, which is
  // the module you are designing for this lab.

  wire [10:0] vcount_b, hcount_b;
  wire vsync_b, hsync_b;
  wire vblnk_b, hblnk_b;
  wire [11:0] rgb_b;

  draw_background my_draw_background(
    .pclk(pclk),
    .rst(rst_out),

    //input
    .vcount_in(vcount),
    .vsync_in(vsync),
    .vblnk_in(vblnk),
    .hcount_in(hcount),
    .hsync_in(hsync),
    .hblnk_in(hblnk),

    //output
    .vcount_out(vcount_b),
    .vsync_out(vsync_b),
    .vblnk_out(vblnk_b),
    .hcount_out(hcount_b),
    .hsync_out(hsync_b),
    .hblnk_out(hblnk_b),
    .rgb_out(rgb_b)
  );

  // Instantiate the MouseCtl module, which is
  // the module you are using for this lab.
  wire [11:0] xpos_m, ypos_m;

  MouseCtl my_MouseCtl(
    .clk(mouse_clk),
  
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    .xpos(xpos_m),
    .ypos(ypos_m)
  );

  // Instantiate the dff (data flip flip) module, which is
  // the module you are designing for this lab.
  wire [11:0] xpos_dff, ypos_dff;

  dff my_dff(
    .pclk(pclk),
    .rst(rst_out),

    .xpos_in(xpos_m),
    .ypos_in(ypos_m),
    .xpos_out(xpos_dff),
    .ypos_out(ypos_dff)
  );

  // Instantiate the draw_react module, which is
  // the module you are designing for this lab.
  wire [10:0] vcount_r, hcount_r;
  wire vsync_r, hsync_r;
  wire vblnk_r, hblnk_r;
  wire [11:0] rgb_r;
  wire [11:0] rgb_pixel, pixel_addr;

  draw_react my_draw_react(
    .pclk(pclk),
    .rst(rst_out),

    // input x, y position of the mouse through dff
    .xpos(xpos_dff),
    .ypos(ypos_dff),

    //input
    .vcount_in(vcount_b),
    .vsync_in(vsync_b),
    .vblnk_in(vblnk_b),
    .hcount_in(hcount_b),
    .hsync_in(hsync_b),
    .hblnk_in(hblnk_b),
    .rgb_in(rgb_b),
    .rgb_pixel(rgb_pixel),

    //output
    .vcount_out(vcount_r),
    .vsync_out(vsync_r),
    .vblnk_out(vblnk_r),
    .hcount_out(hcount_r),
    .hsync_out(hsync_r),
    .hblnk_out(hblnk_r),
    .rgb_out(rgb_r),
    .pixel_addr(pixel_addr)
  );

  // Instantiate the image_rom module, which is
  // the module you are using for this lab.

  image_rom my_image_rom(
    .clk(pclk),
    .address(pixel_addr),
    .rgb(rgb_pixel)
  );

  // Instantiate the MouseDisplay module, which is
  // the module you are using for this lab.
  wire [3:0] rgb_red, rgb_green, rgb_blue;

    MouseDisplay my_MouseDisplay(
    .pixel_clk(pclk),
    .xpos(xpos_dff),
    .ypos(ypos_dff),
    .hcount({1'b0, hcount_r}),
    .vcount({1'b0, vcount_r}),
    .blank(vblnk_r||hblnk_r),

    .red_in(rgb_r[11:8]),
    .green_in(rgb_r[7:4]),
    .blue_in(rgb_r[3:0]),  

    .red_out(rgb_red),
    .green_out(rgb_green),
    .blue_out(rgb_blue)
  );

    // Just pass these through.
    assign hs = hsync_r;
    assign vs = vsync_r;
    assign r  = rgb_red;
    assign g  = rgb_green;
    assign b  = rgb_blue;
    
endmodule
