module drum (
    input CLOCK_50,
    input reset,
    input sample_tick,
    input drum_trigger,
    input [1:0] drum_type, // 0 = kick, 1 = snare, 2 = hihat
    output signed [15:0] drum_wave,
    output drum_active
);

    // Store WAV samples
    reg signed [15:0] kick_rom [0:23784];
    reg signed [15:0] snare_rom [0:23999];
    reg signed [15:0] hihat_rom [0:23999];

    initial begin
        $readmemh("kick.hex", kick_rom);
        $readmemh("snare.hex", snare_rom);
        $readmemh("hihat.hex", hihat_rom);
    end

    // Playback control
    reg [14:0] sample_index;
    reg playing;
    reg signed [15:0] sample_out;

    always @(posedge CLOCK_50) begin
        if (reset) begin
            sample_index <= 15'd0;
            playing <= 1'b0;
            sample_out <= 16'sd0;
        end

        else if (drum_trigger) begin
            sample_index <= 15'd0;
            playing <= 1'b1;
            sample_out <= 16'sd0;
        end

        else if (sample_tick) begin
            if (playing) begin
                case (drum_type)
                    2'd0: sample_out <= kick_rom[sample_index];
                    2'd1: sample_out <= snare_rom[sample_index];
                    2'd2: sample_out <= hihat_rom[sample_index];
                    default: sample_out <= 16'sd0;
                endcase

					if ((drum_type == 2'd0 && sample_index == 15'd23784) ||
						 (drum_type == 2'd1 && sample_index == 15'd23999) ||
						 (drum_type == 2'd2 && sample_index == 15'd23999))
						 playing <= 1'b0;
					else
						 sample_index <= sample_index + 1'b1;
            end
            else
                sample_out <= 16'sd0;
        end
    end

    assign drum_wave = sample_out;
    assign drum_active = playing;

endmodule

