// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1ps / 1ps

module nios_sd_loader_epcq_controller_0 #(
	parameter CS_WIDTH		= 1,
	parameter DEVICE_FAMILY = "Arria V",
	parameter ADDR_WIDTH	= 24,
	parameter ASI_WIDTH		= 1,
	parameter ENABLE_4BYTE_ADDR = 1,
	parameter ASMI_ADDR_WIDTH = 22,
	parameter CHIP_SELS       = 1
)(
	input 	wire		  						clk,
	input 	wire		  						reset_n,
	                                        			
	// ports to access csr                        			
	input 	wire								avl_csr_write,
	input 	wire		  						avl_csr_read,
	input 	wire 	[2:0] 							avl_csr_addr,
	input 	wire 	[31:0] 							avl_csr_wrdata,
	output 	wire	[31:0] 							avl_csr_rddata,
	output 	wire		 						avl_csr_rddata_valid,
	output 	wire			 					avl_csr_waitrequest,
	                                        			
	// ports to access memory        			
	input	wire		  						avl_mem_write,
	input	wire								avl_mem_read,
	input	wire  	[ADDR_WIDTH-1:0]					avl_mem_addr,			
	input	wire	[31:0]							avl_mem_wrdata,
	input	wire	[6:0]							avl_mem_burstcount,
	input	wire 	[3:0]							avl_mem_byteenable,
	output	wire	[31:0]							avl_mem_rddata,
	output	wire								avl_mem_rddata_valid,
	output 	wire			 					avl_mem_waitrequest,


	// interrupt signal
	output	reg 								irq
);

	wire									asmi_busy;
	wire									asmi_data_valid;
	wire	[7:0]  								asmi_dataout;
	wire									asmi_clkin;
	wire									asmi_reset;
	wire    [ASMI_ADDR_WIDTH-1:0]  				                asmi_addr;
	wire	[7:0]  								asmi_datain;
	wire									asmi_fast_read;
	wire									asmi_rden;
	wire									asmi_shift_bytes;
	wire									asmi_wren;
	wire									asmi_write;
	
	wire									asmi_illegal_erase;
	wire									asmi_illegal_write;
	wire	[7:0]  								asmi_rdid_out;
	wire	[7:0]  								asmi_status_out;
	wire									asmi_read_rdid;
	wire									asmi_read_status;
	wire									asmi_read_sid;
	wire									asmi_bulk_erase;
	wire									asmi_sector_erase;
	wire									asmi_sector_protect;

	nios_sd_loader_epcq_controller_0_epcq_controller_instance_name	#(
		.DEVICE_FAMILY 		(DEVICE_FAMILY),
		.ADDR_WIDTH		(ADDR_WIDTH),
		.ASI_WIDTH		(ASI_WIDTH),
		.ASMI_ADDR_WIDTH   	(ASMI_ADDR_WIDTH),
		.CS_WIDTH		(CS_WIDTH),
		.ENABLE_4BYTE_ADDR	(ENABLE_4BYTE_ADDR),
		.CHIP_SELS              (CHIP_SELS)
	) epcq_controller_inst (
		.clk			     (clk		     ),
		.reset_n                     (reset_n                ),
		.avl_csr_write               (avl_csr_write          ),
		.avl_csr_read                (avl_csr_read           ),
		.avl_csr_addr                (avl_csr_addr           ),
		.avl_csr_wrdata              (avl_csr_wrdata         ),
		.avl_csr_rddata              (avl_csr_rddata         ),
		.avl_csr_rddata_valid        (avl_csr_rddata_valid   ),
		.avl_csr_waitrequest         (avl_csr_waitrequest    ),
		.avl_mem_write               (avl_mem_write          ),
		.avl_mem_read                (avl_mem_read           ),
		.avl_mem_addr		     (avl_mem_addr	     ),					
		.avl_mem_wrdata              (avl_mem_wrdata         ),
		.avl_mem_burstcount          (avl_mem_burstcount     ),
		.avl_mem_byteenable          (avl_mem_byteenable     ),
		.avl_mem_rddata              (avl_mem_rddata         ),
		.avl_mem_rddata_valid        (avl_mem_rddata_valid   ),
		.avl_mem_waitrequest         (avl_mem_waitrequest    ),
		.irq                         (irq                    ),
		.epcq_dataout                ({ASI_WIDTH{1'b0}}	     ),
		.epcq_dclk                   (	         	     ),
		.epcq_scein                  (	         	     ),
		.epcq_sdoin                  (	         	     ),
		.epcq_dataoe                 (	         	     ),
		.ddasi_dataoe                ({ASI_WIDTH{1'b0}}      ),
		.ddasi_dataout               (			     ),
		.ddasi_dclk                  (1'b0	             ),
		.ddasi_scein                 ({CS_WIDTH{1'b0}}       ),
		.ddasi_sdoin                 ({ASI_WIDTH{1'b0}}      ),
		.asmi_busy                   (asmi_busy              ),
		.asmi_data_valid             (asmi_data_valid        ),
		.asmi_dataout                (asmi_dataout           ),
		.asmi_clkin                  (asmi_clkin             ),
		.asmi_reset                  (asmi_reset             ),
		.asmi_sce		     (			     ),
		.asmi_addr                   (asmi_addr              ),
		.asmi_datain                 (asmi_datain            ),
		.asmi_fast_read              (asmi_fast_read         ),
		.asmi_rden                   (asmi_rden              ),
		.asmi_shift_bytes            (asmi_shift_bytes       ),
		.asmi_wren                   (asmi_wren              ),
		.asmi_write                  (asmi_write             ),
		.asmi_illegal_erase          (asmi_illegal_erase     ),
		.asmi_illegal_write          (asmi_illegal_write     ),
		.asmi_rdid_out               (asmi_rdid_out          ),
		.asmi_status_out             (asmi_status_out        ),
		.asmi_epcs_id                ({8{1'b0}}		     ),
		.asmi_read_sid               (			     ),
		.asmi_read_rdid              (asmi_read_rdid         ),
		.asmi_read_status            (asmi_read_status       ),
		.asmi_en4b_addr              (			     ),
		.asmi_bulk_erase             (asmi_bulk_erase        ),
		.asmi_sector_erase           (asmi_sector_erase      ),
		.asmi_sector_protect         (asmi_sector_protect    )
	);
	
	nios_sd_loader_epcq_controller_0_asmi_parallel_instance_name asmi_parallel_inst (
		.busy                   (asmi_busy              ),
		.data_valid             (asmi_data_valid        ),
		.dataout                (asmi_dataout           ),
		.clkin                  (asmi_clkin             ),
		.reset                  (asmi_reset             ),
		.addr                   (asmi_addr		),
		.datain                 (asmi_datain            ),
		.fast_read              (asmi_fast_read         ),
		.rden                   (asmi_rden              ),
		.shift_bytes            (asmi_shift_bytes       ),
		.wren                   (asmi_wren              ),
		.write                  (asmi_write             ),
		.illegal_erase          (asmi_illegal_erase     ),
		.illegal_write          (asmi_illegal_write     ),
		.status_out             (asmi_status_out        ),
                .read_dummyclk		(1'b0                   ),
                .read_rdid              (asmi_read_rdid         ),
                .rdid_out               (asmi_rdid_out          ),
		.read_status            (asmi_read_status       ),
		.bulk_erase             (asmi_bulk_erase        ),
		.sector_erase           (asmi_sector_erase      ),
		.sector_protect         (asmi_sector_protect    )
	);
	
endmodule

