onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color purple /keyboard_tb/CLK
add wave -noupdate /keyboard_tb/RESET
add wave -noupdate -color red -radix hexadecimal /keyboard_tb/native_data
add wave -noupdate /keyboard_tb/uut/ps2_controller/CLK
add wave -noupdate /keyboard_tb/uut/ps2_controller/nRESET
add wave -noupdate /keyboard_tb/uut/ps2_controller/PS2_CLK
add wave -noupdate /keyboard_tb/uut/ps2_controller/PS2_DATA
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/ps2_controller/DATA
add wave -noupdate /keyboard_tb/uut/ps2_controller/VALID
add wave -noupdate /keyboard_tb/uut/ps2_controller/ERROR
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/ps2_controller/clk_filter
add wave -noupdate /keyboard_tb/uut/ps2_controller/ps2_clk_in
add wave -noupdate /keyboard_tb/uut/ps2_controller/ps2_dat_in
add wave -noupdate /keyboard_tb/uut/ps2_controller/clk_edge
add wave -noupdate /keyboard_tb/uut/ps2_controller/bit_count
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/ps2_controller/shiftreg
add wave -noupdate /keyboard_tb/uut/ps2_controller/parity
add wave -noupdate /keyboard_tb/uut/input_rcvr/CLOCK
add wave -noupdate /keyboard_tb/uut/input_rcvr/RESET
add wave -noupdate /keyboard_tb/uut/input_rcvr/VALID
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/ADDRESS
add wave -noupdate -radix hexadecimal /keyboard_tb/uut/input_rcvr/PS2_SCAN_CODE
add wave -noupdate /keyboard_tb/uut/input_rcvr/NATIVE_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/PS2nNat
add wave -noupdate /keyboard_tb/uut/input_rcvr/KEY_DATA
add wave -noupdate /keyboard_tb/uut/input_rcvr/PS2_converted_data
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_0_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_1_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_2_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_3_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_4_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_5_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_6_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_7_o
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_0
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_1
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_2
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_3
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_4
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_5
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_6
add wave -noupdate /keyboard_tb/uut/input_rcvr/half_row_7
add wave -noupdate /keyboard_tb/uut/input_rcvr/release
add wave -noupdate /keyboard_tb/uut/input_rcvr/extended
add wave -noupdate /keyboard_tb/uut/input_rcvr/shift
add wave -noupdate /keyboard_tb/uut/input_rcvr/alt
add wave -noupdate /keyboard_tb/uut/input_rcvr/numlock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 274
configure wave -valuecolwidth 70
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4257 ps} {5145 ps}
