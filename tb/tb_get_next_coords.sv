`timescale 1ns/1ps

module tb_get_next_coords;

localparam FIELD_W = 32;
localparam FIELD_H = 15;

localparam X_ADR_SIZE = $clog2(FIELD_W);
localparam Y_ADR_SIZE = $clog2(FIELD_H);

logic [X_ADR_SIZE-1:0] i_x;
logic [Y_ADR_SIZE-1:0] i_y;

logic [X_ADR_SIZE-1:0] o_next_x;
logic [Y_ADR_SIZE-1:0] o_next_y;

get_next_coords #(.FIELD_W(FIELD_W), .FIELD_H(FIELD_H)) dut (.*);

int next_x, next_y;

initial begin
    $dumpfile("dump.svc");

    for (int y = 0; y < FIELD_H; y++) begin
        for (int x = 0; x < FIELD_W; x++) begin
            i_x = X_ADR_SIZE'(x);
            i_y = Y_ADR_SIZE'(y);
            #1;
            $dumpvars;

            next_x = ((x == FIELD_W-1) ? 0 : x+1); // TODO - разобраться, почему не дает объявить прямо здесь
            next_y = ((next_x != 0) ? y : ( (y == FIELD_H-1) ? 0 : y+1 )); 

            $display("x=%d, y=%d, i_x=%d, i_y=%d, o_next_x=%d, o_next_y=%d",
                          x, y, i_x, i_y, o_next_x, o_next_y);
                
            `ASSERT_IMM(next_x === int'(o_next_x), "o_next_x wrong");
            `ASSERT_IMM(next_y === int'(o_next_y), "o_next_y wrong");
        end
    end

    #1 $display("[PASS]"); 
    $finish;
end

endmodule
