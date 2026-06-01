
`timescale 1ns/1ps

module cam #(parameter N = 16)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  test_mode,
    input  wire [3:0]            search_word,
    output reg                   match_found,
    output reg [$clog2(N)-1:0]   match_index
);
    // Memory: N words of 4 bits
    reg [3:0] mem [0:N-1];
    // Pipeline registers for the search word (K = 4 stages)
    reg [3:0] s0, s1, s2, s3;
    // Match vector
    reg [N-1:0] match_vector;
    integer i;
    
  
    initial begin
        for (i = 0; i < N; i = i + 1)
            mem[i] = i[3:0];   // store 0,1,2,... in the CAM
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            s0 <= 0;
            s1 <= 0;
            s2 <= 0;
            s3 <= 0;
            match_vector <= 0;
            match_found <= 0;
            match_index <= 0;
        end
        else begin
            // Pipeline the search word (4 stages)
            s0 <= search_word;
            s1 <= s0;
            s2 <= s1;
            s3 <= s2;
            
            // Test mode
            if (test_mode) begin
                match_vector <= { {(N-1){1'b0}}, 1'b1 };
                match_found  <= 1'b1;
                match_index  <= 0;
            end
            else begin
                
                for (i = 0; i < N; i = i + 1) begin
                    match_vector[i] <= (mem[i] == s3);
                end
                
                // Match detection
                match_found <= |match_vector;
                
                
                match_index <= 0;  
                for (i = N-1; i >= 0; i = i - 1) begin
                    if (match_vector[i])
                        match_index <= i[$clog2(N)-1:0];
                end
            end
        end
    end
endmodule
