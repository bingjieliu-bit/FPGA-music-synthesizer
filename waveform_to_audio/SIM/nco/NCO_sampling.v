module nco (CLOCK_50, reset, sample_tick, phase_increment, phase);
    input CLOCK_50;
    input reset;
    input sample_tick;

    input [31:0] phase_increment;

    output reg [31:0] phase;

    always @(posedge CLOCK_50, posedge reset) begin

        if (reset)
            phase <= 32'd0;

        else if (sample_tick)
            phase <= phase + phase_increment;

    end

endmodule
