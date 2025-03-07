`timescale 1ns/1ps

module tb_next_field_iter;

import defs::*;

initial $dumpfile("dump.svc");

localparam FIELD_W = 5;
localparam FIELD_H = 3;
localparam X_ADR_SIZE     = $clog2(FIELD_W);
localparam Y_ADR_SIZE     = $clog2(FIELD_H);
import defs::NEIGHBOURS_CNT;

bit clk = 0, rst_n = 1;
logic                      i_go = 0;
logic                      i_next_cell_state = 0;
logic [NEIGHBOURS_CNT-1:0] i_next_nbrs       = '0;
logic                      o_is_simulating;
logic [X_ADR_SIZE-1:0]     o_cur_x;
logic [Y_ADR_SIZE-1:0]     o_cur_y;
logic [X_ADR_SIZE-1:0]     o_next_x;
logic [Y_ADR_SIZE-1:0]     o_next_y;
logic                      o_new_cur_cell_state;
field_t                    o_cur_read_field;

next_field_iter #(.FIELD_W(FIELD_W), .FIELD_H(FIELD_H)) dut_inst (.*);

always begin
    $dumpvars(0); 
    #1;
end

initial forever #5 clk = ~clk; 

field_t cur_read_field = FIELD_A; // TODO - разобраться, почему нельзя объявить внутри initial ниже
int next_x, next_y;

logic                      prev_cell_state = 0;
logic [NEIGHBOURS_CNT-1:0] prev_nbrs       = '0;

logic ref_new_cell_state;

next_cell_state ref_next_cell_state_inst (
    .i_nbrs         (prev_nbrs),
    .i_cell_state   (prev_cell_state),
    .o_cell_state   (ref_new_cell_state)
);

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    repeat (3) begin    
        repeat ($urandom_range(1, 10)) @(posedge clk);
        $display("new iter at time: ", $time);
        i_go = 1;
        #5;
        i_go = 0;

        for (int y = 0; y < FIELD_H; y++) begin
            for (int x = 0; x < FIELD_W; x++) begin
                @(posedge clk);
                i_next_cell_state = 1'($urandom_range(0, 1));
                i_next_nbrs       = NEIGHBOURS_CNT'($urandom_range(0, 2**(NEIGHBOURS_CNT)-1));
                
                $display("x=%d, y=%d, o_cur_x=%d, o_cur_y=%d, o_next_x=%d, o_next_y=%d",
                          x, y, o_cur_x, o_cur_y, o_next_x, o_next_y);
                
                `ASSERT_IMM(X_ADR_SIZE'(x) === o_cur_x, "o_cur_x wrong");
                `ASSERT_IMM(Y_ADR_SIZE'(y) === o_cur_y, "o_cur_y wrong");

                next_x = ((x == FIELD_W-1) ? 0 : x+1);
                next_y = ((next_x != 0) ? y : ( (y == FIELD_H-1) ? 0 : y+1 )); 

                `ASSERT_IMM(next_x === int'(o_next_x), "o_next_x wrong");
                `ASSERT_IMM(next_y === int'(o_next_y), "o_next_y wrong");

                `ASSERT_IMM(o_is_simulating, "is_sim not high");

                `ASSERT_IMM(o_new_cur_cell_state === ref_new_cell_state, "mock new_cell_state wrong");

                prev_cell_state = i_next_cell_state;
                prev_nbrs       = i_next_nbrs;
            end
        end

        cur_read_field = ~cur_read_field;
        @(posedge clk);

        `ASSERT_IMM(!o_is_simulating, "is_sim not low");
        `ASSERT_IMM(cur_read_field === o_cur_read_field, "cur_read_field wrong");
    end

    #10;
    $display("[PASS]");
    $finish;
end

endmodule
