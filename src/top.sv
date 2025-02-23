`timescale 1ns/1ps

// EARLY WIP

module top (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        i_cmd_toggle_pause,
    input  logic        i_cmd_load_cfg_1,
    input  logic        i_cmd_load_cfg_2,

    output logic        o_vga_h_sync,
    output logic        o_vga_v_sync,
    output logic [4:0]  o_vga_r,
    output logic [5:0]  o_vga_g,
    output logic [4:0]  o_vga_b
);

import defs::*;

localparam FIELD_W        = 640/2;
localparam FIELD_H        = 480/2;
localparam NEIGHBOURS_CNT = 8;
localparam NFI_CNT        = (640*480) * 10;

localparam X_ADR_SIZE     = $clog2(FIELD_W);
localparam Y_ADR_SIZE     = $clog2(FIELD_H);

// --------------------------------------------------------

logic NFI_allowed;
logic NFI_go;

NFI_controller #(
    .MAX_CNT                (NFI_CNT)
) NFI_controller_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cmd_toggle_pause     (i_cmd_toggle_pause)
    .i_NFI_allowed          (NFI_allowed),

    .o_go                   (NFI_go)
);

// --------------------------------------------------------

logic NFI_is_simulating;

logic                      NFI_next_cell_state;
logic [NEIGHBOURS_CNT-1:0] NFI_next_nbrs;

logic [X_ADR_SIZE-1:0]     NFI_cur_x;
logic [Y_ADR_SIZE-1:0]     NFI_cur_y;
logic [X_ADR_SIZE-1:0]     NFI_next_x;
logic [Y_ADR_SIZE-1:0]     NFI_next_y;

logic                      NFI_new_cur_cell_state;
field_t                    NFI_cur_read_field;

next_field_iter #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H)
) next_field_iter_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_go                   (NFI_go),
    .i_next_cell_state      (NFI_next_cell_state),
    .i_next_nbrs            (NFI_next_nbrs),

    .o_is_simulating        (NFI_is_simulating),
    .o_cur_x                (NFI_cur_x),
    .o_cur_y                (NFI_cur_y),
    .o_next_x               (NFI_next_x),
    .o_next_y               (NFI_next_y),
    .o_new_cur_cell_state   (NFI_new_cur_cell_state),
    .o_cur_read_field       (NFI_cur_read_field)
);

// --------------------------------------------------------

logic [X_ADR_SIZE-1:0]     field_A_x_adr_prw1;
logic [Y_ADR_SIZE-1:0]     field_A_y_adr_prw1;

logic [X_ADR_SIZE-1:0]     field_A_x_adr_pr2;
logic [Y_ADR_SIZE-1:0]     field_A_y_adr_pr2;

logic                      field_A_w_en_p1;
logic                      field_A_write_cell_p1;

logic                      field_A_read_cell_pr1;
logic [NEIGHBOURS_CNT-1:0] field_A_read_nbrs_pr1;

logic                      field_A_read_cell_pr2;

field_ram #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H)
) field_ram_A_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cell_x_adr_prw1      (field_A_x_adr_prw1),
    .i_cell_y_adr_prw1      (field_A_y_adr_prw1),

    .i_cell_x_adr_pr2       (field_A_x_adr_pr2),
    .i_cell_y_adr_pr2       (field_A_y_adr_pr2),

    .i_w_en_p1              (field_A_w_en_p1),
    .i_new_cell_state_p1    (field_A_write_cell_p1),

    .o_cell_state_pr1       (field_A_read_cell_pr1),
    .o_nbrs_pr1             (field_A_read_nbrs_pr1),

    .o_cell_state_pr2       (field_A_read_cell_pr2)
);

// --------------------------------------------------------

logic [X_ADR_SIZE-1:0]     field_B_x_adr_prw1;
logic [Y_ADR_SIZE-1:0]     field_B_y_adr_prw1;

logic [X_ADR_SIZE-1:0]     field_B_x_adr_pr2;
logic [Y_ADR_SIZE-1:0]     field_B_y_adr_pr2;

logic                      field_B_w_en_p1;
logic                      field_B_write_cell_p1;

logic                      field_B_read_cell_pr1;
logic [NEIGHBOURS_CNT-1:0] field_B_read_nbrs_pr1;

logic                      field_B_read_cell_pr2;

field_ram #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H)
) field_ram_B_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cell_x_adr_prw1      (field_B_x_adr_prw1),
    .i_cell_y_adr_prw1      (field_B_y_adr_prw1),

    .i_cell_x_adr_pr2       (field_B_x_adr_pr2),
    .i_cell_y_adr_pr2       (field_B_y_adr_pr2),

    .i_w_en_p1              (field_B_w_en_p1),
    .i_new_cell_state_p1    (field_B_write_cell_p1),

    .o_cell_state_pr1       (field_B_read_cell_pr1),
    .o_nbrs_pr1             (field_B_read_nbrs_pr1),

    .o_cell_state_pr2       (field_B_read_cell_pr2)
);

// --------------------------------------------------------

logic [X_ADR_SIZE-1:0] FCL_cell_x_adr;
logic [Y_ADR_SIZE-1:0] FCL_cell_y_adr;
logic                  FCL_read_cell_cfg_1;
logic                  FCL_read_cell_cfg_2;

field_cfg_rom #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H),
    .CONFIG_ID              (1) 
) field_cfg_rom_1_inst (
    .i_cell_x_adr           (FCL_cell_x_adr),
    .i_cell_y_adr           (FCL_cell_y_adr),

    .o_cell_state           (FCL_read_cell_cfg_1)
);

field_cfg_rom #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H),
    .CONFIG_ID              (2) 
) field_cfg_rom_2_inst (
    .i_cell_x_adr           (FCL_cell_x_adr),
    .i_cell_y_adr           (FCL_cell_y_adr),

    .o_cell_state           (FCL_read_cell_cfg_2)
);

// --------------------------------------------------------

logic FCL_go;
logic FCL_is_loading;

field_cfg_loader #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H),
) field_cfg_loader_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_go                   (FCL_go),
    
    .o_cur_x                (FCL_cell_x_adr),
    .o_cur_y                (FCL_cell_y_adr),
    .o_is_loading           (FCL_is_loading)
);

// --------------------------------------------------------

logic FCL_allowed;
logic FCL_cur_load_cfg_req;

FCL_controller FCL_controller_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cmd_load_cfg_1       (i_cmd_load_cfg_1),
    .i_cmd_load_cfg_2       (i_cmd_load_cfg_2),

    .i_FCL_allowed          (FCL_allowed),
    .i_is_loading           (FCL_is_loading),

    .o_go                   (FCL_go),
    .o_cur_load_cfg_req     (FCL_cur_load_cfg_req)
);

endmodule
