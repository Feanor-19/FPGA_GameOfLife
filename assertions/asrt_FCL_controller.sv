`timescale 1ns/1ps

/* verilator lint_off UNUSEDSIGNAL */
module asrt_FCL_controller import defs::*; (
    input logic          clk,
    input logic          rst_n,

    input logic          i_cmd_load_cfg_1,
    input logic          i_cmd_load_cfg_2,

    input logic          i_FCL_allowed,

    input logic          i_is_loading, 

    input logic          o_go,
    input load_cfg_req_t o_cur_load_cfg_req
);
/* verilator lint_on UNUSEDSIGNAL */

logic rdy = 0;
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        rdy <= 1;
end

// TODO - разобраться почему не работает или удалить
// `ASSERT(CMD_PRIORITY, !i_is_loading && !$past(i_is_loading)
//         && (i_cmd_load_cfg_1 && i_cmd_load_cfg_2) |=> (o_cur_load_cfg_req == CFG_1));

// `ASSERT(CMD1_SINGLE, !i_is_loading && !$past(i_is_loading)
//         && (i_cmd_load_cfg_1 && !i_cmd_load_cfg_2) |=> (o_cur_load_cfg_req == CFG_1));

// `ASSERT(CMD2_SINGLE, !i_is_loading && !$past(i_is_loading)
//         && (!i_cmd_load_cfg_1 && i_cmd_load_cfg_2) |=> (o_cur_load_cfg_req == CFG_2));

`ASSERT(GO_IS_PULSE, o_go |=> !o_go);

`ASSERT(GO_IS_ALLOWED, o_go |-> ($past(i_FCL_allowed) && (o_cur_load_cfg_req != NO_REQ)));

// SADLY NOT SUPPORTED BY VERILATOR :(
// `ASSERT(HOLD_REQ_WHILE_LOAD, $rose(o_go) |=> 
//         (o_cur_load_cfg_req == $past(o_cur_load_cfg_req)) until !i_is_loading);

endmodule
