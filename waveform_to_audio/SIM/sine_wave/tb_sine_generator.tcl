
# Stop previous simulation
quit -sim

# Create work library if necessary
if {![file exists work]} {
    vlib work
}

# Compile Verilog source
vlog wave_generator.v

# Compile testbench
vlog tb_sine_generator.v

# Start simulation
vsim work.tb_sine_generator

# Add waveforms
add wave -radix hexadecimal sim:/tb_sine_generator/phase
add wave -radix decimal sim:/tb_sine_generator/sine_wave

# Run simulation
run -all

# Zoom waveform
wave zoom full
