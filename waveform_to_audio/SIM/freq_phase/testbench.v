`timescale 1ns/1ps

module testbench;

    reg  [9:0] frequency;
    wire [31:0] phase_increment;

    frequency_to_phase dut (
        .frequency(frequency),
        .phase_increment(phase_increment)
    );

    initial begin
        frequency = 10'd0;
        #20 frequency = 10'd1;
        #20 frequency = 10'd2;
        #20 frequency = 10'd100;
        #20 frequency = 10'd440;
        #20 frequency = 10'd1000;
        #20 frequency = 10'd1023;
        #20 $finish;
    end

endmodule
