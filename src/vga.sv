`timescale 1ns/1ps

module vga import defs_vga::*; (
    input  logic                            clk,
    input  logic                            rst_n,

    output logic                            o_draw_active,
    output logic [$clog2(VGA_H_ACTIVE)-1:0] o_active_x,
    output logic [$clog2(VGA_V_ACTIVE)-1:0] o_active_y,
    output logic                            o_h_sync,
    output logic                            o_v_sync
);

localparam H_TOTAL = VGA_H_ACTIVE + VGA_H_FRONT + VGA_H_SYNC + VGA_H_BACK;
localparam V_TOTAL = VGA_V_ACTIVE + VGA_V_FRONT + VGA_V_SYNC + VGA_V_BACK;

localparam LFT_H_SYNC_EDGE = VGA_H_ACTIVE + VGA_H_FRONT - 1;
localparam RHT_H_SYNC_EDGE = H_TOTAL - VGA_H_BACK;
localparam LFT_V_SYNC_EDGE = VGA_V_ACTIVE + VGA_V_FRONT - 1;
localparam RHT_V_SYNC_EDGE = V_TOTAL - VGA_V_BACK;

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

assign o_draw_active = (x_pos < VGA_H_ACTIVE) && (y_pos < VGA_V_ACTIVE);

// REVIEW - технически можно сделать как в комментарии ниже, потому что так 
// и предполагается, но это может привести к ошибкам. стоит ли делать эту подстраховку?
// технически она не даёт никакой доп нагрузки?
assign o_active_x = o_draw_active ? x_pos[$clog2(VGA_H_ACTIVE)-1:0] : '0;
assign o_active_y = o_draw_active ? y_pos[$clog2(VGA_V_ACTIVE)-1:0] : '0;

// assign o_active_x = x_pos[$clog2(VGA_H_ACTIVE)-1:0];
// assign o_active_y = y_pos[$clog2(VGA_V_ACTIVE)-1:0];

assign o_h_sync = (LFT_H_SYNC_EDGE < x_pos && x_pos < RHT_H_SYNC_EDGE) ? 0 : 1;
assign o_v_sync = (LFT_V_SYNC_EDGE < y_pos && y_pos < RHT_V_SYNC_EDGE) ? 0 : 1;

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
