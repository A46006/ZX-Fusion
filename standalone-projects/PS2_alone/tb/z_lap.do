alias zl "do z_lap.do"

vdel -all -lib work

vlib work

vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/PS2_controller_test_tb.vhd"
vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/key_mem.vhd"
vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/PS2_Controller.v"
vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/Altera_UP_PS2_Data_In.v"
vlog -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/Altera_UP_PS2_Command_Out.v"
vcom -work work "C:/Users/pepsu/Documents/MI13D/TFM/TFM-SPEC/03-PS2_impl/PS2_alone/keyboard/PS2_controller_test.vhd"


vsim -t ps -novopt  work.PS2_controller_test_tb

add wave -noupdate -color blue /ps2_controller_test_tb/reset
add wave -noupdate -color blue -radix hex /ps2_controller_test_tb/test_data

add wave -noupdate -color white /ps2_controller_test_tb/uut/CLOCK_50
add wave -noupdate -color white /ps2_controller_test_tb/uut/SW
add wave -noupdate -color white /ps2_controller_test_tb/uut/LEDR
add wave -noupdate -color white /ps2_controller_test_tb/uut/PS2_CLK
add wave -noupdate -color white /ps2_controller_test_tb/uut/PS2_DAT
add wave -noupdate /ps2_controller_test_tb/uut/reset
add wave -noupdate /ps2_controller_test_tb/uut/prefix
add wave -noupdate /ps2_controller_test_tb/uut/scan_code
add wave -noupdate /ps2_controller_test_tb/uut/prefix_s
add wave -noupdate /ps2_controller_test_tb/uut/scan_code_s
add wave -noupdate /ps2_controller_test_tb/uut/error
add wave -noupdate /ps2_controller_test_tb/uut/valid
add wave -noupdate /ps2_controller_test_tb/uut/been_read
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/wraddress
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/rdaddress
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/ps2_command
add wave -noupdate /ps2_controller_test_tb/uut/scan_code_en
add wave -noupdate /ps2_controller_test_tb/uut/ps2_send
add wave -noupdate /ps2_controller_test_tb/uut/numlock
add wave -noupdate /ps2_controller_test_tb/uut/capslock
add wave -noupdate /ps2_controller_test_tb/uut/numlock_led
add wave -noupdate /ps2_controller_test_tb/uut/capslock_led
add wave -noupdate /ps2_controller_test_tb/uut/release
add wave -noupdate /ps2_controller_test_tb/uut/led_set_state
add wave -noupdate /ps2_controller_test_tb/uut/PS2/CLOCK_50
add wave -noupdate /ps2_controller_test_tb/uut/PS2/reset
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/the_command
add wave -noupdate /ps2_controller_test_tb/uut/PS2/send_command
add wave -noupdate /ps2_controller_test_tb/uut/PS2/PS2_CLK
add wave -noupdate /ps2_controller_test_tb/uut/PS2/PS2_DAT
add wave -noupdate /ps2_controller_test_tb/uut/PS2/command_was_sent
add wave -noupdate /ps2_controller_test_tb/uut/PS2/error_communication_timed_out
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/received_data
add wave -noupdate /ps2_controller_test_tb/uut/PS2/received_data_en
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/the_command_w
add wave -noupdate /ps2_controller_test_tb/uut/PS2/send_command_w
add wave -noupdate /ps2_controller_test_tb/uut/PS2/command_was_sent_w
add wave -noupdate /ps2_controller_test_tb/uut/PS2/error_communication_timed_out_w
add wave -noupdate /ps2_controller_test_tb/uut/PS2/ps2_clk_posedge
add wave -noupdate /ps2_controller_test_tb/uut/PS2/ps2_clk_negedge
add wave -noupdate /ps2_controller_test_tb/uut/PS2/start_receiving_data
add wave -noupdate /ps2_controller_test_tb/uut/PS2/wait_for_incoming_data
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/idle_counter
add wave -noupdate /ps2_controller_test_tb/uut/PS2/ps2_clk_reg
add wave -noupdate /ps2_controller_test_tb/uut/PS2/ps2_data_reg
add wave -noupdate /ps2_controller_test_tb/uut/PS2/last_ps2_clk
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/ns_ps2_transceiver
add wave -noupdate -radix hexadecimal /ps2_controller_test_tb/uut/PS2/s_ps2_transceiver

run 



left -expr valid_in


