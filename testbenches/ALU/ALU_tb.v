`timescale 1ns/1ps

`include "modules/headers/alu_op.vh"

module ALU_tb;
    reg [63:0] src_A;
	reg [63:0] src_B;
    reg [4:0] alu_op;
    reg input_size_word;

    wire [63:0] alu_result;
    wire alu_zero;

    ALU dut (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),
        .input_size_word(input_size_word),

        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_tb_result.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== ALU Test START ====================");

        // Test 1: Addition
		$display("\nAddition Test: ");
		
        alu_op = `ALU_OP_ADD;
        input_size_word = 0;

        src_A = 64'd0; src_B = 64'd0; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'd1000; src_B = 64'd2000; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'd1972; src_B = 64'd1121; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'h1111_1111_1111_1111; #10;
        $display("%h + %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        input_size_word = 1; #10;
        $display("%h + %h = %h, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);

        // Test 2: Subtraction
		$display("\nSubtraction Test: ");
		
        alu_op = `ALU_OP_SUB;
        input_size_word = 0;

        src_A = 64'd1972; src_B = 64'd1121; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'd30; src_B = 64'd30; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'd10; src_B = 64'd20; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, $signed(alu_result), alu_zero);
		
        src_A = 64'h0111_1111_0111_1111; src_B = 64'h3EAD_BEEF_3EAD_BEEF; #10;
        $display("%h - %h = %h, Zero: %b", src_A, src_B, $signed(alu_result), alu_zero);

		input_size_word = 1; #10;
        $display("%h - %h = %h, Zero: %b", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero);

        // Test 3: AND
		$display("\nAnd Test: ");
		
        alu_op = `ALU_OP_AND;
        input_size_word = 0;

		src_A = 64'hF0F0_F0F0_F0F0_F0F0; src_B = 64'h0F0F_0F0F_0F0F_0F0F; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 64'hFFFF_0000_FFFF_0000; src_B = 64'h0F0F_0F0F_0F0F_0F0F; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'h7777_7777_7777_7777; src_B = 64'hEF07_189A_EF07_189A; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 4: OR
		$display("\nOr Test: ");
		
        alu_op = `ALU_OP_OR;

		src_A = 64'h0000_0000_0000_0000; src_B = 64'h0000_0000_0000_0000; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'hF0F0_F0F0_F0F0_F0F0; src_B = 64'h0F0F_0F0F_0F0F_0F0F; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'h7777_7777_7777_7777; src_B = 64'hEF07_189A_EF07_189A; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 5: XOR
		$display("\nXor Test: ");
		
        alu_op = `ALU_OP_XOR;

		src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'hFFFF_FFFF_FFFF_FFFF; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'h0F0F_0F0F_0F0F_0F0F; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'h7777_7777_7777_7777; src_B = 64'hEF07_189A_EF07_189A; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 6: SLT
		$display("\nSet Less Than Test: ");
		
        alu_op = `ALU_OP_SLT;

		src_A = 64'd30; src_B = 64'd30;  #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);
		
        src_A = 64'h0000_0000_0000_0000; src_B = 64'hF000_0000_0000_0001; #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);

		src_A = 64'd1121; src_B = 64'd1972; #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);

        // Test 7: SLTU
		$display("\nSet Less Than Unsigned Test: ");
		
        alu_op = `ALU_OP_SLTU;

        src_A = 64'hF000_0000; src_B = 64'hF000_0001; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

		src_A = 64'd1972; src_B = 64'h1121; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'd31011; src_B = 64'd31011; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

		// Test 8: SLL
		$display("\nShift Left Logic Test: ");
		
        alu_op = `ALU_OP_SLL;
		
		src_A = 64'h0F0F_FF00_0F0F_FF00; src_B = 64'd1972; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'h1234_5679_1234_5679; src_B = 64'd63; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'h0FFF_FFFF_1FFF_FFFF; src_B = 64'd3; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        input_size_word = 1; #10;
        $display("%h << %d = %h, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);
		
		// Test 9: SRL
		$display("\nShift Right Logic Test: ");
		
        alu_op = `ALU_OP_SRL;
        input_size_word = 0;
		
		src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'd8; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'd1972; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'hFDEA_DBEF_FDEA_DBEF; src_B = 64'd4; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        input_size_word = 1; #10;
        $display("%h >> %d = %h, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);

        // Test 10: SRA
		$display("\nShift Right Arithmetic Test: ");

        alu_op = `ALU_OP_SRA;
        input_size_word = 0;

        src_A = 64'h8000_0000_0000_0000; src_B = 64'd1972; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'h0000_0000_0000_0000; src_B = 64'd31011; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'hFDEA_DBEF_DEAD_BEEF; src_B = 64'd4; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        input_size_word = 1; #10;
        $display("%h >> %d = %h, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);

        // Test 11: MUL, MULH, MULHSU, MULHU
        /*
        $display("\nMultiplication Test: ");

        alu_op = `ALU_OP_MUL;
        input_size_word = 0;

        src_A = 64'd1972; src_B = 64'd1121; #10;
        $display("%d * %d = ??? / %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        alu_op = `ALU_OP_MULH; #10;
        $display("%d * %d = %d / ???, Zero: %b", src_A, src_B, alu_result, alu_zero);

        alu_op = `ALU_OP_MUL;
        src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'hCAFE_BABE_CAFE_BABE; #10;
        $display("%h * %h = ??? / %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        alu_op = `ALU_OP_MULHU; #10;
        $display("%h * %h = %h / ???, Zero: %b", src_A, src_B, alu_result, alu_zero);

        alu_op = `ALU_OP_MULHSU; #10;
        $display("%d * %d = %h / ???, Zero: %b", $signed(src_A), src_B, alu_result, alu_zero);

        alu_op = `ALU_OP_MULH; #10;
        $display("%d * %d = %h / ???, Zero: %b\n", $signed(src_A), $signed(src_B), alu_result, alu_zero);

        input_size_word = 1;
        alu_op = `ALU_OP_MUL; #10;
        $display("%h * %h = ??? / %h, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);

        alu_op = `ALU_OP_MULHU; #10;
        $display("%h * %h = %h / ???, Zero: %b", src_A[31:0], src_B[31:0], alu_result, alu_zero);

        alu_op = `ALU_OP_MULHSU; #10;
        $display("%d * %d = %h / ???, Zero: %b", $signed(src_A[31:0]), src_B[31:0], alu_result, alu_zero);
        
        alu_op = `ALU_OP_MULH; #10;
        $display("%d * %d = %h / ???, Zero: %b", $signed(src_A[31:0]), $signed(src_B[31:0]), alu_result, alu_zero);
        */
        // Test 12: ABJ
		$display("\nAbjunction Test: ");
		
        alu_op = `ALU_OP_ABJ;

        src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'h0FF0_0FF0_0FF0_0FF0; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'h7812_AEB5_7812_AEB5; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'hFFFF_FFFF_FFFF_FFFF;  #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);

        // Test 12: NOP
		$display("\nNOP Test: ");
		
        alu_op = `ALU_OP_NOP;

        src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'hCAFE_BABE_CAFE_BABE; #10;
        $display("%h NOP %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 64'd1972; src_B = 64'd1121; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 64'd31011; src_B = 64'd31011; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        $display("\n====================  ALU Test END  ====================");

        $stop;
    end

endmodule