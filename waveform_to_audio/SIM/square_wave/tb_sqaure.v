
`timescale 1ns/1ps

module tb_sqaure;

    reg  [31:0] phase;
    wire [15:0] square_wave;

    square_generator dut (
        .phase(phase),
        .square_wave(square_wave)
    );

    initial begin
        phase = 32'h00000000;

        #2 phase = 32'h7FFFFFFF;
        #2 phase = 32'h80000000;
        #2 phase = 32'hFFFFFFFF;
        #2 phase = 32'h00000001;
        #2 phase = 32'h80000001;
        #10;

    end

endmodule
