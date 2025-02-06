`timescale 1ns/1ps

module tb_next_cell_state;

logic [9-1:0] test_dat;

logic [7:0] i_nbrs;
logic       i_cell_state;
logic       o_cell_state;

assign i_nbrs = test_dat[7:0];
assign i_cell_state = test_dat[8];

next_cell_state next_cell_state_inst (
    .i_nbrs   (i_nbrs),
    .i_cell_state   (i_cell_state),
    .o_cell_state   (o_cell_state)
);

integer num_of_nbrs;
assign num_of_nbrs = $countones(i_nbrs);

initial begin
    $dumpfile("dump.svc");
    //$monitor("i_cell_state=%b, i_nbrs=%b, o_cell_state=%b", i_cell_state, i_nbrs, o_cell_state);

    for (test_dat = 0; test_dat != 9'b111111111; test_dat++) begin
        if (( i_cell_state &  (num_of_nbrs == 2 | num_of_nbrs == 3) & !o_cell_state)
          | ( i_cell_state & !(num_of_nbrs == 2 | num_of_nbrs == 3) &  o_cell_state) 
          | (!i_cell_state &  (num_of_nbrs == 3) & !o_cell_state)
          | (!i_cell_state & !(num_of_nbrs == 3) &  o_cell_state))
            $error("[FAIL]: i_cell_state=%b, i_nbrs=%b, o_cell_state=%b", 
                    i_cell_state, i_nbrs, o_cell_state);
        #1 $dumpvars;
    end
    #1 $display("[PASS]"); 
    $finish;
end

endmodule
