`timescale 1ns/1ps

module tb_field_cfg_loader;

initial $dumpfile("dump.svc");

localparam FIELD_W = 5;
localparam FIELD_H = 3;
localparam X_ADR_SIZE     = $clog2(FIELD_W);
localparam Y_ADR_SIZE     = $clog2(FIELD_H);

bit clk = 0, rst_n = 1, i_go = 0;
logic                  o_is_loading;
logic [X_ADR_SIZE-1:0] o_cur_x;
logic [Y_ADR_SIZE-1:0] o_cur_y;

field_cfg_loader #(.FIELD_W(FIELD_W), .FIELD_H(FIELD_H)) dut_inst (.*);

always begin
    $dumpvars(0); 
    #1;
end

initial forever #5 clk = ~clk; 

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

                `ASSERT_IMM(X_ADR_SIZE'(x) === o_cur_x, "o_cur_x wrong");
                `ASSERT_IMM(Y_ADR_SIZE'(y) === o_cur_y, "o_cur_y wrong");

                `ASSERT_IMM(o_is_loading, "is_loading not high");
            end
        end

        @(posedge clk);

        `ASSERT_IMM(!o_is_loading, "is_loading not low");
    end

    #10;
    $display("[PASS]");
    $finish;
end

endmodule
