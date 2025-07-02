`timescale 1ns/1ps

module RegisterFile_tb;
    reg clk;
	reg [4:0] read_reg1;
	reg [4:0] read_reg2;
	reg [4:0] write_reg;
	reg [63:0] write_data;
	reg write_enable;

	wire [63:0] read_data1;
	wire [63:0] read_data2;

    RegisterFile dut (
        .clk(clk),
		.read_reg1(read_reg1),
		.read_reg2(read_reg2),
		.write_reg(write_reg),
		.write_data(write_data),
		.write_enable(write_enable),

		.read_data1(read_data1),
		.read_data2(read_data2)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Register_File_tb_result.vcd");
        $dumpvars(0, dut);

        $display("==================== Register File Test START ====================");

        // Initialize signals
        clk = 0;
        read_reg1 = 5'b0;
        read_reg2 = 5'b0;
        write_reg = 5'b0;
        write_data = 64'b0;
        write_enable = 0;

        // Test 1: Write and read
        $display("Write and read: ");
		
		write_reg = 5'b00001;
		write_data = 64'hDEAD_BEEF_DEAD_BEEF;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b: %h", read_reg1, read_data1);
		
		write_reg = 5'b00001;
		write_data = 64'hCAFE_BABE_CAFE_BABE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b: %h", read_reg1, read_data1);
		
		write_reg = 5'b00010;
		write_data = 64'hDEAD_BEEF_DEAD_BEEF;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		write_reg = 5'b00010;
		write_data = 64'hDEAD_CAFE_DEAD_CAFE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		write_reg = 5'b00001;
		write_data = 64'hBEEF_BABE_BEEF_BABE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		// Test 2: Zero address
        $display("\nZero address: ");
		
		write_reg = 5'b00000;
		write_data = 64'hDEAD_CAFE_DEAD_CAFE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00000;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
        $display("\n====================  Register File Test END  ====================");
        $stop;
    end

endmodule