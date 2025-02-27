`timescale 1ns/1ps

module field_ram import defs::NEIGHBOURS_CNT; #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE = $clog2(FIELD_W),
    localparam Y_ADR_SIZE = $clog2(FIELD_H)
) (
    input  logic                      clk,

    input  logic [X_ADR_SIZE-1:0]     i_cell_x_adr_prw1, // port 1, read (with nbrs)/write
    input  logic [Y_ADR_SIZE-1:0]     i_cell_y_adr_prw1, // port 1, read (with nbrs)/write 

    input  logic [X_ADR_SIZE-1:0]     i_cell_x_adr_pr2,  // port 2, read (w/o nbrs)
    input  logic [Y_ADR_SIZE-1:0]     i_cell_y_adr_pr2,  // port 2, read (w/o nbrs)
    
    input  logic                      i_w_en_p1,
    input  logic                      i_new_cell_state_p1, 

    output logic                      o_cell_state_pr1,
    output logic [NEIGHBOURS_CNT-1:0] o_nbrs_pr1,

    output logic                      o_cell_state_pr2
);

logic field [FIELD_H-1:0] [FIELD_W-1:0];

logic [X_ADR_SIZE-1:0] nbrs_x_adr [NEIGHBOURS_CNT];
logic [Y_ADR_SIZE-1:0] nbrs_y_adr [NEIGHBOURS_CNT];
logic                  nbrs_rlvnt [NEIGHBOURS_CNT];

get_nbrs_address #(
    .FIELD_W        (FIELD_W),
    .FIELD_H        (FIELD_H)
) get_nbrs_address_inst (
    .i_cell_x_adr   (i_cell_x_adr_prw1),
    .i_cell_y_adr   (i_cell_y_adr_prw1),
    
    .o_nbrs_x_adr   (nbrs_x_adr),
    .o_nbrs_y_adr   (nbrs_y_adr),
    .o_nbrs_rlvnt   (nbrs_rlvnt)
);

assign o_cell_state_pr1 = field[i_cell_y_adr_prw1][i_cell_x_adr_prw1];
assign o_cell_state_pr2 = field[i_cell_y_adr_pr2][i_cell_x_adr_pr2];

always_comb begin
    for (int i = 0; i != NEIGHBOURS_CNT; i++)
        o_nbrs_pr1[i] = nbrs_rlvnt[i] ? field[nbrs_y_adr[i]][nbrs_x_adr[i]] : 0; 
end

always_ff @(posedge clk) begin
    if (i_w_en_p1)
        field[i_cell_y_adr_prw1][i_cell_x_adr_prw1] <= i_new_cell_state_p1;
end

endmodule
