`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module BranchPredictor_tb #(
    parameter XLEN = 64
);
    reg clk = 0;
    reg reset = 0;

    reg [6:0] IF_opcode;
    reg [XLEN-1:0] IF_pc;
    reg [XLEN-1:0] IF_imm;
    reg EX_branch;
    reg EX_branch_taken;
    
    wire branch_estimation;
    wire [XLEN-1:0] branch_target;

    BranchPredictor #(.XLEN(XLEN)) dut(
        .clk(clk),
        .reset(reset),
        .IF_opcode(IF_opcode),
        .IF_pc (IF_pc),
        .IF_imm (IF_imm),
        .EX_branch(EX_branch),
        .EX_branch_taken (EX_branch_taken),

        .branch_estimation (branch_estimation),
        .branch_target (branch_target)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/BranchPredictor_tb.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== Branch Predictor Test START ====================");
        $display("");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        $display("[RESET] Branch Predictor Reset Complete");
        $display("        Initial prediction_counter = %b (Strongly Not Taken)", dut.prediction_counter);
        $display("");

        IF_opcode = 7'b0;
        IF_pc = {XLEN{1'b0}};
        IF_imm = {XLEN{1'b0}};
        EX_branch = 1'b0;
        EX_branch_taken = 1'bx;
        // ---------------------------------------------------------------
        // Test 1: Prediction = NT, Actual = Taken (misprediction)
        $display("---------------------------------------------------------------");
        $display("[TEST 1] Prediction = NT, Actual = Taken (misprediction expected)");
        @(negedge clk);
        IF_opcode = `OPCODE_BRANCH;
        IF_pc = 64'h0000_0000;
        IF_imm = 64'd8;
        repeat (2) @(negedge clk);

        $display("        IF_pc = 0x%h, IF_imm = %0d", IF_pc, IF_imm);
        $display("        branch_estimation = %b (0=NT, 1=T)", branch_estimation);
        $display("        branch_target = 0x%h", branch_target);

        // misprediction, prediction counter is now Weakly Not Taken.
        EX_branch_taken = 1'b1;
        EX_branch = 1'b1;
        #10;
        $display("        EX_branch_taken = %b (Actual: Taken)", EX_branch_taken);
        $display("        prediction_counter after update = %b (Expected: 01 Weakly NT)", dut.prediction_counter);
        $display("        Result: %s", (dut.prediction_counter == 2'b01) ? "PASS" : "FAIL");
        $display("");
        // ---------------------------------------------------------------
        // Test 2: Prediction = NT, Actual = Not Taken (well predicted)
        $display("---------------------------------------------------------------");
        $display("[TEST 2] Prediction = NT, Actual = Not Taken (correct prediction)");
        @(negedge clk);
        IF_pc = 64'h0000_0000_0000_0008;
        IF_imm = 64'd12;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        $display("        IF_pc = 0x%h, IF_imm = %0d", IF_pc, IF_imm);
        $display("        branch_estimation = %b (0=NT, 1=T)", branch_estimation);
        $display("        branch_target = 0x%h", branch_target);

        // well predicted, prediction counter is now Strongly Not Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b0; // Target address = 0x0000_000C (PC+4)
        #10;
        $display("        EX_branch_taken = %b (Actual: Not Taken)", EX_branch_taken);
        $display("        prediction_counter after update = %b (Expected: 00 Strongly NT)", dut.prediction_counter);
        $display("        Result: %s", (dut.prediction_counter == 2'b00) ? "PASS" : "FAIL");
        $display("");
        // ---------------------------------------------------------------
        // Test 3: Prediction = NT, Actual = Taken (misprediction)
        $display("---------------------------------------------------------------");
        $display("[TEST 3] Prediction = NT, Actual = Taken (misprediction expected)");
        @(negedge clk);
        IF_pc = 64'h0000_0000_0000_000C;
        IF_imm = 64'd8;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        $display("        IF_pc = 0x%h, IF_imm = %0d", IF_pc, IF_imm);
        $display("        branch_estimation = %b (0=NT, 1=T)", branch_estimation);
        $display("        branch_target = 0x%h", branch_target);

        // misprediction, prediction counter is now Weakly Not Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; 
        #10;
        $display("        EX_branch_taken = %b (Actual: Taken)", EX_branch_taken);
        $display("        prediction_counter after update = %b (Expected: 01 Weakly NT)", dut.prediction_counter);
        $display("        Result: %s", (dut.prediction_counter == 2'b01) ? "PASS" : "FAIL");
        $display("");
        // ---------------------------------------------------------------
        // Test 4: Prediction = NT, Actual = Taken (mispredicted)
        $display("---------------------------------------------------------------");
        $display("[TEST 4] Prediction = NT, Actual = Taken (misprediction expected)");
        @(negedge clk);
        IF_pc = 64'h0000_0000_0000_0014;
        IF_imm = 64'd12;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        $display("        IF_pc = 0x%h, IF_imm = %0d", IF_pc, IF_imm);
        $display("        branch_estimation = %b (0=NT, 1=T)", branch_estimation);
        $display("        branch_target = 0x%h", branch_target);

        // mispredicted, prediction counter is now Weakly Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; // Target address = 0x0000_0020
        #10;
        $display("        EX_branch_taken = %b (Actual: Taken)", EX_branch_taken);
        $display("        prediction_counter after update = %b (Expected: 10 Weakly T)", dut.prediction_counter);
        $display("        Result: %s", (dut.prediction_counter == 2'b10) ? "PASS" : "FAIL");
        $display("");
        // ---------------------------------------------------------------
        // Test 5: Prediction = T, Actual = Taken (well predicted)
        $display("---------------------------------------------------------------");
        $display("[TEST 5] Prediction = T, Actual = Taken (correct prediction)");
        @(negedge clk);
        IF_pc = 64'h0000_0000_0000_0020;
        IF_imm = 64'd8;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        $display("        IF_pc = 0x%h, IF_imm = %0d", IF_pc, IF_imm);
        $display("        branch_estimation = %b (0=NT, 1=T)", branch_estimation);
        $display("        branch_target = 0x%h", branch_target);

        // well predicted, prediction counter is now Strongly Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; // Target address = 0x0000_0028
        #10;
        $display("        EX_branch_taken = %b (Actual: Taken)", EX_branch_taken);
        $display("        prediction_counter after update = %b (Expected: 11 Strongly T)", dut.prediction_counter);
        $display("        Result: %s", (dut.prediction_counter == 2'b11) ? "PASS" : "FAIL");
        $display("");
        // ---------------------------------------------------------------
        $display("==================== Branch Predictor Test FINISH ====================");
        #40;
        $finish;
    end
endmodule