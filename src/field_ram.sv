module field_ram #(
    parameter FIELD_W = 30,
    parameter FIELD_H = 50,

    localparam X_ADR_SIZE     = $clog2(FIELD_W),
    localparam Y_ADR_SIZE     = $clog2(FIELD_H),
    localparam NEIGHBOURS_CNT = 8 //REVIEW
) (
    input  logic                      clk,
    input  logic                      rst, 

    input  logic [X_ADR_SIZE-1:0]     i_cell_x_adr,
    input  logic [Y_ADR_SIZE-1:0]     i_cell_y_adr,

    input  logic                      i_w_en,
    input  logic                      i_new_cell_state, 

    output logic                      o_cell_state,
    output logic [NEIGHBOURS_CNT-1:0] o_nbrs
);

logic [FIELD_H-1:0] [FIELD_W-1:0] field;

logic [X_ADR_SIZE-1:0] nbrs_x_adr [NEIGHBOURS_CNT];
logic [Y_ADR_SIZE-1:0] nbrs_y_adr [NEIGHBOURS_CNT];
logic                  nbrs_rlvnt [NEIGHBOURS_CNT];

get_nbrs_address get_nbrs_address_inst (
    .i_cell_x_adr   (i_cell_x_adr),
    .i_cell_y_adr   (i_cell_y_adr),
    
    .o_nbrs_x_adr   (nbrs_x_adr),
    .o_nbrs_y_adr   (nbrs_y_adr),
    .o_nbrs_rlvnt   (nbrs_rlvnt)
);

assign o_cell_state = field[i_cell_y_adr][i_cell_x_adr];

always_comb begin
    for (int i = 0; i != NEIGHBOURS_CNT; i++)
        o_nbrs[i] = nbrs_rlvnt[i] ? field[nbrs_y_adr[i]][nbrs_x_adr[i]] : 0; 
end

always @(posedge clk, posedge rst) begin
    if (rst)
        field <= 'b0;
    else if (i_w_en)
        field[i_cell_y_adr][i_cell_x_adr] <= i_new_cell_state;
end

endmodule