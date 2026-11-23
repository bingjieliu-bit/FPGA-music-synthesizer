module drum (
    input CLOCK_50,
    input reset,
    input sample_tick,
    input kick_trigger,
    input [31:0] phase,
    output signed [15:0] drum_wave
);

    // Generate sine wave from phase
    wire signed [15:0] sine_wave;

    sine_generator S0 (
        .phase(phase),
        .sine_wave(sine_wave)
    );

    // Amplitude envelope
    reg [15:0] amplitude;

    always @(posedge CLOCK_50) begin
        if (reset)
            amplitude <= 16'd0;

        else if (kick_trigger)
            amplitude <= 16'd50000;

        else if (sample_tick) begin
            if (amplitude > 16'd8192)
                amplitude <= amplitude - (amplitude >> 13);
            else
                amplitude <= 16'd0;
        end
    end

    // Apply envelope to sine wave
    wire signed [32:0] scaled_wave;

    assign scaled_wave =
        $signed(sine_wave) * $signed({1'b0, amplitude});

    assign drum_wave = scaled_wave >>> 15;

endmodule