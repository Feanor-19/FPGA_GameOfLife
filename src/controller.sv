`timescale 1ns/1ps

module controller #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE     = $clog2(FIELD_W),
    localparam Y_ADR_SIZE     = $clog2(FIELD_H),
    localparam NEIGHBOURS_CNT = 8 //REVIEW
) (
    input  logic clk,
    input  logic rst,
    input  logic pause
);

typedef struct packed {
    enum logic {FIELD_A, FIELD_B} field;
    
    logic is_simulating;
    
    logic [X_ADR_SIZE-1:0] x;
    logic [Y_ADR_SIZE-1:0] y;
} cntrler_state_t;

cntrler_state_t state, new_state;

logic field_A_w_en, field_B_w_en;
logic new_cell_state;

logic cell_state_A, nbrs_A;
logic cell_state_B, nbrs_B;
logic cur_cell_state, cur_nbrs;

field_ram field_A #(
    .FIELD_W(FIELD_W),
    .FIELD_H(FIELD_H)
) (
    .clk                (clk),
    .rst                (rst),

    .i_cell_x_adr       (state.x),
    .i_cell_y_adr       (state.y),

    .i_w_en             (field_A_w_en),
    .i_new_cell_state   (new_cell_state),

    .o_cell_state       (cell_state_A),
    .o_nbrs             (nbrs_A)
);

field_ram field_B #(
    .FIELD_W(FIELD_W),
    .FIELD_H(FIELD_H)
) (
    .clk                (clk),
    .rst                (rst),

    .i_cell_x_adr       (state.x),
    .i_cell_y_adr       (state.y),

    .i_w_en             (field_B_w_en),
    .i_new_cell_state   (new_cell_state),

    .o_cell_state       (cell_state_B),
    .o_nbrs             (nbrs_B)
);

next_cell_state next_cell_state_inst (
    .i_nbrs         (cur_nbrs),
    .i_cell_state   (cur_cell_state),

    .o_cell_state   (new_cell_state)
);

assign cur_cell_state = (state.field == FIELD_A) ? cell_state_A : cell_state_B;
assign cur_nbrs       = (state.field == FIELD_A) ? nbrs_A       : nbrs_B;

assign field_A_w_en   = (state.field == FIELD_B) ? 1 : 0;
assign field_B_w_en   = ~field_A_w_en;

always_comb begin
    new_state = state; // REVIEW чтобы не писать new = old ниже в некоторых случаях?
    if (!state.is_simulating) begin
        new_state.is_simulating = 1;
        new_state.x = '0;
        new_state.y = '0;
    end else if (state.x == FIELD_W-1 & state.y == FIELD_H-1) begin
        new_state.is_simulating = 0;
        new_state.field = ~state.field;    
    end else begin
        new_state.y = (state.x == FIELD_W-1) ? state.y + 1 : state.y;
        new_state.x = x + 1;
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        state.is_simulating <= 0;
        state.field <= field_A;
        state.x <= 0;
        state.y <= 0;
    end else begin
        state <= new_state;
    end
end

endmodule
