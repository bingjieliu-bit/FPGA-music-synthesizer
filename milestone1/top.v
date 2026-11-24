module top(CLOCK_50, KEY, SW, PS2_CLK, PS2_DAT,
					LEDR, HEX0, HEX1, HEX2, AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK, AUD_ADCDAT,AUD_XCK,
	FPGA_I2C_SDAT,

	AUD_DACDAT,

	FPGA_I2C_SCLK, 
   VGA_R,
 VGA_G,
  VGA_B,
VGA_HS,
 VGA_VS,
VGA_BLANK_N,
 VGA_SYNC_N,
 VGA_CLK);
   input CLOCK_50;
	input [0:0] KEY;
	input [4:0] SW;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	output [6:0] HEX0, HEX1, HEX2;
	output [9:0] LEDR;

	wire [119:0] freq_data; // 12 note * 10 bit
	wire [11:0] active_note;
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

    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;

keyboard_to_frequency K0(CLOCK_50, KEY, SW[4:3], PS2_CLK, PS2_DAT,
					LEDR, HEX0, HEX1, HEX2,active_note, freq_data);
audio A0(
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
	SW[2:0],
	freq_data
);


vga_demo V0(
		CLOCK_50,
    KEY[0],
    active_note,
    SW[2:0],

   VGA_R,
 VGA_G,
 VGA_B,
VGA_HS,
 VGA_VS,
VGA_BLANK_N,
 VGA_SYNC_N,
 VGA_CLK
);
endmodule
