`timescale 1ns/1ps

module tb_vga;

import defs_vga::*;

localparam H_ACTIVE = VGA_H_ACTIVE;
localparam V_ACTIVE = VGA_V_ACTIVE;

bit clk = 0, rst_n = 1;

logic                        o_draw_active;
logic [$clog2(H_ACTIVE)-1:0] o_active_x;
logic [$clog2(V_ACTIVE)-1:0] o_active_y;
logic                        o_h_sync;
logic                        o_v_sync;

vga dut_inst (.*);

initial $dumpfile("dump.svc");

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
    
    $display(o_draw_active, o_active_x, o_active_y, o_h_sync, o_v_sync);

    #100000;
    $finish;
end

endmodule
