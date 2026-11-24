// ---------------------------------------------------------------------------
// Four separate sprite ROM modules for the synth VGA display.
// Each module is self-contained (own altsyncram, no shared generic module).
// Colour is 9-bit {R[2:0],G[2:0],B[2:0]}.  Address = row*WIDTH + column (row 0 = top).
// q is valid ONE clock after address.  Circles use white (9'o777) as "transparent".
// Put the .mif files in ./MIF or change INIT_FILE.
// ---------------------------------------------------------------------------

// 22x22 circle (black-key / instrument / kick dots): 484 words, MIF obj_circle_22x22.mif
module obj_circle22_mem (address, clock, q);
    parameter n = 9;                 // memory width
    parameter Mn = 9;              // address bits
    parameter INIT_FILE = "./MIF/obj_circle_22x22.mif";

    input wire [Mn-1:0] address;     // 0..483
    input wire clock;
    output [n-1:0] q;
    wire [n-1:0] sub_wire0;
    wire [n-1:0] q = sub_wire0[n-1:0];

    altsyncram altsyncram_component (
                .address_a (address),
                .clock0 (clock),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_a ({n{1'b1}}),
                .data_b (1'b1),
                .eccstatus (),
                .q_b (),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .wren_a (1'b0),
                .wren_b (1'b0));
    defparam
        altsyncram_component.address_aclr_a = "NONE",
        altsyncram_component.clock_enable_input_a = "BYPASS",
        altsyncram_component.clock_enable_output_a = "BYPASS",
        altsyncram_component.init_file = INIT_FILE,
        altsyncram_component.intended_device_family = "Cyclone V",
        altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
        altsyncram_component.lpm_type = "altsyncram",
        altsyncram_component.numwords_a = 484,
        altsyncram_component.operation_mode = "ROM",
        altsyncram_component.outdata_aclr_a = "NONE",
        altsyncram_component.outdata_reg_a = "UNREGISTERED",
        altsyncram_component.widthad_a = Mn,
        altsyncram_component.width_a = n,
        altsyncram_component.width_byteena_a = 1;
endmodule

// 18x18 circle (drum dots): 324 words, MIF obj_circle_18x18.mif
module obj_circle18_mem (address, clock, q);
    parameter n = 9;                 // memory width
    parameter Mn = 9;              // address bits
    parameter INIT_FILE = "./MIF/obj_circle_18x18.mif";

    input wire [Mn-1:0] address;     // 0..323
    input wire clock;
    output [n-1:0] q;
    wire [n-1:0] sub_wire0;
    wire [n-1:0] q = sub_wire0[n-1:0];

    altsyncram altsyncram_component (
                .address_a (address),
                .clock0 (clock),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_a ({n{1'b1}}),
                .data_b (1'b1),
                .eccstatus (),
                .q_b (),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .wren_a (1'b0),
                .wren_b (1'b0));
    defparam
        altsyncram_component.address_aclr_a = "NONE",
        altsyncram_component.clock_enable_input_a = "BYPASS",
        altsyncram_component.clock_enable_output_a = "BYPASS",
        altsyncram_component.init_file = INIT_FILE,
        altsyncram_component.intended_device_family = "Cyclone V",
        altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
        altsyncram_component.lpm_type = "altsyncram",
        altsyncram_component.numwords_a = 324,
        altsyncram_component.operation_mode = "ROM",
        altsyncram_component.outdata_aclr_a = "NONE",
        altsyncram_component.outdata_reg_a = "UNREGISTERED",
        altsyncram_component.widthad_a = Mn,
        altsyncram_component.width_a = n,
        altsyncram_component.width_byteena_a = 1;
endmodule

// 44x20 rectangle (white-key bars): 880 words, MIF obj_rect_44x20.mif
module obj_rect44x20_mem (address, clock, q);
    parameter n = 9;                 // memory width
    parameter Mn = 10;             // address bits
    parameter INIT_FILE = "./MIF/obj_rect_44x20.mif";

    input wire [Mn-1:0] address;     // 0..879
    input wire clock;
    output [n-1:0] q;
    wire [n-1:0] sub_wire0;
    wire [n-1:0] q = sub_wire0[n-1:0];

    altsyncram altsyncram_component (
                .address_a (address),
                .clock0 (clock),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_a ({n{1'b1}}),
                .data_b (1'b1),
                .eccstatus (),
                .q_b (),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .wren_a (1'b0),
                .wren_b (1'b0));
    defparam
        altsyncram_component.address_aclr_a = "NONE",
        altsyncram_component.clock_enable_input_a = "BYPASS",
        altsyncram_component.clock_enable_output_a = "BYPASS",
        altsyncram_component.init_file = INIT_FILE,
        altsyncram_component.intended_device_family = "Cyclone V",
        altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
        altsyncram_component.lpm_type = "altsyncram",
        altsyncram_component.numwords_a = 880,
        altsyncram_component.operation_mode = "ROM",
        altsyncram_component.outdata_aclr_a = "NONE",
        altsyncram_component.outdata_reg_a = "UNREGISTERED",
        altsyncram_component.widthad_a = Mn,
        altsyncram_component.width_a = n,
        altsyncram_component.width_byteena_a = 1;
endmodule

// 56x6 rectangle (waveform bars): 336 words, MIF obj_rect_56x6.mif
module obj_rect56x6_mem (address, clock, q);
    parameter n = 9;                 // memory width
    parameter Mn = 9;              // address bits
    parameter INIT_FILE = "./MIF/obj_rect_56x6.mif";

    input wire [Mn-1:0] address;     // 0..335
    input wire clock;
    output [n-1:0] q;
    wire [n-1:0] sub_wire0;
    wire [n-1:0] q = sub_wire0[n-1:0];

    altsyncram altsyncram_component (
                .address_a (address),
                .clock0 (clock),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_a ({n{1'b1}}),
                .data_b (1'b1),
                .eccstatus (),
                .q_b (),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .wren_a (1'b0),
                .wren_b (1'b0));
    defparam
        altsyncram_component.address_aclr_a = "NONE",
        altsyncram_component.clock_enable_input_a = "BYPASS",
        altsyncram_component.clock_enable_output_a = "BYPASS",
        altsyncram_component.init_file = INIT_FILE,
        altsyncram_component.intended_device_family = "Cyclone V",
        altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
        altsyncram_component.lpm_type = "altsyncram",
        altsyncram_component.numwords_a = 336,
        altsyncram_component.operation_mode = "ROM",
        altsyncram_component.outdata_aclr_a = "NONE",
        altsyncram_component.outdata_reg_a = "UNREGISTERED",
        altsyncram_component.widthad_a = Mn,
        altsyncram_component.width_a = n,
        altsyncram_component.width_byteena_a = 1;
endmodule
