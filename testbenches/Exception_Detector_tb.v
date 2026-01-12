`timescale 1ns/1ps
`include "modules/headers/opcode.vh"
`include "modules/headers/store_funct3.vh"
`include "modules/headers/load_funct3.vh"
`include "modules/headers/trap.vh"

module ExceptionDetector_tb;
    // Clock and Reset
    reg clk;
    reg reset;

    // ID Stage Inputs
    reg [6:0] ID_opcode;
    reg [2:0] ID_funct3;
    reg [11:0] raw_imm;
    reg [1:0] branch_target_lsbs;
    reg branch_estimation;

    // EX Stage Inputs
    reg [6:0] EX_opcode;
    reg [2:0] EX_funct3;
    reg [11:0] EX_raw_imm;
    reg [1:0] alu_result;

    // MEM Stage Inputs
    reg [6:0] MEM_opcode;
    reg [2:0] MEM_funct3;
    reg [1:0] MEM_alu_result;

    // CSR
    reg csr_write_enable;
	
    // Outputs
    wire trapped;
    wire [2:0] trap_status;

    ExceptionDetector dut (
        .clk(clk),
        .reset(reset),
        .ID_opcode(ID_opcode),
        .EX_opcode(EX_opcode),
        .MEM_opcode(MEM_opcode),
        .ID_funct3(ID_funct3),
        .EX_funct3(EX_funct3),
        .MEM_funct3(MEM_funct3),
        .alu_result(alu_result),
        .MEM_alu_result(MEM_alu_result),
        .raw_imm(raw_imm),
        .EX_raw_imm(EX_raw_imm),
        .csr_write_enable(csr_write_enable),
        .branch_target_lsbs(branch_target_lsbs),
        .branch_estimation(branch_estimation),
		
    	.trapped(trapped),
        .trap_status(trap_status)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helper task to wait for synchronous output
    task wait_clk;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    // Helper task to clear all inputs
    task clear_inputs;
        begin
            ID_opcode = 7'b0;
            ID_funct3 = 3'b0;
            raw_imm = 12'b0;
            branch_target_lsbs = 2'b0;
            branch_estimation = 1'b0;
            EX_opcode = 7'b0;
            EX_funct3 = 3'b0;
            EX_raw_imm = 12'b0;
            alu_result = 2'b0;
            MEM_opcode = 7'b0;
            MEM_funct3 = 3'b0;
            MEM_alu_result = 2'b0;
            csr_write_enable = 1'b0;
        end
    endtask

    initial begin
        // Test sequence
        $display("==================== Exception Detector Test START ====================");

        // Initialize
        reset = 1;
        clear_inputs;
        
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Test 1: No exception
        $display("\nNo exception: ");
        
        clear_inputs;
        ID_opcode = `OPCODE_RTYPE;
        wait_clk;
        $display("ID_opcode: %b, trapped: %b, trap_status: %b", ID_opcode, trapped, trap_status);
        
        // Test 2: EBREAK/ECALL/MRET (ID Stage)
        $display("\nEBREAK/ECALL/MRET (ID Stage): ");
        
        clear_inputs;
        ID_opcode = `OPCODE_ENVIRONMENT;
        ID_funct3 = 3'b000;
        
        raw_imm = 12'b000000000001;  // EBREAK
        wait_clk;
        $display("ID_opcode: %b, raw_imm[0]: %b, trapped: %b, trap_status: %b (EBREAK)", ID_opcode, raw_imm[0], trapped, trap_status);
        
        raw_imm = 12'b000000000000;  // ECALL
        wait_clk;
        $display("ID_opcode: %b, raw_imm[0]: %b, trapped: %b, trap_status: %b (ECALL)", ID_opcode, raw_imm[0], trapped, trap_status);
        
        raw_imm = 12'b001100000010;  // MRET
        wait_clk;
        $display("ID_opcode: %b, raw_imm: %b, trapped: %b, trap_status: %b (MRET)", ID_opcode, raw_imm, trapped, trap_status);

        // Test 3: FENCE.I (ID Stage)
        $display("\nFENCE.I (ID Stage): ");
        
        clear_inputs;
        ID_opcode = `OPCODE_FENCE;
        ID_funct3 = 3'b001;  // FENCE.I
        wait_clk;
        $display("ID_opcode: %b, ID_funct3: %b, trapped: %b, trap_status: %b (FENCEI)", ID_opcode, ID_funct3, trapped, trap_status);

        // Test 4: Branch Address misaligned (ID Stage)
        $display("\nBranch Address misaligned (ID Stage): ");
        
        clear_inputs;
        ID_opcode = `OPCODE_BRANCH;
        branch_estimation = 1'b1;  // Branch taken prediction
        
        $display("\nAligned Branch: ");
        branch_target_lsbs = 2'b00;
        wait_clk;
        $display("ID_opcode: %b, branch_target_lsbs: %b, trapped: %b, trap_status: %b", ID_opcode, branch_target_lsbs, trapped, trap_status);

        $display("\nMisaligned Branch: ");
        branch_target_lsbs = 2'b01;
        wait_clk;
        $display("ID_opcode: %b, branch_target_lsbs: %b, trapped: %b, trap_status: %b", ID_opcode, branch_target_lsbs, trapped, trap_status);
        
        // Test 5: JAL/JALR misaligned (EX Stage)
        $display("\nJAL/JALR misaligned (EX Stage): ");
        
        clear_inputs;
        EX_opcode = `OPCODE_JAL;
        
        $display("\nAligned JAL: ");
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, alu_result, trapped, trap_status);

        $display("\nMisaligned JAL: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, alu_result, trapped, trap_status);

        clear_inputs;
        EX_opcode = `OPCODE_JALR;
        
        $display("\nAligned JALR: ");
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, alu_result, trapped, trap_status);

        $display("\nMisaligned JALR: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, alu_result, trapped, trap_status);

        // Test 6: Store misaligned (EX Stage)
        $display("\nStore misaligned (EX Stage): ");
        
        clear_inputs;
        EX_opcode = `OPCODE_STORE;
        
        $display("\nAligned SH: ");
        EX_funct3 = `STORE_SH;
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nMisaligned SH: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nAligned SW: ");
        EX_funct3 = `STORE_SW;
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nMisaligned SW: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        // Test 7: Load misaligned (EX Stage)
        $display("\nLoad misaligned (EX Stage): ");
        
        clear_inputs;
        EX_opcode = `OPCODE_LOAD;
        
        $display("\nAligned LH: ");
        EX_funct3 = `LOAD_LH;
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nMisaligned LH: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nAligned LW: ");
        EX_funct3 = `LOAD_LW;
        alu_result = 2'b00;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        $display("\nMisaligned LW: ");
        alu_result = 2'b01;
        wait_clk;
        $display("EX_opcode: %b, EX_funct3: %b, alu_result: %b, trapped: %b, trap_status: %b", EX_opcode, EX_funct3, alu_result, trapped, trap_status);

        // Test 8: MEM Stage exceptions (for completeness)
        $display("\nMEM Stage Store misaligned: ");
        
        clear_inputs;
        MEM_opcode = `OPCODE_STORE;
        MEM_funct3 = `STORE_SW;
        
        $display("\nAligned SW (MEM): ");
        MEM_alu_result = 2'b00;
        wait_clk;
        $display("MEM_opcode: %b, MEM_funct3: %b, MEM_alu_result: %b, trapped: %b, trap_status: %b", MEM_opcode, MEM_funct3, MEM_alu_result, trapped, trap_status);

        $display("\nMisaligned SW (MEM): ");
        MEM_alu_result = 2'b01;
        wait_clk;
        $display("MEM_opcode: %b, MEM_funct3: %b, MEM_alu_result: %b, trapped: %b, trap_status: %b", MEM_opcode, MEM_funct3, MEM_alu_result, trapped, trap_status);

        // Test 9: Priority test (MEM > EX > ID)
        $display("\nPriority test (MEM > EX > ID): ");
        
        clear_inputs;
        // Set ID exception
        ID_opcode = `OPCODE_ENVIRONMENT;
        ID_funct3 = 3'b000;
        raw_imm = 12'b000000000001;  // EBREAK
        // Set EX exception
        EX_opcode = `OPCODE_JAL;
        alu_result = 2'b01;  // Misaligned
        // Set MEM exception
        MEM_opcode = `OPCODE_STORE;
        MEM_funct3 = `STORE_SW;
        MEM_alu_result = 2'b01;  // Misaligned
        
        wait_clk;
        $display("ID: EBREAK, EX: Misaligned JAL, MEM: Misaligned SW");
        $display("trapped: %b, trap_status: %b (Expected: TRAP_MISALIGNED_STORE = 110)", trapped, trap_status);

        $display("\n====================  Exception Detector Test END  ====================");

        $stop;
    end

endmodule