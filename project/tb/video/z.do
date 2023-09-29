alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "../../constants.vhd"
vcom -work work "../../video/video.vhd"
vcom -work work "../../video/data_interpreter.vhd"
vcom -work work "../../video/vga_controller.vhd"
vcom -work work "../../ram/color_video_ram.vhd"
vcom -work work "../../ram/pixel_video_ram.vhd"
vcom -work work "../../video/video_tb.vhd"


vsim -t ps -novopt  work.video_tb

add wave -position end  sim:/video_tb/clk
add wave -position end  sim:/video_tb/reset
add wave -position end  -color purple sim:/video_tb/v_sync
add wave -position end  -color purple sim:/video_tb/h_sync

add wave -position end  sim:/video_tb/uut/disp_e
add wave -position end -radix hex -color yellow sim:/video_tb/uut/x
add wave -position end -radix hex -color yellow sim:/video_tb/uut/y
add wave -position end  -radix hex -color red sim:/video_tb/red
add wave -position end  -radix hex -color green sim:/video_tb/green
add wave -position end  -radix hex -color blue sim:/video_tb/blue
add wave -position end -radix hex  -color pink sim:/video_tb/uut/interpreter/bright
add wave -position end  -radix hex sim:/video_tb/pixel_data
add wave -position end  -radix hex sim:/video_tb/col_data
add wave -position end  -radix hex sim:/video_tb/pixel_addr
add wave -position end  -radix hex sim:/video_tb/col_addr

# add wave -position end  sim:/video_tb/uut/interpreter/proc_clock

# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/ctr_x
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/curr_pixel_column
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/curr_att_column
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/ctr_y
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/curr_pixel_row
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/curr_att_row
# add wave -position end  -color cyan sim:/video_tb/uut/interpreter/curr_att_row_group
# add wave -position end  -radix hex -color cyan sim:/video_tb/uut/interpreter/pixel_info
# add wave -position end  -radix hex -color cyan sim:/video_tb/uut/interpreter/color_info

# add wave -position end  -radix hex -color cyan sim:/video_tb/uut/interpreter/counter


add wave -position end  -color cyan sim:/video_tb/uut/interpreter/read_enable
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/x_trans
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/pix_col_num
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/att_col_num
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/y_trans
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/pix_row_num
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/att_row_num
add wave -position end -radix hex  -color cyan sim:/video_tb/uut/interpreter/group_num

add wave -position end -radix hex  -color blue sim:/video_tb/uut/interpreter/read_e
add wave -position end -radix hex  -color blue sim:/video_tb/uut/interpreter/read_next
add wave -position end -radix hex  -color blue sim:/video_tb/uut/interpreter/next_was_read


run 



left -expr valid_in


