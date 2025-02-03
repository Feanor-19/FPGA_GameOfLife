`timescale 1ns/1ps

module tb_next_cell_logic;

logic [9-1:0] test_dat;

logic [7:0] i_neighbours;
logic       i_cell_state;
logic       o_cell_state;

assign i_neighbours = test_dat[7:0];
assign i_cell_state = test_dat[8];

next_cell_logic next_cell_logic_inst (
    .i_neighbours   (i_neighbours),
    .i_cell_state   (i_cell_state),
    .o_cell_state   (o_cell_state)
);

integer num_of_neighbours;
assign num_of_neighbours = $countones(i_neighbours);

initial begin
    $dumpfile("dump.svc");
    //$monitor("i_cell_state=%b, i_neighbours=%b, o_cell_state=%b", i_cell_state, i_neighbours, o_cell_state);

    for (test_dat = 0; test_dat != 9'b111111111; test_dat++) begin
        if (( i_cell_state &  (num_of_neighbours == 2 | num_of_neighbours == 3) & !o_cell_state)
          | ( i_cell_state & !(num_of_neighbours == 2 | num_of_neighbours == 3) &  o_cell_state) 
          | (!i_cell_state &  (num_of_neighbours == 3) & !o_cell_state)
          | (!i_cell_state & !(num_of_neighbours == 3) &  o_cell_state))
            $error("[FAIL]: i_cell_state=%b, i_neighbours=%b, o_cell_state=%b", 
                    i_cell_state, i_neighbours, o_cell_state);
        #1 $dumpvars;
    end
    #1 $display("[PASS]"); 
    $finish;
end

endmodule
