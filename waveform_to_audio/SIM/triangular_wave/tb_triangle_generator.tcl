
# Stop previous simulation
quit -sim

# Create work library if necessary
if {![file exists work]} {
    vlib work
}

# Compile Verilog source
vlog wave_generator.v

# Compile testbench
vlog tb_triangle_generator.v

# Start simulation
vsim work.tb_triangle_generator

# Add waveforms
add wave -radix hexadecimal sim:/tb_triangle_generator/phase
add wave -radix decimal sim:/tb_triangle_generator/triangle_wave

# Run simulation
run -all

# Zoom waveform
wave zoom full
