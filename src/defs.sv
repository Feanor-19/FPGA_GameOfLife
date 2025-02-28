`timescale 1ns/1ps

package defs;

/* verilator lint_off UNUSEDPARAM */
localparam NEIGHBOURS_CNT = 8;
/* verilator lint_on UNUSEDPARAM */

typedef enum logic { 
    FIELD_A, 
    FIELD_B 
} field_t;

typedef enum logic [1:0] { 
    NO_REQ, 
    MEM_INIT,
    CFG_1,
    CFG_2
} load_cfg_req_t;     

`define STATIC_ASSERT(EXPR, ERR_MSG) assert((EXPR)) else $error("[STATIC ASSERT FAIL]: ", ERR_MSG)

endpackage
