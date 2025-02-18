// `timescale 1ns/1ps

// // EARLY WIP

// module top (
//     input  logic        clk,
//     input  logic        rst_n,

//     output logic        vga_h_sync,
//     output logic        vga_v_sync,
//     output logic [4:0]  vga_r,
//     output logic [5:0]  vga_g,
//     output logic [4:0]  vga_b
// );

// import defs::*;

// localparam NEW_ITER_PERIOD = 60;

// typedef struct packed {
//     logic                               go;
//     logic [$clog2(NEW_ITER_PERIOD)-1:0] new_iter_cnt;
// } state_t;

// state_t state, new_state;

// endmodule
