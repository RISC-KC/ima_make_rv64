`include "modules/headers/opcode.vh"

module InstructionDecoder (
	input [31:0] instruction,
    
    output [6:0] opcode,
	output [2:0] funct3,
	output [6:0] funct7,
	output [4:0] rs1,
	output [4:0] rs2,
	output [4:0] rd,
	output reg [19:0] raw_imm
);
    assign opcode = instruction[6:0];
	assign funct3 = instruction[14:12];
	assign funct7 = instruction[31:25];
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];

    always @(*) begin
        case (opcode)
			`OPCODE_LUI, `OPCODE_AUIPC: begin // U-type
				raw_imm = instruction[31:12];
            end
			
			`OPCODE_JAL: begin // J-type
				raw_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
			end
			
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_ITYPE_WORD, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin // I-type
				raw_imm = {8'b0, instruction[31:20]};
			end
			
			`OPCODE_BRANCH: begin // B-type
				raw_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
			end
			
			`OPCODE_STORE: begin // S-type
				raw_imm = {8'b0, instruction[31:25], instruction[11:7]};
			end
			
			`OPCODE_RTYPE, `OPCODE_RTYPE_WORD, `OPCODE_ATOMIC: begin // R type
				raw_imm = 20'b0;
			end

			default: begin
				raw_imm = 20'b0;
            end
		endcase
    end

endmodule