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

vcom -work work "../rom/rom.vhd"
vcom -work work "../ram/pixel_video_ram.vhd"
vcom -work work "../ram/color_video_ram.vhd"
vcom -work work "../ram/remaining_ram.vhd"
vcom -work work "../pll.vhd"
vcom -work work "../reset_counter.vhd"
vcom -work work "../top.vhd"
vcom -work work "../tb.vhd"

vsim -t ps -novopt  work.tb

#add wave -position end  -color white sim:/tb/clk_50
add wave -position end  -color green sim:/tb/uut/global_reset
add wave -position end  -color green sim:/tb/uut/pll_reset
add wave -position end  -color green sim:/tb/uut/ula_reset_n
add wave -position end  -color green sim:/tb/uut/cpu_reset_n

#add wave -position end  -color white sim:/tb/uut/video_clock
add wave -position end  -color white sim:/tb/uut/ula_clk
add wave -position end  -color white sim:/tb/uut/cpu_clk

add wave -position end  -color blue -radix hex sim:/tb/uut/cpu_data
add wave -position end  -color blue -radix hex sim:/tb/uut/data_in
add wave -position end  -color cyan -radix hex sim:/tb/uut/ula_en
add wave -position end  -color cyan -radix hex sim:/tb/uut/ula_data_out
add wave -position end  -color blue -radix hex sim:/tb/uut/data_out
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_address
add wave -position end  -color white -radix hex sim:/tb/uut/nios_address
add wave -position end  -color white -radix hex sim:/tb/uut/address

add wave -position end  -color yellow sim:/tb/bus_rq
add wave -position end  -color yellow sim:/tb/nmi

add wave -position end  -color pink -radix hex sim:/tb/halt
add wave -position end  -color pink -radix hex sim:/tb/uut/busak_n

add wave -position end  -color white -radix hex sim:/tb/uut/rom_en
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_pixel_en
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_color_en
add wave -position end  -color white -radix hex sim:/tb/uut/ram_en
add wave -position end  -color white -radix hex sim:/tb/uut/ula_en
add wave -position end  -color white -radix hex sim:/tb/uut/nios_en

add wave -position end  -color blue sim:/tb/uut/cpu_int_n

add wave -position end  -color cyan -radix hex sim:/tb/uut/read_en
add wave -position end  -color pink -radix hex sim:/tb/uut/nios_rd_n
add wave -position end  -color cyan -radix hex sim:/tb/uut/write_en
add wave -position end  -color pink -radix hex sim:/tb/uut/nios_wr_n
add wave -position end  -color cyan -radix hex sim:/tb/uut/mreq_n
add wave -position end  -color pink -radix hex sim:/tb/uut/nios_mreq_n
add wave -position end  -color cyan -radix hex sim:/tb/uut/iorq_n
add wave -position end  -color pink -radix hex sim:/tb/uut/nios_iorq_n

#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/contention_time
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/memory_contention
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/io_contention
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/m_wait
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/nInt
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/vsync
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/v


#add wave -position end  -color yellow -radix hex sim:/tb/uut/ula/ula_counters/nC
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/clk
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/D
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/Q
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/internal_q
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/nRESET
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/SET
#add wave -position end  -color yellow sim:/tb/uut/ula/ula_counters/FD0/EN


add wave -position end  -color white -radix hex sim:/tb/uut/rom_address
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_pixel_addr
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_color_addr
add wave -position end  -color white -radix hex sim:/tb/uut/ram_address



run 



left -expr valid_in
