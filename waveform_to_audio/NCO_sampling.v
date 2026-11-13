module nco (
    input wire clk,
    input wire reset,
    input wire sample_tick,

    input wire [31:0] phase_increment,

    output reg [31:0] phase
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            phase <= 32'd0;

        else if (sample_tick)
            phase <= phase + phase_increment;

    end

endmodule

module audio_sample_tick(clk,reset,sample_tick);
	input clk;
	input reset;
	output reg sample_tick;
	
	reg [25:0] large_counter;
	always @(posedge clk, posedge reset)
		begin
			if(reset) begin
				large_counter<=26'd0;
				sample_tick<=1'b0;
			end
			 else begin

            if (accumulator >= 26'd49952000) begin

                accumulator <= accumulator
                             + 26'd48000
                             - 26'd50000000;

                sample_tick <= 1'b1;

            end

            else begin

                accumulator <= accumulator + 26'd48000;

                sample_tick <= 1'b0;

            end

        end
    end

		
endmodule




module frequency_to_phase (
    input  wire [9:0] frequency,
    output wire [31:0] phase_increment
);

    // For a 48 kHz sample rate:
    // 2^32 / 48000 = 89478.4853 approximately

    assign phase_increment = frequency * 32'd89478;

endmodule