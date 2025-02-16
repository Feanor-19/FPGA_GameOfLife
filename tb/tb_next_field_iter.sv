`timescale 1ns/1ps

module tb_next_field_iter;

import defs::*;

initial $dumpfile("dump.svc");

localparam FIELD_W = 4;
localparam FIELD_H = 3;
localparam X_ADR_SIZE     = $clog2(FIELD_W);
localparam Y_ADR_SIZE     = $clog2(FIELD_H);
localparam NEIGHBOURS_CNT = 8; //REVIEW

logic clk = 0, rst_n = 1, i_go = 0;
logic                        i_cell_state_A = 0;
logic                        i_cell_state_B = 0;
logic [NEIGHBOURS_CNT-1:0]   i_nbrs_A = '0;
logic [NEIGHBOURS_CNT-1:0]   i_nbrs_B = '0;
logic                        o_is_simulating;
logic [X_ADR_SIZE-1:0]       o_x;
logic [X_ADR_SIZE-1:0]       o_y;
logic                        o_new_cell_state;
cur_field_t                  o_cur_read_field;

next_field_iter #(.FIELD_W(FIELD_W), .FIELD_H(FIELD_H)) dut_inst (.*);

always begin
    $dumpvars(0, tb_next_field_iter); // TODO - разобраться, зачем нужно именно так
    #1;
end

initial forever #5 clk = ~clk; 

`define ASSERT(EXPR, ERR_MSG) if (!(EXPR)) $error("[FAIL]: ", ERR_MSG)

cur_field_t cur_read_field = FIELD_A; // TODO - разобраться, почему нельзя объявить внутри initial

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

        // TODO - разобраться, почему waveform показывает другие значения x (4 и 0), чем display ниже
        // strobe вместо display, показывающий "финальные значения для текущего момента времени", даёт
        // те же показания, что и waveform
        for (int y = 0; y < FIELD_H; y++) begin
            for (int x = 0; x < FIELD_W; x++) begin
                @(posedge clk);
                $display("x=%d, y=%d, o_x=%d, o_y=%d, cond=%b",
                          x, y, o_x, o_y, X_ADR_SIZE'(x) === o_x);
                `ASSERT(X_ADR_SIZE'(x) === o_x, "o_x wrong");
                `ASSERT(Y_ADR_SIZE'(y) === o_y, "o_y wrong");
                `ASSERT(o_is_simulating, "is_sim not high");
                `ASSERT(!o_new_cell_state, "mock new_cell_state wrong");
            end
        end

        cur_read_field = ~cur_read_field;
        @(posedge clk);

        `ASSERT(!o_is_simulating, "is_sim not low");
        `ASSERT(cur_read_field === o_cur_read_field, "cur_read_field wrong");
    end

end

`undef ASSERT

initial begin
    #1000
    $display("[PASS]");
    $finish;
end

endmodule
