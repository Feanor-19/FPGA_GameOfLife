`timescale 1ns/1ps

`define NEIGHBOURS_CNT 8 //REVIEW

module get_nbrs_address #(
    parameter FIELD_W = 50,
    parameter FIELD_H = 50
) (
    input  logic [$clog2(FIELD_W)-1:0] i_cell_x_ad,
    input  logic [$clog2(FIELD_H)-1:0] i_cell_y_ad, 

    output logic [$clog2(FIELD_W)-1:0] o_nbrs_x_ad  [`NEIGHBOURS_CNT],
    output logic [$clog2(FIELD_H)-1:0] o_nbrs_y_ad  [`NEIGHBOURS_CNT],
    output logic                       o_nbrs_rlvnt [`NEIGHBOURS_CNT]
);
    
/* neighbours numbering (for NBRS_CNT = 8), x = central cell
*  * - - - > x (width)
*  | 0 1 2
*  | 3 x 4
*  | 5 6 7
*  v
*  y (height)
*/

logic adj_top, adj_left, adj_right, adj_bottom; 

//REVIEW - реально ли это написать адекватнее?...

assign adj_top      = (i_cell_y_ad == 0);
assign adj_left     = (i_cell_x_ad == 0);
assign adj_bottom   = (i_cell_y_ad == FIELD_H - 1);
assign adj_right    = (i_cell_x_ad == FIELD_W - 1);

assign o_nbrs_rlvnt[0] = !(adj_top | adj_left);
assign o_nbrs_rlvnt[1] = !(adj_top);
assign o_nbrs_rlvnt[2] = !(adj_top | adj_right);
assign o_nbrs_rlvnt[3] = !(adj_left);
assign o_nbrs_rlvnt[4] = !(adj_right);
assign o_nbrs_rlvnt[5] = !(adj_bottom | adj_left);
assign o_nbrs_rlvnt[6] = !(adj_bottom)
assign o_nbrs_rlvnt[7] = !(adj_bottom | adj_right)

always_comb begin
    
end

endmodule

`undef NEIGHBOURS_CNT
