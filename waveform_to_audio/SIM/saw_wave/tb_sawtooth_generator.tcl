
# Stop previous simulation
quit -sim

# Create work library if necessary
if {![file exists work]} {
    vlib work
}

# Compile Verilog source
vlog sawtooth_generator.v

# Compile testbench
vlog tb_sawtooth_generator.v

# Start simulation
vsim work.tb_sawtooth_generator

# Add waveforms
add wave -radix hexadecimal sim:/tb_sawtooth_generator/phase
add wave -radix decimal sim:/tb_sawtooth_generator/sawtooth_wave

# Run simulation
run -all

# Zoom waveform
wave zoom full
