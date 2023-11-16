alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "../7seg/symbols_7seg.vhd"
vcom -work work "../7seg/conv_7seg.vhd"
vcom -work work "../7seg/mux_16to1_7bit.vhd"

vcom -work work "../primitive_blocks/FallingEdge_DFF.vhd"
vcom -work work "../primitive_blocks/FallingEdge_TFF_RCE.vhd"

vcom -work work "../ula/ula_top.vhd"
vcom -work work "../ula/ula_port.vhd"
vcom -work work "../ula/ula_count.vhd"

vcom -work work "../T80/T80.vhd"
vcom -work work "../T80/T80_ALU.vhd"
vcom -work work "../T80/T80_MCode.vhd"
vcom -work work "../T80/T80_Pack.vhd"
vcom -work work "../T80/T80_Reg.vhd"
vcom -work work "../T80/T80a.vhd"

vcom -work work "../ram.vhd"
vcom -work work "../top.vhd"
vcom -work work "../tb.vhd"

vsim -t ps -novopt  work.tb

add wave -position end  -color white sim:/tb/clk_50
add wave -position end  -color green sim:/tb/global_reset
add wave -position end  -color green sim:/tb/pll_reset
add wave -position end  -color green sim:/tb/ula_reset_n
add wave -position end  -color green sim:/tb/cpu_reset_n

add wave -position end  -color white sim:/tb/uut/ula_clk
add wave -position end  -color white sim:/tb/uut/cpu_clk

add wave -position end  -color blue -radix hex sim:/tb/uut/cpu_data
add wave -position end  -color blue -radix hex sim:/tb/uut/data_in
add wave -position end  -color cyan -radix hex sim:/tb/uut/ula_data_out
add wave -position end  -color blue -radix hex sim:/tb/uut/data_out
add wave -position end  -color red -radix hex sim:/tb/uut/cpu_address
add wave -position end  -color red -radix hex sim:/tb/uut/address

add wave -position end  -color yellow sim:/tb/bus_rq
add wave -position end  -color yellow sim:/tb/nmi

add wave -position end  -color pink -radix hex sim:/tb/halt
add wave -position end  -color pink -radix hex sim:/tb/uut/busak_n

add wave -position end  -color white -radix hex sim:/tb/uut/ram_en
add wave -position end  -color white -radix hex sim:/tb/uut/ula_en

add wave -position end  -color blue sim:/tb/uut/cpu_int_n

add wave -position end  -color cyan -radix hex sim:/tb/uut/read_en
add wave -position end  -color cyan -radix hex sim:/tb/uut/write_en





run 



left -expr valid_in
