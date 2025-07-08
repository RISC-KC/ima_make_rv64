`timescale 1ns/1ps

`include "modules/headers/branch_funct3.vh"
`include "modules/headers/csr_funct3.vh"
`include "modules/headers/itype_funct3.vh"
`include "modules/headers/load_funct3.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype_funct3.vh"
`include "modules/headers/store_funct3.vh"

module ALUController_tb;
	reg [6:0] opcode;
	reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] imm;
	
    wire [4:0] alu_op;
    wire input_size_word;

    ALUController dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_0(funct7[0]),
        .funct7_5(funct7[5]),
		.imm_10(imm[10]),

        .alu_op(alu_op),
        .input_size_word(input_size_word)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_Controller_tb_result.vcd");
        $dumpvars(0, dut);

        opcode = 7'b0;
		funct3 = 3'b0;
		funct7 = 7'b0;
        imm = 32'b0;

        // Test sequence
        $display("==================== ALU Controller Test START ====================");

        // Test 1: AUIPC
		$display("\nAUIPC: ");
		
		opcode = `OPCODE_AUIPC; #10;
        $display("opcode: %b -> alu_op: %b, input_size_word: %b", opcode, alu_op, input_size_word);

        // Test 2: JAL
		$display("\nJAL: ");
		
		opcode = `OPCODE_JAL; #10;
        $display("opcode: %b -> alu_op: %b, input_size_word: %b", opcode, alu_op, input_size_word);

        // Test 3: JALR
        $display("\nJALR: ");
		
		opcode = `OPCODE_JALR;
        funct3 = 3'b0;
		funct7 = 7'b0;
		imm = 32'h0;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);

        // Test 4: Branch instructions
        $display("\nBranch instructions: ");
		
		opcode = `OPCODE_BRANCH;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `BRANCH_BEQ; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `BRANCH_BNE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `BRANCH_BLT; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `BRANCH_BGE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `BRANCH_BLTU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `BRANCH_BGEU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);

        // Test 5: Load instructions
        $display("\nLoad instructions: ");
		
		opcode = `OPCODE_LOAD;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `LOAD_LB; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `LOAD_LH; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `LOAD_LW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);

        funct3 = `LOAD_LD; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `LOAD_LBU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `LOAD_LHU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);

        funct3 = `LOAD_LWU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		// Test 6: Store instructions
        $display("\nStore instructions: ");
		
		opcode = `OPCODE_STORE;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `STORE_SB; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
        funct3 = `STORE_SH; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
        funct3 = `STORE_SW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
        
        funct3 = `STORE_SD; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);

		// Test 7: I-type instructions
        $display("\nI-type instructions: ");
		
		opcode = `OPCODE_ITYPE;
		imm = 32'b0;

        funct3 = `ITYPE_ADDI;
		funct7 = 7'b0000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_SLLI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_SLTI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_SLTIU; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);

        funct3 = `ITYPE_XORI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);

		funct3 = `ITYPE_SRXI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		imm = 32'h00000400; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_ORI;
		imm = 32'h00000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_ANDI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);

        // Test 8: I-type WORD instructions
        $display("\nI-type WORD instructions: ");
		
		opcode = `OPCODE_ITYPE_WORD;
		imm = 32'b0;

        funct3 = `ITYPE_ADDI;
		funct7 = 7'b0000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `ITYPE_SLLI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);

		funct3 = `ITYPE_SRXI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
		imm = 32'h00000400; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", imm, funct3, opcode, alu_op, input_size_word);
		
        // Test 9: R-type instructions
		$display("\nR-type instructions: ");
		
		opcode = `OPCODE_RTYPE;
		imm = 32'h00000000;

		funct3 = `RTYPE_ADDSUB;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
        
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SLL;
		funct7 = 7'b0000000;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SLT; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SLTU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_XOR; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SRX; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_OR;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_AND; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct7 = 7'b0000001;

        funct3 = `RTYPE_MUL; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_MULH; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_MULHSU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_MULHU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_DIV; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_DIVU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_REM; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_REMU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        // Test 10: R-type WORD instructions
		$display("\nR-type WORD instructions: ");
		
		opcode = `OPCODE_RTYPE_WORD;
		imm = 32'h00000000;

		funct3 = `RTYPE_ADDSUB;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
        
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SLL;
		funct7 = 7'b0000000;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct3 = `RTYPE_SRX; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
		
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct7 = 7'b0000001;

        funct3 = `RTYPE_MUL; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);
        
        funct3 = `RTYPE_DIV; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_DIVU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_REM; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

        funct3 = `RTYPE_REMU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct7, funct3, opcode, alu_op, input_size_word);

		// Test 11: CSR instructions
        $display("\nCSR instructions: ");
		
		opcode = `OPCODE_ENVIRONMENT;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `CSR_CSRRW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `CSR_CSRRS; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `CSR_CSRRC; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `CSR_CSRRWI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `CSR_CSRRSI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		funct3 = `CSR_CSRRCI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		// Test 12: Invalid
        $display("\nInvalid instruction: ");
			
		opcode = 7'b0101010; // Doesn't exist!
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b, input_size_word: %b", funct3, opcode, alu_op, input_size_word);
		
		$display("\n====================  ALU Controller Test END  ====================");
		
		$stop;
    end

endmodule