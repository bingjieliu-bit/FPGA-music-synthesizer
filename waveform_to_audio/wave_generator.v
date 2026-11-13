
module wave_generator(phase, wave_selector,wave_out);
	input [31:0] phase;
	input [1:0] wave_selector;
	output reg [15:0] wave_out;
	
	wire [15:0] sine_wave;
	wire [15:0] square_wave;
	always @(*)
		begin
		case(wave_selector)
			2'b00:wave_out = sqaure_wave;
			2'b01:wave_out= sin_wave;
			
			default:wave_out = 16'sd0;
		endcase
		end
	
endmodule

module sine_generator(phase,sine_wave);
	input [31:0] phase;
	output reg [15:0] sine_wave;
	
	reg signed [15:0] sine_rom[0:1023];
	initial begin
		$readmemh("sine1024.hex",sine_rom);
	end
	
	wire [9:0] address;
	assign address = phase[31:22];
	assign sine_wave = sin_rom[address];
endmodule

module sqaure_generator(phase,square_wave);
	input [31:0] phase;
	output reg [15:0]square_wave;
	assign square_wave = phase[31] ? 16'sd32767:-16'sd32768;
	
endmodule
	

