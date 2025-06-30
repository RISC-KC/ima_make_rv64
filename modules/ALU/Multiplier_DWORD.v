`include "modules/ALU/Multiplier_WORD.v"

module Multiplier_DWORD (
    input [63:0] src_A,
    input [63:0] src_B,
    input signed_A,
    input signed_B,

    output [63:0] prod_high,
    output [63:0] prod_low
);
    wire [63:0] abs_src_A = signed_A ? (src_A[63] == 1 ? -src_A : src_A) : src_A;
    wire [63:0] abs_src_B = signed_B ? (src_B[63] == 1 ? -src_B : src_B) : src_B;

    wire [31:0] prod_AHBH_high;
    wire [31:0] prod_AHBH_low;
    wire [31:0] prod_AHBL_high;
    wire [31:0] prod_AHBL_low;
    wire [31:0] prod_ALBH_high;
    wire [31:0] prod_ALBH_low;
    wire [31:0] prod_ALBL_high;
    wire [31:0] prod_ALBL_low;

    wire [63:0] prod_AHBH;
    wire [63:0] prod_AHBL;
    wire [63:0] prod_ALBH;
    wire [63:0] prod_ALBL;

    wire [127:0] unsigned_sum;
    wire [127:0] sum;

    Multiplier_WORD ahbh(
        .src_A(abs_src_A[63:32]),
        .src_B(abs_src_B[63:32]),
        .signed_A(1'b0),
        .signed_B(1'b0),

        .prod_high(prod_AHBH_high),
        .prod_low(prod_AHBH_low)
    );

    Multiplier_WORD ahbl(
        .src_A(abs_src_A[63:32]),
        .src_B(abs_src_B[31:0]),
        .signed_A(1'b0),
        .signed_B(1'b0),

        .prod_high(prod_AHBL_high),
        .prod_low(prod_AHBL_low)
    );

    Multiplier_WORD albh(
        .src_A(abs_src_A[31:0]),
        .src_B(abs_src_B[63:32]),
        .signed_A(1'b0),
        .signed_B(1'b0),

        .prod_high(prod_ALBH_high),
        .prod_low(prod_ALBH_low)
    );

    Multiplier_WORD albl(
        .src_A(abs_src_A[31:0]),
        .src_B(abs_src_B[31:0]),
        .signed_A(1'b0),
        .signed_B(1'b0),

        .prod_high(prod_ALBL_high),
        .prod_low(prod_ALBL_low)
    );

    assign prod_AHBH = {prod_AHBH_high, prod_AHBH_low};
    assign prod_AHBL = {prod_AHBL_high, prod_AHBL_low};
    assign prod_ALBH = {prod_ALBH_high, prod_ALBH_low};
    assign prod_ALBL = {prod_ALBL_high, prod_ALBL_low};

    assign unsigned_sum = (prod_AHBH << 64) + (prod_AHBL << 32) + (prod_ALBH << 32) + prod_ALBL;
    assign sum = ((signed_A & (src_A[63] == 1)) ^ (signed_B) & (src_B[63] == 1)) ? -unsigned_sum : unsigned_sum;

    assign prod_high = sum[127:64];
    assign prod_low = sum[63:0];
    
endmodule