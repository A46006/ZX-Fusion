	nios_sd_loader u0 (
		.address_external_connection_export            (<connected-to-address_external_connection_export>),            //            address_external_connection.export
		.bus_ack_n_external_connection_export          (<connected-to-bus_ack_n_external_connection_export>),          //          bus_ack_n_external_connection.export
		.bus_req_n_external_connection_export          (<connected-to-bus_req_n_external_connection_export>),          //          bus_req_n_external_connection.export
		.clk_clk                                       (<connected-to-clk_clk>),                                       //                                    clk.clk
		.cpu_address_external_connection_export        (<connected-to-cpu_address_external_connection_export>),        //        cpu_address_external_connection.export
		.cpu_cmd_ack_external_connection_export        (<connected-to-cpu_cmd_ack_external_connection_export>),        //        cpu_cmd_ack_external_connection.export
		.cpu_cmd_en_external_connection_export         (<connected-to-cpu_cmd_en_external_connection_export>),         //         cpu_cmd_en_external_connection.export
		.cpu_cmd_external_connection_export            (<connected-to-cpu_cmd_external_connection_export>),            //            cpu_cmd_external_connection.export
		.cpu_rd_n_external_connection_export           (<connected-to-cpu_rd_n_external_connection_export>),           //           cpu_rd_n_external_connection.export
		.cpu_wr_n_external_connection_export           (<connected-to-cpu_wr_n_external_connection_export>),           //           cpu_wr_n_external_connection.export
		.ctrl_bus_external_connection_export           (<connected-to-ctrl_bus_external_connection_export>),           //           ctrl_bus_external_connection.export
		.data_external_connection_export               (<connected-to-data_external_connection_export>),               //               data_external_connection.export
		.ledg_pio_external_connection_export           (<connected-to-ledg_pio_external_connection_export>),           //           ledg_pio_external_connection.export
		.nmi_n_external_connection_export              (<connected-to-nmi_n_external_connection_export>),              //              nmi_n_external_connection.export
		.reset_reset_n                                 (<connected-to-reset_reset_n>),                                 //                                  reset.reset_n
		.sd_clk_external_connection_export             (<connected-to-sd_clk_external_connection_export>),             //             sd_clk_external_connection.export
		.sd_cmd_external_connection_export             (<connected-to-sd_cmd_external_connection_export>),             //             sd_cmd_external_connection.export
		.sd_dat_external_connection_export             (<connected-to-sd_dat_external_connection_export>),             //             sd_dat_external_connection.export
		.sd_wp_n_external_connection_export            (<connected-to-sd_wp_n_external_connection_export>),            //            sd_wp_n_external_connection.export
		.cpu_address_direct_external_connection_export (<connected-to-cpu_address_direct_external_connection_export>)  // cpu_address_direct_external_connection.export
	);

