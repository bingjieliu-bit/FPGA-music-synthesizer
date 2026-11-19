module square_generator(phase,square_wave);
	input [31:0] phase;
	 output signed [15:0] square_wave;

	assign square_wave = phase[31] ? -16'sd23170 : 16'sd23170;

	
endmodule