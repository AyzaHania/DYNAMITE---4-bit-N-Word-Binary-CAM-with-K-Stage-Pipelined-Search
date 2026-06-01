`timescale 1ns/1ps

module cam_tb;

    reg clk, reset, test_mode;
    reg [3:0] search_word;
    wire match_found;
    wire [3:0] match_index;

    // Instantiate DUT (CAM)
    cam #(16) DUT (
        .clk(clk),
        .reset(reset),
        .test_mode(test_mode),
        .search_word(search_word),
        .match_found(match_found),
        .match_index(match_index)
    );

    // ================================================================
    // CLOCK GENERATION
    // ================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end

    
    initial begin
        // Initialize
        reset = 1;
        test_mode = 0;
        search_word = 4'b0000;
        #20 reset = 0;

        #20;

        // Test 1: Search for value 10 (1010)
        search_word = 4'b1010;
        #40;

        // Test 2: Search for value 5 (0101)
        search_word = 4'b0101;
        #40;

        // Test 3: Search for value 12 (1100)
        search_word = 4'b1100;
        #40;

        // Test 4: Search for 1 (0001)
        search_word = 4'b0001;
        #40;

        // Test mode ON
        test_mode = 1;
        #40;

        // Test mode OFF
        test_mode = 0;
        #40;

        #100;
        $finish;
    end

endmodule
