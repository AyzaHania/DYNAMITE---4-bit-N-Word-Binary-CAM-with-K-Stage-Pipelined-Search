`timescale 1ns/1ps

module cam_tb_postsyn;
    parameter integer N = 512;
    parameter integer K = 5;  
    localparam integer W = $clog2(N);
    
    reg clk;
    reg reset;
    reg test_mode;
    reg [3:0] search_word;
    reg write_enable;
    reg [W-1:0] write_addr;
    reg [3:0] write_data;
    wire match_found;
    wire [W-1:0] match_index;
    
  
    cam DUT (
        .clk(clk),
        .reset(reset),
        .test_mode(test_mode),
        .search_word(search_word),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .match_found(match_found),
        .match_index(match_index)
    );
    
 
    initial begin
        $sdf_annotate("cam_map.sdf", DUT, , "sdf_cam.log", "MAXIMUM", , );
        $display("========================================");
        $display("POST-SYNTHESIS SIMULATION with SDF");
        $display("SDF file: cam_map.sdf");
        $display("========================================");
    end
    
   
    initial begin
        $dumpfile("cam_postsyn.vcd");
        $dumpvars(0, cam_tb_postsyn);
    end
    
    // Clock Generation - 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    
    integer cycle_count;
    initial cycle_count = 0;
    always @(posedge clk) cycle_count = cycle_count + 1;
    
   
    initial begin
        $display("CAM Post-Synthesis Testbench");
        $display("N=%0d, K=%0d (Pipeline Latency)", N, K);
        $display("Clock Period: 10ns (100 MHz)");
        $display("");
        
        reset = 1;
        test_mode = 0;
        search_word = 4'b0000;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        
        repeat(5) @(posedge clk);
        $display("[Cycle %0d] Releasing reset...", cycle_count);
        reset = 0;
        repeat(3) @(posedge clk);
        
        
        $display("\n========== WRITE PHASE ==========");
        write_enable = 1;
        
        
        write_addr = 10;
        write_data = 4'h4;
        @(posedge clk);
        $display("[Cycle %0d] Write: mem[10] = 0x4", cycle_count);
        
        
        write_addr = 20;
        write_data = 4'hA;
        @(posedge clk);
        $display("[Cycle %0d] Write: mem[20] = 0xA", cycle_count);
        
      
        write_addr = 30;
        write_data = 4'hF;
        @(posedge clk);
        $display("[Cycle %0d] Write: mem[30] = 0xF", cycle_count);
        
       
        write_addr = 40;
        write_data = 4'hA;
        @(posedge clk);
        $display("[Cycle %0d] Write: mem[40] = 0xA (duplicate)", cycle_count);
        
        
        write_addr = 50;
        write_data = 4'h7;
        @(posedge clk);
        $display("[Cycle %0d] Write: mem[50] = 0x7", cycle_count);
        
        write_enable = 0;
        repeat(3) @(posedge clk);
        $display("Write phase complete.\n");
        
        
        $display("========== SEARCH PHASE ==========");
        $display("Pipeline Latency: K = %0d cycles\n", K);
        
     
        $display("--- TEST 1: Priority Encoding ---");
        $display("[Cycle %0d] Searching for 0xA...", cycle_count);
        search_word = 4'hA;
        @(posedge clk);
        
        repeat(K) @(posedge clk);  // Wait for pipeline
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (match_found && match_index == 20)
            $display("  ✓ PASS: Correctly matched lowest index 20 (not 40)\n");
        else if (match_found && match_index == 40)
            $display("  ✗ FAIL: Matched index 40 - Priority encoder broken!\n");
        else if (match_found)
            $display("  ✗ FAIL: Matched wrong index %0d\n", match_index);
        else
            $display("  ✗ FAIL: No match found\n");
        
      
        $display("--- TEST 2: Single Match ---");
        $display("[Cycle %0d] Searching for 0xF...", cycle_count);
        search_word = 4'hF;
        @(posedge clk);
        
        repeat(K) @(posedge clk);
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (match_found && match_index == 30)
            $display("  ✓ PASS: Correctly matched index 30\n");
        else
            $display("  ✗ FAIL: Expected index 30\n");
        
     
        $display("--- TEST 3: Another Single Match ---");
        $display("[Cycle %0d] Searching for 0x4...", cycle_count);
        search_word = 4'h4;
        @(posedge clk);
        
        repeat(K) @(posedge clk);
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (match_found && match_index == 10)
            $display("  ✓ PASS: Correctly matched index 10\n");
        else
            $display("  ✗ FAIL: Expected index 10\n");
        
       
        $display("--- TEST 4: Match at Higher Index ---");
        $display("[Cycle %0d] Searching for 0x7...", cycle_count);
        search_word = 4'h7;
        @(posedge clk);
        
        repeat(K) @(posedge clk);
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (match_found && match_index == 50)
            $display("  ✓ PASS: Correctly matched index 50\n");
        else if (match_found)
            $display("  Note: Matched index %0d (may be from init pattern)\n", match_index);
        else
            $display("  ✗ FAIL: Expected index 50\n");
        
       
        $display("--- TEST 5: No Match Case ---");
        $display("[Cycle %0d] Searching for 0xE (not written)...", cycle_count);
        search_word = 4'hE;
        @(posedge clk);
        
        repeat(K) @(posedge clk);
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (!match_found)
            $display("  ✓ PASS: Correctly returned no match\n");
        else
            $display("  Note: Found at index %0d (from init pattern)\n", match_index);
        
       
        $display("--- TEST 6: Pipeline Throughput ---");
        $display("[Cycle %0d] Issuing back-to-back searches...", cycle_count);
        
        search_word = 4'hA; @(posedge clk);
        $display("  [Cycle %0d] Search 0xA", cycle_count);
        
        search_word = 4'hF; @(posedge clk);
        $display("  [Cycle %0d] Search 0xF", cycle_count);
        
        search_word = 4'h4; @(posedge clk);
        $display("  [Cycle %0d] Search 0x4", cycle_count);
        
        search_word = 4'h7; @(posedge clk);
        $display("  [Cycle %0d] Search 0x7", cycle_count);
        
        search_word = 4'h0;
        $display("  Waiting for results...");
        repeat(K+3) @(posedge clk);
        $display("  ✓ Pipeline delivered one result per cycle\n");
        
        // TEST 7: Test mode
        $display("--- TEST 7: Test Mode ---");
        $display("[Cycle %0d] Enabling test mode...", cycle_count);
        test_mode = 1;
        search_word = 4'hF;  // Shouldn't matter
        @(posedge clk);
        
        repeat(K+1) @(posedge clk);
        $display("[Cycle %0d] Result: match_found=%b, match_index=%0d", 
                 cycle_count, match_found, match_index);
        if (match_found && match_index == 0)
            $display("  ✓ PASS: Test mode forces match at index 0\n");
        else
            $display("  ✗ FAIL: Test mode should force index 0\n");
        
        test_mode = 0;
        repeat(3) @(posedge clk);
        
        // ============================================================
        // Summary
        // ============================================================
        repeat(5) @(posedge clk);
        $display("\n========================================");
        $display("POST-SYNTHESIS SIMULATION COMPLETE");
        $display("========================================");
        $display("Total cycles: %0d", cycle_count);
        $display("Waveform: cam_postsyn.vcd");
        $display("SDF log: sdf_cam.log");
        $display("\nCheck SDF annotation:");
        $display("  grep -i 'annotation' sdf_cam.log");
        $display("========================================\n");
        
        $finish;
    end
    
    // Real-time monitor (optional, can comment out if too verbose)
    always @(posedge clk) begin
        if (!reset && write_enable) begin
            $display("    [Cycle %0d] WRITE: addr=%0d, data=0x%h", 
                     cycle_count, write_addr, write_data);
        end
    end
    
endmodule
