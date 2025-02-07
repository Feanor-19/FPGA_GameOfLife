`timescale 1ns/1ps

module tb_get_nbrs_address;

localparam FIELD_W          = 4;
localparam FIELD_H          = 3;
localparam X_ADR_SIZE       = $clog2(FIELD_W);
localparam Y_ADR_SIZE       = $clog2(FIELD_H);
localparam NEIGHBOURS_CNT   = 8;

logic [X_ADR_SIZE-1:0] i_cell_x_adr;
logic [Y_ADR_SIZE-1:0] i_cell_y_adr;

logic [X_ADR_SIZE-1:0] o_nbrs_x_adr [NEIGHBOURS_CNT];
logic [Y_ADR_SIZE-1:0] o_nbrs_y_adr [NEIGHBOURS_CNT];
logic                  o_nbrs_rlvnt [NEIGHBOURS_CNT];

get_nbrs_address #(FIELD_W, FIELD_H) get_nbrs_address_inst (.*);

`define ASSERT(EXPR, ERR_MSG) if (!(EXPR)) $error("[FAIL]: ", ERR_MSG)

initial begin
    $display("FIELD_W=%d,FIELD_H=%d,X_ADR_SIZE=%d,Y_ADR_SIZE=%d", FIELD_W, FIELD_H, X_ADR_SIZE, Y_ADR_SIZE);
    for (int y = 0; y != FIELD_H; y++) begin
        for (int x = 0; x != FIELD_W; x++) begin
            #1;
            i_cell_x_adr = X_ADR_SIZE'(x);
            i_cell_y_adr = Y_ADR_SIZE'(y);
            #1;
            
            $display("i_x_adr=%b, i_y_adr=%b, o_nbrs_rlvnt:", i_cell_x_adr, i_cell_y_adr);
            $display("%b %b %b", o_nbrs_rlvnt[0], o_nbrs_rlvnt[1], o_nbrs_rlvnt[2]);
            $display("%b x %b", o_nbrs_rlvnt[3], o_nbrs_rlvnt[4]);
            $display("%b %b %b", o_nbrs_rlvnt[5], o_nbrs_rlvnt[6], o_nbrs_rlvnt[7]);

            `ASSERT(!o_nbrs_rlvnt[0] | o_nbrs_x_adr[0] == i_cell_x_adr - 1'b1, "NB0X");
            `ASSERT(!o_nbrs_rlvnt[0] | o_nbrs_y_adr[0] == i_cell_y_adr - 1'b1, "NB0X");

            `ASSERT(!o_nbrs_rlvnt[1] | o_nbrs_x_adr[1] == i_cell_x_adr       , "NB1X");
            `ASSERT(!o_nbrs_rlvnt[1] | o_nbrs_y_adr[1] == i_cell_y_adr - 1'b1, "NB1X");

            `ASSERT(!o_nbrs_rlvnt[2] | o_nbrs_x_adr[2] == i_cell_x_adr + 1'b1, "NB2X");
            `ASSERT(!o_nbrs_rlvnt[2] | o_nbrs_y_adr[2] == i_cell_y_adr - 1'b1, "NB2X");

            `ASSERT(!o_nbrs_rlvnt[3] | o_nbrs_x_adr[3] == i_cell_x_adr - 1'b1, "NB3X");
            `ASSERT(!o_nbrs_rlvnt[3] | o_nbrs_y_adr[3] == i_cell_y_adr       , "NB3X");

            `ASSERT(!o_nbrs_rlvnt[4] | o_nbrs_x_adr[4] == i_cell_x_adr + 1'b1, "NB4X");
            `ASSERT(!o_nbrs_rlvnt[4] | o_nbrs_y_adr[4] == i_cell_y_adr       , "NB4X");

            `ASSERT(!o_nbrs_rlvnt[5] | o_nbrs_x_adr[5] == i_cell_x_adr - 1'b1, "NB5X");
            `ASSERT(!o_nbrs_rlvnt[5] | o_nbrs_y_adr[5] == i_cell_y_adr + 1'b1, "NB5X");

            `ASSERT(!o_nbrs_rlvnt[6] | o_nbrs_x_adr[6] == i_cell_x_adr       , "NB6X");
            `ASSERT(!o_nbrs_rlvnt[6] | o_nbrs_y_adr[6] == i_cell_y_adr + 1'b1, "NB6X");

            `ASSERT(!o_nbrs_rlvnt[7] | o_nbrs_x_adr[7] == i_cell_x_adr + 1'b1, "NB7X");
            `ASSERT(!o_nbrs_rlvnt[7] | o_nbrs_y_adr[7] == i_cell_y_adr + 1'b1, "NB7X");

            if (y == 0)         `ASSERT(!o_nbrs_rlvnt[0] & !o_nbrs_rlvnt[1] & !o_nbrs_rlvnt[2], "Yeq0");
            if (x == 0)         `ASSERT(!o_nbrs_rlvnt[0] & !o_nbrs_rlvnt[3] & !o_nbrs_rlvnt[5], "Xeq0");
            if (y == FIELD_H-1) `ASSERT(!o_nbrs_rlvnt[5] & !o_nbrs_rlvnt[6] & !o_nbrs_rlvnt[7], "YeqH");
            if (x == FIELD_W-1) `ASSERT(!o_nbrs_rlvnt[2] & !o_nbrs_rlvnt[4] & !o_nbrs_rlvnt[7], "XeqW");
        end
    end

    #1 $display("[PASS]");
    $finish;
end

endmodule

`undef ASSERT
