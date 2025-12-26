`timescale 1ns/1ps

module ProgramCounter_tb #(
    parameter XLEN = 64
);
    reg clk;
    reg reset;
    reg [XLEN-1:0] next_pc;

    wire [XLEN-1:0] pc;

    ProgramCounter dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),

        .pc(pc)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Program_Counter_tb_result.vcd");
        $dumpvars(0, dut);

        $display("==================== Program Counter Test START ====================");

        // Initialize signals
        clk     = 0;
        reset   = 0;
        next_pc = 0;

        // Test 1: Reset the PC
        $display("Reset the PC: ");
		
		next_pc = 64'h0000_0000_0000_0004;
		
		#10;
        $display("Before reset: pc = %h", pc);
		
        reset = 1;
		next_pc = 64'h0000_0000_0000_0008;
		
		#10;
        $display("After reset = 1, pc = %h", pc);

        reset = 0;
        #10;

        // Test 2: Assigning value to next_pc
        $display("\nAssigning value to next_pc: ");
        
		next_pc = 64'hDEAD_BEEF_DEAD_BEEF;
		
        #10;
        $display("pc = %h", pc);

        next_pc = 64'hCAFE_BEBE_CAFE_BEBE;
		
        #10;
        $display("pc = %h", pc);

        // Test 3: Sudden reset
        $display("\nSudden reset:");
		
        #5;
		reset = 1; // Reset signal in the middle of the clock cycle
		#5;
		
        $display("pc = %h", pc);

        $display("\n====================  Program Counter Test END  ====================");
        $stop;
    end

endmodule