module ProgramCounter (
    input clk,
    input reset,
    input [63:0] next_pc, // Next pc value
    
    output reg [63:0] pc // Current pc value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 64'b0; // Reset to 0
        end 
		else begin
            pc <= next_pc; // Update pc value
        end
    end

endmodule