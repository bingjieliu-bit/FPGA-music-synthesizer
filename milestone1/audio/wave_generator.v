
module wave_generator(phase, wave_selector,wave_out);
	input [31:0] phase;
	input [2:0] wave_selector;
	output reg signed [15:0] wave_out;
	
	wire signed [15:0] sine_wave;
	wire signed [15:0] square_wave;
	sine_generator G0(phase, sine_wave);
	square_generator G1(phase, square_wave);
	always @(*)
		begin
		case(wave_selector)
			3'b000:wave_out = square_wave;
			3'b001:wave_out= sine_wave;
			
			default:wave_out = 16'sd0;
		endcase
		end
	
endmodule

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

module square_generator(phase,square_wave);
	input [31:0] phase;
	 output signed [15:0] square_wave;

	assign square_wave = phase[31] ? 16'sd23170 : -16'sd23170;

	
endmodule
	
module wave_adder (w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,count, final_wave);
	input signed [15:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11;
	input [3:0] count;
	output reg signed[15:0] final_wave;
	reg signed [19:0] sum;
	reg signed [19:0] divisor;
	always @(*) begin

		  
		 sum = {{4{w0[15]}},w0} +
				{{4{w1[15]}},w1} +
				{{4{w2[15]}},w2} +
				{{4{w3[15]}},w3} +
				{{4{w4[15]}},w4} +
				{{4{w5[15]}},w5} +
				{{4{w6[15]}},w6} +
				{{4{w7[15]}},w7} +
				{{4{w8[15]}},w8} +
				{{4{w9[15]}},w9} +
				{{4{w10[15]}},w10} +
				{{4{w11[15]}},w11};
			   divisor = {16'd0, count};
		   if (count != 4'd0)
            final_wave = sum / divisor;
        else
            final_wave = 16'sd0;

	end
endmodule
