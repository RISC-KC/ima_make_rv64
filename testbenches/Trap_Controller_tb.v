`timescale 1ns/1ps
`include "modules/headers/trap.vh"

module TrapController_tb;
  // Parameters
  parameter XLEN = 64;

  // Signal Declaration
  reg         clk;
  reg         reset;
  reg  [XLEN-1:0] ID_pc;
  reg  [XLEN-1:0] EX_pc;
  reg  [XLEN-1:0] MEM_pc;
  reg  [XLEN-1:0] WB_pc;
  reg  [2:0]  trap_status;
  reg  [XLEN-1:0] csr_read_data;

  wire [XLEN-1:0] trap_target;
  wire        ic_clean;
  wire        debug_mode;
  wire        trap_done;
  wire        csr_write_enable;
  wire [11:0] csr_trap_address;
  wire [XLEN-1:0] csr_trap_write_data;
  wire        misaligned_instruction_flush;
  wire        misaligned_memory_flush;
  wire        pth_done_flush;
  wire        standby_mode;

  // DUT instance
  TrapController #(.XLEN(XLEN)) dut (
    .clk                (clk),
    .reset              (reset),
    .ID_pc              (ID_pc),
    .EX_pc              (EX_pc),
    .MEM_pc             (MEM_pc),
    .WB_pc              (WB_pc),
    .trap_status        (trap_status),
    .csr_read_data      (csr_read_data),

    .trap_target        (trap_target),
    .ic_clean           (ic_clean),
    .debug_mode         (debug_mode),
    .csr_write_enable   (csr_write_enable),
    .csr_trap_address   (csr_trap_address),
    .csr_trap_write_data(csr_trap_write_data),
    .trap_done          (trap_done),
    .misaligned_instruction_flush(misaligned_instruction_flush),
    .misaligned_memory_flush(misaligned_memory_flush),
    .pth_done_flush     (pth_done_flush),
    .standby_mode       (standby_mode)
  );

  // Generate clock signal (period = 10ns)
  initial clk = 0;
  always #5 clk = ~clk;

  // VCD dump
  initial begin
    $dumpfile("testbenches/results/waveforms/Trap_Controller_tb_result.vcd");
    $dumpvars(0, TrapController_tb);
  end

  // Monitor setup :  internal state, CSR Read/Write, output changes
  initial begin
    $display("time | th_state | csr_addr | csr_wd   | csr_we |  trap_tgt  | ic_clean | debug | trap_done | standby | mi_flush | mm_flush | pth_flush");
    $monitor("%4t |  %b   |   %h   | %h |   %b    | %h |     %b    |   %b   |     %b     |    %b    |    %b     |    %b     |     %b",
             $time,
             dut.trap_handle_state,
             csr_trap_address,
             csr_trap_write_data,
             csr_write_enable,
             trap_target,
             ic_clean,
             debug_mode,
             trap_done,
             standby_mode,
             misaligned_instruction_flush,
             misaligned_memory_flush,
             pth_done_flush);
  end

  // Helper task to clear all PC inputs
  task clear_pcs;
    begin
      ID_pc  = {XLEN{1'b0}};
      EX_pc  = {XLEN{1'b0}};
      MEM_pc = {XLEN{1'b0}};
      WB_pc  = {XLEN{1'b0}};
    end
  endtask

  // Helper task to set all PCs to same value (simulating pipeline)
  task set_all_pcs;
    input [XLEN-1:0] pc_value;
    begin
      ID_pc  = pc_value;
      EX_pc  = pc_value;
      MEM_pc = pc_value;
      WB_pc  = pc_value;
    end
  endtask

  // Testbench
  initial begin
    $display("==================== Trap Controller Test START ====================");
    // Initialize signals
    reset          = 1;
    trap_status    = `TRAP_NONE;
    clear_pcs;
    csr_read_data  = 64'h0000_0000;
    #20 reset = 0;

    // -- ECALL Test --
    $display("\n-- ECALL Test --");
    set_all_pcs(64'h0000_1100);
    trap_status  = `TRAP_ECALL;
    // mtvec base address = 1000_AA00
    #25; csr_read_data = 64'h1000_AA00;
    #50;  // Extended for standby states (MEM_STANDBY -> WB_STANDBY -> RTRE_STANDBY -> ECALL_MEPC_WRITE)

    /* expected values
    standby_mode = 1 during MEM_STANDBY, WB_STANDBY, RTRE_STANDBY
    CSR_T.Addr = 12'h341
    CSR_T.WD = EX_pc (0000_1100)
    trap_handle_state = IDLE -> MEM_STANDBY -> WB_STANDBY -> RTRE_STANDBY -> ECALL_MEPC_WRITE -> WRITE_MEPC

    CSR_T.Addr = 12'h342
    CSR_T.WD = 64'd11
    trap_handle_state = WRITE_MEPC -> WRITE_MCAUSE

    trap_target = 1000_AA00
    */

    // -- MRET Test --
    $display("\n-- MRET Test (after ECALL) --");
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 64'h0000_1100;  // mepc
    #20;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 64'h0000_1104
    debug_mode = 0
    trap_handle_state = IDLE -> READ_MEPC -> RETURN_MRET -> IDLE
    */

    // -- MISALIGNED_INSTRUCTION Test --
    $display("\n-- MISALIGNED_INSTRUCTION Test --");
    MEM_pc        = 64'h0000_1111;
    trap_status   = `TRAP_MISALIGNED_INSTRUCTION;
    // mtvec, go to trap_handler address
    csr_read_data = 64'h1000_AA00; 
    #30;
    // expected trap_target = 1000_AA00
    // mepc = MEM_pc = 0000_1111
    // mcause = 64'd0
    // misaligned_instruction_flush = 1

    // -- MRET Test --
    $display("\n-- MRET Test (after MISALIGNED_INSTRUCTION) --");
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 64'h0000_1110;  // mepc
    #20;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 64'h0000_1114
    debug_mode = 0
    trap_handle_state = IDLE
    */

    // -- MISALIGNED_STORE Test --
    $display("\n-- MISALIGNED_STORE Test --");
    MEM_pc        = 64'h0000_2220;
    trap_status   = `TRAP_MISALIGNED_STORE;
    csr_read_data = 64'h1000_AA00; 
    #30;
    // expected trap_target = 1000_AA00
    // mepc = MEM_pc = 0000_2220
    // mcause = 64'd6
    // misaligned_memory_flush = 1

    // -- MRET Test --
    $display("\n-- MRET Test (after MISALIGNED_STORE) --");
    trap_status   = `TRAP_MRET;
    csr_read_data = 64'h0000_2220;  // mepc
    #20;

    // -- MISALIGNED_LOAD Test --
    $display("\n-- MISALIGNED_LOAD Test --");
    MEM_pc        = 64'h0000_3330;
    trap_status   = `TRAP_MISALIGNED_LOAD;
    csr_read_data = 64'h1000_AA00; 
    #30;
    // expected trap_target = 1000_AA00
    // mepc = MEM_pc = 0000_3330
    // mcause = 64'd4
    // misaligned_memory_flush = 1

    // -- MRET Test --
    $display("\n-- MRET Test (after MISALIGNED_LOAD) --");
    trap_status   = `TRAP_MRET;
    csr_read_data = 64'h0000_3330;  // mepc
    #20;

    // -- EBREAK Test --
    $display("\n-- EBREAK Test --");
    MEM_pc        = 64'h0000_BBB0;
    trap_status   = `TRAP_EBREAK;
    #20;
    // expected debug_mode = 1
    // mepc = MEM_pc = 0000_BBB0
    // mcause = 64'd3

    // -- MRET Test --
    $display("\n-- MRET Test (after EBREAK) --");
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 64'h0000_BBB0;  // mepc
    #20;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 64'h0000_BBB4
    debug_mode = 0
    trap_handle_state = IDLE
    */

    // -- FENCE.I Test --
    $display("\n-- FENCE.I Test --");
    trap_status = `TRAP_FENCEI;
    #10;
    // expected ic_clean <= 1'b1

    // -- NONE Test --
    $display("\n-- NONE Test --");
    trap_status = `TRAP_NONE;
    #10;
    $display("\n====================  Trap Controller Test END  ====================");
    $finish;
  end
endmodule