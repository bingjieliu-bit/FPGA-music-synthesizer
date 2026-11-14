
module audio (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	wave_selector,
	multi_f
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[2:0]	wave_selector;
input   [119:0] multi_f;
input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;


//reset
 wire reset;
 assign reset =~KEY[0];
 
//unpack frequency
wire [9:0] freq [0:11];

	assign freq[0]  = multi_f[9:0];
	assign freq[1]  = multi_f[19:10];
	assign freq[2]  = multi_f[29:20];
	assign freq[3]  = multi_f[39:30];
	assign freq[4]  = multi_f[49:40];
	assign freq[5]  = multi_f[59:50];
	assign freq[6]  = multi_f[69:60];
	assign freq[7]  = multi_f[79:70];
	assign freq[8]  = multi_f[89:80];
	assign freq[9]  = multi_f[99:90];
	assign freq[10] = multi_f[109:100];
	assign freq[11] = multi_f[119:110];

reg [3:0] active_count;

always @(*) begin
    active_count = 4'd0;

    if (freq[0]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[1]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[2]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[3]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[4]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[5]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[6]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[7]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[8]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[9]  != 10'd0) active_count = active_count + 4'd1;
    if (freq[10] != 10'd0) active_count = active_count + 4'd1;
    if (freq[11] != 10'd0) active_count = active_count + 4'd1;
end

/*
reg [9:0] selected_frequency;

always @(*) begin
    case (SW[3:2])
        2'b00: selected_frequency = 10'd262; // Do - C4
        2'b01: selected_frequency = 10'd294; // Re - D4
        2'b10: selected_frequency = 10'd330; // Mi - E4
        2'b11: selected_frequency = 10'd349; // Fa - F4
        default: selected_frequency = 10'd262;
    endcase
end
*/

//frequency to phase
	wire [31:0] phase_increment [0:11];
	
	frequency_to_phase F0(freq[0], phase_increment[0]);
	frequency_to_phase F1(freq[1], phase_increment[1]);
	frequency_to_phase F2(freq[2], phase_increment[2]);
	frequency_to_phase F3(freq[3], phase_increment[3]);
	frequency_to_phase F4(freq[4], phase_increment[4]);
	frequency_to_phase F5(freq[5], phase_increment[5]);
	frequency_to_phase F6(freq[6], phase_increment[6]);
	frequency_to_phase F7(freq[7], phase_increment[7]);
	frequency_to_phase F8(freq[8], phase_increment[8]);
	frequency_to_phase F9(freq[9], phase_increment[9]);
	frequency_to_phase F10(freq[10], phase_increment[10]);
	frequency_to_phase F11(freq[11], phase_increment[11]);
	


//audio sample timing
  wire sample_tick;
  audio_sample_tick T0(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.sample_tick(sample_tick)
	);

//NCO
	wire [31:0] phase[0:11];
	nco N0 (CLOCK_50, reset, audio_sample_enable, phase_increment[0], phase[0]);
	nco N1 (CLOCK_50, reset, audio_sample_enable, phase_increment[1], phase[1]);
	nco N2 (CLOCK_50, reset, audio_sample_enable, phase_increment[2], phase[2]);
	nco N3 (CLOCK_50, reset, audio_sample_enable, phase_increment[3], phase[3]);
	nco N4 (CLOCK_50, reset, audio_sample_enable, phase_increment[4], phase[4]);
	nco N5 (CLOCK_50, reset, audio_sample_enable, phase_increment[5], phase[5]);
	nco N6 (CLOCK_50, reset, audio_sample_enable, phase_increment[6], phase[6]);
	nco N7 (CLOCK_50, reset, audio_sample_enable, phase_increment[7], phase[7]);
	nco N8 (CLOCK_50, reset, audio_sample_enable, phase_increment[8], phase[8]);
	nco N9 (CLOCK_50, reset, audio_sample_enable, phase_increment[9], phase[9]);
	nco N10 (CLOCK_50, reset, audio_sample_enable, phase_increment[10], phase[10]);
	nco N11 (CLOCK_50, reset, audio_sample_enable, phase_increment[11], phase[11]);

//waveform generator
wire signed [15:0] raw_wave [0:11];
wire signed [15:0] wave_out [0:11];
	wave_generator W0(phase[0], wave_selector, raw_wave[0]);
	wave_generator W1(phase[1], wave_selector, raw_wave[1]);
	wave_generator W2(phase[2], wave_selector, raw_wave[2]);
	wave_generator W3(phase[3], wave_selector, raw_wave[3]);
	wave_generator W4(phase[4], wave_selector, raw_wave[4]);
	wave_generator W5(phase[5], wave_selector, raw_wave[5]);
	wave_generator W6(phase[6], wave_selector, raw_wave[6]);
	wave_generator W7(phase[7], wave_selector, raw_wave[7]);
	wave_generator W8(phase[8], wave_selector, raw_wave[8]);
	wave_generator W9(phase[9], wave_selector, raw_wave[9]);
	wave_generator W10(phase[10], wave_selector, raw_wave[10]);
	wave_generator W11(phase[11], wave_selector, raw_wave[11]);

	assign wave_out[0]  = (freq[0]  == 10'd0) ? 16'sd0 : raw_wave[0];
	assign wave_out[1]  = (freq[1]  == 10'd0) ? 16'sd0 : raw_wave[1];
	assign wave_out[2]  = (freq[2]  == 10'd0) ? 16'sd0 : raw_wave[2];
	assign wave_out[3]  = (freq[3]  == 10'd0) ? 16'sd0 : raw_wave[3];
	assign wave_out[4]  = (freq[4]  == 10'd0) ? 16'sd0 : raw_wave[4];
	assign wave_out[5]  = (freq[5]  == 10'd0) ? 16'sd0 : raw_wave[5];
	assign wave_out[6]  = (freq[6]  == 10'd0) ? 16'sd0 : raw_wave[6];
	assign wave_out[7]  = (freq[7]  == 10'd0) ? 16'sd0 : raw_wave[7];
	assign wave_out[8]  = (freq[8]  == 10'd0) ? 16'sd0 : raw_wave[8];
	assign wave_out[9]  = (freq[9]  == 10'd0) ? 16'sd0 : raw_wave[9];
	assign wave_out[10] = (freq[10] == 10'd0) ? 16'sd0 : raw_wave[10];
	assign wave_out[11] = (freq[11] == 10'd0) ? 16'sd0 : raw_wave[11];

wire signed [15:0] final_wave;
wave_adder WA0 (wave_out[0], wave_out[1], wave_out[2], wave_out[3],wave_out[4], wave_out[5], wave_out[6], wave_out[7],
					wave_out[8], wave_out[9], wave_out[10], wave_out[11],active_count,final_wave);

//audio controller signals
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
reg		[31:0]	left_channel_audio_out;
reg		[31:0]	right_channel_audio_out;
reg				write_audio_out;

assign read_audio_in =1'b0;

wire audio_sample_enable;
assign audio_sample_enable = sample_tick && audio_out_allowed;

// send waveforms samples to audio FIFO

 always @(posedge CLOCK_50 or posedge reset) begin

        if (reset) begin

            left_channel_audio_out <= 32'd0;
            right_channel_audio_out <= 32'd0;

            write_audio_out <= 1'b0;

        end

        else begin

            // Default: no write
            write_audio_out <= 1'b0;

            // New audio sample is ready
            // and output FIFO can accept it

            if (sample_tick && audio_out_allowed) begin

                // Put 16-bit sample in upper 16 bits

                left_channel_audio_out <=
                    {final_wave, 16'b0};

                right_channel_audio_out <=
                    {final_wave, 16'b0};

                // One-cycle write pulse
                write_audio_out <= 1'b1;

            end

        end

    end



/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(1'b0),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(1'b0),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule
