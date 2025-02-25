`timescale 1ns/1ps

package defs;

localparam NEIGHBOURS_CNT = 8;

typedef enum logic { 
    FIELD_A, 
    FIELD_B 
} field_t;

typedef enum logic [1:0] { 
    NO_REQ, 
    CFG_1,
    CFG_2
} load_cfg_req_t;     

endpackage
