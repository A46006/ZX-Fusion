alias z "do z.do"

vdel -all -lib work

vlib work


vcom -work work "../FallingEdge_ DFF.vhd"
vcom -work work "../FallingEdge_ TFF_RCE.vhd"
vcom -work work "../ula_counters.vhd"
vcom -work work "../ula_counters_tb.vhd"

vsim -t ps -novopt  work.ula_counters_tb

add wave -position end  -color white -radix hex sim:/ula_counters_tb/clk_50
add wave -position end  -color white -radix hex sim:/ula_counters_tb/uut/c
add wave -position end  -color white -radix hex sim:/ula_counters_tb/uut/v
add wave -position end  -color yellow sim:/ula_counters_tb/uut/clkhc6
add wave -position end  -color yellow sim:/ula_counters_tb/uut/hcrst

add wave -position end  -color purple -radix hex sim:/ula_counters_tb/uut/en_trce1
add wave -position end  -color purple -radix hex sim:/ula_counters_tb/uut/en_trce2



run 



left -expr valid_in


# cd H:/MI13D/TFM/TFM-SPEC/04-SD_impl/ula_counters/vhd/tb