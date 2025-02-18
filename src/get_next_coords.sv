`timescale 1ns/1ps

module get_next_coords #(
    parameter FIELD_W,
    parameter FIELD_H,

    localparam X_ADR_SIZE = $clog2(FIELD_W),
    localparam Y_ADR_SIZE = $clog2(FIELD_H),
    localparam X_MAX_VAL  = X_ADR_SIZE'(FIELD_W-1),
    localparam Y_MAX_VAL  = Y_ADR_SIZE'(FIELD_H-1)
) (
    input  logic [X_ADR_SIZE-1:0] i_x,
    input  logic [Y_ADR_SIZE-1:0] i_y,

    output logic [X_ADR_SIZE-1:0] o_next_x,
    output logic [Y_ADR_SIZE-1:0] o_next_y
);

always_comb begin
    if (i_x == X_MAX_VAL) begin
        o_next_x = 0;
        o_next_y = (i_y == Y_MAX_VAL) ? 0 : i_y + 1; 
    end else begin
        o_next_x = i_x + 1; 
        o_next_y = i_y;
    end
end

endmodule
