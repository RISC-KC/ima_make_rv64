`timescale 1ns/1ps

`include "modules/headers/branch_funct3.vh"
`include "modules/headers/csr_funct3.vh"
`include "modules/headers/itype_funct3.vh"
`include "modules/headers/load_funct3.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype_funct3.vh"
`include "modules/headers/store_funct3.vh"
`include "modules/headers/alu_src_select.vh"
`include "modules/headers/rf_wd_select.vh"

module ControlUnit_tb;
    reg write_done;
    reg trap_done;
    reg csr_ready;
    reg IF_ID_stall;
	reg [6:0] opcode;
	reg [2:0] funct3;
    
	wire jump;
	wire branch;
	wire [1:0] alu_src_A_select;
	wire [2:0] alu_src_B_select;
	wire csr_write_enable;
	wire register_file_write;
	wire [2:0] register_file_write_data_select;
    wire memory_read;
	wire memory_write;
    wire pc_stall;

    ControlUnit control_unit (
        .write_done(write_done),
        .trap_done(trap_done),
        .csr_ready(csr_ready),
        .IF_ID_stall(IF_ID_stall),
        .opcode(opcode),
        .funct3(funct3),

        .jump(jump),
        .branch(branch),
        .alu_src_A_select(alu_src_A_select),
        .alu_src_B_select(alu_src_B_select),
        .csr_write_enable(csr_write_enable),
        .register_file_write(register_file_write),
        .register_file_write_data_select(register_file_write_data_select),
        .memory_read(memory_read),
        .memory_write(memory_write),
        .pc_stall(pc_stall)
    );

    // Helper task to set normal operating conditions
    task set_normal_conditions;
        begin
            write_done = 1;
            trap_done = 1;
            csr_ready = 1;
            IF_ID_stall = 0;
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/Control_Unit_tb_result.vcd");
        $dumpvars(0, control_unit);

        // Test sequence
        $display("==================== Control Unit Test START ====================");

        // Initialize
        set_normal_conditions;
        opcode = `OPCODE_RTYPE;
        funct3 = `RTYPE_ADDSUB;

        // Test 1: Writing not done
		$display("\nWriting not done: ");

        write_done = 0;
        trap_done = 1;
        csr_ready = 1;
        IF_ID_stall = 0;

        #1;
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);


        set_normal_conditions;

        // Test 1-2: Pre-Trap Handling not done
        $display("\nPTH not done: ");

        trap_done = 0;

        #1;
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        set_normal_conditions;

        // Test 1-3: CSR not ready
        $display("\nCSR not ready: ");

        csr_ready = 0;

        #1;
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        set_normal_conditions;

        // Test 1-4: IF_ID stall
        $display("\nIF_ID stall: ");

        IF_ID_stall = 1;

        #1;
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        set_normal_conditions;

        // Test 2: LUI
		$display("\nLUI: ");
		
		opcode = `OPCODE_LUI;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 3: AUIPC
		$display("\nAUIPC: ");
		
		opcode = `OPCODE_AUIPC;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 4: JAL
		$display("\nJAL: ");
		
		opcode = `OPCODE_JAL;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 5: JALR
		$display("\nJALR: ");
		
		opcode = `OPCODE_JALR;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 6: Branch
		$display("\nBranch: ");
		
		opcode = `OPCODE_BRANCH;
        
        funct3 = `BRANCH_BEQ; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `BRANCH_BNE; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `BRANCH_BLT; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `BRANCH_BGE; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `BRANCH_BLTU; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `BRANCH_BGEU; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 7: Load
		$display("\nLoad: ");
		
		opcode = `OPCODE_LOAD;
        
        funct3 = `LOAD_LB; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `LOAD_LH; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `LOAD_LW; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `LOAD_LBU; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `LOAD_LHU; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 8: Store
		$display("\nStore: ");
		
		opcode = `OPCODE_STORE;
        
        funct3 = `STORE_SB; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `STORE_SH; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `STORE_SW; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 9: I-type
		$display("\nI-type: ");
		
		opcode = `OPCODE_ITYPE;
        
        funct3 = `ITYPE_ADDI; #1;
        $display("funct3: %b (ADDI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_SLLI; #1;
        $display("funct3: %b (SLLI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `ITYPE_SLTI; #1;
        $display("funct3: %b (SLTI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_SLTIU; #1;
        $display("funct3: %b (SLTIU)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_XORI; #1;
        $display("funct3: %b (XORI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_SRXI; #1;
        $display("funct3: %b (SRXI - uses SHAMT)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_ORI; #1;
        $display("funct3: %b (ORI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_ANDI; #1;
        $display("funct3: %b (ANDI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 9-2: I-type Word (RV64I)
		$display("\nI-type Word (RV64I): ");
		
		opcode = `OPCODE_ITYPE_WORD;
        
        funct3 = `ITYPE_ADDI; #1;  // ADDIW
        $display("funct3: %b (ADDIW)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_SLLI; #1;  // SLLIW (uses IMM, not SHAMT)
        $display("funct3: %b (SLLIW - uses IMM)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `ITYPE_SRXI; #1;  // SRLIW/SRAIW (uses SHAMT)
        $display("funct3: %b (SRLIW/SRAIW - uses SHAMT)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 10: R-type
		$display("\nR-type: ");
		
		opcode = `OPCODE_RTYPE;
        
        funct3 = `RTYPE_ADDSUB; #1;
        $display("funct3: %b (ADDSUB)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_SLL; #1;
        $display("funct3: %b (SLL)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `RTYPE_SLT; #1;
        $display("funct3: %b (SLT)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_SLTU; #1;
        $display("funct3: %b (SLTU)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_XOR; #1;
        $display("funct3: %b (XOR)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_SRX; #1;
        $display("funct3: %b (SR)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_OR; #1;
        $display("funct3: %b (OR)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_AND; #1;
        $display("funct3: %b (AND)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 10-2: R-type Word (RV64I)
		$display("\nR-type Word (RV64I): ");
		
		opcode = `OPCODE_RTYPE_WORD;
        
        funct3 = `RTYPE_ADDSUB; #1;  // ADDW/SUBW
        $display("funct3: %b (ADDW/SUBW)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_SLL; #1;  // SLLW
        $display("funct3: %b (SLLW)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `RTYPE_SRX; #1;  // SRLW/SRAW
        $display("funct3: %b (SRLW/SRAW)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 11: Fence
		$display("\nFence: ");
		
		opcode = `OPCODE_FENCE;
        funct3 = 3'b0;
        
        #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        // Test 12: Environment
		$display("\nEnvironment: ");
		
		opcode = `OPCODE_ENVIRONMENT;
        
        funct3 = 3'b0; #1;
        $display("funct3: %b (ECALL/EBREAK/MRET)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `CSR_CSRRW; #1;
        $display("funct3: %b (CSRRW)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);
		
        funct3 = `CSR_CSRRS; #1;
        $display("funct3: %b (CSRRS)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `CSR_CSRRC; #1;
        $display("funct3: %b (CSRRC)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `CSR_CSRRWI; #1;
        $display("funct3: %b (CSRRWI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `CSR_CSRRSI; #1;
        $display("funct3: %b (CSRRSI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b\n", memory_read, memory_write, pc_stall);

        funct3 = `CSR_CSRRCI; #1;
        $display("funct3: %b (CSRRCI)", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pc_stall: %b", memory_read, memory_write, pc_stall);

        $display("\n====================  Control Unit Test END  ====================");

        $stop;
    end

endmodule