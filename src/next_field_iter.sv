`timescale 1ns/1ps

import defs::cur_field_t;

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

    input  logic                        i_cell_state_A,
    input  logic                        i_cell_state_B,

    input  logic [NEIGHBOURS_CNT-1:0]   i_nbrs_A,
    input  logic [NEIGHBOURS_CNT-1:0]   i_nbrs_B,

    output logic                        o_is_simulating,
    
    output logic [X_ADR_SIZE-1:0]       o_x,
    output logic [X_ADR_SIZE-1:0]       o_y,

    output logic                        o_new_cell_state,

    output cur_field_t                  o_cur_read_field
);

import defs::*;

typedef struct packed {
    cur_field_t             read_field;
    logic                   is_simulating;
    logic [X_ADR_SIZE-1:0]  x;
    logic [Y_ADR_SIZE-1:0]  y;
} state_t;

state_t state, new_state;

logic cur_cell_state;
logic [NEIGHBOURS_CNT-1:0] cur_nbrs;

next_cell_state next_cell_state_inst (
    .i_nbrs         (cur_nbrs),
    .i_cell_state   (cur_cell_state),

    .o_cell_state   (o_new_cell_state)
);

assign cur_cell_state = (state.read_field == FIELD_A) ? i_cell_state_A : i_cell_state_B;
assign cur_nbrs       = (state.read_field == FIELD_A) ? i_nbrs_A       : i_nbrs_B;

assign o_cur_read_field = state.read_field;
assign o_is_simulating  = state.is_simulating;
assign o_x              = state.x;
assign o_y              = state.y;

always_comb begin
    new_state = state;
    if (!state.is_simulating) begin
        new_state.is_simulating = i_go;
        new_state.x = '0;
        new_state.y = '0;
    end else if (state.x == X_MAX_VAL & state.y == Y_MAX_VAL) begin
        new_state.is_simulating = 0;
        new_state.read_field = ~state.read_field;
        new_state.x = '0;
        new_state.y = '0;
    end else begin
        if (state.x == X_MAX_VAL) begin
            new_state.x = 0;
            new_state.y = (state.y == Y_MAX_VAL) ? 0 : state.y + 1; // REVIEW actually first case never happens
        end else begin
            new_state.x = state.x + 1; 
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state.is_simulating <= 0;
        state.read_field <= FIELD_A;
        state.x <= '0;
        state.y <= '0;
    end else begin
        state <= new_state;
    end
end

endmodule
