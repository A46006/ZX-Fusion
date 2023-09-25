alias z "do z.do"

vdel -all -lib work

vlib work

vlog -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/PS2_Controller.v"
vlog -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/Altera_UP_PS2_Data_In.v"
vlog -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/Altera_UP_PS2_Command_Out.v"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/input_receiver.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/keyboard_top.vhd"
vcom -work work "H:/MI13D/TFM/TFM-SPEC/03-PS2_impl/project/keyboard/keyboard_tb.vhd"


vsim -t ps -novopt  work.keyboard_tb

add wave -noupdate /keyboard_tb/CLK
add wave -noupdate /keyboard_tb/RESET
add wave -noupdate -color red -radix hexadecimal /keyboard_tb/native_data

add wave -noupdate /keyboard_tb/uut/ps2_controller/CLK
add wave -noupdate /keyboard_tb/uut/ps2_controller/PS2_CLK
add wave -noupdate /keyboard_tb/uut/ps2_controller/PS2_DATA
add wave -noupdate -radix hexadecimal -color blue /keyboard_tb/uut/ps2_controller/DATA
add wave -noupdate /keyboard_tb/uut/ps2_controller/VALID
add wave -noupdate /keyboard_tb/uut/ps2_controller/ERROR
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/ps2_controller/clk_filter
add wave -noupdate /keyboard_tb/uut/ps2_controller/ps2_clk_in
add wave -noupdate /keyboard_tb/uut/ps2_controller/ps2_dat_in
add wave -noupdate /keyboard_tb/uut/ps2_controller/clk_edge
add wave -noupdate /keyboard_tb/uut/ps2_controller/bit_count
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/ps2_controller/shiftreg
add wave -noupdate /keyboard_tb/uut/ps2_controller/parity

add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/ADDRESS
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/PS2_SCAN_CODE
add wave -noupdate /keyboard_tb/uut/input_rcvr/NATIVE_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/PS2nNat
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


