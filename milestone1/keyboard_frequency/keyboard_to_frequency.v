
module keyboard_to_frequency( CLOCK_50, KEY, octave_select, PS2_CLK, PS2_DAT,
					LEDR, HEX0, HEX1, HEX2, freq_data);
	input CLOCK_50;
	input [0:0] KEY;
	input [1:0] octave_select;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	output [6:0] HEX0, HEX1, HEX2;
	output [9:0] LEDR;

	wire [7:0] received_data;
	wire received_data_en;
	wire [11:0] notes_active;
	output [119:0] freq_data; // 12 note * 10 bit

	// Read keyboard input
	PS2_Controller ps2 (
	  .CLOCK_50(CLOCK_50),
	  .reset(~KEY[0]),
	  .the_command(8'h00),
	  .send_command(1'b0),
	  .PS2_CLK(PS2_CLK),
	  .PS2_DAT(PS2_DAT),
	  .command_was_sent(),
	  .error_communication_timed_out(),
	  .received_data(received_data),
	  .received_data_en(received_data_en)
	);

	// Convert keyboard input into musical notes
	keyboard_to_notes keyboard (CLOCK_50, ~KEY[0],
		received_data,
		received_data_en,
		notes_active);

	notes_to_frequency frequencies (
		notes_active, octave_select ,freq_data
	);

	// Turn on LEDs for pressed keys
	assign LEDR = {
		notes_active[0],
		notes_active[1],
		notes_active[2],
		notes_active[3],
		notes_active[4],
		notes_active[5],
		notes_active[6],
		notes_active[7],
		notes_active[8],
		notes_active[9]
	};
	
	frequency_display display (
    notes_active,
    freq_data,
    HEX0, HEX1, HEX2);

endmodule




module keyboard_to_notes (clk,reset, key_data, new_key, notes_active);
    input clk;
    input reset;
    input [7:0] key_data; //which key is pressed or released
    input new_key; // whether new key has arrived
    output reg [11:0] notes_active;

    reg key_released;

    always @(posedge clk) begin
        if (reset) 
		  begin
            notes_active <= 12'b0;
            key_released <= 0;
        end
		  
        else if (new_key) begin

            // F0 means the next key is being released
            if (key_data == 8'hF0)
                key_released <= 1;

            else begin
                // 1 = key pressed, 0 = key released
                case (key_data)
                    8'h1C: notes_active[0]  <= ~key_released; // A = C
                    8'h1D: notes_active[1]  <= ~key_released; // W = C#
                    8'h1B: notes_active[2]  <= ~key_released; // S = D
                    8'h24: notes_active[3]  <= ~key_released; // E = D#
                    8'h23: notes_active[4]  <= ~key_released; // D = E
                    8'h2B: notes_active[5]  <= ~key_released; // F = F
                    8'h2C: notes_active[6]  <= ~key_released; // T = F#
                    8'h34: notes_active[7]  <= ~key_released; // G = G
                    8'h35: notes_active[8]  <= ~key_released; // Y = G#
                    8'h33: notes_active[9]  <= ~key_released; // H = A
                    8'h3C: notes_active[10] <= ~key_released; // U = A#
                    8'h3B: notes_active[11] <= ~key_released; // J = B
                    default: ;//Nothing
                endcase

                key_released <= 0;
            end
        end
    end

endmodule



module notes_to_frequency (notes_active, octave, frequencies);

	input [11:0] notes_active;
	input [1:0] octave;
	output reg [119:0] frequencies;

	reg [9:0] base_freq [0:11]; //12 frequency, 10 bits each
	integer i;

	always @(*) begin
		 base_freq[0]  = 262; // C4  = 261.63 Hz
		 base_freq[1]  = 277; // C#4 = 277.18 Hz
		 base_freq[2]  = 294; // D4  = 293.66 Hz
		 base_freq[3]  = 311; // D#4 = 311.13 Hz
		 base_freq[4]  = 330; // E4  = 329.63 Hz
		 base_freq[5]  = 349; // F4  = 349.23 Hz
		 base_freq[6]  = 370; // F#4 = 369.99 Hz
		 base_freq[7]  = 392; // G4  = 392.00 Hz
		 base_freq[8]  = 415; // G#4 = 415.30 Hz
		 base_freq[9]  = 440; // A4  = 440.00 Hz
		 base_freq[10] = 466; // A#4 = 466.16 Hz
		 base_freq[11] = 494; // B4  = 493.88 Hz

	for (i = 0; i < 12; i = i + 1) begin
		if (!notes_active[i])
			frequencies[i*10 +: 10] = 10'd0;
		else if (octave == 2'b10)
			frequencies[i*10 +: 10] = base_freq[i] << 1; //Double freq when SW3 = 1
		else if (octave == 2'b01)
			frequencies[i*10 +: 10] = base_freq[i] >> 1;//Half freq when SW2 = 1
		else
			frequencies[i*10 +: 10] = base_freq[i];
		end
	end

endmodule



module frequency_display (notes_active, frequencies, HEX0, HEX1, HEX2);

    input [11:0] notes_active;
    input [119:0] frequencies;
    output [6:0] HEX0, HEX1, HEX2;

    reg [9:0] display_freq;
    reg found;
    integer i;

    // Select the first pressed note
    always @(*) begin
        display_freq = 0;
        found = 0;

        for (i = 0; i < 12; i = i + 1) begin
            if (notes_active[i] && !found) begin
                display_freq = frequencies[i*10 +: 10];
                found = 1;
            end
        end
    end

    // Convert frequency into decimal digits
    wire [3:0] digit0, digit1, digit2;

    assign digit0 = display_freq % 10;
    assign digit1 = (display_freq / 10) % 10;
    assign digit2 = (display_freq / 100) % 10;

    // Display frequency
    seg7_display_hex h0(digit0, HEX0);
    seg7_display_hex h1(digit1, HEX1);
    seg7_display_hex h2(digit2, HEX2);

endmodule

module seg7_display_hex(x, h);
    input [3:0] x;
    output reg [6:0] h;

    always @(*) begin
        case (x)
            4'd0: h = ~(7'b0111111);
            4'd1: h = ~(7'b0000110);
            4'd2: h = ~(7'b1011011);
            4'd3: h = ~(7'b1001111);
            4'd4: h = ~(7'b1100110);
            4'd5: h = ~(7'b1101101);
            4'd6: h = ~(7'b1111101);
            4'd7: h = ~(7'b0000111);
            4'd8: h = ~(7'b1111111);
            4'd9: h = ~(7'b1101111);
            default: h = 7'b1111111;
        endcase
    end

endmodule


