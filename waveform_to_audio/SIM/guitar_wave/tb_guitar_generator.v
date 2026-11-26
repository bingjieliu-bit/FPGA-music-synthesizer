
`timescale 1ns/1ps

module tb_guitar_generator;

    reg [31:0] phase;
    wire signed [15:0] guitar_wave;

    integer i;

    // Instantiate guitar generator directly
    guitar_generator uut (
        .phase(phase),
        .guitar_wave(guitar_wave)
    );

    initial begin

        $display("Starting Guitar Generator Simulation");
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
                     guitar_wave);

        end

        $display("Guitar Generator Simulation Complete");



    end

endmodule
