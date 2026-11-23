
module wave_generator(phase, wave_selector,wave_out);
	input [31:0] phase;
	input [2:0] wave_selector;
	output reg signed [15:0] wave_out;
	
	wire signed [15:0] sine_wave;
	wire signed [15:0] square_wave;
	wire signed [15:0] triangle_wave;
	wire signed [15:0] saw_wave;
	wire signed [15:0] piano_wave;
	wire signed [15:0] guitar_wave;
	
	sine_generator G0(phase, sine_wave);
	square_generator G1(phase, square_wave);
	triangle_generator G2(phase, triangle_wave);
	sawtooth_generator G3(phase, saw_wave);
	piano_generator G4(phase,piano_wave);
	guitar_generator G5(phase,guitar_wave);
	
	always @(*)
		begin
		case(wave_selector)
			3'b000:wave_out = square_wave;
			3'b001:wave_out= sine_wave;
			3'b010:wave_out = triangle_wave;
			3'b011: wave_out = saw_wave;
			
			3'b100:wave_out = piano_wave;
			3'b101:wave_out=guitar_wave;
			
			default:wave_out = 16'sd0;
		endcase
		end
	
endmodule

/*reference: https://miscircuitos.com/sinus-wave-generation-with-verilog-using-vivado-for-a-fpga/
reference the idea of getting pre-calculated sine values and how to read from table"sine1024.hex"*/

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

module triangle_generator(phase, triangle_wave);
    input [31:0] phase;
    output signed [15:0] triangle_wave;

    wire [14:0] ramp;
    assign ramp = phase[29:15];

    always_comb begin
        case (phase[31:30])
            2'b00: triangle_wave =  $signed({1'b0, ramp});        // 0 -> +32767
            2'b01: triangle_wave =  16'sd32767 - $signed({1'b0, ramp}); // +32767 -> 0
            2'b10: triangle_wave = -$signed({1'b0, ramp});         // 0 -> -32767
            2'b11: triangle_wave = -16'sd32767 + $signed({1'b0, ramp}); // -32767 -> 0
        endcase
    end
endmodule

module sawtooth_generator(phase, sawtooth_wave);
    input [31:0] phase;
    output signed [15:0] sawtooth_wave;

    wire [14:0] ramp;
    assign ramp = phase[30:16];

    assign sawtooth_wave = phase[31] ? (-16'sd32767 + $signed({1'b0, ramp})) : $signed({1'b0, ramp});
                            
endmodule

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
