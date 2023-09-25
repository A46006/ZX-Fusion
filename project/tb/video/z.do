alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/video/video.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/video/data_interpreter.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/video/vga_controller.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/ram/color_video_ram.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/ram/pixel_video_ram.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/video/video_tb.vhd"


vsim -t ps -novopt  work.video_tb

add wave -position end  sim:/tb/clk
add wave -position end  sim:/tb/reset
add wave -position end  sim:/tb/pixel_en
add wave -position end  -color purple sim:/tb/v_sync
add wave -position end  -color purple sim:/tb/h_sync

add wave -position end  sim:/tb/uut/disp_e
add wave -position end  -color yellow sim:/tb/uut/x
add wave -position end  -color yellow sim:/tb/uut/y
add wave -position end  -radix hex -color red sim:/tb/red
add wave -position end  -radix hex -color green sim:/tb/green
add wave -position end  -radix hex -color blue sim:/tb/blue
add wave -position end  -radix hex sim:/tb/pixel_data
add wave -position end  -radix hex sim:/tb/col_data
add wave -position end  -radix hex sim:/tb/pixel_addr
add wave -position end  -radix hex sim:/tb/col_addr

#add wave -position end  sim:/tb/uut/interpreter/proc_clock

#add wave -position end  -color cyan sim:/tb/uut/interpreter/ctr_x
#add wave -position end  -color cyan sim:/tb/uut/interpreter/curr_pixel_column
#add wave -position end  -color cyan sim:/tb/uut/interpreter/curr_att_column
#add wave -position end  -color cyan sim:/tb/uut/interpreter/ctr_y
#add wave -position end  -color cyan sim:/tb/uut/interpreter/curr_pixel_row
#add wave -position end  -color cyan sim:/tb/uut/interpreter/curr_att_row
#add wave -position end  -color cyan sim:/tb/uut/interpreter/curr_att_row_group
#add wave -position end  -radix hex -color cyan sim:/tb/uut/interpreter/pixel_info
#add wave -position end  -radix hex -color cyan sim:/tb/uut/interpreter/color_info

add wave -position end  -radix hex -color cyan sim:/tb/uut/interpreter/counter


run 



left -expr valid_in


