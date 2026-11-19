
# Stop previous simulation
quit -sim

# Create work library if necessary
if {![file exists work]} {
    vlib work
}

# Compile Verilog source
vlog NCO_sampling.v

# Compile testbench
vlog testbench.v


# Start simulation
vsim -voptargs=+acc work.testbench

# Display waveforms
add wave -r /*

# Run simulation
run -all
