`timescale 1ns/1ps

`include "modules/headers/load_funct3.vh"
`include "modules/headers/store_funct3.vh"

module ByteEnableLogic_tb;
	reg memory_read;
    reg memory_write;
    reg [2:0] funct3;
	reg [63:0] register_file_read_data;
	reg [63:0] data_memory_read_data;
	reg [63:0] address;
	
	reg [63:0] original_data;
	
	wire [63:0] register_file_write_data;
	wire [63:0] data_memory_write_data;
    wire [7:0] write_mask;

    ByteEnableLogic dut (
        .memory_read(memory_read),
		.memory_write(memory_write),
		.funct3(funct3),
		.register_file_read_data(register_file_read_data),
		.data_memory_read_data(data_memory_read_data),
		.address(address),

		.register_file_write_data(register_file_write_data),
		.data_memory_write_data(data_memory_write_data),
		.write_mask(write_mask)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Byte_Enable_Logic_tb_result.vcd");
        $dumpvars(0, dut);

        // Test sequence
        $display("==================== Byte Enable Logic Test START ====================");

        memory_read = 0;
		memory_write = 0;
		funct3 = 3'b0;
		register_file_read_data = 64'b0;
		data_memory_read_data = 64'b0;
		address = 64'b0;
		
        // Test 1: Load
		$display("\nLoad: \n");
		
		data_memory_read_data = 64'hDEAD_BEEF_CAFE_BABE;
		
		#10;
		$display("Full data to load: %h, Actual data loaded: %h (load disabled)", data_memory_read_data, register_file_write_data);
		
		memory_read = 1;
		
		funct3 = `LOAD_LB; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);
		
		funct3 = `LOAD_LH; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);
		
		funct3 = `LOAD_LW; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);

        funct3 = `LOAD_LD; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);
		
		funct3 = `LOAD_LBU; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);
		
		funct3 = `LOAD_LHU; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);

        funct3 = `LOAD_LWU; #10;
        $display("Full data to load: %h, Actual data loaded: %h, funct3: %b, address: %h", data_memory_read_data, register_file_write_data, funct3, address);
		
		// Test 2: Store
		$display("\nStore: ");
		
		original_data = 64'hCCCC_CCCC_CCCC_CCCC;
		
		memory_read = 0;
		funct3 = 3'b0;
		data_memory_read_data = 64'b0;
		address = 64'h0000_0000_0000_00F0;
		
		register_file_read_data = 64'hCAFE_BABE_DEAD_BEEF;
		
		#10;
		$display("%h (register) -> %h (duplicated), store disabled, address: %h, write_mask: %b\n", register_file_read_data, data_memory_write_data, address, write_mask);
		
		memory_write = 1;
		
		funct3 = `STORE_SB;
		
		address = 64'hF0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF5; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF6; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
        address = 64'hF7; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b\n", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

		funct3 = `STORE_SH;
		
		address = 64'hF0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF5; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF6; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
        address = 64'hF7; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b\n", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

		funct3 = `STORE_SW; 
		
		address = 64'hF0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF5; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF6; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
        address = 64'hF7; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b\n", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
        funct3 = `STORE_SD; 
		
		address = 64'hF0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
		address = 64'hF4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF5; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

        address = 64'hF6; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);
		
        address = 64'hF7; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask);

		$display("\n====================  Byte Enable Logic Test END  ====================");
		
		$stop;
    end

endmodule