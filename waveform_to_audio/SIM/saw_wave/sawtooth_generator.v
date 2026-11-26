module sawtooth_generator(phase, sawtooth_wave);
    input [31:0] phase;
    output signed [15:0] sawtooth_wave;

    wire [14:0] ramp;
    assign ramp = phase[30:16];

    assign sawtooth_wave = phase[31] ? (-16'sd32767 + $signed({1'b0, ramp})) : $signed({1'b0, ramp});
                            
endmodule