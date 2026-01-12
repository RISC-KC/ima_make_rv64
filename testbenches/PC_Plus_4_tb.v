`timescale 1ns/1ps

module PCPlus4_tb;
	reg [63:0] pc;
	wire [63:0] pc_plus_4;

    PCPlus4 dut (
        .pc(pc),
		.pc_plus_4(pc_plus_4)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/PC_Plus_4_tb_result.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== PCPlus4 Test START ====================\n");

        pc = 64'h0000_0000_0000_0000; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
        
		pc = 64'hDEAD_BEEF_DEAD_BEEF; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
		
		pc = 64'hCAFE_BEBE_CAFE_BEBE; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
		
		$display("\n====================  PCPlus4 Test END  ====================");
		
		$stop;
    end

endmodule