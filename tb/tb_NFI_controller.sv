`timescale 1ns/1ps

module tb_NFI_controller;

initial $dumpfile("dump.svc");

localparam MAX_CNT = 10;

logic clk = 0, rst_n = 1;
logic i_NFI_allowed = 0;
logic i_cmd_toggle_pause = 0;

logic o_go;

NFI_controller #(.MAX_CNT(MAX_CNT)) dut_inst (.*);

always begin
    $dumpvars(0); 
    #1;
end

initial forever #5 clk = ~clk; 

always begin
    repeat ($urandom_range(1, 10)) @(posedge clk);
    i_NFI_allowed <= ~i_NFI_allowed;
end

always begin
    repeat ($urandom_range(7, 50)) #1;
    i_cmd_toggle_pause <= ~i_cmd_toggle_pause;
end

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    $monitor(o_go);

    #1000;
    $finish;
end

endmodule
