
module sd_nios2_attempt (
	clk_clk,
	key_external_connection_export,
	reset_reset_n,
	sd_clk_external_connection_export,
	sd_cmd_external_connection_export,
	sd_dat_external_connection_export,
	sd_wp_n_external_connection_export);	

	input		clk_clk;
	input	[3:0]	key_external_connection_export;
	input		reset_reset_n;
	output		sd_clk_external_connection_export;
	inout		sd_cmd_external_connection_export;
	inout	[3:0]	sd_dat_external_connection_export;
	input		sd_wp_n_external_connection_export;
endmodule
