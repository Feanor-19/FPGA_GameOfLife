`timescale 1ns/1ps

module tb_field_cfg_rom;

localparam FIELD_W = 4;
localparam FIELD_H = 3;
localparam CONFIG_ID = 1000;

localparam X_ADR_SIZE = $clog2(FIELD_W);
localparam Y_ADR_SIZE = $clog2(FIELD_H);

logic [X_ADR_SIZE-1:0] i_cell_x_adr;
logic [Y_ADR_SIZE-1:0] i_cell_y_adr;

logic                  o_cell_state;

field_cfg_rom #(
    .FIELD_W(FIELD_W), 
    .FIELD_H(FIELD_H), 
    .CONFIG_ID(CONFIG_ID)
) dut (.*);

initial begin
    #5;

    for (int y = 0; y < FIELD_H; y++) begin
        for (int x = 0; x < FIELD_W; x++) begin
            i_cell_x_adr = X_ADR_SIZE'(x);
            i_cell_y_adr = Y_ADR_SIZE'(y);
            #5;
            $write("%b", o_cell_state);
            #5;
        end
        $write("\n");
    end

    #5;
    $finish;
end

endmodule
