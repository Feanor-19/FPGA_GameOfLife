`timescale 1ns/1ps

module top import defs_vga::*; (
    input  logic                clk,                // tuned for vga
    input  logic                rst_n,

    input  logic                i_cmd_toggle_pause, // filtered signal from button
    input  logic                i_cmd_load_cfg_1,   // filtered signal from button
    input  logic                i_cmd_load_cfg_2,   // filtered signal from button

    output logic                o_vga_h_sync,
    output logic                o_vga_v_sync,
    output logic [BITS_R-1:0]   o_vga_r,
    output logic [BITS_G-1:0]   o_vga_g,
    output logic [BITS_B-1:0]   o_vga_b
);

initial begin
    if ($test$plusargs("trace") != 0) begin
        $display("[%0t] Tracing to vlt_dump.svc...\n", $time);
        $dumpfile("dump.svc");
        $dumpvars(0);
    end
    $display("[%0t] Model running...\n", $time);
end

import defs::*;

localparam FIELD_W = VGA_H_ACTIVE/2;
localparam FIELD_H = VGA_V_ACTIVE/2;
localparam NFI_CNT = (VGA_H_ACTIVE*VGA_V_ACTIVE) * 2;

localparam logic[TOTAL_VGA_BITS-1:0] COLOR_ALIVE = {16{1'b1}};
localparam logic[TOTAL_VGA_BITS-1:0] COLOR_DEAD  = '0;

localparam X_ADR_SIZE = $clog2(FIELD_W);
localparam Y_ADR_SIZE = $clog2(FIELD_H);

localparam int SCREEN_CELL_X_SIZE = VGA_H_ACTIVE / FIELD_W;
localparam int SCREEN_CELL_Y_SIZE = VGA_V_ACTIVE / FIELD_H;

// --------------------------------------------------------

logic NFI_allowed;
logic ctrl2NFI_go;

NFI_controller #(
    .MAX_CNT                (NFI_CNT)
) NFI_controller_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cmd_toggle_pause     (i_cmd_toggle_pause),
    .i_NFI_allowed          (NFI_allowed),

    .o_go                   (ctrl2NFI_go)
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

    .i_go                   (ctrl2NFI_go),
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

logic ctrl2FCL_go;
logic FCL_is_loading;

field_cfg_loader #(
    .FIELD_W                (FIELD_W),
    .FIELD_H                (FIELD_H)
) field_cfg_loader_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_go                   (ctrl2FCL_go),
    
    .o_cur_x                (FCL_cell_x_adr),
    .o_cur_y                (FCL_cell_y_adr),
    .o_is_loading           (FCL_is_loading)
);

// --------------------------------------------------------

logic FCL_allowed;
load_cfg_req_t FCL_cur_load_cfg_req;

FCL_controller FCL_controller_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .i_cmd_load_cfg_1       (i_cmd_load_cfg_1),
    .i_cmd_load_cfg_2       (i_cmd_load_cfg_2),

    .i_FCL_allowed          (FCL_allowed),
    .i_is_loading           (FCL_is_loading),

    .o_go                   (ctrl2FCL_go),
    .o_cur_load_cfg_req     (FCL_cur_load_cfg_req)
);

// --------------------------------------------------------

logic                            VGA_draw_active;
logic [$clog2(VGA_H_ACTIVE)-1:0] VGA_active_x;
logic [$clog2(VGA_V_ACTIVE)-1:0] VGA_active_y;
logic                            VGA_cur_cell;

vga vga_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .o_draw_active          (VGA_draw_active),
    .o_active_x             (VGA_active_x),
    .o_active_y             (VGA_active_y),
    .o_h_sync               (o_vga_h_sync),
    .o_v_sync               (o_vga_v_sync)
);

// --------------------------------------------------------

assign NFI_allowed = !NFI_is_simulating && !FCL_is_loading && FCL_cur_load_cfg_req == NO_REQ; 
assign FCL_allowed = !NFI_is_simulating;

logic FCL_read_cell_cur_cfg;
always_comb begin
    case (FCL_cur_load_cfg_req)
        MEM_INIT:   FCL_read_cell_cur_cfg = '0;
        CFG_1:      FCL_read_cell_cur_cfg = FCL_read_cell_cfg_1;
        CFG_2:      FCL_read_cell_cur_cfg = FCL_read_cell_cfg_2; 
        default:    FCL_read_cell_cur_cfg = 'x;
    endcase
end

initial `STATIC_ASSERT(SCREEN_CELL_X_SIZE == 2 && SCREEN_CELL_Y_SIZE == 2, 
                       "current logic requires square cells of size 2");

always_comb begin
    field_A_x_adr_pr2 = X_ADR_SIZE'(VGA_active_x >> 1);
    field_A_y_adr_pr2 = Y_ADR_SIZE'(VGA_active_y >> 1);

    field_B_x_adr_pr2 = X_ADR_SIZE'(VGA_active_x >> 1);
    field_B_y_adr_pr2 = Y_ADR_SIZE'(VGA_active_y >> 1);

    if (NFI_cur_read_field == FIELD_A) begin
        field_A_w_en_p1 = FCL_is_loading;
        field_B_w_en_p1 = NFI_is_simulating;

        field_A_x_adr_prw1 = (FCL_is_loading) ? FCL_cell_x_adr : NFI_next_x;
        field_A_y_adr_prw1 = (FCL_is_loading) ? FCL_cell_y_adr : NFI_next_y;

        field_B_x_adr_prw1 = NFI_cur_x;
        field_B_y_adr_prw1 = NFI_cur_y;

        field_A_write_cell_p1 = (FCL_is_loading)    ? FCL_read_cell_cur_cfg  : 0;
        field_B_write_cell_p1 = (NFI_is_simulating) ? NFI_new_cur_cell_state : 0;
        
        NFI_next_cell_state = field_A_read_cell_pr1;
        NFI_next_nbrs       = field_A_read_nbrs_pr1;

        VGA_cur_cell = field_A_read_cell_pr2;
    end else begin // NFI_cur_read_field == FIELD_B
        field_B_w_en_p1 = FCL_is_loading;
        field_A_w_en_p1 = NFI_is_simulating;

        field_B_x_adr_prw1 = (FCL_is_loading) ? FCL_cell_x_adr : NFI_next_x;
        field_B_y_adr_prw1 = (FCL_is_loading) ? FCL_cell_y_adr : NFI_next_y;

        field_A_x_adr_prw1 = NFI_cur_x;
        field_A_y_adr_prw1 = NFI_cur_y;

        field_B_write_cell_p1 = (FCL_is_loading)    ? FCL_read_cell_cur_cfg  : 0;
        field_A_write_cell_p1 = (NFI_is_simulating) ? NFI_new_cur_cell_state : 0;
        
        NFI_next_cell_state = field_B_read_cell_pr1;
        NFI_next_nbrs       = field_B_read_nbrs_pr1;

        VGA_cur_cell = field_B_read_cell_pr2;
    end
end

always_comb begin
    if (VGA_draw_active)
        {o_vga_r, o_vga_g, o_vga_b} = (VGA_cur_cell) ? COLOR_ALIVE : COLOR_DEAD;
    else
        {o_vga_r, o_vga_g, o_vga_b} = '0;
end

endmodule
