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



// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/18.1std/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2018/07/18 $
// $Author: psgswbuild $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module nios_sd_loader_mm_interconnect_0_router_default_decode
  #(
     parameter DEFAULT_CHANNEL = 2,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 16 
   )
  (output [103 - 99 : 0] default_destination_id,
   output [28-1 : 0] default_wr_channel,
   output [28-1 : 0] default_rd_channel,
   output [28-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[103 - 99 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 28'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 28'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 28'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module nios_sd_loader_mm_interconnect_0_router
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [117-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [117-1    : 0] src_data,
    output reg [28-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 60;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 103;
    localparam PKT_DEST_ID_L = 99;
    localparam PKT_PROTECTION_H = 107;
    localparam PKT_PROTECTION_L = 105;
    localparam ST_DATA_W = 117;
    localparam ST_CHANNEL_W = 28;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 63;
    localparam PKT_TRANS_READ  = 64;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h10 - 64'h0); 
    localparam PAD1 = log2ceil(64'h1000000 - 64'h800000); 
    localparam PAD2 = log2ceil(64'h1080000 - 64'h1040000); 
    localparam PAD3 = log2ceil(64'h1081000 - 64'h1080800); 
    localparam PAD4 = log2ceil(64'h1081020 - 64'h1081000); 
    localparam PAD5 = log2ceil(64'h1081040 - 64'h1081020); 
    localparam PAD6 = log2ceil(64'h1081050 - 64'h1081040); 
    localparam PAD7 = log2ceil(64'h1081060 - 64'h1081050); 
    localparam PAD8 = log2ceil(64'h1081070 - 64'h1081060); 
    localparam PAD9 = log2ceil(64'h1081080 - 64'h1081070); 
    localparam PAD10 = log2ceil(64'h1081090 - 64'h1081080); 
    localparam PAD11 = log2ceil(64'h10810a0 - 64'h1081090); 
    localparam PAD12 = log2ceil(64'h10810b0 - 64'h10810a0); 
    localparam PAD13 = log2ceil(64'h10810c0 - 64'h10810b0); 
    localparam PAD14 = log2ceil(64'h10810d0 - 64'h10810c0); 
    localparam PAD15 = log2ceil(64'h10810e0 - 64'h10810d0); 
    localparam PAD16 = log2ceil(64'h10810f0 - 64'h10810e0); 
    localparam PAD17 = log2ceil(64'h1081100 - 64'h10810f0); 
    localparam PAD18 = log2ceil(64'h1081110 - 64'h1081100); 
    localparam PAD19 = log2ceil(64'h1081120 - 64'h1081110); 
    localparam PAD20 = log2ceil(64'h1081130 - 64'h1081120); 
    localparam PAD21 = log2ceil(64'h1081140 - 64'h1081130); 
    localparam PAD22 = log2ceil(64'h1081150 - 64'h1081140); 
    localparam PAD23 = log2ceil(64'h1081160 - 64'h1081150); 
    localparam PAD24 = log2ceil(64'h1081170 - 64'h1081160); 
    localparam PAD25 = log2ceil(64'h1081180 - 64'h1081170); 
    localparam PAD26 = log2ceil(64'h1081190 - 64'h1081180); 
    localparam PAD27 = log2ceil(64'h1081198 - 64'h1081190); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h1081198;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [28-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    nios_sd_loader_mm_interconnect_0_router_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x0 .. 0x10 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 25'h0   ) begin
            src_channel = 28'b0000000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x800000 .. 0x1000000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 25'h800000   ) begin
            src_channel = 28'b0000000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x1040000 .. 0x1080000 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 25'h1040000   ) begin
            src_channel = 28'b0000000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x1080800 .. 0x1081000 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 25'h1080800   ) begin
            src_channel = 28'b0000000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x1081000 .. 0x1081020 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 25'h1081000   ) begin
            src_channel = 28'b0000000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0x1081020 .. 0x1081040 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 25'h1081020   ) begin
            src_channel = 28'b0000000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 27;
    end

    // ( 0x1081040 .. 0x1081050 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 25'h1081040  && read_transaction  ) begin
            src_channel = 28'b1000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x1081050 .. 0x1081060 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 25'h1081050   ) begin
            src_channel = 28'b0100000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x1081060 .. 0x1081070 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 25'h1081060  && read_transaction  ) begin
            src_channel = 28'b0010000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x1081070 .. 0x1081080 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 25'h1081070   ) begin
            src_channel = 28'b0001000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x1081080 .. 0x1081090 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 25'h1081080  && read_transaction  ) begin
            src_channel = 28'b0000100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x1081090 .. 0x10810a0 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 25'h1081090   ) begin
            src_channel = 28'b0000010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x10810a0 .. 0x10810b0 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 25'h10810a0  && read_transaction  ) begin
            src_channel = 28'b0000001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0x10810b0 .. 0x10810c0 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 25'h10810b0   ) begin
            src_channel = 28'b0000000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x10810c0 .. 0x10810d0 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 25'h10810c0   ) begin
            src_channel = 28'b0000000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0x10810d0 .. 0x10810e0 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 25'h10810d0   ) begin
            src_channel = 28'b0000000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0x10810e0 .. 0x10810f0 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 25'h10810e0   ) begin
            src_channel = 28'b0000000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0x10810f0 .. 0x1081100 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 25'h10810f0  && read_transaction  ) begin
            src_channel = 28'b0000000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x1081100 .. 0x1081110 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 25'h1081100  && read_transaction  ) begin
            src_channel = 28'b0000000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

    // ( 0x1081110 .. 0x1081120 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 25'h1081110  && read_transaction  ) begin
            src_channel = 28'b0000000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x1081120 .. 0x1081130 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 25'h1081120  && read_transaction  ) begin
            src_channel = 28'b0000000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x1081130 .. 0x1081140 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 25'h1081130  && read_transaction  ) begin
            src_channel = 28'b0000000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 24;
    end

    // ( 0x1081140 .. 0x1081150 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 25'h1081140   ) begin
            src_channel = 28'b0000000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 25;
    end

    // ( 0x1081150 .. 0x1081160 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 25'h1081150   ) begin
            src_channel = 28'b0000000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x1081160 .. 0x1081170 )
    if ( {address[RG:PAD24],{PAD24{1'b0}}} == 25'h1081160  && read_transaction  ) begin
            src_channel = 28'b0000000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 26;
    end

    // ( 0x1081170 .. 0x1081180 )
    if ( {address[RG:PAD25],{PAD25{1'b0}}} == 25'h1081170   ) begin
            src_channel = 28'b0000000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x1081180 .. 0x1081190 )
    if ( {address[RG:PAD26],{PAD26{1'b0}}} == 25'h1081180   ) begin
            src_channel = 28'b0000000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x1081190 .. 0x1081198 )
    if ( {address[RG:PAD27],{PAD27{1'b0}}} == 25'h1081190   ) begin
            src_channel = 28'b0000000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


