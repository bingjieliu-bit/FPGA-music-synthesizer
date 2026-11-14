
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
	SW,
	multi_frequency
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
input		[3:0]	SW;
input   [119:0] multi_frequency;
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
 
//test_frequency
wire [9:0] frequency;
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
assign frequency = multi_frequency[9:0];

//frequency to phase
	wire [31:0] phase_increment;
	
	frequency_to_phase F0(
		.frequency(frequency), 
		.phase_increment(phase_increment)
	);

//audio sample timing
  wire sample_tick;
  audio_sample_tick T0(
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.sample_tick(sample_tick)
	);

//NCO
wire [31:0] phase;
 nco N0(
	.CLOCK_50(CLOCK_50),
	.reset(reset),
	.sample_tick(audio_sample_enable),
	.phase_increment(phase_increment),
	.phase(phase)
);

//waveform generator
wire signed [15:0] wave_out;

wave_generator W0(
	.phase(phase), 
	.wave_selector(SW[1:0]),
	.wave_out(wave_out)
);

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
                    {wave_out, 16'b0};

                right_channel_audio_out <=
                    {wave_out, 16'b0};

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
