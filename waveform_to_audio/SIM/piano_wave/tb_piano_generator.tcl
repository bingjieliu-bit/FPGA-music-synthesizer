
# Stop previous simulation
quit -sim

# Create work library if necessary
if {![file exists work]} {
    vlib work
}

# Compile Verilog source
vlog wave_generator.v

# Compile testbench
vlog tb_piano_generator.v

# Start simulation
vsim work.tb_piano_generator

# Add waveforms
add wave -radix hexadecimal sim:/tb_piano_generator/phase
add wave -radix decimal sim:/tb_piano_generator/piano_wave

# Run simulation
run -all

# Zoom waveform
wave zoom full
