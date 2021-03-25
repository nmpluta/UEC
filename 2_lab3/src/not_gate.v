// File: not_gate.v - inverter
// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module not_gate (
    input wire in_data,
    output wire out_data 
);

    assign out_data=~in_data;

endmodule