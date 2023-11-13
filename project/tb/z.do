alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "../constants.vhd"

vcom -work work "../nios_sd_loader/simulation/nios_sd_loader.vhd"

vcom -work work "../nios_per_reg.vhd"

vcom -work work "../keyboard/input_receiver.vhd"
vcom -work work "../keyboard/keyboard_top.vhd"
vlog -work work "../keyboard/PS2_Controller/PS2_Controller.v"
vlog -work work "../keyboard/PS2_Controller/Altera_UP_PS2_Data_In.v"
vlog -work work "../keyboard/PS2_Controller/Altera_UP_PS2_Command_Out.v"

vcom -work work "../pll/pll.vhd"

vcom -work work "../ram/color_video_ram.vhd"
vcom -work work "../ram/pixel_video_ram.vhd"
vcom -work work "../ram/remaining_ram.vhd"
vcom -work work "../rom/rom.vhd"

vcom -work work "../t80/T80.vhd"
vcom -work work "../t80/T80_ALU.vhd"
vcom -work work "../t80/T80_MCode.vhd"
vcom -work work "../t80/T80_Pack.vhd"
vcom -work work "../t80/T80_Reg.vhd"
vcom -work work "../t80/T80a.vhd"

vcom -work work "../ula/ula_count.vhd"
vcom -work work "../ula/ula_port.vhd"

vcom -work work "../video/video.vhd"
vcom -work work "../video/data_interpreter.vhd"
vcom -work work "../video/vga_controller.vhd"

vcom -work work "../reset_counter.vhd"
vcom -work work "../top.vhd"
vcom -work work "../tb.vhd"

vsim -t ps -novopt  work.tb

add wave -position end  -color cyan sim:/tb/SD_CLK
add wave -position end  -color cyan sim:/tb/SD_CMD
add wave -position end  -color cyan -radix hex sim:/tb/SD_DAT


add wave -position end  -radix hex -color white sim:/tb/reset
add wave -position end  -radix hex -color white sim:/tb/uut/rst_ctr_num
add wave -position end  sim:/tb/clk_50

add wave -position end  -radix hex -color white sim:/tb/uut/video_reset
add wave -position end  sim:/tb/uut/ula_clock
add wave -position end  sim:/tb/uut/video_clock
add wave -position end  sim:/tb/uut/cpu_clock

add wave -position end  -color cyan -radix hex sim:/tb/uut/nios_address
add wave -position end  -color cyan -radix hex sim:/tb/uut/nios_data
add wave -position end  -color cyan -radix hex sim:/tb/uut/nios_ctrl_bus
add wave -position end  -color cyan sim:/tb/uut/nios_reg_en
add wave -position end  -color cyan -radix hex sim:/tb/uut/cpu_address_reg_out

add wave -position end  -color blue sim:/tb/uut/cpu_busrq_n
add wave -position end  -color blue sim:/tb/uut/cpu_busak_n

add wave -position end  -color white sim:/tb/uut/cpu_iorq_n
add wave -position end  -color white sim:/tb/uut/cpu_mreq_n
add wave -position end  -color white sim:/tb/uut/read_en
add wave -position end  -color white sim:/tb/uut/cpu_rd_n
add wave -position end  -color white sim:/tb/uut/write_en
add wave -position end  -color white sim:/tb/uut/cpu_wr_n

add wave -position end  -color yellow sim:/tb/uut/nios_en
add wave -position end  -color yellow sim:/tb/uut/ula_en
add wave -position end  -color yellow sim:/tb/uut/rom_en
add wave -position end  -color yellow sim:/tb/uut/cpu_pixel_en
add wave -position end  -color yellow sim:/tb/uut/cpu_color_en
add wave -position end  -color yellow sim:/tb/uut/ram_en

add wave -position end  -color white -radix hex sim:/tb/uut/rom_address
add wave -position end  -color white -radix hex sim:/tb/uut/video_pixel_addr
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_pixel_addr
add wave -position end  -color white -radix hex sim:/tb/uut/video_color_addr
add wave -position end  -color white -radix hex sim:/tb/uut/cpu_color_addr
add wave -position end  -color white -radix hex sim:/tb/uut/ram_address

add wave -position end	-color pink -radix hex sim:/tb/uut/cpu_address
add wave -position end  -color pink sim:/tb/uut/cpu_wait_n
#add wave -position end  -color pink sim:/tb/uut/cpu_mreq_n
#add wave -position end  -color pink sim:/tb/uut/cpu_rd_n
#add wave -position end  -color pink sim:/tb/uut/cpu_wr_n
add wave -position end	-color pink -radix hex sim:/tb/uut/cpu_data
add wave -position end	-color pink -radix hex sim:/tb/uut/ula_counters/c
add wave -position end	-color pink -radix hex sim:/tb/uut/ula_counters/n_clk_wait
add wave -position end	-color pink -radix hex sim:/tb/uut/ula_counters/contention_mem_zone
add wave -position end	-color pink -radix hex sim:/tb/uut/ula_counters/cpu_stop

add wave -noupdate -color blue /tb/uut/video_processor/controller/reset_n
add wave -noupdate -color blue /tb/uut/video_processor/controller/h_sync
add wave -noupdate -color blue /tb/uut/video_processor/controller/v_sync
add wave -noupdate -color blue /tb/uut/video_processor/controller/disp_ena
add wave -noupdate -color blue /tb/uut/video_processor/controller/column
add wave -noupdate -color blue /tb/uut/video_processor/controller/row
add wave -noupdate -color green -radix hex /tb/uut/video_processor/x
add wave -noupdate -color green -radix hex /tb/uut/video_processor/y

add wave -noupdate -color yellow /tb/uut/video_processor/interpreter/FLASH_CLK
add wave -noupdate -color yellow /tb/uut/video_processor/interpreter/RESET
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/PIXEL_DATA
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/COLOR_DATA
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/PIXEL_ADDR
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/COLOR_ADDR
add wave -noupdate -color yellow /tb/uut/video_processor/interpreter/READ_E
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/pixel_info
add wave -noupdate -color yellow -radix hex /tb/uut/video_processor/interpreter/color_info
add wave -noupdate -color yellow /tb/uut/video_processor/interpreter/read_next
add wave -noupdate -color yellow /tb/uut/video_processor/interpreter/next_was_read

add wave -position end  -radix hex -color red sim:/tb/VGA_R
add wave -position end  -radix hex -color green sim:/tb/VGA_G
add wave -position end  -radix hex -color blue sim:/tb/VGA_B

add wave -position end  -radix hex sim:/tb/uut/video_pixel_data_out
add wave -position end  -radix hex sim:/tb/uut/video_color_data_out
add wave -position end  -radix hex sim:/tb/uut/video_pixel_addr
add wave -position end  -radix hex sim:/tb/uut/video_color_addr


run 



left -expr valid_in


