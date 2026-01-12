`timescale 1ns/1ps

module DataMemory_tb;

    parameter XLEN = 64;

    reg clk;
    reg write_enable;
    reg [XLEN-1:0] address;
    reg [XLEN-1:0] write_data;
    reg [7:0] write_mask;
    reg [XLEN-1:0] rom_read_data;

    wire [XLEN-1:0] read_data;
    wire [XLEN-1:0] rom_address;

    // Test result counters
    integer pass_count;
    integer fail_count;
    integer test_num;

    DataMemory #(.XLEN(XLEN)) data_memory (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .write_mask(write_mask),
        .rom_read_data(rom_read_data),
        .rom_address(rom_address),
        .read_data(read_data)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    // Task for checking results with PASS/FAIL indication
    task check_result;
        input [XLEN-1:0] expected_val;
        input [255:0] test_name;
        begin
            test_num = test_num + 1;
            if (read_data === expected_val) begin
                $display("  [PASS] #%0d %s", test_num, test_name);
                $display("         Expected: %016h | Actual: %016h", expected_val, read_data);
                pass_count = pass_count + 1;
            end 
            else begin
                $display("  [FAIL] #%0d %s", test_num, test_name);
                $display("         Expected: %016h | Actual: %016h", expected_val, read_data);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Task for checking rom_address
    task check_rom_address;
        input [XLEN-1:0] expected_addr;
        input [255:0] test_name;
        begin
            test_num = test_num + 1;
            if (rom_address === expected_addr) begin
                $display("  [PASS] #%0d %s", test_num, test_name);
                $display("         Expected: %016h | Actual: %016h", expected_addr, rom_address);
                pass_count = pass_count + 1;
            end 
            else begin
                $display("  [FAIL] #%0d %s", test_num, test_name);
                $display("         Expected: %016h | Actual: %016h", expected_addr, rom_address);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("testbenches/results/waveforms/Data_Memory_tb_result.vcd");
        $dumpvars(0, data_memory);

        $display("==================== Data Memory Test START (RV64I) ====================");

        // Initialize signals
        clk = 0;
        write_enable = 0;
        address = 64'h0000_0000_0000_0000;
        write_data = 64'h0000_0000_0000_0000;
        write_mask = 8'b0000_0000;
        rom_read_data = 64'h0000_0000_0000_0000;
        pass_count = 0;
        fail_count = 0;
        test_num = 0;

        #10;

        // ========================================================================
        // Test 1: ROM Address Region Test (0x0000xxxx)
        $display("\n[Test 1] ROM Address Region Read (0x0000xxxx):");
        
        address = 64'h0000_0000_0000_0004;
        rom_read_data = 64'h1234_5678_9ABC_DEF0;
        #10;
        check_result(64'h1234_5678_9ABC_DEF0, "ROM read at 0x00000004");
        check_rom_address(64'h0000_0000_0000_0004, "ROM address output");
        
        address = 64'h0000_0000_0000_1000;
        rom_read_data = 64'hABCD_EF01_2345_6789;
        #10;
        check_result(64'hABCD_EF01_2345_6789, "ROM read at 0x00001000");
        
        address = 64'h0000_0000_0000_FFFC;
        rom_read_data = 64'hCAFE_BABE_DEAD_BEEF;
        #10;
        check_result(64'hCAFE_BABE_DEAD_BEEF, "ROM read at 0x0000FFFC");

        // ========================================================================
        // Test 2: RAM Address Region Initialization (0x1000xxxx)
        $display("\n[Test 2] RAM Address Region Initialization (0x1000xxxx):");

        address = 64'h0000_0000_1000_0004;
        rom_read_data = 64'hDEAD_BEEF_CAFE_BABE;
        #10;
        check_result(64'h0000_0000_0000_0000, "RAM initial value (should be 0)");
        
        // ========================================================================
        // Test 3: RAM Full Write and Read (64-bit)
        $display("\n[Test 3] RAM Full Write and Read (mask=11111111):");

        address = 64'h0000_0000_1000_0004;
        write_data = 64'hDEAD_BEEF_CAFE_BABE;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        rom_read_data = 64'h1234_5678_9ABC_DEF0;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hDEAD_BEEF_CAFE_BABE, "Full 64-bit write");

        // ========================================================================
        // Test 4: RAM Partial Write - Lower 4 Bytes (Byte Masking)
        $display("\n[Test 4] RAM Partial Write - Lower 4 Bytes:");

        // Reset the memory location
        address = 64'h0000_0000_1000_0008;
        write_data = 64'hFFFF_FFFF_FFFF_FFFF;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // mask = 00000001: byte[7:0]
        write_data = 64'h1122_3344_5566_77AA;
        write_mask = 8'b0000_0001;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_FFFF_FFAA, "mask=00000001 byte[7:0]");

        // mask = 00000010: byte[15:8]
        write_data = 64'h1122_3344_5566_BB88;
        write_mask = 8'b0000_0010;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_FFFF_BBAA, "mask=00000010 byte[15:8]");

        // mask = 00000100: byte[23:16]
        write_data = 64'h1122_3344_55CC_7788;
        write_mask = 8'b0000_0100;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_FFCC_BBAA, "mask=00000100 byte[23:16]");

        // mask = 00001000: byte[31:24]
        write_data = 64'h1122_3344_DD66_7788;
        write_mask = 8'b0000_1000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_DDCC_BBAA, "mask=00001000 byte[31:24]");

        // ========================================================================
        // Test 5: RAM Partial Write - Upper 4 Bytes (Byte Masking)
        $display("\n[Test 5] RAM Partial Write - Upper 4 Bytes:");

        // mask = 00010000: byte[39:32]
        write_data = 64'h1122_33EE_5566_7788;
        write_mask = 8'b0001_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFEE_DDCC_BBAA, "mask=00010000 byte[39:32]");

        // mask = 00100000: byte[47:40]
        write_data = 64'h1122_FF44_5566_7788;
        write_mask = 8'b0010_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFEE_DDCC_BBAA, "mask=00100000 byte[47:40]");

        // mask = 01000000: byte[55:48]
        write_data = 64'h11AB_3344_5566_7788;
        write_mask = 8'b0100_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFAB_FFEE_DDCC_BBAA, "mask=01000000 byte[55:48]");

        // mask = 10000000: byte[63:56]
        write_data = 64'hCD22_3344_5566_7788;
        write_mask = 8'b1000_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hCDAB_FFEE_DDCC_BBAA, "mask=10000000 byte[63:56]");

        // ========================================================================
        // Test 6: RAM Partial Write - Half-Word and Word Masking
        $display("\n[Test 6] RAM Partial Write - Half-Word and Word:");

        // Reset memory
        address = 64'h0000_0000_1000_000C;
        write_data = 64'h0000_0000_0000_0000;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // mask = 00000011: lower half-word
        write_data = 64'hAAAA_BBBB_CCCC_DDDD;
        write_mask = 8'b0000_0011;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h0000_0000_0000_DDDD, "mask=00000011 lower half-word");

        // mask = 00001100: second half-word
        write_data = 64'hAAAA_BBBB_EEEE_FFFF;
        write_mask = 8'b0000_1100;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h0000_0000_EEEE_DDDD, "mask=00001100 second half-word");

        // mask = 00001111: lower word
        address = 64'h0000_0000_1000_0010;
        write_data = 64'h1111_2222_3333_4444;
        write_mask = 8'b0000_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h0000_0000_3333_4444, "mask=00001111 lower word");

        // mask = 11110000: upper word
        write_data = 64'h5555_6666_7777_8888;
        write_mask = 8'b1111_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h5555_6666_3333_4444, "mask=11110000 upper word");

        // ========================================================================
        // Test 7: RAM Multiple Address Write/Read
        $display("\n[Test 7] RAM Multiple Address Write/Read:");

        address = 64'h0000_0000_1000_0014;
        write_data = 64'h1972_1121_1984_0315;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h1972_1121_1984_0315, "Write to 0x10000014");

        address = 64'h0000_0000_1000_0004;
        #10;
        check_result(64'hDEAD_BEEF_CAFE_BABE, "Read previous 0x10000004");

        // ========================================================================
        // Test 8: Address Region Boundary Test
        $display("\n[Test 8] Address Region Boundary Test:");
        
        address = 64'h0000_0000_0000_FFFC;
        rom_read_data = 64'hFFFF_FFFF_FFFF_FFFF;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_FFFF_FFFF, "ROM boundary 0x0000FFFC");
        
        address = 64'h0000_0000_1000_0000;
        write_data = 64'h1111_1111_2222_2222;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h1111_1111_2222_2222, "RAM boundary 0x10000000");

        // ========================================================================
        // Test 9: Invalid Address Region (not ROM or RAM)
        $display("\n[Test 9] Invalid Address Region:");
        
        address = 64'h0000_0000_2000_0000;
        rom_read_data = 64'h1234_5678_9ABC_DEF0;
        #10;
        check_result(64'h0000_0000_0000_0000, "Invalid 0x20000000");
        
        address = 64'hFFFF_FFFF_FFFF_FFFF;
        #10;
        check_result(64'h0000_0000_0000_0000, "Invalid 0xFFFFFFFFFFFFFFFF");

        // ========================================================================
        // Test 10: ROM vs RAM Read Priority Test
        $display("\n[Test 10] ROM vs RAM Read Priority:");
        
        address = 64'h0000_0000_1000_0020;
        write_data = 64'hAAAA_AAAA_AAAA_AAAA;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hAAAA_AAAA_AAAA_AAAA, "RAM write 0x10000020");
        
        address = 64'h0000_0000_0000_0020;
        rom_read_data = 64'hBBBB_BBBB_BBBB_BBBB;
        #10;
        check_result(64'hBBBB_BBBB_BBBB_BBBB, "ROM read 0x00000020");

        // ========================================================================
        // Test 11: RAM Write Enable Control
        $display("\n[Test 11] RAM Write Enable Control:");

        address = 64'h0000_0000_1000_0024;
        write_data = 64'hDEAD_BEEF_CAFE_BABE;
        write_mask = 8'b1111_1111;
        write_enable = 0;
        #10;
        check_result(64'h0000_0000_0000_0000, "write_enable=0");
        
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hDEAD_BEEF_CAFE_BABE, "write_enable=1");

        // ========================================================================
        // Test 12: ROM Address Output Verification
        $display("\n[Test 12] ROM Address Output Verification:");
        
        address = 64'h0000_0000_0000_0100;
        #10;
        check_rom_address(64'h0000_0000_0000_0100, "rom_address=0x00000100");
        
        address = 64'h0000_0000_0000_2000;
        #10;
        check_rom_address(64'h0000_0000_0000_2000, "rom_address=0x00002000");

        // ========================================================================
        // Test 13: Zero Mask Write (No bytes written)
        $display("\n[Test 13] Zero Mask Write:");

        address = 64'h0000_0000_1000_0028;
        write_data = 64'hFFFF_FFFF_FFFF_FFFF;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        write_data = 64'h0000_0000_0000_0000;
        write_mask = 8'b0000_0000;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hFFFF_FFFF_FFFF_FFFF, "mask=00000000 no write");

        // ========================================================================
        // Test 14: Alternating Byte Pattern Masking
        $display("\n[Test 14] Alternating Byte Pattern:");

        address = 64'h0000_0000_1000_002C;
        write_data = 64'h0000_0000_0000_0000;
        write_mask = 8'b1111_1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // mask = 01010101
        write_data = 64'hAA11_BB22_CC33_DD44;
        write_mask = 8'b0101_0101;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'h0011_0022_0033_0044, "mask=01010101");

        // mask = 10101010
        write_data = 64'hEE55_FF66_0077_1188;
        write_mask = 8'b1010_1010;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        check_result(64'hEE11_FF22_0033_1144, "mask=10101010");

        // ========================================================================
        // Test Summary
        $display("\n==================== Test Summary ====================");
        $display("  Total: %0d | PASSED: %0d | FAILED: %0d", test_num, pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** SOME TESTS FAILED ***");
        $display("====================  Data Memory Test END  ====================");
        
        $finish;
    end

endmodule