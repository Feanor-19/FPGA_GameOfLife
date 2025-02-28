// next_field_iter controller

`timescale 1ns/1ps

module NFI_controller #(
    parameter  MAX_CNT,

    localparam CNT_BITS = $clog2(MAX_CNT+1)
) (
    input  logic clk,
    input  logic rst_n,

    input  logic i_cmd_toggle_pause,
    input  logic i_NFI_allowed,

    output logic o_go
);

logic [CNT_BITS-1:0] cnt;
logic prev_cmd_tgl_pause;
logic paused;

assign o_go = (cnt == CNT_BITS'(MAX_CNT));

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        prev_cmd_tgl_pause <= 0;
    else
        prev_cmd_tgl_pause <= i_cmd_toggle_pause;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        paused <= 0;
    else if (i_cmd_toggle_pause && !prev_cmd_tgl_pause) 
        paused <= ~paused;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end else begin
        if (cnt != CNT_BITS'(MAX_CNT) && !paused && i_NFI_allowed)
            cnt <= cnt + 1;
        else if (cnt == CNT_BITS'(MAX_CNT))
            cnt <= 0;
    end
end

endmodule
