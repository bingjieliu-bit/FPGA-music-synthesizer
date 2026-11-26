
`timescale 1ns/1ps

module tb_sawtooth_generator;

    reg [31:0] phase;
    wire signed [15:0] sawtooth_wave;

    integer i;

    // Instantiate sine generator directly
    sawtooth_generator uut (
        .phase(phase),
        .sawtooth_wave(sawtooth_wave)
    );

    initial begin

        $display("Starting Saw Wave Simulation");
        $display("Time(ns)\tPhase\t\tAddress\tOutput");

        // Start at phase zero
        phase = 32'd0;

        // Sweep through all 1024 ROM addresses
        for (i = 0; i < 1024; i = i + 1) begin

            phase = i * 4194304; // 2^22
            #10;

            $display("%0t\t%h\t%0d\t%0d",
                     $time,
                     phase,
                     phase[31:22],
                     sawtooth_wave);

        end

        $display("Saw Wave Simulation Complete");



    end

endmodule
