`timescale 1ns/1ps

module tb_FCL_controller;

import defs::*;

localparam FIELD_W = 4;
localparam FIELD_H = 3;

localparam X_ADR_SIZE = $clog2(FIELD_W);
localparam Y_ADR_SIZE = $clog2(FIELD_H);

bit clk = 0, rst_n = 1;

logic i_cmd_load_cfg_1 = 0;
logic i_cmd_load_cfg_2 = 0;
logic i_FCL_allowed    = 1;

logic is_loading; 
logic go;

load_cfg_req_t         o_cur_load_cfg_req;
logic [X_ADR_SIZE-1:0] o_FCL_cur_x;
logic [Y_ADR_SIZE-1:0] o_FCL_cur_y;

FCL_controller dut_inst (
    .clk                (clk),
    .rst_n              (rst_n),

    .i_cmd_load_cfg_1   (i_cmd_load_cfg_1),
    .i_cmd_load_cfg_2   (i_cmd_load_cfg_2),
    .i_FCL_allowed      (i_FCL_allowed),
    .i_is_loading       (is_loading),
  
    .o_go               (go),
    .o_cur_load_cfg_req (o_cur_load_cfg_req)
);

field_cfg_loader #(
    .FIELD_W            (FIELD_W), 
    .FIELD_H            (FIELD_H)
) FCL_ref_inst (
    .clk                (clk),
    .rst_n              (rst_n),
    .i_go               (go),

    .o_cur_x            (o_FCL_cur_x),
    .o_cur_y            (o_FCL_cur_y),
    .o_is_loading       (is_loading)
);

initial $dumpfile("dump.svc");

always begin
    $dumpvars(0); 
    #1;
end

initial forever #5 clk = ~clk; 

always @(posedge clk) begin
   $display("cur_state = %s", dut_inst.state.name); 
end

always begin
    repeat ($urandom_range(1, 10)) @(posedge clk);
    if (!is_loading) i_FCL_allowed <= ~i_FCL_allowed;
end

always begin
    repeat ($urandom_range(20, 50)) #1;
    i_cmd_load_cfg_1 <= ~i_cmd_load_cfg_1;
end

always begin
    repeat ($urandom_range(20, 50)) #1;
    i_cmd_load_cfg_2 <= ~i_cmd_load_cfg_2;
end

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    $display(o_cur_load_cfg_req, o_FCL_cur_x, o_FCL_cur_y);

    @(posedge clk);
    // mem_init should start
    `ASSERT_IMM(o_cur_load_cfg_req === MEM_INIT, "clc_req wrong after rst");
    `ASSERT_IMM(go === 1, "o_go wrong after rst");

    @(posedge clk);

    wait(!is_loading);
    @(posedge clk);
    @(posedge clk);
    `ASSERT_IMM(o_cur_load_cfg_req === NO_REQ, "clc_req wrong after done loading");

    #10000;
    $finish;
end

endmodule
