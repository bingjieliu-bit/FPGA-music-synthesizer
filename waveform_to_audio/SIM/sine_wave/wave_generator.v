
module sine_generator(phase,sine_wave);
	input [31:0] phase;
	output signed [15:0] sine_wave;
	
	reg signed [15:0] sine_rom[0:1023];
	initial begin
		$readmemh("sine1024.hex",sine_rom);
	end
	
	wire [9:0] address;
	assign address = phase[31:22];
	assign sine_wave = sine_rom[address];
endmodule
