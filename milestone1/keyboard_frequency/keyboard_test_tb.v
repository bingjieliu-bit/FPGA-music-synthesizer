
`timescale 1ns/1ps

module keyboard_test_tb;

    reg clk;
    reg reset;
    reg [7:0] key_data;
    reg new_key;
    wire [11:0] notes_active;

    keyboard_to_notes dut (
        clk,
        reset,
        key_data,
        new_key,
        notes_active
    );

    // Simulate 50 MHz clock
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        key_data = 0;
        new_key = 0;

        #20 reset = 0;

        // Press A (C)
        #20 key_data = 8'h1C;
        new_key = 1;
        #20 new_key = 0;

        // Press D (E)
        #20 key_data = 8'h23;
        new_key = 1;
        #20 new_key = 0;

        // Release A
        #20 key_data = 8'hF0;
        new_key = 1;
        #20 new_key = 0;

        #20 key_data = 8'h1C;
        new_key = 1;
        #20 new_key = 0;

        #100 $stop;
    end

endmodule
