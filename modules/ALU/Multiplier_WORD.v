`ifndef __MULTIPLIER_DWORD_V__
`define __MULTIPLIER_DWORD_V__

module Multiplier_WORD (
    input [31:0] src_A,
    input [31:0] src_B,
    input signed_A,
    input signed_B,
    
    output [31:0] prod_high,
    output [31:0] prod_low
);
    wire [31:0] abs_src_A = signed_A ? (src_A[31] == 1 ? -src_A : src_A) : src_A;
    wire [31:0] abs_src_B = signed_B ? (src_B[31] == 1 ? -src_B : src_B) : src_B;

    wire [63:0] prod_unsigned /* synthesis use_dsp = "yes" */;
    wire [63:0] prod;

    assign prod_unsigned = abs_src_A * abs_src_B;
    assign prod = ((signed_A & (src_A[31] == 1)) ^ (signed_B) & (src_B[31] == 1)) ? -prod_unsigned : prod_unsigned;
    
    assign prod_high = prod[63:32];
    assign prod_low = prod[31:0];
    
endmodule

`endif