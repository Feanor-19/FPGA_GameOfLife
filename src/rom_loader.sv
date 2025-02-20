`timescale 1ns/1ps

module rom_loader #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE = $clog2(FIELD_W),
    localparam Y_ADR_SIZE = $clog2(FIELD_H)
) (
    input  logic clk,
    input  logic rst_n,
    input  logic i_go,

    output logic [X_ADR_SIZE-1:0] o_cur_x,
    output logic [Y_ADR_SIZE-1:0] o_cur_y,

    output logic o_is_loading
);

typedef struct packed {
    logic                  is_loading;
    logic [X_ADR_SIZE-1:0] cur_x;
    logic [Y_ADR_SIZE-1:0] cur_y;
} state_t;

state_t state, new_state;

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

assign o_is_loading = state.is_loading;
assign o_cur_x      = state.cur_x;
assign o_cur_y      = state.cur_y;

always_comb begin
    if (!state.is_loading) begin
        new_state.is_loading = i_go;
        new_state.cur_x      = '0;
        new_state.cur_y      = '0;
    end else begin
        new_state.cur_x = next_x;
        new_state.cur_y = next_y;
        
        if (next_x == '0 & next_y == '0) 
            new_state.is_loading = 0;
        else
            new_state.is_loading = 1;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state.cur_x      <= '0;
        state.cur_y      <= '0;
        state.is_loading <= 0;
    end else begin
        state <= new_state;
    end
end
    
endmodule
