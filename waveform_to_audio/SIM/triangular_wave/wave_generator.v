
module triangle_generator(phase, triangle_wave);
    input [31:0] phase;
    output reg signed [15:0] triangle_wave;

    wire [14:0] ramp;
    assign ramp = phase[29:15];

    always @(*) begin
        case (phase[31:30])
            2'b00: triangle_wave =  $signed({1'b0, ramp});        // 0 -> +32767
            2'b01: triangle_wave =  16'sd32767 - $signed({1'b0, ramp}); // +32767 -> 0
            2'b10: triangle_wave = -$signed({1'b0, ramp});         // 0 -> -32767
            2'b11: triangle_wave = -16'sd32767 + $signed({1'b0, ramp}); // -32767 -> 0
        endcase
    end
endmodule
