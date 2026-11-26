module vga_demo (
    input wire CLOCK_50,
    input wire Resetn,
    input wire [11:0] notes,
    input wire [2:0] waveform_sele,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS,
    output wire VGA_BLANK_N,
    output wire VGA_SYNC_N,
    output wire VGA_CLK
);

    wire [9:0] note_x, wave_x;
    wire [8:0] note_y, wave_y;
    wire [8:0] note_color, wave_color;
    wire note_active, wave_active;

    wire [9:0] draw_x;
    wire [8:0] draw_y;
    wire [8:0] draw_color;
    wire draw_write;

    note_draw ND (
        .Clock(CLOCK_50),
        .Resetn(Resetn),
        .notes(notes),
        .VGA_x(note_x),
        .VGA_y(note_y),
        .VGA_color(note_color),
        .scan_active(note_active)
    );

    waveform_draw WD (
        .Clock(CLOCK_50),
        .Resetn(Resetn),
        .waveform(waveform_sele),
        .VGA_x(wave_x),
        .VGA_y(wave_y),
        .VGA_color(wave_color),
        .scan_active(wave_active)
    );

    assign draw_x     = note_active ? note_x : wave_x;
    assign draw_y     = note_active ? note_y : wave_y;
    assign draw_color = note_active ? note_color : wave_color;
    assign draw_write = note_active | wave_active;

    vga_adapter VGA (
        .resetn(Resetn),
        .clock(CLOCK_50),
        .color(draw_color),
        .x(draw_x),
        .y(draw_y),
        .write(draw_write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.BACKGROUND_IMAGE = "./MIF/bmp_640_9.mif";
endmodule

//waveform draw
module waveform_draw (Clock, Resetn, waveform, VGA_x,VGA_y,VGA_color,scan_active);
    input Clock;
    input Resetn;
    input [2:0] waveform;
    output reg [9:0] VGA_x;
    output reg [8:0] VGA_y;
    output reg [8:0] VGA_color;
    output reg scan_active;


    localparam BAR_BACKGROUND = 9'b000_000_000;
	 
	reg [2:0] displayed_selection;
	reg [2:0] desired_selection;
	
		//reset 
    always @(posedge Clock) begin
    if (!Resetn)
        desired_selection <= 3'b0;
    else
        desired_selection <= waveform+3'b001;
    end

    

    reg scan_restore;
    reg [2:0] scan_id;
    reg [5:0] XC;//counterX
    reg [4:0] YC;//counterY
    reg [5:0] scan_width;
    reg [4:0] scan_height;
    reg selection_is_circle;

    reg [9:0] selection_x;
    reg [8:0] selection_y;
    always @(*) begin
        selection_x = 10'd0;
        selection_y = 9'd0;
        scan_width = 6'd60; //for basic waves
        scan_height = 5'd10;
        selection_is_circle = 1'b0;
        case (scan_id)
            3'd1: begin selection_x=10'd390; selection_y=9'd28; end // Square
            3'd2: begin selection_x=10'd308; selection_y=9'd28; end // Sine
            3'd3: begin selection_x=10'd554; selection_y=9'd28; end // Triangle
            3'd4: begin selection_x=10'd472; selection_y=9'd28; end // Saw
            3'd5: begin selection_x=10'd426; selection_y=9'd118; scan_width=6'd22; scan_height=5'd22; selection_is_circle=1'b1; end // Piano
            3'd6: begin selection_x=10'd594; selection_y=9'd118; scan_width=6'd22; scan_height=5'd22; selection_is_circle=1'b1; end // Guitar
            default: begin selection_x=10'd0; selection_y=9'd0; end
        endcase
    end


    wire [8:0] circle_address = (YC * 22) + XC;
    wire [8:0] circle_color, background_color;
    obj_circle22_mem CROM (.address(circle_address), .clock(Clock), .q(circle_color));
    background_mem BROM (.address(circle_address), .clock(Clock), .q(background_color));
	


    reg [8:0] pixel_color;

    always @(*) begin
        VGA_x = 10'd0;
        VGA_y = 9'd0;
        VGA_color = 9'd0;
        pixel_color = 9'd0;

        if (scan_active) begin
            VGA_x = selection_x + XC;
            VGA_y = selection_y + YC;

            if (selection_is_circle) begin
                if (scan_restore) begin
                    pixel_color = background_color;
                end 
					 else begin
                    pixel_color = circle_color;
                end
            end 
				else begin
                if (scan_restore) begin
                    pixel_color = BAR_BACKGROUND;
                end 
					 else begin
                    pixel_color = 9'b011_111_011;//green(109, 255, 109)
                end
            end

            VGA_color = pixel_color;
        end
    end


  
    
    // Waveform scan FSM
    always @(posedge Clock) begin
        if (!Resetn) begin
            scan_active <= 1'b0;
            scan_restore <= 1'b0;
            scan_id <= 3'd0;
            XC <= 6'd0;
            YC <= 5'd0;
            displayed_selection <= 3'd0;
        end else begin
            if (!scan_active) begin
                XC <= 6'd0;
                YC <= 5'd0;

                if (displayed_selection != desired_selection) begin
                    if (displayed_selection != 0) begin
                        scan_id <= displayed_selection;
                        scan_restore <= 1'b1; // erase old selector
                    end 
						  else if (desired_selection != 0) begin
                        scan_id <= desired_selection;
                        scan_restore <= 1'b0; // draw new selector
                    end

                    scan_active <= 1'b1;
                end
            end 
				else begin
                if ((XC == scan_width-1) &&(YC == scan_height-1)) begin

                    scan_active <= 1'b0;
                    XC <= 6'd0;
                    YC <= 5'd0;

                    if (scan_restore)
                        displayed_selection <= 3'd0;
                    else
                        displayed_selection <= scan_id;

                end 
					 else if (XC == scan_width-1) begin
                    XC <= 6'd0;
                    YC <= YC + 1'b1;
                end 
					 else begin
                    XC <= XC + 1'b1;
                end
            end
        end
    end

endmodule

//note draw
module note_draw (Clock, Resetn, notes, VGA_x, VGA_y, VGA_color,scan_active);
    input Clock;
    input Resetn;
    input [11:0] notes;
    output reg [9:0] VGA_x;
    output reg [8:0] VGA_y;
    output reg [8:0] VGA_color;
    output reg scan_active;

  
    localparam WHITE_KEY_BACKGROUND = 9'b011_011_100;
	
	 
    reg [11:0] displayed_notes;
    reg [11:0] desired_notes;
    always @(posedge Clock) begin
        if (!Resetn) begin
            desired_notes <= 12'b0;
        end else begin
            desired_notes <= notes;
        end
    end



    reg scan_restore;
    reg [3:0] scan_id;
    reg [5:0] XC;
    reg [4:0] YC;

    reg note_mismatch;
    reg [3:0] next_note;
    always @(*) begin
        note_mismatch = 1'b1;
        next_note = 4'd0;
        if      (desired_notes[0]  != displayed_notes[0])  next_note = 4'd0;
        else if (desired_notes[1]  != displayed_notes[1])  next_note = 4'd1;
        else if (desired_notes[2]  != displayed_notes[2])  next_note = 4'd2;
        else if (desired_notes[3]  != displayed_notes[3])  next_note = 4'd3;
        else if (desired_notes[4]  != displayed_notes[4])  next_note = 4'd4;
        else if (desired_notes[5]  != displayed_notes[5])  next_note = 4'd5;
        else if (desired_notes[6]  != displayed_notes[6])  next_note = 4'd6;
        else if (desired_notes[7]  != displayed_notes[7])  next_note = 4'd7;
        else if (desired_notes[8]  != displayed_notes[8])  next_note = 4'd8;
        else if (desired_notes[9]  != displayed_notes[9])  next_note = 4'd9;
        else if (desired_notes[10] != displayed_notes[10]) next_note = 4'd10;
        else if (desired_notes[11] != displayed_notes[11]) next_note = 4'd11;
        else note_mismatch = 1'b0;
    end

    reg [9:0] note_x;
    reg [8:0] note_y;
    reg note_is_black;
    wire [5:0] note_width = note_is_black ? 6'd22 : 6'd44;
    wire [4:0] note_height = note_is_black ? 5'd22 : 5'd20;
    always @(*) begin
        note_x = 10'd18;
        note_y = 9'd394;
        note_is_black = 1'b0;
        case (scan_id)
            4'd0:  begin note_x=10'd18;  note_is_black=0; end // C
            4'd1:  begin note_x=10'd70;  note_y=9'd346; note_is_black=1; end // C#
            4'd2:  begin note_x=10'd98;  note_is_black=0; end // D
            4'd3:  begin note_x=10'd150; note_y=9'd346; note_is_black=1; end // D#
            4'd4:  begin note_x=10'd178;  note_is_black=0; end // E
            4'd5:  begin note_x=10'd258;  note_is_black=0; end // F
            4'd6:  begin note_x=10'd310; note_y=9'd346; note_is_black=1; end // F#
            4'd7:  begin note_x=10'd338;  note_is_black=0; end // G
            4'd8:  begin note_x=10'd390; note_y=9'd346; note_is_black=1; end // G#
            4'd9:  begin note_x=10'd418;  note_is_black=0; end // A
            4'd10: begin note_x=10'd470; note_y=9'd346; note_is_black=1; end // A#
            4'd11: begin note_x=10'd498;  note_is_black=0; end // B
            default: begin note_x=10'd18; note_y=9'd394; note_is_black=0; end
        endcase
    end


    wire [8:0] circle_address = (YC * 22) + XC;
    wire [9:0] rect44_address = (YC * 44) + XC;
    wire [8:0] circle_color, rect44_color, background_color;
    obj_circle22_mem CROM (.address(circle_address), .clock(Clock), .q(circle_color));
    obj_rect44x20_mem RROM (.address(rect44_address), .clock(Clock), .q(rect44_color));
    background_mem BROM (.address(circle_address), .clock(Clock), .q(background_color));

	reg [8:0] pixel_color;

	always @(*) begin
		 VGA_x = 10'd0;
		 VGA_y = 9'd0;
		 VGA_color = 9'd0;
		 pixel_color = 9'd0;

		 if (scan_active) begin
			  VGA_x = note_x + XC;
			  VGA_y = note_y + YC;

			  if (note_is_black) begin
					if (scan_restore)
						 pixel_color = background_color;
					else
						 pixel_color = circle_color;
			  end
			  else begin
					if (scan_restore)
						 pixel_color = WHITE_KEY_BACKGROUND;
					else
						 pixel_color = rect44_color;
			  end

			  VGA_color = pixel_color;
		 end
	end

	//FSM
    always @(posedge Clock) begin
        if (!Resetn) begin
            scan_active <= 1'b0;
            scan_restore <= 1'b0;
            scan_id <= 4'd0;
            XC <= 6'd0;
            YC <= 5'd0;
            displayed_notes <= 12'b0;
        end 
		  else begin
            if (!scan_active) begin
                XC <= 6'd0;
                YC <= 5'd0;
                if (note_mismatch) begin
                    scan_id <= next_note;
                    scan_restore <= ~desired_notes[next_note];
                    scan_active <= 1'b1;
                end
            end 
				else begin
                if ((XC == note_width-1) && (YC == note_height-1)) begin
                    scan_active <= 1'b0;
                    XC <= 6'd0;
                    YC <= 5'd0;
                    displayed_notes[scan_id] <= ~scan_restore;
                end 
					 else if (XC == note_width-1) begin
                    XC <= 6'd0;
                    YC <= YC + 1'b1;
                end 
					 else begin
                    XC <= XC + 1'b1;
                end
            end
        end
    end
endmodule
