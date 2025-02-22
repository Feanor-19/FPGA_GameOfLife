`timescale 1ns/1ps

import defs::field_t;

module next_field_iter #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE     = $clog2(FIELD_W),
    localparam Y_ADR_SIZE     = $clog2(FIELD_H),
    localparam X_MAX_VAL      = X_ADR_SIZE'(FIELD_W-1),
    localparam Y_MAX_VAL      = Y_ADR_SIZE'(FIELD_H-1),
    localparam NEIGHBOURS_CNT = 8 //REVIEW
) (
    input  logic clk,
    input  logic rst_n,
    input  logic i_go,

    input  logic                      i_next_cell_state,
    input  logic [NEIGHBOURS_CNT-1:0] i_next_nbrs,

    output logic                      o_is_simulating,
    
    output logic [X_ADR_SIZE-1:0]     o_cur_x,
    output logic [Y_ADR_SIZE-1:0]     o_cur_y,

    output logic [X_ADR_SIZE-1:0]     o_next_x,
    output logic [Y_ADR_SIZE-1:0]     o_next_y,

    output logic                      o_new_cur_cell_state,

    output field_t                    o_cur_read_field
);

import defs::*;

typedef struct packed {
    field_t                    read_field;
    logic                      is_simulating;
    logic [X_ADR_SIZE-1:0]     cur_x;
    logic [Y_ADR_SIZE-1:0]     cur_y;
    logic                      cur_cell_state;
    logic [NEIGHBOURS_CNT-1:0] cur_nbrs;
} state_t;

state_t state, new_state;

next_cell_state next_cell_state_inst (
    .i_nbrs         (state.cur_nbrs),
    .i_cell_state   (state.cur_cell_state),

    .o_cell_state   (o_new_cur_cell_state)
);

logic [X_ADR_SIZE-1:0] next_x;
logic [Y_ADR_SIZE-1:0] next_y;

get_next_coords #(
    .FIELD_W    (FIELD_W), 
    .FIELD_H    (FIELD_H)
) get_next_coords_inst (
    .i_x        (state.cur_x),
    .i_y        (state.cur_y),

    .o_next_x   (next_x),
    .o_next_y   (next_y)
);

assign o_cur_read_field = state.read_field;
assign o_is_simulating  = state.is_simulating;
assign o_cur_x          = state.cur_x;
assign o_cur_y          = state.cur_y;

assign o_next_x         = new_state.cur_x;
assign o_next_y         = new_state.cur_y;

always_comb begin
    new_state = state;
    if (!state.is_simulating) begin
        new_state.is_simulating = i_go;
        new_state.cur_x = '0;
        new_state.cur_y = '0;
    end else if (state.cur_x == X_MAX_VAL & state.cur_y == Y_MAX_VAL) begin
        new_state.is_simulating = 0;
        new_state.read_field = ~state.read_field;
        new_state.cur_x = '0;
        new_state.cur_y = '0;
    end else begin
        new_state.cur_x = next_x;
        new_state.cur_y = next_y;
    end
    new_state.cur_cell_state = i_next_cell_state;
    new_state.cur_nbrs       = i_next_nbrs;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state.is_simulating  <= 0;
        state.read_field     <= FIELD_A;
        state.cur_x          <= '0;
        state.cur_y          <= '0;
        state.cur_cell_state <= '0;
        state.cur_nbrs       <= '0;
    end else begin
        state <= new_state;
    end
end

endmodule
