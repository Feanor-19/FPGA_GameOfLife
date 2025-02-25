`timescale 1ns/1ps

module next_cell_state import defs::NEIGHBOURS_CNT; (
    input  logic [NEIGHBOURS_CNT-1:0]   i_nbrs,
    input  logic                        i_cell_state,

    output logic                        o_cell_state
);

localparam NUM_NBRS_SIZE = $clog2(NEIGHBOURS_CNT + 1) ;

logic [NUM_NBRS_SIZE-1:0] num_alive_nbrs; 
logic [NEIGHBOURS_CNT-1:0] tmp_nbrs;

always_comb begin
    tmp_nbrs = i_nbrs;
    num_alive_nbrs = 0;
    while (|tmp_nbrs) begin
        num_alive_nbrs += (NUM_NBRS_SIZE)'(tmp_nbrs[0]);
        tmp_nbrs >>= 1;
    end
end

always_comb begin
    if (i_cell_state) begin
        if (num_alive_nbrs == 2 || num_alive_nbrs == 3)
            o_cell_state = 1'b1;
        else
            o_cell_state = 1'b0;
    end else begin
        if (num_alive_nbrs == 3)
            o_cell_state = 1'b1;
        else
            o_cell_state = 1'b0;
    end
end

endmodule
