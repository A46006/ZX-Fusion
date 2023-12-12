	nios_sd_loader u0 (
		.address_external_connection_export            (<connected-to-address_external_connection_export>),            //            address_external_connection.export
		.bus_ack_n_external_connection_export          (<connected-to-bus_ack_n_external_connection_export>),          //          bus_ack_n_external_connection.export
		.bus_req_n_external_connection_export          (<connected-to-bus_req_n_external_connection_export>),          //          bus_req_n_external_connection.export
		.clk_50_clk                                    (<connected-to-clk_50_clk>),                                    //                                 clk_50.clk
		.cpu_address_direct_external_connection_export (<connected-to-cpu_address_direct_external_connection_export>), // cpu_address_direct_external_connection.export
		.cpu_address_external_connection_export        (<connected-to-cpu_address_external_connection_export>),        //        cpu_address_external_connection.export
		.cpu_cmd_ack_external_connection_export        (<connected-to-cpu_cmd_ack_external_connection_export>),        //        cpu_cmd_ack_external_connection.export
		.cpu_cmd_en_external_connection_export         (<connected-to-cpu_cmd_en_external_connection_export>),         //         cpu_cmd_en_external_connection.export
		.cpu_cmd_external_connection_export            (<connected-to-cpu_cmd_external_connection_export>),            //            cpu_cmd_external_connection.export
		.cpu_int_inf_external_connection_export        (<connected-to-cpu_int_inf_external_connection_export>),        //        cpu_int_inf_external_connection.export
		.cpu_rd_n_external_connection_export           (<connected-to-cpu_rd_n_external_connection_export>),           //           cpu_rd_n_external_connection.export
		.cpu_wr_n_external_connection_export           (<connected-to-cpu_wr_n_external_connection_export>),           //           cpu_wr_n_external_connection.export
		.ctrl_bus_external_connection_export           (<connected-to-ctrl_bus_external_connection_export>),           //           ctrl_bus_external_connection.export
		.data_external_connection_export               (<connected-to-data_external_connection_export>),               //               data_external_connection.export
		.lcd_external_RS                               (<connected-to-lcd_external_RS>),                               //                           lcd_external.RS
		.lcd_external_RW                               (<connected-to-lcd_external_RW>),                               //                                       .RW
		.lcd_external_data                             (<connected-to-lcd_external_data>),                             //                                       .data
		.lcd_external_E                                (<connected-to-lcd_external_E>),                                //                                       .E
		.ledg_pio_external_connection_export           (<connected-to-ledg_pio_external_connection_export>),           //           ledg_pio_external_connection.export
		.nmi_n_external_connection_export              (<connected-to-nmi_n_external_connection_export>),              //              nmi_n_external_connection.export
		.reset_reset_n                                 (<connected-to-reset_reset_n>),                                 //                                  reset.reset_n
		.sd_clk_external_connection_export             (<connected-to-sd_clk_external_connection_export>),             //             sd_clk_external_connection.export
		.sd_cs_external_connection_export              (<connected-to-sd_cs_external_connection_export>),              //              sd_cs_external_connection.export
		.sd_miso_external_connection_export            (<connected-to-sd_miso_external_connection_export>),            //            sd_miso_external_connection.export
		.sd_mosi_external_connection_export            (<connected-to-sd_mosi_external_connection_export>),            //            sd_mosi_external_connection.export
		.sd_wp_n_external_connection_export            (<connected-to-sd_wp_n_external_connection_export>),            //            sd_wp_n_external_connection.export
		.pll_areset_conduit_export                     (<connected-to-pll_areset_conduit_export>),                     //                     pll_areset_conduit.export
		.pll_locked_conduit_export                     (<connected-to-pll_locked_conduit_export>)                      //                     pll_locked_conduit.export
	);

