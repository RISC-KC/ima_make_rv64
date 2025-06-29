`timescale 1ns/1ps

module Multiplier_DWORD_tb;
    reg [63:0] src_A;
    reg [63:0] src_B;
    reg signed_A;
    reg signed_B;

    wire [63:0] prod_high;
    wire [63:0] prod_low;

    wire [127:0] prod;
    wire [127:0] expected_prod;

    Multiplier_DWORD dut (
        .src_A(src_A),
        .src_B(src_B),
        .signed_A(signed_A),
        .signed_B(signed_B),
        
        .prod_high(prod_high),
        .prod_low(prod_low)
    );

    assign prod = {prod_high, prod_low};
    assign expected_prod = {{64{(signed_A & src_A[63] == 1)}}, src_A} * {{64{(signed_B & src_B[63] == 1)}}, src_B};

    initial begin
        $dumpfile("testbenches/results/waveforms/Multiplier_DWORD_tb_result.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== Multiplier_DWORD Test START ====================");

        // Test 1: Unsigned * Unsigned
        $display("\nUnsigned * Unsigned: ");
        signed_A = 0; signed_B = 0;

        src_A = 64'd7; src_B = 64'd7; #10;
        $display("%d * %d = %d (Expected: %d)", src_A, src_B, prod, expected_prod);

        src_A = -64'd45; src_B = 64'd20; #10;
        $display("%d * %d = %d (Expected: %d)", src_A, src_B, prod, expected_prod);

        src_A = 64'd37; src_B = -64'd1999; #10;
        $display("%d * %d = %d (Expected: %d)", src_A, src_B, prod, expected_prod);

        src_A = -64'd32168789; src_B = -64'd999999; #10;
        $display("%d * %d = %d (Expected: %d)", src_A, src_B, prod, expected_prod);

        src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'hCAFE_BABE_CAFE_BABE; #10;
        $display("%h * %h = %h (Expected: %h)", src_A, src_B, prod, expected_prod);

        // Test 2: Signed * Unsigned
        $display("\nSigned * Unsigned: ");
        signed_A = 1; signed_B = 0;

        src_A = 64'd7456; src_B = 64'd52; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), src_B, $signed(prod), $signed(expected_prod));

        src_A = -64'd50; src_B = 64'd3; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), src_B, $signed(prod), $signed(expected_prod));

        src_A = 64'd1972; src_B = -64'd123456789; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), src_B, $signed(prod), $signed(expected_prod));

        src_A = -64'd1121; src_B = -64'd987654231; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), src_B, $signed(prod), $signed(expected_prod));

        // Test 3: Signed * Signed
        $display("\nSigned * Signed: ");
        signed_A = 1; signed_B = 1;

        src_A = 64'd5959; src_B = 64'd123456; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), $signed(src_B), $signed(prod), $signed(expected_prod));

        src_A = -64'd2232; src_B = 64'd99999999; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), $signed(src_B), $signed(prod), $signed(expected_prod));

        src_A = 64'd8282; src_B = -64'd1818; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), $signed(src_B), $signed(prod), $signed(expected_prod));

        src_A = -64'd1972; src_B = -64'd1121; #10;
        $display("%d * %d = %d (Expected: %d)", $signed(src_A), $signed(src_B), $signed(prod), $signed(expected_prod));
        
        $display("\n====================  Multiplier_DWORD Test END  ====================");

        $stop;
    end

endmodule