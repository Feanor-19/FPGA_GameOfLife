`timescale 1ns/1ps

`define NEIGHBOURS_CNT 8 //REVIEW

module next_cell_state (
    input  logic [`NEIGHBOURS_CNT-1:0]  i_neighbours,
    input  logic                        i_cell_state,

    output logic                        o_cell_state
);

logic [$clog2(`NEIGHBOURS_CNT + 1)-1:0] num_alive_neighbours; 

assign num_alive_neighbours = ($countones(i_neighbours));

always_comb begin
    if (i_cell_state) begin
        if (num_alive_neighbours == 2 | num_alive_neighbours == 3)
            o_cell_state = 1'b1;
        else
            o_cell_state = 1'b0;
    end else begin
        if (num_alive_neighbours == 3)
            o_cell_state = 1'b1;
        else
            o_cell_state = 1'b0;
    end
end

endmodule
