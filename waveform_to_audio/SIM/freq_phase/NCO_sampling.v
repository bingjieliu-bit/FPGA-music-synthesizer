

module frequency_to_phase (frequency, phase_increment);
    input [9:0] frequency;
    output [31:0] phase_increment;


    // For a 48 kHz sample rate:
    // 2^32 / 48000 = 89478.4853 approximately

    assign phase_increment = frequency * 32'd89478;

endmodule
