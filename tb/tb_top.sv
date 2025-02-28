`timescale 1ns/1ps

module tb_top;

import defs::*;
import defs_vga::*;

bit clk = 0, rst_n = 1;

logic i_cmd_toggle_pause = 0;
logic i_cmd_load_cfg_1   = 0;
logic i_cmd_load_cfg_2   = 0;  

logic              o_vga_h_sync;
logic              o_vga_v_sync;
logic [BITS_R-1:0] o_vga_r;
logic [BITS_G-1:0] o_vga_g;
logic [BITS_B-1:0] o_vga_b;

top top_inst (.*);

initial $dumpfile("dump.svc");

always begin
    @(posedge clk) $dumpvars(0); 
end

initial forever #5 clk = ~clk; 

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    $display(o_vga_h_sync, o_vga_v_sync, o_vga_r, o_vga_g, o_vga_b);

    #100000000;
    $finish;
end

endmodule
