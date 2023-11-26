alias z "do z.do"

vdel -all -lib work

vlib work

vcom -work work "../7seg/spin_anim_7seg.vhd"
vcom -work work "../7seg/double_spin_anim_7seg.vhd"
vcom -work work "../7seg/spin_ctr.vhd"

vcom -work work "../top.vhd"
vcom -work work "../tb.vhd"

vsim -t ps -novopt  work.tb

add wave -position end  -color white sim:/tb/clk_50
add wave -position end  -color blue sim:/tb/set
add wave -position end  -color blue sim:/tb/clr
add wave -position end  -color orange sim:/tb/hex7
add wave -position end  -color orange sim:/tb/hex6
add wave -position end  -color orange sim:/tb/hex5
add wave -position end  -color orange sim:/tb/hex4

add wave -position end  -color yellow -radix hex sim:/tb/uut/double_spin/count_num
add wave -position end  -color yellow sim:/tb/uut/double_spin/clk2
add wave -position end  -color yellow sim:/tb/uut/double_spin/clk1

#add wave -position end  -color yellow sim:/tb/uut/spin2/state
#add wave -position end  -color yellow -radix hex sim:/tb/uut/spin2/D1
#add wave -position end  -color yellow -radix hex sim:/tb/uut/spin2/D0



run 



left -expr valid_in
