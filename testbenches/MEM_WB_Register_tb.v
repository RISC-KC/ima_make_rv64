`timescale 1ns/1ps

module MEM_WB_Register_tb;
    localparam XLEN = 64;

    reg clk = 0;
    reg reset = 0;
    reg MEM_WB_stall = 0;
    reg flush = 0;

    // signals from EX/MEM register
    reg [XLEN-1:0] MEM_pc;
    reg [XLEN-1:0] MEM_pc_plus_4;
    reg [31:0] MEM_instruction;
    reg [2:0] MEM_register_file_write_data_select;
    reg [XLEN-1:0] MEM_imm;
    reg [19:0] MEM_raw_imm;
    reg [XLEN-1:0] MEM_csr_read_data;
    reg [XLEN-1:0] MEM_alu_result;
    reg MEM_register_write_enable;
    reg MEM_csr_write_enable;
    reg [4:0] MEM_rs1;
    reg [4:0] MEM_rd;
    reg [6:0] MEM_opcode;

    // signals from MEM phase
    reg [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data;
    reg [XLEN-1:0] MEM_data_memory_write_data;
    reg MEM_write_enable;

    // outputs
    wire [XLEN-1:0] WB_pc;
    wire [XLEN-1:0] WB_pc_plus_4;
    wire [31:0] WB_instruction;
    wire [2:0] WB_register_file_write_data_select;
    wire [XLEN-1:0] WB_imm;
    wire [19:0] WB_raw_imm;
    wire [XLEN-1:0] WB_csr_read_data;
    wire [XLEN-1:0] WB_alu_result;
    wire WB_register_write_enable;
    wire WB_csr_write_enable;
    wire [4:0] WB_rs1;
    wire [4:0] WB_rd;
    wire [6:0] WB_opcode;
    wire [XLEN-1:0] WB_byte_enable_logic_register_file_write_data;
    wire [XLEN-1:0] WB_data_memory_write_data;
    wire WB_write_enable;

    // test result tracking
    integer pass_count = 0;
    integer fail_count = 0;

    MEM_WB_Register #(.XLEN(XLEN)) mem_wb_register (
        .clk(clk),
        .reset(reset),
        .MEM_WB_stall(MEM_WB_stall),
        .flush(flush),

        .MEM_pc(MEM_pc),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_instruction(MEM_instruction),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_imm(MEM_imm),
        .MEM_raw_imm(MEM_raw_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_rs1(MEM_rs1),
        .MEM_rd(MEM_rd),
        .MEM_opcode(MEM_opcode),
        .MEM_byte_enable_logic_register_file_write_data(MEM_byte_enable_logic_register_file_write_data),
        .MEM_data_memory_write_data(MEM_data_memory_write_data),
        .MEM_write_enable(MEM_write_enable),

        .WB_pc(WB_pc),
        .WB_pc_plus_4(WB_pc_plus_4),
        .WB_instruction(WB_instruction),
        .WB_register_file_write_data_select(WB_register_file_write_data_select),
        .WB_imm(WB_imm),
        .WB_raw_imm(WB_raw_imm),
        .WB_csr_read_data(WB_csr_read_data),
        .WB_alu_result(WB_alu_result),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_rs1(WB_rs1),
        .WB_rd(WB_rd),
        .WB_opcode(WB_opcode),
        .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data),
        .WB_data_memory_write_data(WB_data_memory_write_data),
        .WB_write_enable(WB_write_enable)
    );

    always #5 clk = ~clk;

    // task for checking and displaying result
    task check;
        input [255:0] name;
        input [XLEN-1:0] expected;
        input [XLEN-1:0] actual;
        begin
            if (expected === actual) begin
                $display("[PASS] %0s | Expected: %h | Actual: %h", name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s | Expected: %h | Actual: %h", name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/MEM_WB_Register_tb_result.vcd");
        $dumpvars(0, MEM_WB_Register_tb.mem_wb_register);

        $display("\nMEM_WB_Register Test START\n");

        // initialize inputs
        MEM_pc = 0;
        MEM_pc_plus_4 = 0;
        MEM_instruction = 32'h0000_0013;
        MEM_register_file_write_data_select = 0;
        MEM_imm = 0;
        MEM_raw_imm = 0;
        MEM_csr_read_data = 0;
        MEM_alu_result = 0;
        MEM_register_write_enable = 0;
        MEM_csr_write_enable = 0;
        MEM_rs1 = 0;
        MEM_rd = 0;
        MEM_opcode = 0;
        MEM_byte_enable_logic_register_file_write_data = 0;
        MEM_data_memory_write_data = 0;
        MEM_write_enable = 0;

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk); #1;

        $display("Test 1: After Reset (should be NOP and zero)");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc", 64'h0, WB_pc);
        check("WB_pc_plus_4", 64'h0, WB_pc_plus_4);
        check("WB_instruction", 64'h0000_0013, {32'b0, WB_instruction});
        check("WB_alu_result", 64'h0, WB_alu_result);
        check("WB_register_write_enable", 64'h0, {63'b0, WB_register_write_enable});
        check("WB_rd", 64'h0, {59'b0, WB_rd});
        check("WB_data_memory_write_data", 64'h0, WB_data_memory_write_data);
        check("WB_write_enable", 64'h0, {63'b0, WB_write_enable});
        $display("");

        // Test 2: Normal data transfer
        @(negedge clk);
        MEM_pc                           = 64'h0000_0000_0000_0000;
        MEM_pc_plus_4                    = 64'h0000_0000_0000_0004;
        MEM_instruction                  = 32'h0062_8533;           // ADD x10, x5, x6
        MEM_register_file_write_data_select = 3'b010;               // ALU result -> Register File
        MEM_imm                          = 64'h0000_0000_0000_0000;
        MEM_raw_imm                      = 20'h00000;
        MEM_csr_read_data                = 64'h0000_0000_0000_0000;
        MEM_alu_result                   = 64'h0000_0000_0000_000B; // ALU result = 11
        MEM_register_write_enable        = 1'b1;                    // Register Write Enable
        MEM_csr_write_enable             = 1'b0;
        MEM_rs1                          = 5'd5;
        MEM_rd                           = 5'd10;
        MEM_opcode                       = 7'b0110011;              // R-type
        MEM_byte_enable_logic_register_file_write_data = 64'h0000_0000_0000_000A;
        MEM_data_memory_write_data       = 64'h0000_0000_0000_0000;
        MEM_write_enable                 = 1'b0;

        @(posedge clk); #1;
        $display("Test 2: Normal data transfer");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc", 64'h0000_0000_0000_0000, WB_pc);
        check("WB_pc_plus_4", 64'h0000_0000_0000_0004, WB_pc_plus_4);
        check("WB_instruction", 64'h0062_8533, {32'b0, WB_instruction});
        check("WB_alu_result", 64'h0000_0000_0000_000B, WB_alu_result);
        check("WB_register_write_enable", 64'h1, {63'b0, WB_register_write_enable});
        check("WB_rd", 64'd10, {59'b0, WB_rd});
        check("WB_opcode", 64'b0110011, {57'b0, WB_opcode});
        check("WB_write_enable", 64'h0, {63'b0, WB_write_enable});
        $display("");

        // Test 3: Stall behavior (output should hold previous value)
        @(negedge clk);
        MEM_WB_stall = 1'b1;
        MEM_pc                           = 64'hFFFF_FFFF_FFFF_FFFF; // new value (should NOT be latched)
        MEM_pc_plus_4                    = 64'hFFFF_FFFF_FFFF_FFFF;
        MEM_instruction                  = 32'hFFFF_FFFF;
        MEM_alu_result                   = 64'hFFFF_FFFF_FFFF_FFFF;
        MEM_rd                           = 5'd31;
        MEM_data_memory_write_data       = 64'hFFFF_FFFF_FFFF_FFFF;
        MEM_write_enable                 = 1'b1;

        @(posedge clk); #1;
        $display("Test 3: Stall behavior (should hold previous values)");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc (stalled)", 64'h0000_0000_0000_0000, WB_pc);
        check("WB_pc_plus_4 (stalled)", 64'h0000_0000_0000_0004, WB_pc_plus_4);
        check("WB_instruction (stalled)", 64'h0062_8533, {32'b0, WB_instruction});
        check("WB_alu_result (stalled)", 64'h0000_0000_0000_000B, WB_alu_result);
        check("WB_rd (stalled)", 64'd10, {59'b0, WB_rd});
        check("WB_data_memory_write_data (stalled)", 64'h0, WB_data_memory_write_data);
        check("WB_write_enable (stalled)", 64'h0, {63'b0, WB_write_enable});
        MEM_WB_stall = 1'b0;
        $display("");

        // Test 4: New data after stall released (Store instruction)
        @(negedge clk);
        MEM_pc                           = 64'h0000_0000_0000_0004;
        MEM_pc_plus_4                    = 64'h0000_0000_0000_0008;
        MEM_instruction                  = 32'h00B5_A023;           // SW x11, 0(x11)
        MEM_register_file_write_data_select = 3'b000;               // No write to Register File
        MEM_imm                          = 64'h0000_0000_0000_0000;
        MEM_raw_imm                      = 20'h00000;
        MEM_csr_read_data                = 64'h0000_0000_0000_0000;
        MEM_alu_result                   = 64'h0000_0000_1000_0020; // address
        MEM_register_write_enable        = 1'b0;
        MEM_csr_write_enable             = 1'b0;
        MEM_rs1                          = 5'd11;
        MEM_rd                           = 5'd0;
        MEM_opcode                       = 7'b0100011;              // STORE
        MEM_byte_enable_logic_register_file_write_data = 64'h0000_0000_0000_0000;
        MEM_data_memory_write_data       = 64'h0000_0000_DEAD_BEEF;
        MEM_write_enable                 = 1'b1;

        @(posedge clk); #1;
        $display("Test 4: Store instruction data transfer");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc", 64'h0000_0000_0000_0004, WB_pc);
        check("WB_pc_plus_4", 64'h0000_0000_0000_0008, WB_pc_plus_4);
        check("WB_instruction", 64'h00B5_A023, {32'b0, WB_instruction});
        check("WB_alu_result", 64'h0000_0000_1000_0020, WB_alu_result);
        check("WB_data_memory_write_data", 64'h0000_0000_DEAD_BEEF, WB_data_memory_write_data);
        check("WB_write_enable", 64'h1, {63'b0, WB_write_enable});
        check("WB_opcode", 64'b0100011, {57'b0, WB_opcode});
        $display("");

        // Test 5: Flush behavior
        @(negedge clk);
        MEM_pc                           = 64'h0000_0000_0000_0008;
        MEM_pc_plus_4                    = 64'h0000_0000_0000_000C;
        MEM_instruction                  = 32'hCAFE_BABE;
        MEM_alu_result                   = 64'hABCD_1234_5678_9ABC;
        MEM_register_write_enable        = 1'b1;
        MEM_csr_write_enable             = 1'b1;
        MEM_rd                           = 5'd20;
        MEM_data_memory_write_data       = 64'h1234_5678_9ABC_DEF0;
        MEM_write_enable                 = 1'b1;
        flush = 1'b1;

        @(posedge clk); #1;
        flush = 1'b0;
        $display("Test 5: Flush behavior (should be NOP and zero)");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc (flushed)", 64'h0, WB_pc);
        check("WB_pc_plus_4 (flushed)", 64'h0, WB_pc_plus_4);
        check("WB_instruction (flushed)", 64'h0000_0013, {32'b0, WB_instruction});
        check("WB_alu_result (flushed)", 64'h0, WB_alu_result);
        check("WB_register_write_enable (flushed)", 64'h0, {63'b0, WB_register_write_enable});
        check("WB_csr_write_enable (flushed)", 64'h0, {63'b0, WB_csr_write_enable});
        check("WB_rd (flushed)", 64'h0, {59'b0, WB_rd});
        check("WB_data_memory_write_data (flushed)", 64'h0, WB_data_memory_write_data);
        check("WB_write_enable (flushed)", 64'h0, {63'b0, WB_write_enable});
        $display("");

        // Test 6: CSR instruction
        @(negedge clk);
        MEM_pc                           = 64'h0000_0000_0000_000C;
        MEM_pc_plus_4                    = 64'h0000_0000_0000_0010;
        MEM_instruction                  = 32'hF11_02_573;           // CSRRS x10, mvendorid, x0
        MEM_register_file_write_data_select = 3'b011;                // CSR -> Register File
        MEM_imm                          = 64'h0000_0000_0000_0000;
        MEM_raw_imm                      = 20'hF1102;
        MEM_csr_read_data                = 64'h0000_0000_5256_4B43;  // mvendorid
        MEM_alu_result                   = 64'h0000_0000_0000_0000;
        MEM_register_write_enable        = 1'b1;
        MEM_csr_write_enable             = 1'b0;
        MEM_rs1                          = 5'd0;
        MEM_rd                           = 5'd10;
        MEM_opcode                       = 7'b1110011;               // ENVIRONMENT
        MEM_byte_enable_logic_register_file_write_data = 64'h0000_0000_5256_4B43;
        MEM_data_memory_write_data       = 64'h0000_0000_0000_0000;
        MEM_write_enable                 = 1'b0;

        @(posedge clk); #1;
        $display("Test 6: CSR instruction");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|     BERF_WD      |       imm      |  csr_read_data |   ALU result   | rs1 |  rd | opcode |");
        $display("| %h | %h | %h | %h | %b | %b | %b |", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rs1, WB_rd, WB_opcode);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_csr_read_data", 64'h0000_0000_5256_4B43, WB_csr_read_data);
        check("WB_raw_imm", 64'hF1102, {44'b0, WB_raw_imm});
        check("WB_opcode", 64'b1110011, {57'b0, WB_opcode});
        check("WB_write_enable", 64'h0, {63'b0, WB_write_enable});
        $display("");

        // Test 7: Flush priority over stall
        @(negedge clk);
        MEM_WB_stall = 1'b1;
        flush = 1'b1;
        MEM_pc                           = 64'h1234_5678_9ABC_DEF0;
        MEM_alu_result                   = 64'hFEDC_BA98_7654_3210;
        MEM_data_memory_write_data       = 64'hAAAA_BBBB_CCCC_DDDD;
        MEM_write_enable                 = 1'b1;

        @(posedge clk); #1;
        MEM_WB_stall = 1'b0;
        flush = 1'b0;
        $display("Test 7: Flush priority over stall (flush should win)");
        $display("|       PC       |     PC+4     |  instruction | RF_WD_sel | CSR_WE | Reg_WE |");
        $display("| %h | %h |   %h   |    %b    |   %b    |   %b    |", WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|  DM_write_data   | write_enable |");
        $display("| %h |      %b       |", WB_data_memory_write_data, WB_write_enable);
        check("WB_pc (flush priority)", 64'h0, WB_pc);
        check("WB_instruction (flush priority)", 64'h0000_0013, {32'b0, WB_instruction});
        check("WB_alu_result (flush priority)", 64'h0, WB_alu_result);
        check("WB_data_memory_write_data (flush priority)", 64'h0, WB_data_memory_write_data);
        check("WB_write_enable (flush priority)", 64'h0, {63'b0, WB_write_enable});
        $display("");

        // Summary
        $display("Test Summary: PASS = %0d, FAIL = %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("All tests PASSED!\n");
        else
            $display("Some tests FAILED!\n");

        $display("MEM_WB_Register Test END\n");
        $finish;
    end

endmodule