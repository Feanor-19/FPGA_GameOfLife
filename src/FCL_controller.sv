// field_cfg_loader controller

`timescale 1ns/1ps

module FCL_controller import defs::*; (
    input  logic          clk,
    input  logic          rst_n,

    input  logic          i_cmd_load_cfg_1,
    input  logic          i_cmd_load_cfg_2,

    input  logic          i_FCL_allowed,

    input  logic          i_is_loading, 

    output logic          o_go,
    output load_cfg_req_t o_cur_load_cfg_req
);

typedef enum logic [1:0] { 
    DEFAULT, 
    START_LOADING, 
    WAIT_LOAD_END
} state_t;

load_cfg_req_t cur_load_cfg_req, new_load_cfg_req;
state_t state, new_state;

always_comb begin
    new_state        = state;
    new_load_cfg_req = cur_load_cfg_req;

    unique case (state)
        DEFAULT: begin
            if      (i_cmd_load_cfg_1)
                new_load_cfg_req = CFG_1;
            else if (i_cmd_load_cfg_2)
                new_load_cfg_req = CFG_2;
            
            if (cur_load_cfg_req != NO_REQ && i_FCL_allowed)
                new_state = START_LOADING;
        end
        START_LOADING:
            new_state = WAIT_LOAD_END;
        WAIT_LOAD_END: begin
            if (!i_is_loading) begin
                new_state        = DEFAULT;
                new_load_cfg_req = NO_REQ;
            end
        end
    endcase
end

assign o_cur_load_cfg_req = cur_load_cfg_req;
assign o_go = (state == START_LOADING);

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state            <= START_LOADING;
        cur_load_cfg_req <= MEM_INIT;
    end
    else begin
        state            <= new_state;
        cur_load_cfg_req <= new_load_cfg_req;
    end
end
    
endmodule
