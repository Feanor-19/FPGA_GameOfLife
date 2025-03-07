`timescale 1ns/1ps

module asrt_NFI_controller (
    input logic clk,
    input logic rst_n,

    input logic i_cmd_toggle_pause,
    input logic i_NFI_allowed,

    input logic o_go
);

import defs::*;

logic rdy = 0;
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        rdy <= 1;
end

logic paused_for_assert;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        paused_for_assert <= 0;
    else if ($rose(i_cmd_toggle_pause))
        paused_for_assert <= ~paused_for_assert;
end

`ASSERT(GO_IS_PULSE, o_go |=> !o_go);

`ASSERT(GO_IS_ALLOWED, o_go |-> $past(i_NFI_allowed) && !$past(paused_for_assert));

endmodule
