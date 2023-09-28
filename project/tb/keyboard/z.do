alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "../../constants.vhd"
vlog -work work "../../keyboard/PS2_Controller/PS2_Controller.v"
vlog -work work "../../keyboard/PS2_Controller/Altera_UP_PS2_Data_In.v"
vlog -work work "../../keyboard/PS2_Controller/Altera_UP_PS2_Command_Out.v"
vcom -work work "../../keyboard/input_receiver.vhd"
vcom -work work "../../keyboard/keyboard_top.vhd"
vcom -work work "../../keyboard/keyboard_tb.vhd"


vsim -t ps -novopt  work.keyboard_tb

add wave -noupdate /keyboard_tb/CLK
add wave -noupdate /keyboard_tb/RESET
add wave -noupdate -color red -radix hexadecimal /keyboard_tb/native_data

add wave -noupdate /keyboard_tb/uut/CLOCK
add wave -noupdate /keyboard_tb/uut/PS2_CLOCK
add wave -noupdate /keyboard_tb/uut/PS2_DATA
add wave -noupdate -radix hexadecimal -color blue /keyboard_tb/uut/KEY_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/VALID

add wave -noupdate -radix hexadecimal -color pink /keyboard_tb/uut/input_rcvr/PS2_COMMAND
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/PS2_COMMAND_EN
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/PS2_COMMAND_ACK
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/PS2_COMMAND_ERR

add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/ADDRESS
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/PS2_SCAN_CODE
add wave -noupdate /keyboard_tb/uut/input_rcvr/NATIVE_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/NATnPS2
add wave -noupdate /keyboard_tb/uut/input_rcvr/KEY_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/PS2_converted_data

add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_0_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_1_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_2_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_3_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_4_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_5_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_6_o
add wave -noupdate -color purple /keyboard_tb/uut/input_rcvr/half_row_7_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_0
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_1
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_2
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_3
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_4
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_5
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_6
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_7

add wave -noupdate -color yellow /keyboard_tb/uut/input_rcvr/release
add wave -noupdate -color yellow /keyboard_tb/uut/input_rcvr/extended
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/shift
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/alt
add wave -noupdate -color pink /keyboard_tb/uut/input_rcvr/numlock

run 



left -expr valid_in


