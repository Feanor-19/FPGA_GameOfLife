module field_ram #(
    parameter FIELD_W = 30,
    parameter FIELD_H = 50,

    localparam X_ADR_SIZE     = $clog2(FIELD_W),
    localparam Y_ADR_SIZE     = $clog2(FIELD_H),
    localparam NEIGHBOURS_CNT = 8 //REVIEW
) (
    
);
    
endmodule