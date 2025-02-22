// next_field_iter controller

`timescale 1ns/1ps

module NFI_controller #(
    parameter  MAX_CNT,

    localparam CNT_BITS = $clog2(MAX_CNT+1)
) (
    input  logic clk,
    input  logic rst_n,

    input  logic i_NFI_allowed,

    output logic o_go
);

logic [CNT_BITS-1:0] cnt;

assign o_go = (cnt == MAX_CNT);

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end else begin
        if (cnt != MAX_CNT & i_NFI_allowed)
            cnt <= cnt + 1;
        else if (cnt == MAX_CNT)
            cnt <= 0;
    end
end

endmodule
