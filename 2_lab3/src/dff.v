// File: dff.v - data flip flop module

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module dff (
    input wire pclk,                                  // Peripheral Clock
    input wire rst,                                   // Synchrous reset

    input wire [11:0] xpos_in,
    input wire [11:0] ypos_in,
    output reg [11:0] xpos_out,
    output reg [11:0] ypos_out
);

    always @(posedge pclk) begin
        if(rst) begin
            xpos_out <= 12'b0;
            ypos_out <= 12'b0;
        end
        else begin
            xpos_out <= xpos_in;
            ypos_out <= ypos_in;
        end        
    end  
endmodule