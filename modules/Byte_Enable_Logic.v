`include "modules/headers/load_funct3.vh"
`include "modules/headers/store_funct3.vh"

module ByteEnableLogic (
    input memory_read,							// signal indicating that register file should read from data memory
    input memory_write,							// signal indicating that register file should write to data memory
    input [2:0] funct3,							// funct3
	input [63:0] register_file_read_data,		// data read from register file
	input [63:0] data_memory_read_data,			// data read from data memory
	input [63:0] address,						// address for checking alignment
	
	output reg [63:0] register_file_write_data,	// data to write at register file
	output reg [63:0] data_memory_write_data,	// data to write at data memory
    output reg [7:0] write_mask					// bitmask for writing data
);

    always @(*) begin
        if (memory_read) begin
			data_memory_write_data = 64'b0;
			write_mask = 8'b0;
			
			case (funct3)
				`LOAD_LB: begin
					register_file_write_data = {{56{data_memory_read_data[7]}}, data_memory_read_data[7:0]};
				end
				`LOAD_LH: begin
					register_file_write_data = {{48{data_memory_read_data[15]}}, data_memory_read_data[15:0]};
				end
				`LOAD_LW: begin
					register_file_write_data = {{32{data_memory_read_data[31]}}, data_memory_read_data[31:0]};
				end
                `LOAD_LD: begin
					register_file_write_data = data_memory_read_data;
                end
				`LOAD_LBU: begin
					register_file_write_data = {56'b0, data_memory_read_data[7:0]};
				end
				`LOAD_LHU: begin
					register_file_write_data = {48'b0, data_memory_read_data[15:0]};
				end
                `LOAD_LWU: begin
					register_file_write_data = {32'b0, data_memory_read_data[31:0]};
                end
				default: begin
					register_file_write_data = 64'b0;
				end
			endcase
		end
		else if (memory_write) begin
			register_file_write_data = 64'b0;
						
			case (funct3)
				`STORE_SB: begin
					data_memory_write_data = {8{register_file_read_data[7:0]}};
					
					case (address[2:0])
						3'b000: begin
							write_mask = 8'b0000_0001;
						end
						3'b001: begin
							write_mask = 8'b0000_0010;
						end
						3'b010: begin
							write_mask = 8'b0000_0100;
						end
						3'b011: begin
							write_mask = 8'b0000_1000;
						end
						3'b100: begin
							write_mask = 8'b0001_0000;
						end
						3'b101: begin
							write_mask = 8'b0010_0000;
						end
						3'b110: begin
							write_mask = 8'b0100_0000;
						end
						3'b111: begin
							write_mask = 8'b1000_0000;
						end
					endcase
				end
				`STORE_SH: begin
					data_memory_write_data = {4{register_file_read_data[15:0]}};
					
					case (address[2:0])
						3'b000: begin
							write_mask = 8'b0000_0011;
						end
						3'b010: begin
							write_mask = 8'b0000_1100;
						end
						3'b100: begin
							write_mask = 8'b0011_0000;
						end
						3'b110: begin
							write_mask = 8'b1100_0000;
						end
						default: begin
							write_mask = 8'b0;
						end
					endcase
				end
				`STORE_SW: begin
					data_memory_write_data = {2{register_file_read_data[31:0]}};
					
					case (address[2:0])
						3'b000: begin
							write_mask = 8'b0000_1111;
						end
						3'b100: begin
							write_mask = 8'b1111_0000;
						end
						default: begin
							write_mask = 8'b0;
						end
					endcase
				end
				`STORE_SD: begin
					data_memory_write_data = register_file_read_data;

					if (address[2:0] == 3'b0) begin
						write_mask = 8'b1111_1111;
					end
					else begin
						write_mask = 8'b0;
					end
				end
				default: begin
					data_memory_write_data = 64'b0;
					write_mask = 8'b0;
				end
			endcase
		end
		else begin
			register_file_write_data = 64'b0;
			data_memory_write_data = 64'b0;
			write_mask = 8'b0;
		end
    end

endmodule