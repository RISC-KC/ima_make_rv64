`timescale 1ns/1ps

`include "modules/headers/opcode.vh"
`include "modules/headers/trap.vh"

module HazardUnit_tb;
    reg clk = 0;
    reg reset = 0;
    
    // Trap and CSR control signals
    reg trap_done;
    reg csr_ready;
    reg standby_mode;
    reg [2:0] trap_status;
    reg misaligned_instruction_flush;
    reg misaligned_memory_flush;
    reg pth_done_flush;

    // ID stage signals
    reg [4:0] ID_rs1;
    reg [4:0] ID_rs2;
    reg [11:0] ID_raw_imm;

    // MEM stage signals
    reg [4:0] MEM_rd;
    reg MEM_register_write_enable;
    reg MEM_csr_write_enable;
    reg [11:0] MEM_csr_write_address;

    // WB stage signals
    reg [4:0] WB_rd;
    reg WB_register_write_enable;
    reg WB_csr_write_enable;
    reg [11:0] WB_csr_write_address;

    // EX stage signals
    reg [4:0] EX_rd;
    reg [6:0] EX_opcode;
    reg [4:0] EX_rs1;
    reg [4:0] EX_rs2;
    reg [11:0] EX_imm;
    reg EX_csr_write_enable;

    // Control signals
    reg EX_jump;
    reg branch_prediction_miss; 

    // Outputs - ALU forwarding
    wire [1:0] hazard_mem;
    wire [1:0] hazard_wb;
    wire csr_hazard_mem;
    wire csr_hazard_wb;

    // Outputs - Store data forwarding
    wire store_hazard_mem;
    wire store_hazard_wb;

    // Outputs - Flush signals
    wire IF_ID_flush;
    wire ID_EX_flush;
    wire EX_MEM_flush;
    wire MEM_WB_flush;

    // Outputs - Stall signals
    wire IF_ID_stall;
    wire ID_EX_stall;
    wire EX_MEM_stall;
    wire MEM_WB_stall;

    HazardUnit dut (
        .clk(clk),
        .reset(reset),
        .trap_done(trap_done),
        .csr_ready(csr_ready),
        .standby_mode(standby_mode),
        .trap_status(trap_status),
        .misaligned_instruction_flush(misaligned_instruction_flush),
        .misaligned_memory_flush(misaligned_memory_flush),
        .pth_done_flush(pth_done_flush),
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .ID_raw_imm(ID_raw_imm),
        .MEM_rd(MEM_rd),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_csr_write_address(MEM_csr_write_address),
        .WB_rd(WB_rd),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_csr_write_address(WB_csr_write_address),
        .EX_rd(EX_rd),
        .EX_opcode(EX_opcode),
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .EX_imm(EX_imm),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_jump(EX_jump),
        .branch_prediction_miss(branch_prediction_miss),

        .hazard_mem(hazard_mem),
        .hazard_wb(hazard_wb),
        .csr_hazard_mem(csr_hazard_mem),
        .csr_hazard_wb(csr_hazard_wb),
        .store_hazard_mem(store_hazard_mem),
        .store_hazard_wb(store_hazard_wb),
        .IF_ID_flush(IF_ID_flush),
        .ID_EX_flush(ID_EX_flush),
        .EX_MEM_flush(EX_MEM_flush),
        .MEM_WB_flush(MEM_WB_flush),
        .IF_ID_stall(IF_ID_stall),
        .ID_EX_stall(ID_EX_stall),
        .EX_MEM_stall(EX_MEM_stall),
        .MEM_WB_stall(MEM_WB_stall)
    );

    always #5 clk = ~clk;

    // Task to reset all inputs to default state
    task reset_inputs;
    begin
        trap_done = 1'b1;
        csr_ready = 1'b1;
        standby_mode = 1'b0;
        trap_status = `TRAP_NONE;
        misaligned_instruction_flush = 1'b0;
        misaligned_memory_flush = 1'b0;
        pth_done_flush = 1'b0;
        ID_rs1 = 5'd0;
        ID_rs2 = 5'd0;
        ID_raw_imm = 12'd0;
        MEM_rd = 5'd0;
        MEM_register_write_enable = 1'b0;
        MEM_csr_write_enable = 1'b0;
        MEM_csr_write_address = 12'd0;
        WB_rd = 5'd0;
        WB_register_write_enable = 1'b0;
        WB_csr_write_enable = 1'b0;
        WB_csr_write_address = 12'd0;
        EX_rd = 5'd0;
        EX_opcode = `OPCODE_RTYPE;
        EX_rs1 = 5'd0;
        EX_rs2 = 5'd0;
        EX_imm = 12'd0;
        EX_csr_write_enable = 1'b0;
        EX_jump = 1'b0;
        branch_prediction_miss = 1'b0;
    end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/Hazard_Unit_tb_result.vcd");
        $dumpvars(0, HazardUnit_tb.dut);

        $display("==================== Hazard Unit Test START ====================\n");

        // reset signals
        reset = 1'b1;
        reset_inputs();
        #10;
        
        reset = 1'b0;
        @(posedge clk);

        // ===================== ALU Forwarding Tests =====================

        // Test 1 : No RAW hazard
        $display("Test 1 (No hazard)");
        reset_inputs();
        EX_rs1 = 5'd1;
        EX_rs2 = 5'd2;
        MEM_rd = 5'd3;
        MEM_register_write_enable = 1'b1;
        WB_rd = 5'd4;
        WB_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 00)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)", hazard_wb);
        $display("IF_ID_flush  = %b", IF_ID_flush);
        $display("ID_EX_flush  = %b\n", ID_EX_flush);
        
        // Test 2 : MEM stage rs1 hazard (MEM_rd == EX_rs1)
        $display("Test 2 (MEM rs1 hazard)");
        reset_inputs();
        EX_rs1 = 5'd3;
        EX_rs2 = 5'd4;
        MEM_rd = 5'd3;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 01)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)", hazard_wb);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)\n", ID_EX_flush);

        // Test 3 : MEM stage rs2 hazard (MEM_rd == EX_rs2)
        $display("Test 3 (MEM rs2 hazard)");
        reset_inputs();
        EX_rs1 = 5'd6;
        EX_rs2 = 5'd5;
        MEM_rd = 5'd5;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 10)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)", hazard_wb);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)\n", ID_EX_flush);

        // Test 4 : WB stage rs1 hazard (WB_rd == EX_rs1, no MEM hazard)
        $display("Test 4 (WB rs1 hazard)");
        reset_inputs();
        EX_rs1 = 5'd7;
        EX_rs2 = 5'd8;
        WB_rd = 5'd7;
        WB_register_write_enable = 1'b1;
        MEM_rd = 5'd9;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 00)", hazard_mem);
        $display("hazard_wb  = %b (expect 01)", hazard_wb);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)\n", ID_EX_flush);

        // Test 5 : Both MEM rs1/rs2 hazards
        $display("Test 5 (MEM both rs1/rs2 hazard)");
        reset_inputs();
        EX_rs1 = 5'd7;
        EX_rs2 = 5'd7;
        MEM_rd = 5'd7;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 11)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)", hazard_wb);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)\n", ID_EX_flush);

        // Test 6 : MEM priority over WB (same register)
        $display("Test 6 (MEM priority over WB)");
        reset_inputs();
        EX_rs1 = 5'd10;
        EX_rs2 = 5'd11;
        MEM_rd = 5'd10;
        MEM_register_write_enable = 1'b1;
        WB_rd = 5'd10;
        WB_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 01)", hazard_mem);
        $display("hazard_wb  = %b (expect 00, MEM has priority)", hazard_wb);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)\n", ID_EX_flush);

        // ===================== Store Data Forwarding Tests =====================

        // Test 7 : Store instruction - MEM stage rs2 hazard (store data forwarding)
        $display("Test 7 (Store MEM rs2 hazard - store data forwarding)");
        reset_inputs();
        EX_opcode = `OPCODE_STORE;
        EX_rs1 = 5'd1;
        EX_rs2 = 5'd5;  // store data register
        MEM_rd = 5'd5;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 00, store disables ALUsrcB)", hazard_mem);
        $display("store_hazard_mem = %b (expect 1)", store_hazard_mem);
        $display("store_hazard_wb  = %b (expect 0)\n", store_hazard_wb);

        // Test 8 : Store instruction - WB stage rs2 hazard
        $display("Test 8 (Store WB rs2 hazard - store data forwarding)");
        reset_inputs();
        EX_opcode = `OPCODE_STORE;
        EX_rs1 = 5'd1;
        EX_rs2 = 5'd6;  // store data register
        WB_rd = 5'd6;
        WB_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_wb = %b (expect 00, store disables ALUsrcB)", hazard_wb);
        $display("store_hazard_mem = %b (expect 0)", store_hazard_mem);
        $display("store_hazard_wb  = %b (expect 1)\n", store_hazard_wb);

        // ===================== CSR Hazard Tests =====================

        // Test 9 : CSR hazard from MEM stage
        $display("Test 9 (CSR hazard MEM)");
        reset_inputs();
        EX_imm = 12'h305;  // mtvec address
        MEM_csr_write_enable = 1'b1;
        MEM_csr_write_address = 12'h305;
        @(posedge clk);
        $display("csr_hazard_mem = %b (expect 1)", csr_hazard_mem);
        $display("csr_hazard_wb  = %b (expect 0)\n", csr_hazard_wb);

        // Test 10 : CSR hazard from WB stage
        $display("Test 10 (CSR hazard WB)");
        reset_inputs();
        EX_imm = 12'h341;  // mepc address
        WB_csr_write_enable = 1'b1;
        WB_csr_write_address = 12'h341;
        @(posedge clk);
        $display("csr_hazard_mem = %b (expect 0)", csr_hazard_mem);
        $display("csr_hazard_wb  = %b (expect 1)\n", csr_hazard_wb);

        // ===================== Flush Tests =====================

        // Test 11 : Branch prediction miss flush
        $display("Test 11 (Branch prediction miss flush)");
        reset_inputs();
        branch_prediction_miss = 1'b1;
        @(posedge clk);
        $display("IF_ID_flush  = %b (expect 1)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 1)", ID_EX_flush);
        $display("EX_MEM_flush = %b (expect 0)", EX_MEM_flush);
        $display("MEM_WB_flush = %b (expect 0)\n", MEM_WB_flush);

        // Test 12 : Jump flush
        $display("Test 12 (Jump flush)");
        reset_inputs();
        EX_jump = 1'b1;
        @(posedge clk);
        $display("IF_ID_flush  = %b (expect 1)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 1)", ID_EX_flush);
        $display("EX_MEM_flush = %b (expect 0)", EX_MEM_flush);
        $display("MEM_WB_flush = %b (expect 0)\n", MEM_WB_flush);

        // Test 13 : PTH done flush (all stages)
        $display("Test 13 (PTH done flush - all stages)");
        reset_inputs();
        pth_done_flush = 1'b1;
        @(posedge clk);
        $display("IF_ID_flush  = %b (expect 1)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 1)", ID_EX_flush);
        $display("EX_MEM_flush = %b (expect 1)", EX_MEM_flush);
        $display("MEM_WB_flush = %b (expect 1)\n", MEM_WB_flush);

        // ===================== Stall Tests =====================

        // Test 14 : Standby mode stall (ID phase exception handling)
        $display("Test 14 (Standby mode stall)");
        reset_inputs();
        standby_mode = 1'b1;
        @(posedge clk);
        $display("IF_ID_stall  = %b (expect 1)", IF_ID_stall);
        $display("ID_EX_stall  = %b (expect 1)", ID_EX_stall);
        $display("EX_MEM_stall = %b (expect 0)", EX_MEM_stall);
        $display("MEM_WB_stall = %b (expect 0)\n", MEM_WB_stall);

        // Test 15 : trap_done = 0 stall (all stages)
        $display("Test 15 (trap_done=0 stall - all stages)");
        reset_inputs();
        trap_done = 1'b0;
        @(posedge clk);
        $display("IF_ID_stall  = %b (expect 1)", IF_ID_stall);
        $display("ID_EX_stall  = %b (expect 1)", ID_EX_stall);
        $display("EX_MEM_stall = %b (expect 1)", EX_MEM_stall);
        $display("MEM_WB_stall = %b (expect 1)\n", MEM_WB_stall);

        // Test 16 : csr_ready = 0 stall (all stages)
        $display("Test 16 (csr_ready=0 stall - all stages)");
        reset_inputs();
        csr_ready = 1'b0;
        @(posedge clk);
        $display("IF_ID_stall  = %b (expect 1)", IF_ID_stall);
        $display("ID_EX_stall  = %b (expect 1)", ID_EX_stall);
        $display("EX_MEM_stall = %b (expect 1)", EX_MEM_stall);
        $display("MEM_WB_stall = %b (expect 1)\n", MEM_WB_stall);

        // ===================== Edge Case Tests =====================

        // Test 17 : x0 register should not cause hazard
        $display("Test 17 (x0 no hazard)");
        reset_inputs();
        EX_rs1 = 5'd0;
        EX_rs2 = 5'd0;
        MEM_rd = 5'd0;
        MEM_register_write_enable = 1'b1;
        @(posedge clk);
        $display("hazard_mem = %b (expect 00, x0 no hazard)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)\n", hazard_wb);

        // Test 18 : No hazard when write enable is 0
        $display("Test 18 (Write enable=0 no hazard)");
        reset_inputs();
        EX_rs1 = 5'd5;
        EX_rs2 = 5'd5;
        MEM_rd = 5'd5;
        MEM_register_write_enable = 1'b0;  // write disabled
        @(posedge clk);
        $display("hazard_mem = %b (expect 00, WE=0)", hazard_mem);
        $display("hazard_wb  = %b (expect 00)\n", hazard_wb);

        // Test 19 : Normal operation (no stall, no flush)
        $display("Test 19 (Normal operation)");
        reset_inputs();
        @(posedge clk);
        $display("IF_ID_flush  = %b (expect 0)", IF_ID_flush);
        $display("ID_EX_flush  = %b (expect 0)", ID_EX_flush);
        $display("EX_MEM_flush = %b (expect 0)", EX_MEM_flush);
        $display("MEM_WB_flush = %b (expect 0)", MEM_WB_flush);
        $display("IF_ID_stall  = %b (expect 0)", IF_ID_stall);
        $display("ID_EX_stall  = %b (expect 0)", ID_EX_stall);
        $display("EX_MEM_stall = %b (expect 0)", EX_MEM_stall);
        $display("MEM_WB_stall = %b (expect 0)\n", MEM_WB_stall);

        $display("==================== Hazard Unit Test END ====================\n");
        $stop;
    end

endmodule