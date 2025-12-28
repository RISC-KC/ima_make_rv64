`timescale 1ns/1ps

module PCController_tb #(
    parameter XLEN = 64
);
    reg jump;
    reg branch_estimation;
    reg trapped;
    reg [XLEN-1:0] pc;
    reg [XLEN-1:0] jump_target;
    reg [XLEN-1:0] branch_target;
    reg [XLEN-1:0] trap_target;
	reg pc_stall;

    wire [XLEN-1:0] next_pc;

    PCController #(.XLEN(XLEN)) pc_controller (
        .jump(jump),
        .branch_estimation(branch_estimation),
        .trapped(trapped),
        .pc(pc),
        .jump_target(jump_target),
        .branch_target(branch_target),
        .trap_target(trap_target),
		.pc_stall(pc_stall),

        .next_pc(next_pc)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/PC_Controller_tb_result.vcd");
        $dumpvars(0, pc_controller);

		// Test sequence
        $display("==================== PCController Test START ====================");

        pc = 64'b0;
        jump_target = 64'b0;
        branch_target = 64'b0;
        trap_target = 64'b0;

        // Test 1: Pause PC update
        $display("\nPause PC update: ");

        pc_stall = 1;

        jump = 1;
        branch_estimation = 0;
        trapped = 0;

        jump_target = 64'h12345678_9ABCDEF0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        jump_target = 64'b0;

        // Test 2: No jump, no branch, no trap
        $display("\nNo jump, No branch, No trap: ");

        pc_stall = 0;

        jump = 0;
        branch_estimation = 0;
        trapped = 0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 3: Jump
		$display("\nJump: ");
		
        pc = next_pc;

        jump = 1;
		branch_estimation = 0;
		trapped = 0;

        jump_target = 64'hDEAD0000_BEEFCAF8;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 4: Branch taken
        $display("\nBranch taken: ");
        
        pc = next_pc;

		jump = 0;
		branch_estimation = 1;
		trapped = 0;

        branch_target = 64'h0000CCCC_DDDDDDDC;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 5: Trapped
        $display("\nTrapped: ");
        
        pc = next_pc;

		jump = 0;
		branch_estimation = 0;
		trapped = 1;
		
        trap_target = 64'hCAFEBABE_DEADBEE0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 6: Normal increment
        $display("\nNormal increment: ");
        
        pc = 64'h00000000_00001000;

		jump = 0;
		branch_estimation = 0;
		trapped = 0;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        $display("\n====================  PCController Test END  ====================");
        $stop;
    end

endmodule