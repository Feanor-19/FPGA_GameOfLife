`timescale 1ns/1ps

module tb_NFI_controller;

initial $dumpfile("dump.svc");

localparam MAX_CNT  = 10;

logic clk = 0, rst_n = 1;
logic i_NFI_allowed = 0;

logic o_go;

NFI_controller #(.MAX_CNT(MAX_CNT)) dut_inst (.*);

always begin
    $dumpvars(0, tb_next_field_iter); 
    #1;
end

initial forever #5 clk = ~clk; 

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    @(posedge clk);
    i_NFI_allowed = 1;

    $monitor(o_go);

    #89 i_NFI_allowed = 0;

    #19 i_NFI_allowed = 1;

    #1000;
    $finish;
end

endmodule
