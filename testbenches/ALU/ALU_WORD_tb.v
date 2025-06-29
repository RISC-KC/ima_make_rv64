`timescale 1ns/1ps

`include "modules/headers/alu_op.vh"

module ALU_WORD_tb;
    reg [31:0] src_A;
	reg [31:0] src_B;
    reg [4:0] alu_op;

    wire [31:0] alu_result;
    wire alu_zero;

    ALU_WORD dut (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),

        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_WORD_tb_result.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== ALU_WORD Test START ====================");

        // Test 1: Addition
		$display("\nAddition Test: ");
		
        alu_op = `ALU_OP_ADD;

        src_A = 32'd0; src_B = 32'd0; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd1000; src_B = 32'd2000; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 2: Subtraction
		$display("\nSubtraction Test: ");
		
        alu_op = `ALU_OP_SUB;

        src_A = 32'd30; src_B = 32'd30; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd10; src_B = 32'd20; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, $signed(alu_result), alu_zero);
		
		src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

		// Test 3: SLL
		$display("\nShift Left Logic Test: ");
		
        alu_op = `ALU_OP_SLL;

		src_A = 32'h1234_5679; src_B = 32'd31; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 32'h0FFF_FFFF; src_B = 32'd3; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h0F0F_FF00; src_B = 32'd1972; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		// Test 4: SRL
		$display("\nShift Right Logic Test: ");
		
        alu_op = `ALU_OP_SRL;

        src_A = 32'hFDEA_DBEF; src_B = 32'd4; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'hDEAD_BEEF; src_B = 32'd8; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'hFFFF_FFFF; src_B = 32'd1972; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 5: SRA
		$display("\nShift Right Arithmetic Test: ");

        alu_op = `ALU_OP_SRA;

        src_A = 32'hFDEA_DBEF; src_B = 32'd4; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'h8000_0000; src_B = 32'd1972; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h0000_0000; src_B = 32'd31011; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 6: NOP
		$display("\nNOP Test: ");
		
        alu_op = `ALU_OP_NOP;

        src_A = 32'hDEAD_BEEF; src_B = 32'hCAFE_BEBE; #10;
        $display("%h NOP %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd31011; src_B = 32'd31011; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        $display("\n====================  ALU_WORD Test END  ====================");

        $stop;
    end

endmodule