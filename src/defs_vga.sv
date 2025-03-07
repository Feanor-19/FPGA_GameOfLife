`timescale 1ns/1ps

package defs_vga;

// verilator lint_off UNUSEDPARAM
localparam VGA_H_ACTIVE = 640;
localparam VGA_H_FRONT  = 16;
localparam VGA_H_SYNC   = 96;
localparam VGA_H_BACK   = 48;

localparam VGA_V_ACTIVE = 480;
localparam VGA_V_FRONT  = 10;
localparam VGA_V_SYNC   = 2;
localparam VGA_V_BACK   = 33;

localparam BITS_R         = 5;
localparam BITS_G         = 6;
localparam BITS_B         = 5;
localparam TOTAL_VGA_BITS = BITS_R + BITS_G + BITS_B;
// verilator lint_on UNUSEDPARAM

endpackage
