`timescale 1ns/1ps

module EX_MEM_Register_tb #(
    parameter XLEN = 64
);

    reg clk = 0;
    reg reset = 0;
    reg flush = 0;
    reg EX_MEM_stall = 0;

    reg [XLEN-1:0] EX_pc;
    reg [XLEN-1:0] EX_pc_plus_4;
    reg [31:0] EX_instruction;

    reg EX_memory_read;
    reg EX_memory_write;
    reg [2:0] EX_register_file_write_data_select;
    reg EX_register_write_enable;
    reg EX_csr_write_enable;
    reg [6:0] EX_opcode; 
    reg [2:0] EX_funct3;
    reg [4:0] EX_rs1;
    reg [4:0] EX_rd;
    reg [XLEN-1:0] EX_read_data2;
    reg [XLEN-1:0] EX_imm;
    reg [19:0] EX_raw_imm;
    reg [XLEN-1:0] EX_csr_read_data;

    reg [XLEN-1:0] EX_alu_result;

    wire [XLEN-1:0] MEM_pc;
    wire [XLEN-1:0] MEM_pc_plus_4;
    wire [31:0] MEM_instruction;

    wire MEM_memory_read;
    wire MEM_memory_write;
    wire [2:0] MEM_register_file_write_data_select;
    wire MEM_register_write_enable;
    wire MEM_csr_write_enable;
    wire [6:0] MEM_opcode;
    wire [2:0] MEM_funct3;
    wire [4:0] MEM_rs1;
    wire [4:0] MEM_rd;
    wire [XLEN-1:0] MEM_read_data2;
    wire [XLEN-1:0] MEM_imm;
    wire [19:0] MEM_raw_imm;
    wire [XLEN-1:0] MEM_csr_read_data;

    wire [XLEN-1:0] MEM_alu_result;

    EX_MEM_Register #(.XLEN(XLEN)) dut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .EX_MEM_stall(EX_MEM_stall),

        .EX_pc(EX_pc),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_instruction(EX_instruction),

        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_rs1(EX_rs1),
        .EX_rd(EX_rd),
        .EX_read_data2(EX_read_data2),
        .EX_imm(EX_imm),
        .EX_raw_imm(EX_raw_imm),
        .EX_csr_read_data(EX_csr_read_data),

        .EX_alu_result(EX_alu_result),

        .MEM_pc(MEM_pc),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_instruction(MEM_instruction),

        .MEM_memory_read(MEM_memory_read),
        .MEM_memory_write(MEM_memory_write),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_opcode(MEM_opcode),
        .MEM_funct3(MEM_funct3),
        .MEM_rs1(MEM_rs1),
        .MEM_rd(MEM_rd),
        .MEM_read_data2(MEM_read_data2),
        .MEM_imm(MEM_imm),
        .MEM_raw_imm(MEM_raw_imm),
        .MEM_csr_read_data(MEM_csr_read_data),

        .MEM_alu_result(MEM_alu_result)
    );

    always #5 clk = ~clk;

    // Task for displaying register state
    task display_state;
        begin
            $display("|         PC           |         PC+4         |   instruction  | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
            $display("|   %h   |   %h   |    %h    |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc, MEM_pc_plus_4, MEM_instruction, MEM_memory_read, MEM_memory_write, MEM_csr_write_enable, MEM_register_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
            $display("|     Register RD2     |        imm        |    csr_read_data    |      ALU result      |  rs1  |  rd  | raw_imm |");
            $display("|   %h   |  %h |   %h    |    %h    |  %b  |  %b  |  %h  |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result, MEM_rs1, MEM_rd, MEM_raw_imm);
        end
    endtask

    // Task for setting EX stage inputs
    task set_ex_inputs;
        input [XLEN-1:0] pc;
        input [XLEN-1:0] pc_plus_4;
        input [31:0] instruction;
        input mem_read;
        input mem_write;
        input [2:0] rf_wd_sel;
        input reg_we;
        input csr_we;
        input [6:0] opcode;
        input [2:0] funct3;
        input [4:0] rs1;
        input [4:0] rd;
        input [XLEN-1:0] read_data2;
        input [XLEN-1:0] imm;
        input [19:0] raw_imm;
        input [XLEN-1:0] csr_read_data;
        input [XLEN-1:0] alu_result;
        begin
            EX_pc = pc;
            EX_pc_plus_4 = pc_plus_4;
            EX_instruction = instruction;
            EX_memory_read = mem_read;
            EX_memory_write = mem_write;
            EX_register_file_write_data_select = rf_wd_sel;
            EX_register_write_enable = reg_we;
            EX_csr_write_enable = csr_we;
            EX_opcode = opcode;
            EX_funct3 = funct3;
            EX_rs1 = rs1;
            EX_rd = rd;
            EX_read_data2 = read_data2;
            EX_imm = imm;
            EX_raw_imm = raw_imm;
            EX_csr_read_data = csr_read_data;
            EX_alu_result = alu_result;
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/EX_MEM_Register_tb_result.vcd");
        $dumpvars(0, EX_MEM_Register_tb.dut);

        // Test sequence
        $display("==================== EX_MEM Register Test START ====================\n");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk);
        $display("Test 0: After Reset (should be NOP and zero)");
        display_state();
        #10;
        
        // Test 1: Normal operation - SD instruction
        @(negedge clk); 
        set_ex_inputs(
            64'h0000_0000_0000_0004,   // pc
            64'h0000_0000_0000_0008,   // pc_plus_4
            32'h00B53023,              // SD x11, 0(x10)
            1'b0,                      // mem_read
            1'b1,                      // mem_write (Store)
            3'b000,                    // rf_wd_sel (don't-care for store)
            1'b0,                      // reg_we
            1'b0,                      // csr_we
            7'b0100011,                // opcode (STORE)
            3'b011,                    // funct3 (SD)
            5'b01010,                  // rs1 (x10)
            5'b00000,                  // rd (don't-care for store)
            64'hDEAD_BEEF_CAFE_BABE,   // read_data2 (Write Data)
            64'h0000_0000_0000_0000,   // imm (offset 0)
            20'h00000,                 // raw_imm
            64'h0000_0000_0000_0000,   // csr_read_data
            64'h0000_0001_0000_0040    // alu_result
        );

        @(posedge clk); #1;
        $display("Test 1: SD instruction latched");
        display_state();
        
        // Test 2: No input change (should be same)
        @(posedge clk); #1;
        $display("Test 2: No input change (should be same as Test 1)");
        display_state();

        // Test 3: LD instruction
        @(negedge clk); 
        set_ex_inputs(
            64'h0000_0000_0000_000C,   // pc
            64'h0000_0000_0000_0010,   // pc_plus_4
            32'h00053503,              // LD x10, 0(x10)
            1'b1,                      // mem_read (Load)
            1'b0,                      // mem_write
            3'b001,                    // rf_wd_sel (D_RD -> RF)
            1'b1,                      // reg_we
            1'b0,                      // csr_we
            7'b0000011,                // opcode (LOAD)
            3'b011,                    // funct3 (LD)
            5'b01010,                  // rs1 (x10)
            5'b01010,                  // rd (x10)
            64'h0000_0000_0000_0000,   // read_data2
            64'h0000_0000_0000_0000,   // imm (offset 0)
            20'h00000,                 // raw_imm
            64'h0000_0000_0000_0000,   // csr_read_data
            64'h0000_0002_0000_0030    // alu_result
        );

        $display("Test 3-1: LD instruction input (output should still be Test 1)");
        display_state();

        @(posedge clk); #1;
        $display("Test 3-2: LD instruction latched");
        display_state();

        // Test 4: Flush test
        flush = 1'b1; #10;
        flush = 1'b0;

        $display("Test 4: Flushed (should be NOP and zero)");
        display_state();

        // Test 5: R-type ADD instruction
        @(negedge clk);
        set_ex_inputs(
            64'h0000_0000_0000_0014,   // pc
            64'h0000_0000_0000_0018,   // pc_plus_4
            32'h00C58633,              // ADD x12, x11, x12
            1'b0,                      // mem_read
            1'b0,                      // mem_write
            3'b000,                    // rf_wd_sel (ALU result -> RF)
            1'b1,                      // reg_we
            1'b0,                      // csr_we
            7'b0110011,                // opcode (R-type)
            3'b000,                    // funct3 (ADD)
            5'b01011,                  // rs1 (x11)
            5'b01100,                  // rd (x12)
            64'h0000_0000_0000_0006,   // read_data2
            64'h0000_0000_0000_0000,   // imm
            20'h00000,                 // raw_imm
            64'h0000_0000_0000_0000,   // csr_read_data
            64'h0000_0000_0000_000B    // alu_result (0x5 + 0x6 = 11)
        );
        $display("Test 5-1: ADD instruction input (output should still be flushed)");
        display_state();

        @(posedge clk); #1;
        $display("Test 5-2: ADD instruction latched");
        display_state();

        // ==================== STALL TESTS ====================
        $display("\n==================== STALL Tests ====================\n");

        // Test 6: Stall - register should hold value
        @(negedge clk);
        EX_MEM_stall = 1'b1;  // Enable stall
        set_ex_inputs(
            64'hAAAA_AAAA_AAAA_AAAA,   // pc (new value)
            64'hBBBB_BBBB_BBBB_BBBB,   // pc_plus_4 (new value)
            32'hFFFFFFFF,              // instruction (new value)
            1'b1,                      // mem_read (different)
            1'b1,                      // mem_write (different)
            3'b111,                    // rf_wd_sel (different)
            1'b0,                      // reg_we (different)
            1'b1,                      // csr_we (different)
            7'b1111111,                // opcode (different)
            3'b111,                    // funct3 (different)
            5'b11111,                  // rs1 (different)
            5'b11111,                  // rd (different)
            64'hFFFF_FFFF_FFFF_FFFF,   // read_data2 (different)
            64'hCCCC_CCCC_CCCC_CCCC,   // imm (different)
            20'hFFFFF,                 // raw_imm (different)
            64'hDDDD_DDDD_DDDD_DDDD,   // csr_read_data (different)
            64'hEEEE_EEEE_EEEE_EEEE    // alu_result (different)
        );

        $display("Test 6-1: Stall enabled, new input applied (output should still be Test 5-2)");
        display_state();

        @(posedge clk); #1;
        $display("Test 6-2: After clock with stall=1 (should STILL be Test 5-2, NOT new values)");
        display_state();

        // Verify stall is working
        if (MEM_pc == 64'h0000_0000_0000_0014 && MEM_alu_result == 64'h0000_0000_0000_000B) begin
            $display(">>> STALL TEST PASSED: Register held previous value <<<\n");
        end else begin
            $display(">>> STALL TEST FAILED: Register should have held previous value <<<\n");
        end

        // Test 7: Multiple cycles with stall
        @(posedge clk); #1;
        $display("Test 7: Second clock with stall=1 (should still hold same value)");
        display_state();

        @(posedge clk); #1;
        $display("Test 8: Third clock with stall=1 (should still hold same value)");
        display_state();

        // Test 9: Release stall - new value should be latched
        @(negedge clk);
        EX_MEM_stall = 1'b0;  // Disable stall
        $display("Test 9-1: Stall released (output should still be held value)");
        display_state();

        @(posedge clk); #1;
        $display("Test 9-2: After clock with stall=0 (should NOW show new values from Test 6)");
        display_state();

        // Verify stall release worked
        if (MEM_pc == 64'hAAAA_AAAA_AAAA_AAAA && MEM_alu_result == 64'hEEEE_EEEE_EEEE_EEEE) begin
            $display(">>> STALL RELEASE TEST PASSED: New value latched after stall released <<<\n");
        end else begin
            $display(">>> STALL RELEASE TEST FAILED: New value should have been latched <<<\n");
        end

        // Test 10: Flush priority over stall
        @(negedge clk);
        EX_MEM_stall = 1'b1;  // Enable stall
        set_ex_inputs(
            64'h1111_1111_1111_1111,   // pc
            64'h2222_2222_2222_2222,   // pc_plus_4
            32'h12345678,              // instruction
            1'b1, 1'b1, 3'b010, 1'b1, 1'b1,
            7'b0010011, 3'b000, 5'b00001, 5'b00010,
            64'h3333_3333_3333_3333,
            64'h4444_4444_4444_4444,
            20'h12345,
            64'h5555_5555_5555_5555,
            64'h6666_6666_6666_6666
        );

        @(posedge clk); #1;
        $display("Test 10-1: Stall=1, new input (should hold previous Test 9-2 values)");
        display_state();

        // Now apply flush while stall is still active
        flush = 1'b1;
        @(posedge clk); #1;
        flush = 1'b0;
        $display("Test 10-2: Flush=1 with Stall=1 (flush should take priority, output should be NOP/zero)");
        display_state();

        // Verify flush priority
        if (MEM_pc == 64'h0 && MEM_instruction == 32'h0000_0013 && MEM_memory_read == 1'b0) begin
            $display(">>> FLUSH PRIORITY TEST PASSED: Flush took priority over stall <<<\n");
        end else begin
            $display(">>> FLUSH PRIORITY TEST FAILED: Flush should take priority over stall <<<\n");
        end

        // Test 11: Normal operation after flush with stall still high
        EX_MEM_stall = 1'b0;  // Release stall
        @(negedge clk);
        set_ex_inputs(
            64'h0000_0000_0000_0020,   // pc
            64'h0000_0000_0000_0024,   // pc_plus_4
            32'h00000033,              // instruction
            1'b0, 1'b0, 3'b000, 1'b1, 1'b0,
            7'b0110011, 3'b000, 5'b00000, 5'b00001,
            64'h0000_0000_0000_0000,
            64'h0000_0000_0000_0000,
            20'h00000,
            64'h0000_0000_0000_0000,
            64'h0000_0000_0000_0005
        );

        @(posedge clk); #1;
        $display("Test 11: Normal operation resumed after stall released");
        display_state();

        // Test 12: CSR instruction with raw_imm
        @(negedge clk);
        set_ex_inputs(
            64'h0000_0000_0000_0028,   // pc
            64'h0000_0000_0000_002C,   // pc_plus_4
            32'h30102573,              // CSRRS x10, mstatus, x0
            1'b0,                      // mem_read
            1'b0,                      // mem_write
            3'b100,                    // rf_wd_sel (CSR -> RF)
            1'b1,                      // reg_we
            1'b1,                      // csr_we
            7'b1110011,                // opcode (SYSTEM)
            3'b010,                    // funct3 (CSRRS)
            5'b00000,                  // rs1 (x0)
            5'b01010,                  // rd (x10)
            64'h0000_0000_0000_0000,   // read_data2
            64'h0000_0000_0000_0301,   // imm (CSR address)
            20'h00301,                 // raw_imm (mstatus address)
            64'h1234_5678_9ABC_DEF0,   // csr_read_data
            64'h0000_0000_0000_0000    // alu_result
        );

        @(posedge clk); #1;
        $display("Test 12: CSR instruction with raw_imm");
        display_state();

        $display("\n====================  EX_MEM Register Test END  ====================");

        $stop;
    end

endmodule