`timescale 1ns/1ps

module testbench;

    reg CLOCK_50;
    reg reset;
    wire sample_tick;

    audio_sample_tick dut (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .sample_tick(sample_tick)
    );

    // 50 MHz clock: 20 ns period
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Reset, then run long enough to observe several pulses.
    initial begin
        reset = 1'b1;
        #60;
        reset = 1'b0;

        // With terminal counts 4, 4, and 3, pulses repeat
        // every 5, 5, and 4 clock cycles.
        #1000;
        $finish;
    end

endmodule

