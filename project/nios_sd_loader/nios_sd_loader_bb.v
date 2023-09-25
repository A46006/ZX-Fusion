
module nios_sd_loader (
	address_external_connection_export,
	bus_ack_n_external_connection_export,
	bus_req_n_external_connection_export,
	clk_clk,
	cpu_address_external_connection_export,
	cpu_cmd_ack_external_connection_export,
	cpu_cmd_en_external_connection_export,
	cpu_cmd_external_connection_export,
	cpu_rd_n_external_connection_export,
	cpu_wr_n_external_connection_export,
	ctrl_bus_external_connection_export,
	data_external_connection_export,
	ledg_pio_external_connection_export,
	nmi_n_external_connection_export,
	reset_reset_n,
	sd_clk_external_connection_export,
	sd_cmd_external_connection_export,
	sd_dat_external_connection_export,
	sd_wp_n_external_connection_export,
	cpu_address_direct_external_connection_export);	

	output	[15:0]	address_external_connection_export;
	input		bus_ack_n_external_connection_export;
	output		bus_req_n_external_connection_export;
	input		clk_clk;
	input	[15:0]	cpu_address_external_connection_export;
	output		cpu_cmd_ack_external_connection_export;
	input		cpu_cmd_en_external_connection_export;
	input	[7:0]	cpu_cmd_external_connection_export;
	input		cpu_rd_n_external_connection_export;
	input		cpu_wr_n_external_connection_export;
	output	[3:0]	ctrl_bus_external_connection_export;
	inout	[7:0]	data_external_connection_export;
	output	[7:0]	ledg_pio_external_connection_export;
	output		nmi_n_external_connection_export;
	input		reset_reset_n;
	output		sd_clk_external_connection_export;
	inout		sd_cmd_external_connection_export;
	inout	[3:0]	sd_dat_external_connection_export;
	input		sd_wp_n_external_connection_export;
	input	[15:0]	cpu_address_direct_external_connection_export;
endmodule
