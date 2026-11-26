
module piano_generator(phase,piano_wave);
	input [31:0] phase;
	output signed [15:0] piano_wave;
	
	reg signed [15:0] piano_rom[0:1023];
	initial begin
		$readmemh("piano1024.hex",piano_rom);
	end
	
	wire [9:0] address;
	assign address = phase[31:22];
	assign piano_wave = piano_rom[address];
endmodule