
vlib work
vmap work work

vlog wave_generator.v
vlog tb_sqaure.v

vsim -quiet -voptargs=+acc work.tb_sqaure

view wave
add wave -radix hex sim:/tb_sqaure/phase
add wave -radix hex sim:/tb_sqaure/square_wave

run -all
