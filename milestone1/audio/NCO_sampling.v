module nco (CLOCK_50, reset, sample_tick, phase_increment, phase);
    input CLOCK_50;
    input reset;
    input sample_tick;

    input [31:0] phase_increment;

    output reg [31:0] phase;

    always @(posedge CLOCK_50, posedge reset) begin

        if (reset)
            phase <= 32'd0;

        else if (sample_tick)
            phase <= phase + phase_increment;

    end

endmodule

module audio_sample_tick(CLOCK_50,reset,sample_tick);
	input CLOCK_50;
	input reset;
	output reg sample_tick;
	
	reg [10:0] accumulator;
	reg [1:0] count;
	always @(posedge CLOCK_50, posedge reset)
		begin
			if(reset) begin
				accumulator<=11'd0;
				sample_tick<=1'b0;
				count<=2'd0;
			end
			 else begin
				sample_tick<=1'b0;
				if (count ==2'd2) begin
				//the cycle of 1041
					if (accumulator == 11'd1040) begin
						accumulator <=11'd0;
						count<=2'd0;
						sample_tick <=1'b1;

					end

					else begin
						accumulator <=accumulator +11'd1;
					end
				end
				else begin
				//First and second interval
					if(accumulator == 11'd1041) begin
						accumulator <=11'd0;
						count<=count+2'd1;
						sample_tick<=1'b1;
					end
					else begin
						accumulator <=accumulator +11'd1;
					end
				end
        end
    end

		
endmodule




module frequency_to_phase (frequency, phase_increment);
    input [9:0] frequency;
    output [31:0] phase_increment;


    // For a 48 kHz sample rate:
    // 2^32 / 48000 = 89478.4853 approximately

    assign phase_increment = frequency * 32'd89478;

endmodule
