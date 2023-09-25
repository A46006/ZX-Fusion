onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst
add wave -noupdate /tb/enable
add wave -noupdate /tb/valid_in
add wave -noupdate /tb/start
add wave -noupdate /tb/instr
add wave -noupdate -radix hexadecimal /tb/input_data
add wave -noupdate /tb/d
add wave -noupdate /tb/clock
add wave -noupdate /tb/uut/clk_in
add wave -noupdate /tb/uut/reset_in
add wave -noupdate -color white /tb/uut/valid_in
add wave -noupdate -radix hexadecimal /tb/uut/stream_in
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/stream_out
add wave -noupdate /tb/uut/valid_out
add wave -noupdate /tb/uut/reset
add wave -noupdate /tb/uut/mult_data_in
add wave -noupdate /tb/uut/mult_data_in_pipe1
add wave -noupdate /tb/uut/mult_data_in_pipe2
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/reset
add wave -noupdate -color white -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/valid_in
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/clock0
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/dataa
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/dataa_reg
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/datab_reg
add wave -noupdate -color yellow -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/mult_in_a
add wave -noupdate -color yellow -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/mult_in_b
add wave -noupdate -color yellow -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/mult_result
add wave -noupdate -color yellow -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/mult_result_reg
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/add_sub
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/add_sub_reg
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/add_result
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/add_result_reg
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/mac_out_reg
add wave -noupdate -color orange -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/result
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/accum_sload
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/accum_sload2
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/acc_cnt
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/acc_cnt_reg
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/acc_load_reg
add wave -noupdate -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/acc_load_reg2
add wave -noupdate -color red -radix hexadecimal /tb/uut/ndim_filter_inst(0)/mac_inst/coef_num
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {299761 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 314
configure wave -valuecolwidth 64
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
WaveRestoreZoom {291746 ps} {406482 ps}
