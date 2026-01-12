`timescale 1ns/1ps

module RV32I46F5SPMMIO_tb #(
    parameter XLEN = 64
);
    reg clk;
    reg reset;
    wire [31:0] retire_instruction;
    wire [XLEN-1:0] mmio_data_memory_address;
    wire [XLEN-1:0] mmio_data_memory_write_data;
    wire mmio_data_memory_write_enable;

    RV64I59F5SP rv64i59f_5sp (
        .clk(clk),
        .reset(reset),
        .UART_busy(1'b0),

        .retire_instruction(retire_instruction),
        .MMIO_data_memory_address(mmio_data_memory_address),
        .MMIO_data_memory_write_data(mmio_data_memory_write_data),
        .MMIO_data_memory_write_enable(mmio_data_memory_write_enable)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/RV64I59F_5SP_tb.vcd");
        $dumpvars(0, rv64i59f_5sp);

        $display("==================== RV64I59F_5SP Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;

        #3340;

        $display("\n====================  RV64I59F_5SP Test END  ====================");
        $stop;
    end

endmodule
