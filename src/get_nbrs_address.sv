`timescale 1ns/1ps

module get_nbrs_address #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE     = $clog2(FIELD_W),
    localparam Y_ADR_SIZE     = $clog2(FIELD_H),
    localparam NEIGHBOURS_CNT = 8 //REVIEW
) (
    input  logic [X_ADR_SIZE-1:0] i_cell_x_adr,
    input  logic [Y_ADR_SIZE-1:0] i_cell_y_adr, 

    output logic [X_ADR_SIZE-1:0] o_nbrs_x_adr [NEIGHBOURS_CNT],
    output logic [Y_ADR_SIZE-1:0] o_nbrs_y_adr [NEIGHBOURS_CNT],
    output logic                  o_nbrs_rlvnt [NEIGHBOURS_CNT]
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

assign adj_top      = (i_cell_y_adr == 0);
assign adj_left     = (i_cell_x_adr == 0);
assign adj_bottom   = (i_cell_y_adr == (Y_ADR_SIZE)'(FIELD_H - 1));
assign adj_right    = (i_cell_x_adr == (X_ADR_SIZE)'(FIELD_W - 1));

assign o_nbrs_rlvnt[0] = !(adj_top | adj_left);
assign o_nbrs_rlvnt[1] = !(adj_top);
assign o_nbrs_rlvnt[2] = !(adj_top | adj_right);
assign o_nbrs_rlvnt[3] = !(adj_left);
assign o_nbrs_rlvnt[4] = !(adj_right);
assign o_nbrs_rlvnt[5] = !(adj_bottom | adj_left);
assign o_nbrs_rlvnt[6] = !(adj_bottom);
assign o_nbrs_rlvnt[7] = !(adj_bottom | adj_right);

always_comb begin
    for (int i = 0; i != 8; i++) begin
        o_nbrs_x_adr[i] = i_cell_x_adr; 
        o_nbrs_y_adr[i] = i_cell_y_adr;
    end

    o_nbrs_x_adr[0] -= 1'b1;
    o_nbrs_y_adr[0] -= 1'b1;

    o_nbrs_y_adr[1] -= 1'b1;

    o_nbrs_x_adr[2] += 1'b1;
    o_nbrs_y_adr[2] -= 1'b1;

    o_nbrs_x_adr[3] -= 1'b1;

    o_nbrs_x_adr[4] += 1'b1;

    o_nbrs_x_adr[5] -= 1'b1;
    o_nbrs_y_adr[5] += 1'b1;
    
    o_nbrs_y_adr[6] += 1'b1;

    o_nbrs_x_adr[7] += 1'b1;
    o_nbrs_y_adr[7] += 1'b1;
end

endmodule
