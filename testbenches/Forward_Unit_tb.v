`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ForwardUnit_tb;
localparam XLEN = 64;

integer test_count;
integer pass_count;
integer fail_count;

// Hazard signals - ALU forwarding
reg [1:0] hazard_mem;
reg [1:0] hazard_wb;

// Hazard signals - Store data forwarding
reg store_hazard_mem;
reg store_hazard_wb;

// MEM stage signals
reg [XLEN-1:0] MEM_imm;
reg [XLEN-1:0] MEM_alu_result;
reg [XLEN-1:0] MEM_csr_read_data;
reg [XLEN-1:0] byte_enable_logic_register_file_write_data;
reg [XLEN-1:0] MEM_pc_plus_4;
reg [6:0] MEM_opcode;

// WB stage signals
reg [XLEN-1:0] WB_imm;
reg [XLEN-1:0] WB_alu_result;
reg [XLEN-1:0] WB_csr_read_data;
reg [XLEN-1:0] WB_byte_enable_logic_register_file_write_data;
reg [XLEN-1:0] WB_pc_plus_4;
reg [6:0] WB_opcode;

// CSR hazard signals
reg csr_hazard_mem;
reg csr_hazard_wb;
reg [XLEN-1:0] MEM_csr_write_data;
reg [XLEN-1:0] WB_csr_write_data;
reg [XLEN-1:0] csr_read_data;

// Outputs
wire [XLEN-1:0] alu_forward_source_data_a;
wire [XLEN-1:0] alu_forward_source_data_b;
wire [1:0] alu_forward_source_select_a;
wire [1:0] alu_forward_source_select_b;
wire [XLEN-1:0] store_forward_data;
wire store_forward_enable;
wire [XLEN-1:0] csr_forward_data;

ForwardUnit #(.XLEN(XLEN)) forward_unit (
    .hazard_mem(hazard_mem),
    .hazard_wb(hazard_wb),
    .store_hazard_mem(store_hazard_mem),
    .store_hazard_wb(store_hazard_wb),
    .MEM_imm(MEM_imm),
    .MEM_alu_result(MEM_alu_result),
    .MEM_csr_read_data(MEM_csr_read_data),
    .byte_enable_logic_register_file_write_data(byte_enable_logic_register_file_write_data),
    .MEM_pc_plus_4(MEM_pc_plus_4),
    .MEM_opcode(MEM_opcode),
    .WB_imm(WB_imm),
    .WB_alu_result(WB_alu_result),
    .WB_csr_read_data(WB_csr_read_data),
    .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data),
    .WB_pc_plus_4(WB_pc_plus_4),
    .WB_opcode(WB_opcode),
    .csr_hazard_mem(csr_hazard_mem),
    .csr_hazard_wb(csr_hazard_wb),
    .MEM_csr_write_data(MEM_csr_write_data),
    .WB_csr_write_data(WB_csr_write_data),
    .csr_read_data(csr_read_data),
    .alu_forward_source_data_a(alu_forward_source_data_a),
    .alu_forward_source_data_b(alu_forward_source_data_b),
    .alu_forward_source_select_a(alu_forward_source_select_a),
    .alu_forward_source_select_b(alu_forward_source_select_b),
    .store_forward_data(store_forward_data),
    .store_forward_enable(store_forward_enable),
    .csr_forward_data(csr_forward_data)
);

task check;
    input [255:0] name;
    input [XLEN-1:0] expected;
    input [XLEN-1:0] actual;
begin
    test_count = test_count + 1;
    if (expected === actual) begin
        pass_count = pass_count + 1;
        $display("[PASS] %0s | Expected: %h, Actual: %h", name, expected, actual);
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] %0s | Expected: %h, Actual: %h", name, expected, actual);
    end
end
endtask

task check_2bit;
    input [255:0] name;
    input [1:0] expected;
    input [1:0] actual;
begin
    test_count = test_count + 1;
    if (expected === actual) begin
        pass_count = pass_count + 1;
        $display("[PASS] %0s | Expected: %b, Actual: %b", name, expected, actual);
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] %0s | Expected: %b, Actual: %b", name, expected, actual);
    end
end
endtask

task check_1bit;
    input [255:0] name;
    input expected;
    input actual;
begin
    test_count = test_count + 1;
    if (expected === actual) begin
        pass_count = pass_count + 1;
        $display("[PASS] %0s | Expected: %b, Actual: %b", name, expected, actual);
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] %0s | Expected: %b, Actual: %b", name, expected, actual);
    end
end
endtask

task init_signals;
begin
    hazard_mem = 2'b00;
    hazard_wb = 2'b00;
    store_hazard_mem = 1'b0;
    store_hazard_wb = 1'b0;
    MEM_imm = 64'hAAAA_BBBB_CCCC_0000;
    MEM_alu_result = 64'hDEAD_BEEF_CAFE_BABE;
    MEM_csr_read_data = 64'hFACE_CAFE_1234_5678;
    byte_enable_logic_register_file_write_data = 64'h1111_2222_3333_4444;
    MEM_pc_plus_4 = 64'h0000_0000_0040_1004;
    MEM_opcode = `OPCODE_RTYPE;
    WB_imm = 64'h5555_6666_7777_0000;
    WB_alu_result = 64'hBEEF_DEAD_BABE_CAFE;
    WB_csr_read_data = 64'hCAFE_FACE_8765_4321;
    WB_byte_enable_logic_register_file_write_data = 64'h9999_AAAA_BBBB_CCCC;
    WB_pc_plus_4 = 64'h0000_0000_0080_2008;
    WB_opcode = `OPCODE_RTYPE;
    csr_hazard_mem = 1'b0;
    csr_hazard_wb = 1'b0;
    MEM_csr_write_data = 64'h1111_2222_3333_4444;
    WB_csr_write_data = 64'h5555_6666_7777_8888;
    csr_read_data = 64'h9999_AAAA_BBBB_CCCC;
end
endtask

initial begin
    $dumpfile("testbenches/results/waveforms/ForwardUnit_tb.vcd");
    $dumpvars(0, ForwardUnit_tb);

    test_count = 0;
    pass_count = 0;
    fail_count = 0;

    $display("==================== Forward Unit Test START ====================");
    init_signals();
    #1;

    // ALU Forward Select Tests
    $display("\n[ALU Forward Select Tests]");
    
    hazard_mem = 2'b00; hazard_wb = 2'b00; #1;
    check_2bit("No hazard - select_a", 2'b00, alu_forward_source_select_a);
    check_2bit("No hazard - select_b", 2'b00, alu_forward_source_select_b);

    hazard_mem = 2'b01; hazard_wb = 2'b00; #1;
    check_2bit("MEM hazard rs1 - select_a", 2'b10, alu_forward_source_select_a);
    check_2bit("MEM hazard rs1 - select_b", 2'b00, alu_forward_source_select_b);

    hazard_mem = 2'b10; hazard_wb = 2'b00; #1;
    check_2bit("MEM hazard rs2 - select_a", 2'b00, alu_forward_source_select_a);
    check_2bit("MEM hazard rs2 - select_b", 2'b10, alu_forward_source_select_b);

    hazard_mem = 2'b11; hazard_wb = 2'b00; #1;
    check_2bit("MEM hazard both - select_a", 2'b10, alu_forward_source_select_a);
    check_2bit("MEM hazard both - select_b", 2'b10, alu_forward_source_select_b);

    hazard_mem = 2'b00; hazard_wb = 2'b01; #1;
    check_2bit("WB hazard rs1 - select_a", 2'b11, alu_forward_source_select_a);
    check_2bit("WB hazard rs1 - select_b", 2'b00, alu_forward_source_select_b);

    hazard_mem = 2'b00; hazard_wb = 2'b10; #1;
    check_2bit("WB hazard rs2 - select_a", 2'b00, alu_forward_source_select_a);
    check_2bit("WB hazard rs2 - select_b", 2'b11, alu_forward_source_select_b);

    hazard_mem = 2'b11; hazard_wb = 2'b11; #1;
    check_2bit("MEM priority over WB - select_a", 2'b10, alu_forward_source_select_a);
    check_2bit("MEM priority over WB - select_b", 2'b10, alu_forward_source_select_b);

    // MEM Stage Forward Data Tests (by opcode)
    $display("\n[MEM Stage Forward Data Tests]");
    hazard_mem = 2'b01; hazard_wb = 2'b00;

    MEM_opcode = `OPCODE_RTYPE; #1;
    check("RTYPE -> MEM_alu_result", MEM_alu_result, alu_forward_source_data_a);

    MEM_opcode = `OPCODE_LOAD; #1;
    check("LOAD -> byte_enable_logic data", byte_enable_logic_register_file_write_data, alu_forward_source_data_a);

    MEM_opcode = `OPCODE_ENVIRONMENT; #1;
    check("ENVIRONMENT -> MEM_csr_read_data", MEM_csr_read_data, alu_forward_source_data_a);

    MEM_opcode = `OPCODE_LUI; #1;
    check("LUI -> MEM_imm", MEM_imm, alu_forward_source_data_a);

    MEM_opcode = `OPCODE_JAL; #1;
    check("JAL -> MEM_pc_plus_4", MEM_pc_plus_4, alu_forward_source_data_a);

    MEM_opcode = `OPCODE_JALR; #1;
    check("JALR -> MEM_pc_plus_4", MEM_pc_plus_4, alu_forward_source_data_a);

    // WB Stage Forward Data Tests (by opcode)
    $display("\n[WB Stage Forward Data Tests]");
    hazard_mem = 2'b00; hazard_wb = 2'b01;
    MEM_opcode = `OPCODE_RTYPE;

    WB_opcode = `OPCODE_RTYPE; #1;
    check("WB RTYPE -> WB_alu_result", WB_alu_result, alu_forward_source_data_a);

    WB_opcode = `OPCODE_LOAD; #1;
    check("WB LOAD -> WB_byte_enable data", WB_byte_enable_logic_register_file_write_data, alu_forward_source_data_a);

    WB_opcode = `OPCODE_ENVIRONMENT; #1;
    check("WB ENV -> WB_csr_read_data", WB_csr_read_data, alu_forward_source_data_a);

    WB_opcode = `OPCODE_LUI; #1;
    check("WB LUI -> WB_imm", WB_imm, alu_forward_source_data_a);

    WB_opcode = `OPCODE_JAL; #1;
    check("WB JAL -> WB_pc_plus_4", WB_pc_plus_4, alu_forward_source_data_a);

    WB_opcode = `OPCODE_JALR; #1;
    check("WB JALR -> WB_pc_plus_4", WB_pc_plus_4, alu_forward_source_data_a);

    // Store Data Forwarding Tests
    $display("\n[Store Data Forwarding Tests]");
    init_signals();

    store_hazard_mem = 1'b0; store_hazard_wb = 1'b0; #1;
    check_1bit("No store hazard - enable", 1'b0, store_forward_enable);
    check("No store hazard - data", 64'h0, store_forward_data);

    store_hazard_mem = 1'b1; store_hazard_wb = 1'b0;
    MEM_opcode = `OPCODE_RTYPE; #1;
    check_1bit("Store hazard MEM - enable", 1'b1, store_forward_enable);
    check("Store hazard MEM - data", MEM_alu_result, store_forward_data);

    store_hazard_mem = 1'b0; store_hazard_wb = 1'b1;
    WB_opcode = `OPCODE_RTYPE; #1;
    check_1bit("Store hazard WB - enable", 1'b1, store_forward_enable);
    check("Store hazard WB - data", WB_alu_result, store_forward_data);

    store_hazard_mem = 1'b1; store_hazard_wb = 1'b1; #1;
    check("Store MEM priority over WB", MEM_alu_result, store_forward_data);

    store_hazard_mem = 1'b1; store_hazard_wb = 1'b0;
    MEM_opcode = `OPCODE_LOAD; #1;
    check("Store hazard with LOAD opcode", byte_enable_logic_register_file_write_data, store_forward_data);

    // CSR Forwarding Tests
    $display("\n[CSR Forwarding Tests]");
    init_signals();
    MEM_csr_write_data = 64'hAAAA_BBBB_CCCC_DDDD;
    WB_csr_write_data = 64'hEEEE_FFFF_0000_1111;
    csr_read_data = 64'h2222_3333_4444_5555;

    csr_hazard_mem = 1'b0; csr_hazard_wb = 1'b0; #1;
    check("No CSR hazard -> csr_read_data", csr_read_data, csr_forward_data);

    csr_hazard_mem = 1'b1; csr_hazard_wb = 1'b0; #1;
    check("CSR hazard MEM", MEM_csr_write_data, csr_forward_data);

    csr_hazard_mem = 1'b0; csr_hazard_wb = 1'b1; #1;
    check("CSR hazard WB", WB_csr_write_data, csr_forward_data);

    csr_hazard_mem = 1'b1; csr_hazard_wb = 1'b1; #1;
    check("CSR MEM priority over WB", MEM_csr_write_data, csr_forward_data);

    // 64-bit Edge Cases
    $display("\n[64-bit Edge Case Tests]");
    init_signals();
    hazard_mem = 2'b01; hazard_wb = 2'b00;
    MEM_opcode = `OPCODE_RTYPE;

    MEM_alu_result = 64'hFFFF_FFFF_FFFF_FFFF; #1;
    check("Max 64-bit value", 64'hFFFF_FFFF_FFFF_FFFF, alu_forward_source_data_a);

    MEM_alu_result = 64'hDEAD_BEEF_0000_0000; #1;
    check("Upper 32-bits only", 64'hDEAD_BEEF_0000_0000, alu_forward_source_data_a);

    MEM_alu_result = 64'h0000_0000_CAFE_BABE; #1;
    check("Lower 32-bits only", 64'h0000_0000_CAFE_BABE, alu_forward_source_data_a);

    // Combined Scenario
    $display("\n[Combined Hazard Scenario]");
    init_signals();
    hazard_mem = 2'b01; hazard_wb = 2'b10;
    MEM_opcode = `OPCODE_LUI;
    WB_opcode = `OPCODE_LOAD;
    #1;
    check("rs1 from MEM (LUI)", MEM_imm, alu_forward_source_data_a);
    check("rs2 from WB (LOAD)", WB_byte_enable_logic_register_file_write_data, alu_forward_source_data_b);

    // Summary
    $display("\n==================== Forward Unit Test END ====================");
    $display("Total: %0d, Passed: %0d, Failed: %0d", test_count, pass_count, fail_count);
    if (fail_count == 0) $display("*** ALL TESTS PASSED ***");
    else $display("*** SOME TESTS FAILED ***");

    $finish;
end

endmodule