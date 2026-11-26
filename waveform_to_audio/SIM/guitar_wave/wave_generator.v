
module guitar_generator(phase,guitar_wave);
	input [31:0] phase;
	output signed [15:0] guitar_wave;
	
	reg signed [15:0] guitar_rom[0:1023];
	initial begin
		$readmemh("guitar1024.hex",guitar_rom);
	end
	
	wire [9:0] address;
	assign address = phase[31:22];
	assign guitar_wave = guitar_rom[address];
endmodule
