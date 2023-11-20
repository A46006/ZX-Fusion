onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color white /tb/clk_50
add wave -noupdate -color green /tb/uut/global_reset
add wave -noupdate -color green /tb/uut/pll_reset
add wave -noupdate -color green /tb/uut/ula_reset_n
add wave -noupdate -color green /tb/uut/cpu_reset_n
add wave -noupdate -color white /tb/uut/ula_clk
add wave -noupdate -color white /tb/uut/cpu_clk
add wave -noupdate -color blue -radix hexadecimal /tb/uut/cpu_data
add wave -noupdate -color blue -radix hexadecimal /tb/uut/data_in
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/ula_en
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/ula_data_out
add wave -noupdate -color blue -radix hexadecimal /tb/uut/data_out
add wave -noupdate -color white -radix hexadecimal /tb/uut/cpu_address
add wave -noupdate -color white -radix hexadecimal /tb/uut/nios_address
add wave -noupdate -color white -radix hexadecimal /tb/uut/address
add wave -noupdate -color orange -radix hexadecimal /tb/uut/SW
add wave -noupdate -color orange -radix hexadecimal /tb/address
add wave -noupdate -color yellow /tb/bus_rq
add wave -noupdate -color yellow /tb/nmi
add wave -noupdate -color pink -radix hexadecimal /tb/halt
add wave -noupdate -color pink -radix hexadecimal /tb/uut/busak_n
add wave -noupdate -color white -radix hexadecimal /tb/uut/ram_en
add wave -noupdate -color white -radix hexadecimal /tb/uut/ula_en
add wave -noupdate -color white -radix hexadecimal /tb/uut/nios_en
add wave -noupdate -color blue /tb/uut/cpu_int_n
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/read_en
add wave -noupdate -color pink -radix hexadecimal /tb/uut/nios_rd_n
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/write_en
add wave -noupdate -color pink -radix hexadecimal /tb/uut/nios_wr_n
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/mreq_n
add wave -noupdate -color pink -radix hexadecimal /tb/uut/nios_mreq_n
add wave -noupdate -color cyan -radix hexadecimal /tb/uut/iorq_n
add wave -noupdate -color pink -radix hexadecimal /tb/uut/nios_iorq_n
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/contention_time
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/memory_contention
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/io_contention
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/m_wait
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/nINT
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/vsync
add wave -noupdate -color yellow /tb/uut/ula/ula_counters/v
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16234531279 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {16232670747 ps} {16239663538 ps}
