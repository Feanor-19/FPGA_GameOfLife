`timescale 1ns/1ps

module vga (
    input  logic                        clk,
    input  logic                        rst_n,

    output logic                        o_draw_active,
    output logic [$clog2(H_ACTIVE)-1:0] o_active_x,
    output logic [$clog2(V_ACTIVE)-1:0] o_active_y,
    output logic                        o_h_sync,
    output logic                        o_v_sync
);

import defs_vga::*;

localparam H_ACTIVE = VGA_H_ACTIVE;
localparam H_FRONT  = VGA_H_FRONT;
localparam H_SYNC   = VGA_H_SYNC;
localparam H_BACK   = VGA_H_BACK;

localparam V_ACTIVE = VGA_V_ACTIVE;
localparam V_FRONT  = VGA_V_FRONT;
localparam V_SYNC   = VGA_V_SYNC;
localparam V_BACK   = VGA_V_BACK;

localparam H_TOTAL = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;
localparam V_TOTAL = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

logic [$clog2(H_TOTAL)-1:0] x_pos;
logic [$clog2(V_TOTAL)-1:0] y_pos;

logic [$clog2(H_TOTAL)-1:0] next_x_pos;
logic [$clog2(V_TOTAL)-1:0] next_y_pos;

get_next_coords #(
    .FIELD_W    (H_TOTAL),
    .FIELD_H    (V_TOTAL)
) get_next_coords_inst (
    .i_x        (x_pos),
    .i_y        (y_pos),

    .o_next_x   (next_x_pos),
    .o_next_y   (next_y_pos)
);

assign o_draw_active = (x_pos < H_ACTIVE) & (y_pos < V_ACTIVE);

assign o_active_x = o_draw_active ? x_pos[$clog2(H_ACTIVE)-1:0] : '0;
assign o_active_y = o_draw_active ? y_pos[$clog2(V_ACTIVE)-1:0] : '0;

assign o_h_sync = (H_ACTIVE+H_FRONT-1 < x_pos & x_pos < H_TOTAL-H_BACK) ? 0 : 1;
assign o_v_sync = (V_ACTIVE+V_FRONT-1 < y_pos & y_pos < V_TOTAL-V_BACK) ? 0 : 1;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        x_pos <= 0;
        y_pos <= 0;
    end else begin
        x_pos <= next_x_pos;
        y_pos <= next_y_pos;
    end
end

endmodule
