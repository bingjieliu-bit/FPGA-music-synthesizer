onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Outputs
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate -radix hexadecimal /testbench/key_data
add wave -noupdate /testbench/uut1/key_released
add wave -noupdate -radix binary /testbench/new_key
add wave -noupdate /testbench/octave
add wave -noupdate -divider {Active Notes}
add wave -noupdate /testbench/uut2/notes_active
add wave -noupdate -divider Frequencies
add wave -noupdate -radix hexadecimal /testbench/frequencies
add wave -noupdate -divider {Individual Frequencies}
add wave -noupdate -radix unsigned {/testbench/frequencies[9:0]}
add wave -noupdate -radix unsigned {/testbench/frequencies[19:10]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {503011 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 194
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {504 ns}
