`timescale 1ns/1ps

module testbench;
    reg CLOCK_50;
    reg reset;
    reg sample_tick;
    reg [31:0] phase_increment;
    wire [31:0] phase;

    nco dut (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .sample_tick(sample_tick),
        .phase_increment(phase_increment),
        .phase(phase)
    );

    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        reset = 1;
        sample_tick = 0;
        phase_increment = 32'd100;
        #40 reset = 0;
        #20 sample_tick = 1;
        #20 sample_tick = 0;
        #60 sample_tick = 1;
        #20 sample_tick = 0;
        #60 sample_tick = 1;
        #20 sample_tick = 0;
        #40 phase_increment = 32'd200;
        #20 sample_tick = 1;
        #20 sample_tick = 0;
        #60 sample_tick = 1;
        #20 sample_tick = 0;
        #100 $finish;
    end
endmodule
