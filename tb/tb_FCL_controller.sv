`timescale 1ns/1ps

module tb_FCL_controller;

import defs::*;

bit clk = 0, rst_n = 1;

logic          i_cmd_load_cfg_1 = 0;
logic          i_cmd_load_cfg_2 = 0;

logic          i_FCL_allowed    = 0;
logic          i_is_loading     = 0; 

logic          o_go;
load_cfg_req_t o_cur_load_cfg_req;

FCL_controller dut_inst (.*);

initial $dumpfile("dump.svc");

always begin
    $dumpvars(0); 
    #1;
end

initial forever #5 clk = ~clk; 

`define ASSERT(EXPR, ERR_MSG) if (!(EXPR)) $error("[FAIL]: ", ERR_MSG)

always @(posedge clk) begin
   $display("cur_state = %s", dut_inst.state.name); 
end

initial begin
    #5;
    rst_n = 0;
    #5;
    rst_n = 1;

    @(posedge clk);
    `ASSERT(o_cur_load_cfg_req === NO_REQ, "clc_req wrong after rst");
    `ASSERT(o_go === 0, "o_go wrong after rst");

    #1 i_cmd_load_cfg_1 = 1;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    i_FCL_allowed = 1;

    #1;
    `ASSERT(o_cur_load_cfg_req === CFG_1, "clc_req wrong 1");
    `ASSERT(o_go === 1, "o_go not high");

    i_is_loading = 1;

    @(posedge clk);
    #1;
    `ASSERT(o_cur_load_cfg_req === CFG_1, "clc_req wrong 2");
    `ASSERT(o_go === 0, "o_go not low");
    
    #1 i_cmd_load_cfg_1 = 0; // supposing button clicking lasts a few click posedges
    
    @(posedge clk);
    #1;
    `ASSERT(o_cur_load_cfg_req === CFG_1, "clc_req wrong 3");
    `ASSERT(o_go === 0, "o_go not low");

    @(posedge clk);
    i_is_loading = 0;

    @(posedge clk);
    #1;
    `ASSERT(o_cur_load_cfg_req === NO_REQ, "clc_req wrong 4");
    `ASSERT(o_go === 0, "o_go not low");

    #100;
    $display("[PASS]");
    $finish;
end

`undef ASSERT

endmodule
