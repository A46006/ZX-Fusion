alias zl "do z_lap.do"

vdel -all -lib work

vlib work

vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/PS2_Controller.v"
vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/Altera_UP_PS2_Data_In.v"
vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/Altera_UP_PS2_Command_Out.v"
vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/input_receiver.vhd"
vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/keyboard_top.vhd"
vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/keyboard_tb.vhd"


vsim -t ps -novopt  work.video_tb

add wave -position end  -color purple sim:/tb/clk
add wave -position end  sim:/tb/reset
add wave -position end  -radix hex -color red sim:/tb/native_data

run 



left -expr valid_in


