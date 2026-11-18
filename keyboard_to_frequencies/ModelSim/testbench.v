`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg [7:0] key_data;
    reg new_key;
    reg [1:0] octave;

    wire [11:0] notes_active;
    wire [119:0] frequencies;

    // Instantiate keyboard-to-notes module
    keyboard_to_notes uut1 (
        .clk(clk),
        .reset(reset),
        .key_data(key_data),
        .new_key(new_key),
        .notes_active(notes_active)
    );

    // Instantiate notes-to-frequency module
    notes_to_frequency uut2 (
        .notes_active(notes_active),
        .octave(octave),
        .frequencies(frequencies)
    );

    // 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    // Simulate receiving one scan code
    task send_key;
        input [7:0] code;
        begin
            @(negedge clk);
            key_data = code;
            new_key = 1;

            @(negedge clk);
            new_key = 0;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        key_data = 0;
        new_key = 0;
        octave = 2'b00;

        // Reset
        #40;
        reset = 0;

        // Press A (C4 = 262 Hz)
        send_key(8'h1C);
        #40;

        // Press W (C#4 = 277 Hz)
        // Both C and C# should be active
        send_key(8'h1D);
        #40;

        // Release A
        send_key(8'hF0);
        send_key(8'h1C);
        #40;

        // Change octave to C5
        octave = 2'b10;
        #40;

        // Change octave to C3
        octave = 2'b01;
        #40;

        // Return to C4
        octave = 2'b00;
        #40;

        // Release W
        send_key(8'hF0);
        send_key(8'h1D);
        #40;

        $stop;
    end

endmodule