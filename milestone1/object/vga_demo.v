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

    wire [9:0] draw_x;
    wire [8:0] draw_y;
    wire [8:0] draw_color;
    wire draw_write;

    circle_multi_drawer DRAWER (
        .Clock(CLOCK_50),
        .Resetn(Resetn),
        .notes(notes),
        .waveform(waveform_sele),
        .VGA_x(draw_x),
        .VGA_y(draw_y),
        .VGA_color(draw_color),
        .VGA_write(draw_write)
    );

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


module circle_multi_drawer (
    input wire Clock,
    input wire Resetn,
    input wire [11:0] notes,
    input wire [2:0] waveform,
    output reg [9:0] VGA_x,
    output reg [8:0] VGA_y,
    output reg [8:0] VGA_color,
    output reg VGA_write
);
    localparam TRANSPARENT = 9'h1FF;
    localparam WHITE_KEY_BACKGROUND = 9'b011_011_100; // RGB approx. 109,109,146 at 3 bits/channel
    localparam BAR_BACKGROUND = 9'h000;

    // Two-flop synchronizers for note inputs and waveform switch.
    reg [11:0] notes_meta, notes_sync;
    reg [2:0] wave_meta, wave_sync;
    always @(posedge Clock) begin
        if (!Resetn) begin
            notes_meta <= 12'b0;
            notes_sync <= 12'b0;
            wave_meta <= 3'b0;
            wave_sync <= 3'b0;
        end else begin
            notes_meta <= notes;
            notes_sync <= notes_meta;
            wave_meta <= waveform;
            wave_sync <= wave_meta;
        end
    end


    // notes[0:11] are C, C#, D, D#, E, F, F#, G, G#, A, A#, B.
    reg [11:0] displayed_notes;
    wire [11:0] desired_notes = notes_sync;
    reg [2:0] displayed_selection;
    reg [2:0] desired_selection;

    always @(*) begin
        case (wave_sync)
            3'b000: desired_selection = 3'd1; // Square
            3'b001: desired_selection = 3'd2; // Sine
            3'b010: desired_selection = 3'd3; // Triangle
            3'b011: desired_selection = 3'd4; // Saw
            3'b100: desired_selection = 3'd5; // Piano
            3'b101: desired_selection = 3'd6; // Guitar
            default: desired_selection = 3'd0; // No selection
        endcase
    end


    // Scan control: note object (0) or waveform selector (1).
    reg scan_active, scan_restore, scan_kind;
    reg [3:0] scan_id;       // note index 0..11; selector ID 1..6
    reg [5:0] XC;
    reg [4:0] YC;
    reg [5:0] scan_width;
    reg [4:0] scan_height;
    reg selection_is_circle;

    // Find first note bit whose desired/displayed state differs.
    reg note_mismatch;
    reg [3:0] next_note;
    integer k;
    always @(*) begin
        note_mismatch = 1'b0;
        next_note = 4'd0;
        for (k = 0; k < 12; k = k + 1) begin
            if (!note_mismatch && (desired_notes[k] != displayed_notes[k])) begin
                note_mismatch = 1'b1;
                next_note = k[3:0];
            end
        end
    end


    // Note geometry. Black-key circles: C#, D#, F#, G#, A#.
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
            4'd0: begin note_x=10'd18;  note_is_black=0; end // C
            4'd1: begin note_x=10'd70;  note_y=9'd346; note_is_black=1; end // C#
            4'd2: begin note_x=10'd98;  note_is_black=0; end // D
            4'd3: begin note_x=10'd150; note_y=9'd346; note_is_black=1; end // D#
            4'd4: begin note_x=10'd178; note_is_black=0; end // E
            4'd5: begin note_x=10'd258; note_is_black=0; end // F
            4'd6: begin note_x=10'd310; note_y=9'd346; note_is_black=1; end // F#
            4'd7: begin note_x=10'd338; note_is_black=0; end // G
            4'd8: begin note_x=10'd390; note_y=9'd346; note_is_black=1; end // G#
            4'd9: begin note_x=10'd418; note_is_black=0; end // A
            4'd10:begin note_x=10'd470; note_y=9'd346; note_is_black=1; end // A#
            4'd11:begin note_x=10'd498; note_is_black=0; end // B
            default:begin note_x=10'd18; note_y=9'd394; note_is_black=0; end
        endcase
    end


    // Waveform/instrument selector locations and dimensions.
    reg [9:0] selection_x;
    reg [8:0] selection_y;
    always @(*) begin
        selection_x = 10'd0;
        selection_y = 9'd0;
        scan_width = 6'd60;
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
    wire [9:0] rect44_address = (YC * 44) + XC;
    wire [8:0] circle_color, rect44_color, background_color;

    obj_circle22_mem CROM (.address(circle_address), .clock(Clock), .q(circle_color));
    obj_rect44x20_mem RROM (.address(rect44_address), .clock(Clock), .q(rect44_color));
    background_mem BROM (.address(circle_address), .clock(Clock), .q(background_color));

    reg [8:0] pixel_color;
    reg pixel_write;
    reg bar_border;
    always @(*) begin
        VGA_x = 10'd0;
        VGA_y = 9'd0;
        VGA_color = 9'd0;
        VGA_write = 1'b0;
        pixel_color = 9'd0;
        pixel_write = 1'b0;
        bar_border = 1'b0;

        if (scan_active) begin
            if (!scan_kind) begin
                // Note rendering.
                VGA_x = note_x + XC;
                VGA_y = note_y + YC;
                if (note_is_black) begin
                    if (scan_restore) begin
                        pixel_color = background_color;
                        pixel_write = 1'b1;
                    end else begin
                        pixel_color = circle_color;
                        pixel_write = (circle_color != TRANSPARENT);
                    end
                end else begin
                    if (scan_restore) begin
                        pixel_color = WHITE_KEY_BACKGROUND;
                        pixel_write = 1'b1;
                    end else begin
                        pixel_color = rect44_color;
                        pixel_write = (rect44_color != TRANSPARENT);
                    end
                end
            end else begin
                // Selector rendering.
                VGA_x = selection_x + XC;
                VGA_y = selection_y + YC;
                if (selection_is_circle) begin
                    if (scan_restore) begin
                        pixel_color = background_color;
                        pixel_write = 1'b1;
                    end else begin
                        pixel_color = circle_color;
                        pixel_write = (circle_color != TRANSPARENT);
                    end
                end else begin
                    if (scan_restore) begin
                        pixel_color = BAR_BACKGROUND;
                        pixel_write = 1'b1;
                    end else begin
                        bar_border = (XC < 2) || (XC >= 58) || (YC < 2) || (YC >= 8);
                        pixel_color = bar_border ? 9'h12F : 9'b011_111_011;
                        pixel_write = 1'b1;
                    end
                end
            end
            VGA_color = pixel_color;
            VGA_write = pixel_write;
        end
    end


    // FSM. Notes are prioritized; selector is serviced after note updates.
    always @(posedge Clock) begin
        if (!Resetn) begin
            scan_active <= 1'b0;
            scan_restore <= 1'b0;
            scan_kind <= 1'b0;
            scan_id <= 4'd0;
            XC <= 6'd0;
            YC <= 5'd0;
            displayed_notes <= 12'b0;
            displayed_selection <= 3'd0;
        end else begin
            if (!scan_active) begin
                XC <= 6'd0;
                YC <= 5'd0;
                if (note_mismatch) begin
                    scan_kind <= 1'b0;
                    scan_id <= next_note;
                    scan_restore <= ~desired_notes[next_note];
                    scan_active <= 1'b1;
                end else if (displayed_selection != desired_selection) begin
                    scan_kind <= 1'b1;
                    if (displayed_selection != 0) begin
                        scan_id <= {1'b0, displayed_selection};
                        scan_restore <= 1'b1;
                    end else if (desired_selection != 0) begin
                        scan_id <= {1'b0, desired_selection};
                        scan_restore <= 1'b0;
                    end
                    scan_active <= 1'b1;
                end
            end else begin
                if (!scan_kind) begin
                    // Note objects: 22x22 black circles or 44x20 white rectangles.
                    if ((XC == note_width-1) && (YC == note_height-1)) begin
                        scan_active <= 1'b0;
                        XC <= 6'd0;
                        YC <= 5'd0;
                        displayed_notes[scan_id] <= ~scan_restore;
                    end else if (XC == note_width-1) begin
                        XC <= 6'd0;
                        YC <= YC + 1'b1;
                    end else begin
                        XC <= XC + 1'b1;
                    end
                end else begin
                    if ((XC == scan_width-1) && (YC == scan_height-1)) begin
                        scan_active <= 1'b0;
                        XC <= 6'd0;
                        YC <= 5'd0;
                        if (scan_restore)
                            displayed_selection <= 3'd0;
                        else
                            displayed_selection <= scan_id[2:0];
                    end else if (XC == scan_width-1) begin
                        XC <= 6'd0;
                        YC <= YC + 1'b1;
                    end else begin
                        XC <= XC + 1'b1;
                    end
                end
            end
        end
    end
endmodule


module background_mem (
    input wire [8:0] address,
    input wire clock,
    output wire [8:0] q
);
    wire [8:0] rom_q;
    altsyncram background_rom_inst (
        .address_a(address), .clock0(clock), .q_a(rom_q),
        .aclr0(1'b0), .aclr1(1'b0), .address_b(1'b1),
        .addressstall_a(1'b0), .addressstall_b(1'b0),
        .byteena_a(1'b1), .byteena_b(1'b1), .clock1(1'b1),
        .clocken0(1'b1), .clocken1(1'b1), .clocken2(1'b1), .clocken3(1'b1),
        .data_a(9'h1FF), .data_b(1'b1), .eccstatus(), .q_b(),
        .rden_a(1'b1), .rden_b(1'b1), .wren_a(1'b0), .wren_b(1'b0)
    );
    defparam background_rom_inst.address_aclr_a = "NONE",
        background_rom_inst.clock_enable_input_a = "BYPASS",
        background_rom_inst.clock_enable_output_a = "BYPASS",
        background_rom_inst.init_file = "./MIF/obj_circle_blue_22x22.mif",
        background_rom_inst.intended_device_family = "Cyclone V",
        background_rom_inst.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
        background_rom_inst.lpm_type = "altsyncram",
        background_rom_inst.numwords_a = 484,
        background_rom_inst.operation_mode = "ROM",
        background_rom_inst.outdata_aclr_a = "NONE",
        background_rom_inst.outdata_reg_a = "UNREGISTERED",
        background_rom_inst.widthad_a = 9,
        background_rom_inst.width_a = 9,
        background_rom_inst.width_byteena_a = 1;
    assign q = rom_q;
endmodule
