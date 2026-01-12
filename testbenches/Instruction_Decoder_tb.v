`timescale 1ns/1ps

`include "modules/headers/opcode.vh"
`include "modules/headers/itype_funct3.vh"
`include "modules/headers/rtype_funct3.vh"

module InstructionDecoder_tb;
    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1;
    wire [5:0] rs2;
    wire [4:0] rd;
    wire [19:0] raw_imm;

    // Test result tracking
    integer test_count;
    integer pass_count;
    integer fail_count;

    InstructionDecoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .raw_imm(raw_imm)
    );

    // Task: Check all fields - always print Expected and Got
    task check_all;
        input [6:0] exp_opcode;
        input [2:0] exp_funct3;
        input [6:0] exp_funct7;
        input [4:0] exp_rs1;
        input [5:0] exp_rs2;
        input [4:0] exp_rd;
        input [19:0] exp_raw_imm;
        input [256*8-1:0] test_name;
        begin
            test_count = test_count + 1;
            if (opcode === exp_opcode && funct3 === exp_funct3 && funct7 === exp_funct7 &&
                rs1 === exp_rs1 && rs2 === exp_rs2 && rd === exp_rd && raw_imm === exp_raw_imm) begin
                $display("[PASS] %0s", test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s", test_name);
                fail_count = fail_count + 1;
            end
            $display("       Expected: op=%b f3=%b f7=%b rs1=%2d rs2=%2d rd=%2d imm=%05h",
                     exp_opcode, exp_funct3, exp_funct7, exp_rs1, exp_rs2, exp_rd, exp_raw_imm);
            $display("       Got:      op=%b f3=%b f7=%b rs1=%2d rs2=%2d rd=%2d imm=%05h",
                     opcode, funct3, funct7, rs1, rs2, rd, raw_imm);
            $display("");
        end
    endtask

    // Task: Check opcode, rd, and raw_imm only (for U-type, J-type where other fields are don't care)
    task check_u_type;
        input [6:0] exp_opcode;
        input [4:0] exp_rd;
        input [19:0] exp_raw_imm;
        input [256*8-1:0] test_name;
        begin
            test_count = test_count + 1;
            if (opcode === exp_opcode && rd === exp_rd && raw_imm === exp_raw_imm) begin
                $display("[PASS] %0s", test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s", test_name);
                fail_count = fail_count + 1;
            end
            $display("       Expected: op=%b rd=%2d imm=%05h (f3/f7/rs1/rs2 = don't care)",
                     exp_opcode, exp_rd, exp_raw_imm);
            $display("       Got:      op=%b rd=%2d imm=%05h (f3=%b f7=%b rs1=%2d rs2=%2d)",
                     opcode, rd, raw_imm, funct3, funct7, rs1, rs2);
            $display("");
        end
    endtask

    // Task: Check opcode, funct3, rs1, rd, raw_imm (for I-type non-shift)
    task check_i_type;
        input [6:0] exp_opcode;
        input [2:0] exp_funct3;
        input [4:0] exp_rs1;
        input [4:0] exp_rd;
        input [19:0] exp_raw_imm;
        input [256*8-1:0] test_name;
        begin
            test_count = test_count + 1;
            if (opcode === exp_opcode && funct3 === exp_funct3 && rs1 === exp_rs1 &&
                rd === exp_rd && raw_imm === exp_raw_imm) begin
                $display("[PASS] %0s", test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s", test_name);
                fail_count = fail_count + 1;
            end
            $display("       Expected: op=%b f3=%b rs1=%2d rd=%2d imm=%05h (f7/rs2 = don't care)",
                     exp_opcode, exp_funct3, exp_rs1, exp_rd, exp_raw_imm);
            $display("       Got:      op=%b f3=%b rs1=%2d rd=%2d imm=%05h (f7=%b rs2=%2d)",
                     opcode, funct3, rs1, rd, raw_imm, funct7, rs2);
            $display("");
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/InstructionDecoder_tb_result.vcd");
        $dumpvars(0, dut);

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        $display("=====");
        $display("         Simplified RV64I Instruction Decoder Testbench                        ");
        $display("=====");
        $display("Design Notes:");
        $display("  - opcode/funct3/rs1/rd: Direct wire assignment");
        $display("  - rs2/funct7: Conditional (rv64_shift selects 6-bit or 5-bit mode)");
        $display("  - raw_imm: Case statement based on opcode");
        $display("  - Don't care fields may contain garbage values (by design)");
        $display("=====\n");

        //=====
        // Section 1: R-type 64-bit Shift (SLL, SRL, SRA)
        // rv64_shift=1: rs2=6-bit shamt, funct7={1'b0, inst[31:26]}
        $display("---------- Section 1: R-type 64-bit Shift (6-bit shamt) ----------\n");

        // SLL x10, x5, shamt=20 (010100)
        instruction = 32'b000000_010100_00101_001_01010_0110011;
        #10;
        check_all(7'b0110011, 3'b001, 7'b0000000, 5'd5, 6'd20, 5'd10, 20'd0,
                  "SLL x10, x5, shamt=20");

        // SLL x4, x3, shamt=63 (111111) - maximum
        instruction = 32'b000000_111111_00011_001_00100_0110011;
        #10;
        check_all(7'b0110011, 3'b001, 7'b0000000, 5'd3, 6'd63, 5'd4, 20'd0,
                  "SLL x4, x3, shamt=63 (max)");

        // SRL x15, x8, shamt=32 (100000)
        instruction = 32'b000000_100000_01000_101_01111_0110011;
        #10;
        check_all(7'b0110011, 3'b101, 7'b0000000, 5'd8, 6'd32, 5'd15, 20'd0,
                  "SRL x15, x8, shamt=32");

        // SRA x20, x12, shamt=48 - funct7[4]=1
        instruction = 32'b010000_110000_01100_101_10100_0110011;
        #10;
        check_all(7'b0110011, 3'b101, 7'b0010000, 5'd12, 6'd48, 5'd20, 20'd0,
                  "SRA x20, x12, shamt=48");

        // SRA x30, x31, shamt=63 (max)
        instruction = 32'b010000_111111_11111_101_11110_0110011;
        #10;
        check_all(7'b0110011, 3'b101, 7'b0010000, 5'd31, 6'd63, 5'd30, 20'd0,
                  "SRA x30, x31, shamt=63 (max)");

        //=====
        // Section 2: I-type 64-bit Shift (SLLI, SRLI, SRAI)
        // rv64_shift=1: rs2=6-bit shamt (same as instruction[25:20])
        // funct7={1'b0, inst[31:26]}, raw_imm=6-bit shamt
        $display("---------- Section 2: I-type 64-bit Shift (6-bit shamt) ----------\n");

        // SLLI x5, x10, 32 - rs2 also gets shamt (by design)
        instruction = 32'b000000_100000_01010_001_00101_0010011;
        #10;
        check_all(7'b0010011, 3'b001, 7'b0000000, 5'd10, 6'd32, 5'd5, {14'b0, 6'd32},
                  "SLLI x5, x10, 32");

        // SLLI x2, x1, 63 (max)
        instruction = 32'b000000_111111_00001_001_00010_0010011;
        #10;
        check_all(7'b0010011, 3'b001, 7'b0000000, 5'd1, 6'd63, 5'd2, {14'b0, 6'd63},
                  "SLLI x2, x1, 63 (max)");

        // SRLI x8, x4, 40
        instruction = 32'b000000_101000_00100_101_01000_0010011;
        #10;
        check_all(7'b0010011, 3'b101, 7'b0000000, 5'd4, 6'd40, 5'd8, {14'b0, 6'd40},
                  "SRLI x8, x4, 40");

        // SRAI x12, x6, 55 - funct7[4]=1
        instruction = 32'b010000_110111_00110_101_01100_0010011;
        #10;
        check_all(7'b0010011, 3'b101, 7'b0010000, 5'd6, 6'd55, 5'd12, {14'b0, 6'd55},
                  "SRAI x12, x6, 55");

        // SRAI x29, x28, 63 (max)
        instruction = 32'b010000_111111_11100_101_11101_0010011;
        #10;
        check_all(7'b0010011, 3'b101, 7'b0010000, 5'd28, 6'd63, 5'd29, {14'b0, 6'd63},
                  "SRAI x29, x28, 63 (max)");

        //===== 
        // Section 3: R-type Non-Shift (ADD, SUB, AND, OR, XOR, SLT, SLTU)
        // rv64_shift=0: rs2={1'b0, inst[24:20]}, funct7=inst[31:25]
        $display("---------- Section 3: R-type Non-Shift (5-bit rs2) ----------\n");

        // ADD x10, x5, x6
        instruction = 32'b0000000_00110_00101_000_01010_0110011;
        #10;
        check_all(7'b0110011, 3'b000, 7'b0000000, 5'd5, 6'd6, 5'd10, 20'd0,
                  "ADD x10, x5, x6");

        // SUB x12, x8, x4
        instruction = 32'b0100000_00100_01000_000_01100_0110011;
        #10;
        check_all(7'b0110011, 3'b000, 7'b0100000, 5'd8, 6'd4, 5'd12, 20'd0,
                  "SUB x12, x8, x4");

        // AND x15, x10, x20
        instruction = 32'b0000000_10100_01010_111_01111_0110011;
        #10;
        check_all(7'b0110011, 3'b111, 7'b0000000, 5'd10, 6'd20, 5'd15, 20'd0,
                  "AND x15, x10, x20");

        // OR x18, x12, x31
        instruction = 32'b0000000_11111_01100_110_10010_0110011;
        #10;
        check_all(7'b0110011, 3'b110, 7'b0000000, 5'd12, 6'd31, 5'd18, 20'd0,
                  "OR x18, x12, x31");

        // XOR x20, x15, x25
        instruction = 32'b0000000_11001_01111_100_10100_0110011;
        #10;
        check_all(7'b0110011, 3'b100, 7'b0000000, 5'd15, 6'd25, 5'd20, 20'd0,
                  "XOR x20, x15, x25");

        // SLT x22, x18, x28
        instruction = 32'b0000000_11100_10010_010_10110_0110011;
        #10;
        check_all(7'b0110011, 3'b010, 7'b0000000, 5'd18, 6'd28, 5'd22, 20'd0,
                  "SLT x22, x18, x28");

        // SLTU x24, x20, x30
        instruction = 32'b0000000_11110_10100_011_11000_0110011;
        #10;
        check_all(7'b0110011, 3'b011, 7'b0000000, 5'd20, 6'd30, 5'd24, 20'd0,
                  "SLTU x24, x20, x30");

        //===== 
        // Section 4: I-type Non-Shift (ADDI, ANDI, ORI, XORI, SLTI, SLTIU)
        // rv64_shift=0, raw_imm=12-bit, funct7/rs2 are don't care
        $display("---------- Section 4: I-type Non-Shift (12-bit imm) ----------\n");

        // ADDI x5, x10, 100
        instruction = 32'b000001100100_01010_000_00101_0010011;
        #10;
        check_i_type(7'b0010011, 3'b000, 5'd10, 5'd5, {8'b0, 12'd100}, "ADDI x5, x10, 100");

        // ADDI x8, x15, -16
        instruction = 32'b111111110000_01111_000_01000_0010011;
        #10;
        check_i_type(7'b0010011, 3'b000, 5'd15, 5'd8, {8'b0, 12'b111111110000}, "ADDI x8, x15, -16");

        // ANDI x12, x6, 0xFF
        instruction = 32'b000011111111_00110_111_01100_0010011;
        #10;
        check_i_type(7'b0010011, 3'b111, 5'd6, 5'd12, {8'b0, 12'h0FF}, "ANDI x12, x6, 0xFF");

        // ORI x14, x8, 0x123
        instruction = 32'b000100100011_01000_110_01110_0010011;
        #10;
        check_i_type(7'b0010011, 3'b110, 5'd8, 5'd14, {8'b0, 12'h123}, "ORI x14, x8, 0x123");

        // XORI x16, x10, 0x7FF
        instruction = 32'b011111111111_01010_100_10000_0010011;
        #10;
        check_i_type(7'b0010011, 3'b100, 5'd10, 5'd16, {8'b0, 12'h7FF}, "XORI x16, x10, 0x7FF");

        // SLTI x18, x12, -1
        instruction = 32'b111111111111_01100_010_10010_0010011;
        #10;
        check_i_type(7'b0010011, 3'b010, 5'd12, 5'd18, {8'b0, 12'hFFF}, "SLTI x18, x12, -1");

        // SLTIU x20, x14, 2047
        instruction = 32'b011111111111_01110_011_10100_0010011;
        #10;
        check_i_type(7'b0010011, 3'b011, 5'd14, 5'd20, {8'b0, 12'h7FF}, "SLTIU x20, x14, 2047");

        //===== 
        // Section 5: Load Instructions
        $display("---------- Section 5: Load Instructions ----------\n");

        // LW x5, 100(x10)
        instruction = 32'b000001100100_01010_010_00101_0000011;
        #10;
        check_i_type(7'b0000011, 3'b010, 5'd10, 5'd5, {8'b0, 12'd100}, "LW x5, 100(x10)");

        // LD x10, 256(x5)
        instruction = 32'b000100000000_00101_011_01010_0000011;
        #10;
        check_i_type(7'b0000011, 3'b011, 5'd5, 5'd10, {8'b0, 12'd256}, "LD x10, 256(x5)");

        // LWU x12, 64(x8)
        instruction = 32'b000001000000_01000_110_01100_0000011;
        #10;
        check_i_type(7'b0000011, 3'b110, 5'd8, 5'd12, {8'b0, 12'd64}, "LWU x12, 64(x8)");

        // LB x4, -4(x3)
        instruction = 32'b111111111100_00011_000_00100_0000011;
        #10;
        check_i_type(7'b0000011, 3'b000, 5'd3, 5'd4, {8'b0, 12'b111111111100}, "LB x4, -4(x3)");

        // LH x6, 8(x5)
        instruction = 32'b000000001000_00101_001_00110_0000011;
        #10;
        check_i_type(7'b0000011, 3'b001, 5'd5, 5'd6, {8'b0, 12'd8}, "LH x6, 8(x5)");

        // LBU x8, 1(x7)
        instruction = 32'b000000000001_00111_100_01000_0000011;
        #10;
        check_i_type(7'b0000011, 3'b100, 5'd7, 5'd8, {8'b0, 12'd1}, "LBU x8, 1(x7)");

        // LHU x10, -2(x9)
        instruction = 32'b111111111110_01001_101_01010_0000011;
        #10;
        check_i_type(7'b0000011, 3'b101, 5'd9, 5'd10, {8'b0, 12'b111111111110}, "LHU x10, -2(x9)");

        //===== 
        // Section 6: RV64I Word Instructions (OPCODE_ITYPE_WORD)
        $display("---------- Section 6: RV64I I-type Word Instructions ----------\n");

        // ADDIW x5, x10, 100
        instruction = 32'b000001100100_01010_000_00101_0011011;
        #10;
        check_i_type(7'b0011011, 3'b000, 5'd10, 5'd5, {8'b0, 12'd100}, "ADDIW x5, x10, 100");

        // ADDIW x8, x15, -16
        instruction = 32'b111111110000_01111_000_01000_0011011;
        #10;
        check_i_type(7'b0011011, 3'b000, 5'd15, 5'd8, {8'b0, 12'b111111110000}, "ADDIW x8, x15, -16");

        // SLLIW x8, x4, 16 (5-bit shamt)
        instruction = 32'b0000000_10000_00100_001_01000_0011011;
        #10;
        check_all(7'b0011011, 3'b001, 7'b0000000, 5'd4, 6'd16, 5'd8, {15'b0, 5'd16},
                  "SLLIW x8, x4, 16");

        // SLLIW x3, x2, 31 (max 5-bit)
        instruction = 32'b0000000_11111_00010_001_00011_0011011;
        #10;
        check_all(7'b0011011, 3'b001, 7'b0000000, 5'd2, 6'd31, 5'd3, {15'b0, 5'd31},
                  "SLLIW x3, x2, 31 (max)");

        // SRLIW x12, x6, 20
        instruction = 32'b0000000_10100_00110_101_01100_0011011;
        #10;
        check_all(7'b0011011, 3'b101, 7'b0000000, 5'd6, 6'd20, 5'd12, {15'b0, 5'd20},
                  "SRLIW x12, x6, 20");

        // SRAIW x15, x8, 25 - funct7=0100000
        instruction = 32'b0100000_11001_01000_101_01111_0011011;
        #10;
        check_all(7'b0011011, 3'b101, 7'b0100000, 5'd8, 6'd25, 5'd15, {15'b0, 5'd25},
                  "SRAIW x15, x8, 25");

        //===== 
        // Section 7: RV64I R-type Word Instructions (OPCODE_RTYPE_WORD)
        $display("---------- Section 7: RV64I R-type Word Instructions ----------\n");

        // ADDW x10, x5, x6
        instruction = 32'b0000000_00110_00101_000_01010_0111011;
        #10;
        check_all(7'b0111011, 3'b000, 7'b0000000, 5'd5, 6'd6, 5'd10, 20'd0,
                  "ADDW x10, x5, x6");

        // SUBW x12, x8, x4
        instruction = 32'b0100000_00100_01000_000_01100_0111011;
        #10;
        check_all(7'b0111011, 3'b000, 7'b0100000, 5'd8, 6'd4, 5'd12, 20'd0,
                  "SUBW x12, x8, x4");

        // SLLW x14, x10, x5
        instruction = 32'b0000000_00101_01010_001_01110_0111011;
        #10;
        check_all(7'b0111011, 3'b001, 7'b0000000, 5'd10, 6'd5, 5'd14, 20'd0,
                  "SLLW x14, x10, x5");

        // SRLW x16, x12, x6
        instruction = 32'b0000000_00110_01100_101_10000_0111011;
        #10;
        check_all(7'b0111011, 3'b101, 7'b0000000, 5'd12, 6'd6, 5'd16, 20'd0,
                  "SRLW x16, x12, x6");

        // SRAW x18, x14, x7
        instruction = 32'b0100000_00111_01110_101_10010_0111011;
        #10;
        check_all(7'b0111011, 3'b101, 7'b0100000, 5'd14, 6'd7, 5'd18, 20'd0,
                  "SRAW x18, x14, x7");

        //===== 
        // Section 8: Store Instructions
        $display("---------- Section 8: Store Instructions ----------\n");

        // SW x10, 100(x5) - raw_imm = {imm[11:5], imm[4:0]} = {0000011, 00100} = 100
        instruction = 32'b0000011_01010_00101_010_00100_0100011;
        #10;
        check_all(7'b0100011, 3'b010, 7'b0000011, 5'd5, 6'd10, 5'd4, {8'b0, 12'd100},
                  "SW x10, 100(x5)");

        // SD x15, 256(x8) - raw_imm = {0001000, 00000} = 256
        instruction = 32'b0001000_01111_01000_011_00000_0100011;
        #10;
        check_all(7'b0100011, 3'b011, 7'b0001000, 5'd8, 6'd15, 5'd0, {8'b0, 12'd256},
                  "SD x15, 256(x8)");

        // SB x20, 8(x3) - raw_imm = {0000000, 01000} = 8
        instruction = 32'b0000000_10100_00011_000_01000_0100011;
        #10;
        check_all(7'b0100011, 3'b000, 7'b0000000, 5'd3, 6'd20, 5'd8, {8'b0, 12'd8},
                  "SB x20, 8(x3)");

        // SH x12, -4(x6) - raw_imm = {1111111, 11100} = -4
        instruction = 32'b1111111_01100_00110_001_11100_0100011;
        #10;
        check_all(7'b0100011, 3'b001, 7'b1111111, 5'd6, 6'd12, 5'd28, {8'b0, 12'b111111111100},
                  "SH x12, -4(x6)");

        //===== 
        // Section 9: Branch Instructions
        $display("---------- Section 9: Branch Instructions ----------\n");

        // BEQ x5, x6, +8 - raw_imm = {inst[31], inst[7], inst[30:25], inst[11:8]}
        instruction = 32'b0000000_00110_00101_000_01000_1100011;
        #10;
        check_all(7'b1100011, 3'b000, 7'b0000000, 5'd5, 6'd6, 5'd8, 12'b0_0_000000_0100,
                  "BEQ x5, x6, +8");

        // BNE x10, x15, -16
        instruction = 32'b1111111_01111_01010_001_10001_1100011;
        #10;
        check_all(7'b1100011, 3'b001, 7'b1111111, 5'd10, 6'd15, 5'd17, 12'b1_1_111111_1000,
                  "BNE x10, x15, -16");

        // BLT x3, x4, +128
        instruction = 32'b0000100_00100_00011_100_00000_1100011;
        #10;
        check_all(7'b1100011, 3'b100, 7'b0000100, 5'd3, 6'd4, 5'd0, 12'b0_0_000100_0000,
                  "BLT x3, x4, +128");

        // BGE x7, x8, +16
        // raw_imm = {inst[31], inst[7], inst[30:25], inst[11:8]}
        // imm=+16 → imm[12:1]=0000_0000_1000, imm[11]=0, inst[7]=0
        instruction = 32'b0000000_01000_00111_101_10000_1100011;
        #10;
        check_all(7'b1100011, 3'b101, 7'b0000000, 5'd7, 6'd8, 5'd16, 12'b0_0_000000_1000,
                  "BGE x7, x8, +16");

        //=====
        // Section 10: U-type Instructions (LUI, AUIPC)
        // Note: funct3/funct7/rs1/rs2 are don't care (direct wire to instruction bits)
        $display("---------- Section 10: U-type Instructions ----------\n");

        // LUI x5, 0x12345
        instruction = 32'b00010010001101000101_00101_0110111;
        #10;
        check_u_type(7'b0110111, 5'd5, 20'h12345, "LUI x5, 0x12345");

        // LUI x10, 0xFFFFF
        instruction = 32'b11111111111111111111_01010_0110111;
        #10;
        check_u_type(7'b0110111, 5'd10, 20'hFFFFF, "LUI x10, 0xFFFFF");

        // AUIPC x6, 0xABCDE
        instruction = 32'b10101011110011011110_00110_0010111;
        #10;
        check_u_type(7'b0010111, 5'd6, 20'hABCDE, "AUIPC x6, 0xABCDE");

        // AUIPC x15, 0x00001
        instruction = 32'b00000000000000000001_01111_0010111;
        #10;
        check_u_type(7'b0010111, 5'd15, 20'h00001, "AUIPC x15, 0x00001");

        //=====
        // Section 11: J-type Instructions (JAL)
        $display("---------- Section 11: J-type Instructions (JAL) ----------\n");

        // JAL x1, +8 - raw_imm = {inst[31], inst[19:12], inst[20], inst[30:21]}
        instruction = 32'b0_0000000100_0_00000000_00001_1101111;
        #10;
        check_u_type(7'b1101111, 5'd1, 20'b0_00000000_0_0000000100, "JAL x1, +8");

        // JAL x0, -20 (unconditional jump)
        instruction = 32'b1_1111110110_1_11111111_00000_1101111;
        #10;
        check_u_type(7'b1101111, 5'd0, 20'b1_11111111_1_1111110110, "JAL x0, -20");

        //=====
        // Section 12: JALR Instructions
        $display("---------- Section 12: JALR Instructions ----------\n");

        // JALR x1, 0(x5)
        instruction = 32'b000000000000_00101_000_00001_1100111;
        #10;
        check_i_type(7'b1100111, 3'b000, 5'd5, 5'd1, {8'b0, 12'd0}, "JALR x1, 0(x5)");

        // JALR x0, 4(x1) - return
        instruction = 32'b000000000100_00001_000_00000_1100111;
        #10;
        check_i_type(7'b1100111, 3'b000, 5'd1, 5'd0, {8'b0, 12'd4}, "JALR x0, 4(x1)");

        //=====
        // Section 13: Environment Instructions (ECALL, EBREAK, CSR)
        $display("---------- Section 13: Environment Instructions ----------\n");

        // ECALL
        instruction = 32'b000000000000_00000_000_00000_1110011;
        #10;
        check_i_type(7'b1110011, 3'b000, 5'd0, 5'd0, {8'b0, 12'd0}, "ECALL");

        // EBREAK
        instruction = 32'b000000000001_00000_000_00000_1110011;
        #10;
        check_i_type(7'b1110011, 3'b000, 5'd0, 5'd0, {8'b0, 12'd1}, "EBREAK");

        // CSRRW x5, mstatus, x10
        instruction = 32'b001100000000_01010_001_00101_1110011;
        #10;
        check_i_type(7'b1110011, 3'b001, 5'd10, 5'd5, {8'b0, 12'h300}, "CSRRW x5, mstatus(0x300), x10");

        // CSRRSI x8, mie, 0x1F
        instruction = 32'b001100000100_11111_110_01000_1110011;
        #10;
        check_i_type(7'b1110011, 3'b110, 5'd31, 5'd8, {8'b0, 12'h304}, "CSRRSI x8, mie(0x304), 0x1F");

        // Summary
        $display("=====");
        $display("TEST SUMMARY");
        $display("=====");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        if (fail_count == 0) begin
            $display("Result:      ALL TESTS PASSED!");
        end else begin
            $display("Result:      SOME TESTS FAILED!");
        end
        $display("=====");

        $finish;
    end

endmodule