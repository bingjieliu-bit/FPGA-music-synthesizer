

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
					if (accumulator == 11'd3) begin
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
					if(accumulator == 11'd4) begin
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

