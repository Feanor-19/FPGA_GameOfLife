`timescale 1ns/1ps

module asrt_vga import defs_vga::*; (
    input logic                            clk,
    input logic                            rst_n,

    input logic                            o_draw_active,
    input logic [$clog2(VGA_H_ACTIVE)-1:0] o_active_x,
    input logic [$clog2(VGA_V_ACTIVE)-1:0] o_active_y,
    input logic                            o_h_sync,
    input logic                            o_v_sync
);

import defs::*;

localparam H_TOTAL = VGA_H_ACTIVE + VGA_H_FRONT + VGA_H_SYNC + VGA_H_BACK;
localparam V_TOTAL = VGA_V_ACTIVE + VGA_V_FRONT + VGA_V_SYNC + VGA_V_BACK;

logic rdy = 0;
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        rdy <= 1;
end

int ref_x = '0;
int ref_y = '0;
int new_ref_x;
int new_ref_y;

always_comb begin
    new_ref_x = (ref_x != H_TOTAL-1) ? ref_x + 1 : '0;
    if (new_ref_x == 0)
        new_ref_y = (ref_y != V_TOTAL-1) ? ref_y + 1 : '0;
    else
        new_ref_y = ref_y;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ref_x <= '0;
        ref_y <= '0;
    end else begin
        ref_x <= new_ref_x;
        ref_y <= new_ref_y;
    end
end

`ASSERT(DRAW_ACTIVE, o_draw_active |-> (o_active_x < VGA_H_ACTIVE) && (o_active_y < VGA_V_ACTIVE));

`ASSERT(ACTIVE_X, o_draw_active |-> int'(o_active_x) === ref_x);

`ASSERT(ACTIVE_Y, o_draw_active |-> int'(o_active_y) === ref_y);

`ASSERT(H_SYNC, (ref_x inside {[VGA_H_ACTIVE + VGA_H_FRONT : VGA_H_ACTIVE + VGA_H_FRONT + VGA_H_SYNC - 1]})
                ? !o_h_sync : o_h_sync);

`ASSERT(V_SYNC, (ref_y inside {[VGA_V_ACTIVE + VGA_V_FRONT : VGA_V_ACTIVE + VGA_V_FRONT + VGA_V_SYNC - 1]})
                ? !o_v_sync : o_v_sync);

endmodule
