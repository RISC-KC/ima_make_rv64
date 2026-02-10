`timescale 1ns/1ps

`include "modules/headers/alu_op.vh"

module ALU_tb;
    reg clk;
    reg reset;
    reg [63:0] src_A;
	reg [63:0] src_B;
    reg [4:0] alu_op;
    reg input_size_word;
    reg div_start;

    wire div_busy;
    wire [63:0] alu_result;
    wire alu_zero;

    ALU dut (
        .clk(clk),
        .reset(reset),
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),
        .input_size_word(input_size_word),
        .div_start,

        .div_busy,
        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Division wait task
    task wait_div_complete;
        begin
            @(posedge clk);  // 입력 안정화
            @(posedge clk);  // 추가 안정화
            div_start = 1;
            @(posedge clk);
            div_start = 0;
            @(posedge clk);
            // Wait for busy to go low
            while (div_busy) begin
                @(posedge clk);
            end
            @(posedge clk);  // 결과 안정화
            @(posedge clk);  // 추가 안정화
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_tb_result.vcd");
        $dumpvars(0, dut);

        // ★★★ Initialize - 필수! ★★★
        reset = 1;
        div_start = 0;
        src_A = 0;
        src_B = 0;
        alu_op = `ALU_OP_ADD;
        input_size_word = 0;
        
        #30;  // reset 유지
        reset = 0;
        #20;  // reset 해제 후 안정화

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

        $display("\nMultiplication Test (DWORD): ");

        alu_op = `ALU_OP_MUL;
        input_size_word = 0;

        src_A = 64'd10; src_B = 64'd20; #10;
        $display("MUL: %d * %d = %d (expected: 200), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd200) ? "PASS" : "FAIL");

        src_A = 64'd1000; src_B = 64'd1000; #10;
        $display("MUL: %d * %d = %d (expected: 1000000), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd1000000) ? "PASS" : "FAIL");

        src_A = 64'd1972; src_B = 64'd1121; #10;
        $display("MUL: %d * %d = %d (expected: 2210612), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd2210612) ? "PASS" : "FAIL");

        // MULH 테스트 - 상위 64비트 확인
        // 2^32 * 2^32 = 2^64, 상위 64비트 = 1, 하위 64비트 = 0
        alu_op = `ALU_OP_MUL;
        src_A = 64'h1_0000_0000; src_B = 64'h1_0000_0000; #10;
        $display("MUL: 0x%h * 0x%h = low 0x%h (expected: 0x0), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'h0) ? "PASS" : "FAIL");

        alu_op = `ALU_OP_MULHU; #10;
        $display("MULHU: 0x%h * 0x%h = high 0x%h (expected: 0x1), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'h1) ? "PASS" : "FAIL");

        // 부호 있는 곱셈 테스트: -1 * 10 = -10
        alu_op = `ALU_OP_MUL;
        src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'd10; #10; // -1 * 10
        $display("MUL: %d * %d = %d (expected: -10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == -10) ? "PASS" : "FAIL");

        alu_op = `ALU_OP_MULH; #10;
        $display("MULH: %d * %d = high %d (expected: -1), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == -1) ? "PASS" : "FAIL");

        // 큰 값 테스트
        alu_op = `ALU_OP_MUL;
        src_A = 64'hDEAD_BEEF_DEAD_BEEF; src_B = 64'hCAFE_BABE_CAFE_BABE; #10;
        $display("MUL: 0x%h * 0x%h = low 0x%h (expected: 0xC231623F88CF5B62), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'hC231623F88CF5B62) ? "PASS" : "FAIL");

        alu_op = `ALU_OP_MULHU; #10;
        $display("MULHU: 0x%h * 0x%h = high 0x%h (expected: 0xB092AB7CE9F4B259), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'hB092AB7CE9F4B259) ? "PASS" : "FAIL");

        $display("\nMultiplication Test (WORD): ");

        input_size_word = 1;
        
        // 간단한 검증용 테스트
        alu_op = `ALU_OP_MUL;
        src_A = 64'd7; src_B = 64'd8; #10;
        $display("MUL: %d * %d = %d (expected: 56), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 56) ? "PASS" : "FAIL");

        src_A = 64'd100; src_B = 64'd100; #10;
        $display("MUL: %d * %d = %d (expected: 10000), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 10000) ? "PASS" : "FAIL");

        // MULH 테스트 - 상위 32비트 확인
        // 2^16 * 2^16 = 2^32, 상위 32비트 = 1, 하위 32비트 = 0
        src_A = 64'h0001_0000; src_B = 64'h0001_0000; #10;
        $display("MUL: 0x%h * 0x%h = low 0x%h (expected: 0x0, sign-ext), Zero: %b, %s", src_A[31:0], src_B[31:0], alu_result, alu_zero, (alu_result == 64'h0) ? "PASS" : "FAIL");

        alu_op = `ALU_OP_MULHU; #10;
        $display("MULHU: 0x%h * 0x%h = high 0x%h (expected: 0x1, sign-ext), Zero: %b, %s", src_A[31:0], src_B[31:0], alu_result, alu_zero, (alu_result == 64'h0000_0000_0000_0001) ? "PASS" : "FAIL");

        // 부호 있는 곱셈 테스트: -1 * 5 = -5
        alu_op = `ALU_OP_MUL;
        src_A = 64'hFFFF_FFFF; src_B = 64'd5; #10; // -1 * 5
        $display("MUL: %d * %d = %d (expected: -5), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == -5) ? "PASS" : "FAIL");

        alu_op = `ALU_OP_MULH; #10;
        $display("MULH: %d * %d = high %d (expected: -1), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == -1) ? "PASS" : "FAIL");

        // Test 12: DIV, DIVU, REM, REMU
        $display("\nDivision Test (DWORD): ");

        alu_op = `ALU_OP_DIV;
        input_size_word = 0;

        // 기본 나눗셈
        src_A = 64'd100; src_B = 64'd10;
        wait_div_complete;
        $display("DIV: %d / %d = %d (expected: 10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        src_A = 64'd1972; src_B = 64'd100;
        wait_div_complete;
        $display("DIV: %d / %d = %d (expected: 19), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 19) ? "PASS" : "FAIL");

        // 부호 있는 나눗셈: -100 / 10 = -10
        src_A = 64'hFFFF_FFFF_FFFF_FF9C; src_B = 64'd10;
        wait_div_complete;
        $display("DIV: %d / %d = %d (expected: -10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == -10) ? "PASS" : "FAIL");

        // 부호 있는 나눗셈: -100 / -10 = 10
        src_A = 64'hFFFF_FFFF_FFFF_FF9C; src_B = 64'hFFFF_FFFF_FFFF_FFF6;
        wait_div_complete;
        $display("DIV: %d / %d = %d (expected: 10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        // 0으로 나눗셈 (RISC-V 스펙: 결과는 -1)
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("DIV: %d / %d = %d (expected: -1), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == -1) ? "PASS" : "FAIL");

        // DIVU 테스트
        alu_op = `ALU_OP_DIVU;

        src_A = 64'd100; src_B = 64'd10;
        wait_div_complete;
        $display("DIVU: %d / %d = %d (expected: 10), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd10) ? "PASS" : "FAIL");

        src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'd2;
        wait_div_complete;
        $display("DIVU: 0x%h / %d = 0x%h (expected: 0x7FFFFFFFFFFFFFFF), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'h7FFF_FFFF_FFFF_FFFF) ? "PASS" : "FAIL");

        // 0으로 나눗셈 (RISC-V 스펙: 결과는 모두 1)
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("DIVU: %d / %d = 0x%h (expected: 0xFFFFFFFFFFFFFFFF), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'hFFFF_FFFF_FFFF_FFFF) ? "PASS" : "FAIL");

        // REM 테스트
        alu_op = `ALU_OP_REM;

        src_A = 64'd100; src_B = 64'd30;
        wait_div_complete;
        $display("REM: %d %% %d = %d (expected: 10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        src_A = 64'd1972; src_B = 64'd100;
        wait_div_complete;
        $display("REM: %d %% %d = %d (expected: 72), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 72) ? "PASS" : "FAIL");

        // 부호 있는 나머지: -100 % 30 = -10
        src_A = 64'hFFFF_FFFF_FFFF_FF9C; src_B = 64'd30;
        wait_div_complete;
        $display("REM: %d %% %d = %d (expected: -10), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == -10) ? "PASS" : "FAIL");

        // 0으로 나눗셈 (RISC-V 스펙: 결과는 피제수)
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("REM: %d %% %d = %d (expected: 100), Zero: %b, %s", $signed(src_A), $signed(src_B), $signed(alu_result), alu_zero, ($signed(alu_result) == 100) ? "PASS" : "FAIL");

        // REMU 테스트
        alu_op = `ALU_OP_REMU;

        src_A = 64'd100; src_B = 64'd30;
        wait_div_complete;
        $display("REMU: %d %% %d = %d (expected: 10), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd10) ? "PASS" : "FAIL");

        src_A = 64'hFFFF_FFFF_FFFF_FFFF; src_B = 64'd2;
        wait_div_complete;
        $display("REMU: 0x%h %% %d = %d (expected: 1), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd1) ? "PASS" : "FAIL");

        // 0으로 나눗셈 (RISC-V 스펙: 결과는 피제수)
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("REMU: %d %% %d = %d (expected: 100), Zero: %b, %s", src_A, src_B, alu_result, alu_zero, (alu_result == 64'd100) ? "PASS" : "FAIL");

        $display("\nDivision Test (WORD - DIVW, DIVUW, REMW, REMUW): ");

        input_size_word = 1;

        // DIVW 테스트
        alu_op = `ALU_OP_DIV;

        src_A = 64'd100; src_B = 64'd10;
        wait_div_complete;
        $display("DIVW: %d / %d = %d (expected: 10), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        // 부호 있는 나눗셈: -100 / 10 = -10 (32비트)
        src_A = 64'h0000_0000_FFFF_FF9C; src_B = 64'd10;
        wait_div_complete;
        $display("DIVW: %d / %d = %d (expected: -10), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == -10) ? "PASS" : "FAIL");

        // 0으로 나눗셈
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("DIVW: %d / %d = %d (expected: -1), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == -1) ? "PASS" : "FAIL");

        // DIVUW 테스트
        alu_op = `ALU_OP_DIVU;

        src_A = 64'd100; src_B = 64'd10;
        wait_div_complete;
        $display("DIVUW: %d / %d = %d (expected: 10), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        src_A = 64'h0000_0000_FFFF_FFFF; src_B = 64'd2;
        wait_div_complete;
        $display("DIVUW: 0x%h / %d = 0x%h (expected: 0x7FFFFFFF, sign-ext), Zero: %b, %s", src_A[31:0], src_B[31:0], alu_result, alu_zero, (alu_result == 64'h0000_0000_7FFF_FFFF) ? "PASS" : "FAIL");

        // 0으로 나눗셈
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("DIVUW: %d / %d = 0x%h (expected: 0xFFFFFFFF, sign-ext to -1), Zero: %b, %s", src_A[31:0], src_B[31:0], alu_result, alu_zero, ($signed(alu_result) == -1) ? "PASS" : "FAIL");

        // REMW 테스트
        alu_op = `ALU_OP_REM;

        src_A = 64'd100; src_B = 64'd30;
        wait_div_complete;
        $display("REMW: %d %% %d = %d (expected: 10), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        // 부호 있는 나머지: -100 % 30 = -10 (32비트)
        src_A = 64'h0000_0000_FFFF_FF9C; src_B = 64'd30;
        wait_div_complete;
        $display("REMW: %d %% %d = %d (expected: -10), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == -10) ? "PASS" : "FAIL");

        // 0으로 나눗셈
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("REMW: %d %% %d = %d (expected: 100), Zero: %b, %s", $signed(src_A[31:0]), $signed(src_B[31:0]), $signed(alu_result), alu_zero, ($signed(alu_result) == 100) ? "PASS" : "FAIL");

        // REMUW 테스트
        alu_op = `ALU_OP_REMU;

        src_A = 64'd100; src_B = 64'd30;
        wait_div_complete;
        $display("REMUW: %d %% %d = %d (expected: 10), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 10) ? "PASS" : "FAIL");

        src_A = 64'h0000_0000_FFFF_FFFF; src_B = 64'd2;
        wait_div_complete;
        $display("REMUW: 0x%h %% %d = %d (expected: 1), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 1) ? "PASS" : "FAIL");

        // 0으로 나눗셈
        src_A = 64'd100; src_B = 64'd0;
        wait_div_complete;
        $display("REMUW: %d %% %d = %d (expected: 100), Zero: %b, %s", src_A[31:0], src_B[31:0], $signed(alu_result), alu_zero, ($signed(alu_result) == 100) ? "PASS" : "FAIL");
        
        // Test 13: ABJ
		$display("\nAbjunction Test: ");
		
        alu_op = `ALU_OP_ABJ;
        input_size_word = 0;

        src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'h0FF0_0FF0_0FF0_0FF0; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'h7812_AEB5_7812_AEB5; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 64'hFFFF_FFFF_FFFF_FFFF; src_A = 64'hFFFF_FFFF_FFFF_FFFF;  #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);

        // Test 14: NOP
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