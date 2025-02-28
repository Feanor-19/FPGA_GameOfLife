`timescale 1ns/1ps

module field_cfg_rom #(
    parameter FIELD_W,
    parameter FIELD_H,
    parameter CONFIG_ID,

    localparam X_ADR_SIZE = $clog2(FIELD_W),
    localparam Y_ADR_SIZE = $clog2(FIELD_H)
) (
    input  logic [X_ADR_SIZE-1:0] i_cell_x_adr,
    input  logic [Y_ADR_SIZE-1:0] i_cell_y_adr,

    output logic                  o_cell_state
);

// readmemb doesn't work with multi-dimensional arrays, also it seems to require 
// data in the file to be written like in hex, although it is readmemB
logic mem [FIELD_W*FIELD_H];

assign o_cell_state = mem[i_cell_y_adr * FIELD_W + integer'(i_cell_x_adr)];

initial $readmemb($sformatf("field_configs/field_config_%0d.txt", CONFIG_ID), mem);

endmodule
