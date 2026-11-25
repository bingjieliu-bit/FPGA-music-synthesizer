
`timescale 1ns/1ps

module testbench;

    reg CLOCK_50;
    reg reset;
    reg sample_tick;
    reg [2:0] drum_trigger;

    wire signed [15:0] kick_wave;
    wire signed [15:0] snare_wave;
    wire signed [15:0] hihat_wave;

    wire kick_active;
    wire snare_active;
    wire hihat_active;

    // Kick
    drum D0 (
        CLOCK_50, reset, sample_tick,
        drum_trigger[0], 2'd0,
        kick_wave, kick_active
    );

    // Snare
    drum D1 (
        CLOCK_50, reset, sample_tick,
        drum_trigger[1], 2'd1,
        snare_wave, snare_active
    );

    // Hi-hat
    drum D2 (
        CLOCK_50, reset, sample_tick,
        drum_trigger[2], 2'd2,
        hihat_wave, hihat_active
    );

    // 50 MHz clock
    always #10 CLOCK_50 = ~CLOCK_50;

    // Faster sample tick for simulation
    reg [3:0] counter;

    always @(posedge CLOCK_50) begin
        if (reset)
            counter <= 4'd0;
        else if (counter == 4'd9)
            counter <= 4'd0;
        else
            counter <= counter + 1'b1;
    end

    always @(*) begin
        sample_tick = (counter == 4'd9);
    end

    initial begin
        CLOCK_50 = 0;
        reset = 1;
        drum_trigger = 3'b000;

        #100;
        reset = 0;

        // Trigger kick
        #100;
        drum_trigger[0] = 1;
        #20;
        drum_trigger[0] = 0;

        // Trigger snare
        #1000;
        drum_trigger[1] = 1;
        #20;
        drum_trigger[1] = 0;

        // Trigger hi-hat
        #1000;
        drum_trigger[2] = 1;
        #20;
        drum_trigger[2] = 0;

        // Allow samples to play
        #5000000;

        $stop;
    end

endmodule
