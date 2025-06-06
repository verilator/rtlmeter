// Copyright (c) 2015 Princeton University
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Princeton University nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

`include "define.tmp.h"
`include "piton_system.vh"
`include "mc_define.h"
`ifdef PITONSYS_AXI4_MEM
`include "noc_axi4_bridge_define.vh"
`endif
`include "uart16550_define.vh"
`include "chipset_define.vh"

// Filename: chipset_impl.v
// Author: mmckeown
// Description: Top-level chipset implementation.  Instantiates
//              different versions of chipsets based on different
//              macros.  Some logic is common to all chipset implementations.

// Macros used in this file:
//  PITON_FPGA_MC_DDR3                  Set to indicate an FPGA implementation will
//                                      use a DDR2/3 memory controller.  If
//                                      this is not set, a default "fake"
//                                      simulated DRAM is used.
//  PITONSYS_NO_MC                      If set, no memory controller is used. This is used
//                                      in the testing of the Piton system, where a small test
//                                      can be run on the chip with DRAM
//                                      emulated in BRAMs
//  PITONSYS_IOCTRL                     Set to use real I/O controller, otherwise a fake I/O bridge
//                                      is used and emulates I/O in PLI C calls.  This may not be compatible
//                                      with the "fake" memory controller or no memory controller at all
//  PITONSYS_UART                       Set to include a UART in the Piton system chipset.  The UART
//                                      can be used as an I/O device and/or a device for bootloading
//                                      test programs (see PITONSYS_UART_BOOT)
//  PITONSYS_UART_LOOBACK               Set to looback UART to itself.  Used for testing purposes
//  PITONSYS_UART_BOOT                  Set for UART boot hardware to be included.  If this is the
//                                      only boot option set, it is always used.  If there is another
//                                      boot option, a switch can be used to enable UART boot
//  PITONSYS_SPI                        Set to include a SPI in the Piton system chipset.  SPI is generally
//                                      used for SD card boot, but could potentially be used for other
//                                      purposes
//  NEXYS4DDR_BOARD NEXYSVIDEO_BOARD    Used to indicate which board this code is
//                                      being synthesized for. There are more than just these
// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml


module chipset_impl(
    // Clocks and resets
    input                                       chipset_clk,
    input                                       chipset_rst_n,
    input                                       piton_ready_n,

    output                                      test_start,
    output                                      uart_rst_out_n,

    // invalid access inside packet filter
    output                                      invalid_access_o,

`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
`ifndef F1_BOARD
`ifdef PITONSYS_DDR4
    input                                       mc_clk_p,
    input                                       mc_clk_n,
`else  // PITONSYS_DDR4
    input                                       mc_clk,
`endif // PITONSYS_DDR4
`endif // ifndef F1_BOARD
`endif // endif PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC

    // Main chip interface
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc1,
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc2,
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc3,
    output                                      chipset_intf_val_noc1,
    output                                      chipset_intf_val_noc2,
    output                                      chipset_intf_val_noc3,
    input                                       chipset_intf_rdy_noc1,
    input                                       chipset_intf_rdy_noc2,
    input                                       chipset_intf_rdy_noc3,

    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc1,
    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc2,
    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc3,
    input                                       intf_chipset_val_noc1,
    input                                       intf_chipset_val_noc2,
    input                                       intf_chipset_val_noc3,
    output                                      intf_chipset_rdy_noc1,
    output                                      intf_chipset_rdy_noc2,
    output                                      intf_chipset_rdy_noc3

    // DRAM and I/O interfaces
`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
    ,
    output                                      init_calib_complete
`ifndef F1_BOARD
    // Generalized interface for any FPGA board we support.
    // Not all signals will be used for all FPGA boards (see constraints)
`ifdef PITONSYS_DDR4
    ,
    output                                      ddr_act_n,
    output [`DDR3_BG_WIDTH-1:0]                 ddr_bg,
`else // PITONSYS_DDR4
    ,
    output                                      ddr_cas_n,
    output                                      ddr_ras_n,
    output                                      ddr_we_n,
`endif // PITONSYS_DDR4
    output [`DDR3_ADDR_WIDTH-1:0]               ddr_addr,
    output [`DDR3_BA_WIDTH-1:0]                 ddr_ba,
    output [`DDR3_CK_WIDTH-1:0]                 ddr_ck_n,
    output [`DDR3_CK_WIDTH-1:0]                 ddr_ck_p,
    output [`DDR3_CKE_WIDTH-1:0]                ddr_cke,
    output                                      ddr_reset_n,
    inout  [`DDR3_DQ_WIDTH-1:0]                 ddr_dq,
    inout  [`DDR3_DQS_WIDTH-1:0]                ddr_dqs_n,
    inout  [`DDR3_DQS_WIDTH-1:0]                ddr_dqs_p,
`ifndef NEXYSVIDEO_BOARD
    output [`DDR3_CS_WIDTH-1:0]                 ddr_cs_n,
`endif // endif NEXYSVIDEO_BOARD
`ifdef PITONSYS_DDR4
`ifdef XUPP3R_BOARD
    output                                      ddr_parity,
`else
    inout [`DDR3_DM_WIDTH-1:0]                  ddr_dm,
`endif // XUPP3R_BOARD
`else // PITONSYS_DDR4
    output [`DDR3_DM_WIDTH-1:0]                 ddr_dm,
`endif // PITONSYS_DDR4
    output [`DDR3_ODT_WIDTH-1:0]                ddr_odt
`else // ifndef F1_BOARD
    // AXI Write Address Channel Signals
    ,
    input                                        mc_clk,
    output wire [`AXI4_ID_WIDTH     -1:0]    m_axi_awid,
    output wire [`AXI4_ADDR_WIDTH   -1:0]    m_axi_awaddr,
    output wire [`AXI4_LEN_WIDTH    -1:0]    m_axi_awlen,
    output wire [`AXI4_SIZE_WIDTH   -1:0]    m_axi_awsize,
    output wire [`AXI4_BURST_WIDTH  -1:0]    m_axi_awburst,
    output wire                                  m_axi_awlock,
    output wire [`AXI4_CACHE_WIDTH  -1:0]    m_axi_awcache,
    output wire [`AXI4_PROT_WIDTH   -1:0]    m_axi_awprot,
    output wire [`AXI4_QOS_WIDTH    -1:0]    m_axi_awqos,
    output wire [`AXI4_REGION_WIDTH -1:0]    m_axi_awregion,
    output wire [`AXI4_USER_WIDTH   -1:0]    m_axi_awuser,
    output wire                                  m_axi_awvalid,
    input  wire                                  m_axi_awready,

    // AXI Write Data Channel Signals
    output wire  [`AXI4_ID_WIDTH     -1:0]    m_axi_wid,
    output wire  [`AXI4_DATA_WIDTH   -1:0]    m_axi_wdata,
    output wire  [`AXI4_STRB_WIDTH   -1:0]    m_axi_wstrb,
    output wire                                   m_axi_wlast,
    output wire  [`AXI4_USER_WIDTH   -1:0]    m_axi_wuser,
    output wire                                   m_axi_wvalid,
    input  wire                                   m_axi_wready,

    // AXI Read Address Channel Signals
    output wire  [`AXI4_ID_WIDTH     -1:0]    m_axi_arid,
    output wire  [`AXI4_ADDR_WIDTH   -1:0]    m_axi_araddr,
    output wire  [`AXI4_LEN_WIDTH    -1:0]    m_axi_arlen,
    output wire  [`AXI4_SIZE_WIDTH   -1:0]    m_axi_arsize,
    output wire  [`AXI4_BURST_WIDTH  -1:0]    m_axi_arburst,
    output wire                                   m_axi_arlock,
    output wire  [`AXI4_CACHE_WIDTH  -1:0]    m_axi_arcache,
    output wire  [`AXI4_PROT_WIDTH   -1:0]    m_axi_arprot,
    output wire  [`AXI4_QOS_WIDTH    -1:0]    m_axi_arqos,
    output wire  [`AXI4_REGION_WIDTH -1:0]    m_axi_arregion,
    output wire  [`AXI4_USER_WIDTH   -1:0]    m_axi_aruser,
    output wire                                   m_axi_arvalid,
    input  wire                                   m_axi_arready,

    // AXI Read Data Channel Signals
    input  wire  [`AXI4_ID_WIDTH     -1:0]    m_axi_rid,
    input  wire  [`AXI4_DATA_WIDTH   -1:0]    m_axi_rdata,
    input  wire  [`AXI4_RESP_WIDTH   -1:0]    m_axi_rresp,
    input  wire                                   m_axi_rlast,
    input  wire  [`AXI4_USER_WIDTH   -1:0]    m_axi_ruser,
    input  wire                                   m_axi_rvalid,
    output wire                                   m_axi_rready,

    // AXI Write Response Channel Signals
    input  wire  [`AXI4_ID_WIDTH     -1:0]    m_axi_bid,
    input  wire  [`AXI4_RESP_WIDTH   -1:0]    m_axi_bresp,
    input  wire  [`AXI4_USER_WIDTH   -1:0]    m_axi_buser,
    input  wire                                   m_axi_bvalid,
    output wire                                   m_axi_bready, 

    input  wire                                   ddr_ready
`endif // ifndef F1_BOARD
`endif // ifdef PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC

`ifdef PITONSYS_IOCTRL
`ifdef PITONSYS_UART
    ,
    output                                      uart_tx,
    input                                       uart_rx
`ifdef PITONSYS_UART_BOOT
    ,
    input                                       uart_boot_en,
    input                                       uart_timeout_en
`endif // endif PITONSYS_UART_BOOT
`endif // endif PITONSYS_UART

`ifdef PITONSYS_SPI
    ,
    input                                       sd_clk,
    input                                       sd_cd,
    output                                      sd_reset,
    output                                      sd_clk_out,
    inout                                       sd_cmd,
    inout   [3:0]                               sd_dat
`endif // endif PITONSYS_SPI
`ifdef PITON_FPGA_ETHERNETLITE
    ,
    input                                       net_axi_clk,
    output                                      net_phy_rst_n,

    input                                       net_phy_tx_clk,
    output                                      net_phy_tx_en,
    output  [3 : 0]                             net_phy_tx_data,

    input                                       net_phy_rx_clk,
    input                                       net_phy_dv,
    input  [3 : 0]                              net_phy_rx_data,
    input                                       net_phy_rx_er,

    inout                                       net_phy_mdio_io,
    output                                      net_phy_mdc
`endif // PITON_FPGA_ETHERNETLITE
`endif // endif PITONSYS_IO_CTRL
`ifdef PITON_RV64_PLATFORM
`ifdef PITON_RV64_DEBUGUNIT
    // Debug
,   output                                      ndmreset_o      // non-debug module reset
,   output                                      dmactive_o      // debug module is active
,   output [`PITON_NUM_TILES-1:0]               debug_req_o     // async debug request
,   input  [`PITON_NUM_TILES-1:0]               unavailable_i   // communicate whether the hart is unavailable (e.g.: power down)
    // JTAG
,   input                                       tck_i
,   input                                       tms_i
,   input                                       trst_ni
,   input                                       td_i
,   output                                      td_o
,   output                                      tdo_oe_o
`endif // ifdef PITON_RV64_DEBUGUNIT

`ifdef PITON_RV64_CLINT
    // CLINT
,   input                                       rtc_i           // Real-time clock in (usually 32.768 kHz)
,   output [`PITON_NUM_TILES-1:0]               timer_irq_o     // Timer interrupts
,   output [`PITON_NUM_TILES-1:0]               ipi_o           // software interrupt (a.k.a inter-process-interrupt)
`endif // ifdef PITON_RV64_CLINT

`ifdef PITON_RV64_PLIC
    // PLIC
,   output [`PITON_NUM_TILES*2-1:0]             irq_o           // level sensitive IR lines, mip & sip (async)
`endif // ifdef PITON_RV64_PLIC
`endif // ifdef PITON_RV64_PLATFORM
);

///////////////////////
// Type declarations //
///////////////////////
wire                                            mc_ui_clk_sync_rst;

reg                                             init_calib_complete_f;
reg                                             init_calib_complete_ff;

reg                                             io_ctrl_rst_n;

`ifndef PITONSYS_IOCTRL
wire                                            uart_boot_en;
wire                                            uart_timeout_en;
`else // ifdef PITONSYS_IOCTRL
`ifndef PITONSYS_UART
wire                                            uart_boot_en;
wire                                            uart_timeout_en;
`else // ifdef PITONSYS_UART
`ifndef PITONSYS_UART_BOOT
wire                                            uart_boot_en;
wire                                            uart_timeout_en;
`endif // endif PITONSYS_UART_BOOT
`endif // endif PITONSYS_UART
`endif // endif PITONSYS_IOCTRL

wire                                            cpu_mem_traffic;
wire                                            chip_filter_noc2_valid;
wire    [`NOC_DATA_WIDTH-1:0]                   chip_filter_noc2_data;
wire                                            filter_chip_noc2_ready;
wire                                            filter_chip_noc3_valid;
wire    [`NOC_DATA_WIDTH-1:0]                   filter_chip_noc3_data;
wire                                            chip_filter_noc3_ready;


wire                                            test_good_end;
wire                                            test_bad_end;


wire [`DATA_WIDTH-1:0] chip_buf_xbar_noc2_data;
wire                   chip_buf_xbar_noc2_valid;
wire                   chip_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_chip_noc2_data;
wire                   xbar_buf_chip_noc2_valid;
wire                   xbar_buf_chip_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_chip_noc2_data;
wire                   buf_chip_noc2_valid;
wire                   chip_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] chip_buf_noc2_data;
wire                   chip_buf_noc2_valid;
wire                   buf_chip_noc2_ready;


wire [`DATA_WIDTH-1:0] chip_buf_xbar_noc3_data;
wire                   chip_buf_xbar_noc3_valid;
wire                   chip_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_chip_noc3_data;
wire                   xbar_buf_chip_noc3_valid;
wire                   xbar_buf_chip_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_chip_noc3_data;
wire                   buf_chip_noc3_valid;
wire                   chip_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] chip_buf_noc3_data;
wire                   chip_buf_noc3_valid;
wire                   buf_chip_noc3_ready;


wire [`DATA_WIDTH-1:0] mem_buf_xbar_noc2_data;
wire                   mem_buf_xbar_noc2_valid;
wire                   mem_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_mem_noc2_data;
wire                   xbar_buf_mem_noc2_valid;
wire                   xbar_buf_mem_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_mem_noc2_data;
wire                   buf_mem_noc2_valid;
wire                   mem_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] mem_buf_noc2_data;
wire                   mem_buf_noc2_valid;
wire                   buf_mem_noc2_ready;


wire [`DATA_WIDTH-1:0] mem_buf_xbar_noc3_data;
wire                   mem_buf_xbar_noc3_valid;
wire                   mem_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_mem_noc3_data;
wire                   xbar_buf_mem_noc3_valid;
wire                   xbar_buf_mem_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_mem_noc3_data;
wire                   buf_mem_noc3_valid;
wire                   mem_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] mem_buf_noc3_data;
wire                   mem_buf_noc3_valid;
wire                   buf_mem_noc3_ready;


assign mem_buf_noc2_data = `DATA_WIDTH'b0;
assign mem_buf_noc2_valid = 1'b0;
assign mem_buf_noc3_ready = 1'b0;


wire [`DATA_WIDTH-1:0] iob_buf_xbar_noc2_data;
wire                   iob_buf_xbar_noc2_valid;
wire                   iob_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_iob_noc2_data;
wire                   xbar_buf_iob_noc2_valid;
wire                   xbar_buf_iob_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_iob_noc2_data;
wire                   buf_iob_noc2_valid;
wire                   iob_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] iob_buf_noc2_data;
wire                   iob_buf_noc2_valid;
wire                   buf_iob_noc2_ready;


wire [`DATA_WIDTH-1:0] iob_buf_xbar_noc3_data;
wire                   iob_buf_xbar_noc3_valid;
wire                   iob_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_iob_noc3_data;
wire                   xbar_buf_iob_noc3_valid;
wire                   xbar_buf_iob_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_iob_noc3_data;
wire                   buf_iob_noc3_valid;
wire                   iob_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] iob_buf_noc3_data;
wire                   iob_buf_noc3_valid;
wire                   buf_iob_noc3_ready;


wire [`DATA_WIDTH-1:0]            iob_filter_noc2_data;
wire                              iob_filter_noc2_valid;
wire                              filter_iob_noc2_ready;


wire [`DATA_WIDTH-1:0]             filter_iob_noc3_data;
wire                               filter_iob_noc3_valid;
wire                               iob_filter_noc3_ready;


wire [`DATA_WIDTH-1:0] uart_buf_xbar_noc2_data;
wire                   uart_buf_xbar_noc2_valid;
wire                   uart_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_uart_noc2_data;
wire                   xbar_buf_uart_noc2_valid;
wire                   xbar_buf_uart_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_uart_noc2_data;
wire                   buf_uart_noc2_valid;
wire                   uart_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] uart_buf_noc2_data;
wire                   uart_buf_noc2_valid;
wire                   buf_uart_noc2_ready;


wire [`DATA_WIDTH-1:0] uart_buf_xbar_noc3_data;
wire                   uart_buf_xbar_noc3_valid;
wire                   uart_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_uart_noc3_data;
wire                   xbar_buf_uart_noc3_valid;
wire                   xbar_buf_uart_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_uart_noc3_data;
wire                   buf_uart_noc3_valid;
wire                   uart_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] uart_buf_noc3_data;
wire                   uart_buf_noc3_valid;
wire                   buf_uart_noc3_ready;


wire [`DATA_WIDTH-1:0]            uart_filter_noc2_data;
wire                              uart_filter_noc2_valid;
wire                              filter_uart_noc2_ready;


wire [`DATA_WIDTH-1:0]             filter_uart_noc3_data;
wire                               filter_uart_noc3_valid;
wire                               uart_filter_noc3_ready;


wire [`DATA_WIDTH-1:0] ariane_debug_buf_xbar_noc2_data;
wire                   ariane_debug_buf_xbar_noc2_valid;
wire                   ariane_debug_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_debug_noc2_data;
wire                   xbar_buf_ariane_debug_noc2_valid;
wire                   xbar_buf_ariane_debug_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_debug_noc2_data;
wire                   buf_ariane_debug_noc2_valid;
wire                   ariane_debug_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] ariane_debug_buf_noc2_data;
wire                   ariane_debug_buf_noc2_valid;
wire                   buf_ariane_debug_noc2_ready;


wire [`DATA_WIDTH-1:0] ariane_debug_buf_xbar_noc3_data;
wire                   ariane_debug_buf_xbar_noc3_valid;
wire                   ariane_debug_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_debug_noc3_data;
wire                   xbar_buf_ariane_debug_noc3_valid;
wire                   xbar_buf_ariane_debug_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_debug_noc3_data;
wire                   buf_ariane_debug_noc3_valid;
wire                   ariane_debug_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] ariane_debug_buf_noc3_data;
wire                   ariane_debug_buf_noc3_valid;
wire                   buf_ariane_debug_noc3_ready;


assign ariane_debug_buf_noc2_data = `DATA_WIDTH'b0;
assign ariane_debug_buf_noc2_valid = 1'b0;
assign ariane_debug_buf_noc3_ready = 1'b0;


wire [`DATA_WIDTH-1:0] ariane_bootrom_buf_xbar_noc2_data;
wire                   ariane_bootrom_buf_xbar_noc2_valid;
wire                   ariane_bootrom_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_bootrom_noc2_data;
wire                   xbar_buf_ariane_bootrom_noc2_valid;
wire                   xbar_buf_ariane_bootrom_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_bootrom_noc2_data;
wire                   buf_ariane_bootrom_noc2_valid;
wire                   ariane_bootrom_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] ariane_bootrom_buf_noc2_data;
wire                   ariane_bootrom_buf_noc2_valid;
wire                   buf_ariane_bootrom_noc2_ready;


wire [`DATA_WIDTH-1:0] ariane_bootrom_buf_xbar_noc3_data;
wire                   ariane_bootrom_buf_xbar_noc3_valid;
wire                   ariane_bootrom_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_bootrom_noc3_data;
wire                   xbar_buf_ariane_bootrom_noc3_valid;
wire                   xbar_buf_ariane_bootrom_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_bootrom_noc3_data;
wire                   buf_ariane_bootrom_noc3_valid;
wire                   ariane_bootrom_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] ariane_bootrom_buf_noc3_data;
wire                   ariane_bootrom_buf_noc3_valid;
wire                   buf_ariane_bootrom_noc3_ready;


assign ariane_bootrom_buf_noc2_data = `DATA_WIDTH'b0;
assign ariane_bootrom_buf_noc2_valid = 1'b0;
assign ariane_bootrom_buf_noc3_ready = 1'b0;


wire [`DATA_WIDTH-1:0] ariane_clint_buf_xbar_noc2_data;
wire                   ariane_clint_buf_xbar_noc2_valid;
wire                   ariane_clint_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_clint_noc2_data;
wire                   xbar_buf_ariane_clint_noc2_valid;
wire                   xbar_buf_ariane_clint_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_clint_noc2_data;
wire                   buf_ariane_clint_noc2_valid;
wire                   ariane_clint_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] ariane_clint_buf_noc2_data;
wire                   ariane_clint_buf_noc2_valid;
wire                   buf_ariane_clint_noc2_ready;


wire [`DATA_WIDTH-1:0] ariane_clint_buf_xbar_noc3_data;
wire                   ariane_clint_buf_xbar_noc3_valid;
wire                   ariane_clint_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_clint_noc3_data;
wire                   xbar_buf_ariane_clint_noc3_valid;
wire                   xbar_buf_ariane_clint_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_clint_noc3_data;
wire                   buf_ariane_clint_noc3_valid;
wire                   ariane_clint_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] ariane_clint_buf_noc3_data;
wire                   ariane_clint_buf_noc3_valid;
wire                   buf_ariane_clint_noc3_ready;


assign ariane_clint_buf_noc2_data = `DATA_WIDTH'b0;
assign ariane_clint_buf_noc2_valid = 1'b0;
assign ariane_clint_buf_noc3_ready = 1'b0;


wire [`DATA_WIDTH-1:0] ariane_plic_buf_xbar_noc2_data;
wire                   ariane_plic_buf_xbar_noc2_valid;
wire                   ariane_plic_buf_xbar_noc2_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_plic_noc2_data;
wire                   xbar_buf_ariane_plic_noc2_valid;
wire                   xbar_buf_ariane_plic_noc2_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_plic_noc2_data;
wire                   buf_ariane_plic_noc2_valid;
wire                   ariane_plic_buf_noc2_ready;

wire [`DATA_WIDTH-1:0] ariane_plic_buf_noc2_data;
wire                   ariane_plic_buf_noc2_valid;
wire                   buf_ariane_plic_noc2_ready;


wire [`DATA_WIDTH-1:0] ariane_plic_buf_xbar_noc3_data;
wire                   ariane_plic_buf_xbar_noc3_valid;
wire                   ariane_plic_buf_xbar_noc3_yummy;
wire [`DATA_WIDTH-1:0] xbar_buf_ariane_plic_noc3_data;
wire                   xbar_buf_ariane_plic_noc3_valid;
wire                   xbar_buf_ariane_plic_noc3_yummy;

wire [`DATA_WIDTH-1:0] buf_ariane_plic_noc3_data;
wire                   buf_ariane_plic_noc3_valid;
wire                   ariane_plic_buf_noc3_ready;

wire [`DATA_WIDTH-1:0] ariane_plic_buf_noc3_data;
wire                   ariane_plic_buf_noc3_valid;
wire                   buf_ariane_plic_noc3_ready;


assign ariane_plic_buf_noc2_data = `DATA_WIDTH'b0;
assign ariane_plic_buf_noc2_valid = 1'b0;
assign ariane_plic_buf_noc3_ready = 1'b0;



//////////////////////
// Sequential Logic //
//////////////////////

`ifdef PITONSYS_IOCTRL
`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
always @ (posedge chipset_clk)
begin
    init_calib_complete_f <= init_calib_complete;
    init_calib_complete_ff <= init_calib_complete_f;
end
`endif // endif PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC
`endif // endif PITONSYS_IOCTRL

/////////////////////////
// Combinational Logic //
/////////////////////////

// Currently NoC 1 from chipset to interface is not used
// by any chipset implementation
assign chipset_intf_data_noc1 = {`NOC_DATA_WIDTH{1'b0}};
assign chipset_intf_val_noc1 = 1'b0;

// Currently NoC 3 from interface to chipset is not used
// by any chipset implementation
assign intf_chipset_rdy_noc3 = 1'b0;
assign chip_buf_noc3_valid = 1'b0;
assign chip_buf_noc3_data = {`NOC_DATA_WIDTH{1'b0}};

`ifdef PITONSYS_NO_MC
`ifndef PITON_FPGA_SYNTH
    // Tie off splitter memory interface
    assign mem_buf_noc2_ready = 1'b0;
    assign mem_buf_noc3_valid = 1'b0;
    assign mem_buf_noc3_data = {`NOC_DATA_WIDTH{1'b0}};
`endif // endif PITON_FPGA_SYNTH
`endif // endif PITONSYS_NO_MC


`ifdef PITONSYS_IOCTRL
    always @ *
    begin
    `ifndef PITONSYS_NO_MC
    `ifdef PITON_FPGA_MC_DDR3
        // Reset I/O ctrl as long as DRAM ctrl is not reset
        // and not calibrated or initialized
        io_ctrl_rst_n = ~mc_ui_clk_sync_rst & init_calib_complete_ff;
    `else // ifndef PITON_FPGA_MC_DDR3
        io_ctrl_rst_n = chipset_rst_n;
    `endif // endif PITON_FPGA_MC_DDR3
    `else // ifdef PITONSYS_NO_MC
        io_ctrl_rst_n = chipset_rst_n;
    `endif // PITONSYS_NO_MC
    end
`endif // endif PITONSYS_IOCTRL

`ifndef PITONSYS_IOCTRL
    assign uart_boot_en = 1'b0;
    assign uart_timeout_en = 1'b0;
`else // ifdef PITONSYS_IOCTRL
    `ifndef PITONSYS_UART
        assign uart_boot_en = 1'b0;
        assign uart_timeout_en = 1'b0;
    `else // ifdef PITONSYS_UART
        `ifndef PITONSYS_UART_BOOT
            assign uart_boot_en = 1'b0;
            assign uart_timeout_en = 1'b0;
        `endif // endif PITONSYS_UART_BOOT
    `endif // endif PITONSYS_UART
`endif // endif PITONSYS_IOCTRL

//////////////////////////
// Sub-module Instances //
//////////////////////////
`ifdef PITONSYS_IOCTRL
    assign cpu_mem_traffic = test_start | (~uart_boot_en);
`else
    assign cpu_mem_traffic = 1'b1;
`endif

assign chipset_intf_val_noc2 = buf_chip_noc2_valid;
assign chipset_intf_data_noc2 = buf_chip_noc2_data;
assign chip_buf_noc2_ready = chipset_intf_rdy_noc2;

assign chip_filter_noc2_valid = intf_chipset_val_noc2;
assign chip_filter_noc2_data = intf_chipset_data_noc2;
assign intf_chipset_rdy_noc2    = filter_chip_noc2_ready & cpu_mem_traffic;

// NoC 3
assign chipset_intf_val_noc3    = cpu_mem_traffic & filter_chip_noc3_valid;
assign chipset_intf_data_noc3   = filter_chip_noc3_data;

assign chip_filter_noc3_ready  = cpu_mem_traffic ? chipset_intf_rdy_noc3 : 1'b1;

`ifdef PITONSYS_UART_BOOT
test_end_checker test_end_checker(
    .clk                    (chipset_clk),
    .rst_n                  (chipset_rst_n),

    .src_checker_noc2_val   (chip_filter_noc2_valid),
    .src_checker_noc2_data  (chip_filter_noc2_data),
    .src_checker_noc2_rdy   (filter_chip_noc2_ready),

    .uart_boot_en           (uart_boot_en),
    .test_good_end          (test_good_end),
    .test_bad_end           (test_bad_end)
);
`else
    assign test_good_end = 1'b0;
    assign test_bad_end = 1'b0;
`endif


wire [3-1:0] invalid_access;
assign invalid_access_o = |invalid_access;


packet_filter chip_packet_filter(
    .clk(chipset_clk),
    .rst_n(chipset_rst_n),
    // need to connect this to a LED
    .invalid_access_o(invalid_access[0]),

    // noc2 to filter wires
    .noc2_filter_val(chip_filter_noc2_valid),
    .noc2_filter_data(chip_filter_noc2_data),
    .filter_noc2_rdy(filter_chip_noc2_ready),

    // filter to noc3 wires
    .filter_noc3_val(filter_chip_noc3_valid),
    .filter_noc3_data(filter_chip_noc3_data),
    .noc3_filter_rdy(chip_filter_noc3_ready),

    // filter to xbar wires
    .filter_xbar_val(chip_buf_noc2_valid),
    .filter_xbar_data(chip_buf_noc2_data),
    .xbar_filter_rdy(buf_chip_noc2_ready),

    // xbar to filter wires
    .xbar_filter_val(buf_chip_noc3_valid),
    .xbar_filter_data(buf_chip_noc3_data),
    .filter_xbar_rdy(chip_buf_noc3_ready),

    .uart_boot_en(uart_boot_en)
);


packet_filter iob_packet_filter(
    .clk(chipset_clk),
    .rst_n(chipset_rst_n),
    // need to connect this to a LED
    .invalid_access_o(invalid_access[1]),

    // noc2 to filter wires
    .noc2_filter_val(iob_filter_noc2_valid),
    .noc2_filter_data(iob_filter_noc2_data),
    .filter_noc2_rdy(filter_iob_noc2_ready),

    // filter to noc3 wires
    .filter_noc3_val(filter_iob_noc3_valid),
    .filter_noc3_data(filter_iob_noc3_data),
    .noc3_filter_rdy(iob_filter_noc3_ready),

    // filter to xbar wires
    .filter_xbar_val(iob_buf_noc2_valid),
    .filter_xbar_data(iob_buf_noc2_data),
    .xbar_filter_rdy(buf_iob_noc2_ready),

    // xbar to filter wires
    .xbar_filter_val(buf_iob_noc3_valid),
    .xbar_filter_data(buf_iob_noc3_data),
    .filter_xbar_rdy(iob_buf_noc3_ready),

    .uart_boot_en(uart_boot_en)
);


packet_filter uart_packet_filter(
    .clk(chipset_clk),
    .rst_n(chipset_rst_n),
    // need to connect this to a LED
    .invalid_access_o(invalid_access[2]),

    // noc2 to filter wires
    .noc2_filter_val(uart_filter_noc2_valid),
    .noc2_filter_data(uart_filter_noc2_data),
    .filter_noc2_rdy(filter_uart_noc2_ready),

    // filter to noc3 wires
    .filter_noc3_val(filter_uart_noc3_valid),
    .filter_noc3_data(filter_uart_noc3_data),
    .noc3_filter_rdy(uart_filter_noc3_ready),

    // filter to xbar wires
    .filter_xbar_val(uart_buf_noc2_valid),
    .filter_xbar_data(uart_buf_noc2_data),
    .xbar_filter_rdy(buf_uart_noc2_ready),

    // xbar to filter wires
    .xbar_filter_val(buf_uart_noc3_valid),
    .xbar_filter_data(buf_uart_noc3_data),
    .filter_xbar_rdy(uart_buf_noc3_ready),

    .uart_boot_en(uart_boot_en)
);




io_xbar_top_wrap io_xbar_noc2 (
    .clk                (chipset_clk),
    .reset_in           (~chipset_rst_n),

    .myChipID                   (14'b10000000000000),    // the first chip
    .myLocX                     (8'b0),  // not used
    .myLocY                     (8'b0),  // not used

    .dataIn_0(chip_buf_xbar_noc2_data),
    .validIn_0(chip_buf_xbar_noc2_valid),
    .yummyIn_0(chip_buf_xbar_noc2_yummy),
    .dataOut_0(xbar_buf_chip_noc2_data),
    .validOut_0(xbar_buf_chip_noc2_valid),
    .yummyOut_0(xbar_buf_chip_noc2_yummy),

    .dataIn_1(mem_buf_xbar_noc2_data),
    .validIn_1(mem_buf_xbar_noc2_valid),
    .yummyIn_1(mem_buf_xbar_noc2_yummy),
    .dataOut_1(xbar_buf_mem_noc2_data),
    .validOut_1(xbar_buf_mem_noc2_valid),
    .yummyOut_1(xbar_buf_mem_noc2_yummy),

    .dataIn_2(iob_buf_xbar_noc2_data),
    .validIn_2(iob_buf_xbar_noc2_valid),
    .yummyIn_2(iob_buf_xbar_noc2_yummy),
    .dataOut_2(xbar_buf_iob_noc2_data),
    .validOut_2(xbar_buf_iob_noc2_valid),
    .yummyOut_2(xbar_buf_iob_noc2_yummy),

    .dataIn_3(uart_buf_xbar_noc2_data),
    .validIn_3(uart_buf_xbar_noc2_valid),
    .yummyIn_3(uart_buf_xbar_noc2_yummy),
    .dataOut_3(xbar_buf_uart_noc2_data),
    .validOut_3(xbar_buf_uart_noc2_valid),
    .yummyOut_3(xbar_buf_uart_noc2_yummy),

    .dataIn_4(ariane_debug_buf_xbar_noc2_data),
    .validIn_4(ariane_debug_buf_xbar_noc2_valid),
    .yummyIn_4(ariane_debug_buf_xbar_noc2_yummy),
    .dataOut_4(xbar_buf_ariane_debug_noc2_data),
    .validOut_4(xbar_buf_ariane_debug_noc2_valid),
    .yummyOut_4(xbar_buf_ariane_debug_noc2_yummy),

    .dataIn_5(ariane_bootrom_buf_xbar_noc2_data),
    .validIn_5(ariane_bootrom_buf_xbar_noc2_valid),
    .yummyIn_5(ariane_bootrom_buf_xbar_noc2_yummy),
    .dataOut_5(xbar_buf_ariane_bootrom_noc2_data),
    .validOut_5(xbar_buf_ariane_bootrom_noc2_valid),
    .yummyOut_5(xbar_buf_ariane_bootrom_noc2_yummy),

    .dataIn_6(ariane_clint_buf_xbar_noc2_data),
    .validIn_6(ariane_clint_buf_xbar_noc2_valid),
    .yummyIn_6(ariane_clint_buf_xbar_noc2_yummy),
    .dataOut_6(xbar_buf_ariane_clint_noc2_data),
    .validOut_6(xbar_buf_ariane_clint_noc2_valid),
    .yummyOut_6(xbar_buf_ariane_clint_noc2_yummy),

    .dataIn_7(ariane_plic_buf_xbar_noc2_data),
    .validIn_7(ariane_plic_buf_xbar_noc2_valid),
    .yummyIn_7(ariane_plic_buf_xbar_noc2_yummy),
    .dataOut_7(xbar_buf_ariane_plic_noc2_data),
    .validOut_7(xbar_buf_ariane_plic_noc2_valid),
    .yummyOut_7(xbar_buf_ariane_plic_noc2_yummy)
);

io_xbar_top_wrap io_xbar_noc3 (
    .clk                (chipset_clk),
    .reset_in           (~chipset_rst_n),

    .myChipID                   (14'b10000000000000),    // the first chip
    .myLocX                     (8'b0),  // not used
    .myLocY                     (8'b0),  // not used

    .dataIn_0(chip_buf_xbar_noc3_data),
    .validIn_0(chip_buf_xbar_noc3_valid),
    .yummyIn_0(chip_buf_xbar_noc3_yummy),
    .dataOut_0(xbar_buf_chip_noc3_data),
    .validOut_0(xbar_buf_chip_noc3_valid),
    .yummyOut_0(xbar_buf_chip_noc3_yummy),

    .dataIn_1(mem_buf_xbar_noc3_data),
    .validIn_1(mem_buf_xbar_noc3_valid),
    .yummyIn_1(mem_buf_xbar_noc3_yummy),
    .dataOut_1(xbar_buf_mem_noc3_data),
    .validOut_1(xbar_buf_mem_noc3_valid),
    .yummyOut_1(xbar_buf_mem_noc3_yummy),

    .dataIn_2(iob_buf_xbar_noc3_data),
    .validIn_2(iob_buf_xbar_noc3_valid),
    .yummyIn_2(iob_buf_xbar_noc3_yummy),
    .dataOut_2(xbar_buf_iob_noc3_data),
    .validOut_2(xbar_buf_iob_noc3_valid),
    .yummyOut_2(xbar_buf_iob_noc3_yummy),

    .dataIn_3(uart_buf_xbar_noc3_data),
    .validIn_3(uart_buf_xbar_noc3_valid),
    .yummyIn_3(uart_buf_xbar_noc3_yummy),
    .dataOut_3(xbar_buf_uart_noc3_data),
    .validOut_3(xbar_buf_uart_noc3_valid),
    .yummyOut_3(xbar_buf_uart_noc3_yummy),

    .dataIn_4(ariane_debug_buf_xbar_noc3_data),
    .validIn_4(ariane_debug_buf_xbar_noc3_valid),
    .yummyIn_4(ariane_debug_buf_xbar_noc3_yummy),
    .dataOut_4(xbar_buf_ariane_debug_noc3_data),
    .validOut_4(xbar_buf_ariane_debug_noc3_valid),
    .yummyOut_4(xbar_buf_ariane_debug_noc3_yummy),

    .dataIn_5(ariane_bootrom_buf_xbar_noc3_data),
    .validIn_5(ariane_bootrom_buf_xbar_noc3_valid),
    .yummyIn_5(ariane_bootrom_buf_xbar_noc3_yummy),
    .dataOut_5(xbar_buf_ariane_bootrom_noc3_data),
    .validOut_5(xbar_buf_ariane_bootrom_noc3_valid),
    .yummyOut_5(xbar_buf_ariane_bootrom_noc3_yummy),

    .dataIn_6(ariane_clint_buf_xbar_noc3_data),
    .validIn_6(ariane_clint_buf_xbar_noc3_valid),
    .yummyIn_6(ariane_clint_buf_xbar_noc3_yummy),
    .dataOut_6(xbar_buf_ariane_clint_noc3_data),
    .validOut_6(xbar_buf_ariane_clint_noc3_valid),
    .yummyOut_6(xbar_buf_ariane_clint_noc3_yummy),

    .dataIn_7(ariane_plic_buf_xbar_noc3_data),
    .validIn_7(ariane_plic_buf_xbar_noc3_valid),
    .yummyIn_7(ariane_plic_buf_xbar_noc3_yummy),
    .dataOut_7(xbar_buf_ariane_plic_noc3_data),
    .validOut_7(xbar_buf_ariane_plic_noc3_valid),
    .yummyOut_7(xbar_buf_ariane_plic_noc3_yummy)
    ,
    .thanksIn_7()
);

valrdy_to_credit noc2_chip_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(chip_buf_noc2_data),
      .valid_in(chip_buf_noc2_valid),
      .ready_in(buf_chip_noc2_ready),

      .data_out(chip_buf_xbar_noc2_data),           // Data
      .valid_out(chip_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_chip_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_chip(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_chip_noc2_data),
      .valid_in(xbar_buf_chip_noc2_valid),
      .yummy_in(chip_buf_xbar_noc2_yummy),

      .data_out(buf_chip_noc2_data),           // Data
      .valid_out(buf_chip_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(chip_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_chip_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(chip_buf_noc3_data),
      .valid_in(chip_buf_noc3_valid),
      .ready_in(buf_chip_noc3_ready),

      .data_out(chip_buf_xbar_noc3_data),           // Data
      .valid_out(chip_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_chip_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_chip(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_chip_noc3_data),
      .valid_in(xbar_buf_chip_noc3_valid),
      .yummy_in(chip_buf_xbar_noc3_yummy),

      .data_out(buf_chip_noc3_data),           // Data
      .valid_out(buf_chip_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(chip_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_mem_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(mem_buf_noc2_data),
      .valid_in(mem_buf_noc2_valid),
      .ready_in(buf_mem_noc2_ready),

      .data_out(mem_buf_xbar_noc2_data),           // Data
      .valid_out(mem_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_mem_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_mem(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_mem_noc2_data),
      .valid_in(xbar_buf_mem_noc2_valid),
      .yummy_in(mem_buf_xbar_noc2_yummy),

      .data_out(buf_mem_noc2_data),           // Data
      .valid_out(buf_mem_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(mem_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_mem_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(mem_buf_noc3_data),
      .valid_in(mem_buf_noc3_valid),
      .ready_in(buf_mem_noc3_ready),

      .data_out(mem_buf_xbar_noc3_data),           // Data
      .valid_out(mem_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_mem_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_mem(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_mem_noc3_data),
      .valid_in(xbar_buf_mem_noc3_valid),
      .yummy_in(mem_buf_xbar_noc3_yummy),

      .data_out(buf_mem_noc3_data),           // Data
      .valid_out(buf_mem_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(mem_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_iob_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(iob_buf_noc2_data),
      .valid_in(iob_buf_noc2_valid),
      .ready_in(buf_iob_noc2_ready),

      .data_out(iob_buf_xbar_noc2_data),           // Data
      .valid_out(iob_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_iob_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_iob(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_iob_noc2_data),
      .valid_in(xbar_buf_iob_noc2_valid),
      .yummy_in(iob_buf_xbar_noc2_yummy),

      .data_out(buf_iob_noc2_data),           // Data
      .valid_out(buf_iob_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(iob_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_iob_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(iob_buf_noc3_data),
      .valid_in(iob_buf_noc3_valid),
      .ready_in(buf_iob_noc3_ready),

      .data_out(iob_buf_xbar_noc3_data),           // Data
      .valid_out(iob_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_iob_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_iob(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_iob_noc3_data),
      .valid_in(xbar_buf_iob_noc3_valid),
      .yummy_in(iob_buf_xbar_noc3_yummy),

      .data_out(buf_iob_noc3_data),           // Data
      .valid_out(buf_iob_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(iob_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_uart_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(uart_buf_noc2_data),
      .valid_in(uart_buf_noc2_valid),
      .ready_in(buf_uart_noc2_ready),

      .data_out(uart_buf_xbar_noc2_data),           // Data
      .valid_out(uart_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_uart_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_uart(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_uart_noc2_data),
      .valid_in(xbar_buf_uart_noc2_valid),
      .yummy_in(uart_buf_xbar_noc2_yummy),

      .data_out(buf_uart_noc2_data),           // Data
      .valid_out(buf_uart_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(uart_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_uart_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(uart_buf_noc3_data),
      .valid_in(uart_buf_noc3_valid),
      .ready_in(buf_uart_noc3_ready),

      .data_out(uart_buf_xbar_noc3_data),           // Data
      .valid_out(uart_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_uart_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_uart(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_uart_noc3_data),
      .valid_in(xbar_buf_uart_noc3_valid),
      .yummy_in(uart_buf_xbar_noc3_yummy),

      .data_out(buf_uart_noc3_data),           // Data
      .valid_out(buf_uart_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(uart_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_ariane_debug_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_debug_buf_noc2_data),
      .valid_in(ariane_debug_buf_noc2_valid),
      .ready_in(buf_ariane_debug_noc2_ready),

      .data_out(ariane_debug_buf_xbar_noc2_data),           // Data
      .valid_out(ariane_debug_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_debug_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_ariane_debug(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_debug_noc2_data),
      .valid_in(xbar_buf_ariane_debug_noc2_valid),
      .yummy_in(ariane_debug_buf_xbar_noc2_yummy),

      .data_out(buf_ariane_debug_noc2_data),           // Data
      .valid_out(buf_ariane_debug_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_debug_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_ariane_debug_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_debug_buf_noc3_data),
      .valid_in(ariane_debug_buf_noc3_valid),
      .ready_in(buf_ariane_debug_noc3_ready),

      .data_out(ariane_debug_buf_xbar_noc3_data),           // Data
      .valid_out(ariane_debug_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_debug_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_ariane_debug(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_debug_noc3_data),
      .valid_in(xbar_buf_ariane_debug_noc3_valid),
      .yummy_in(ariane_debug_buf_xbar_noc3_yummy),

      .data_out(buf_ariane_debug_noc3_data),           // Data
      .valid_out(buf_ariane_debug_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_debug_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_ariane_bootrom_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_bootrom_buf_noc2_data),
      .valid_in(ariane_bootrom_buf_noc2_valid),
      .ready_in(buf_ariane_bootrom_noc2_ready),

      .data_out(ariane_bootrom_buf_xbar_noc2_data),           // Data
      .valid_out(ariane_bootrom_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_bootrom_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_ariane_bootrom(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_bootrom_noc2_data),
      .valid_in(xbar_buf_ariane_bootrom_noc2_valid),
      .yummy_in(ariane_bootrom_buf_xbar_noc2_yummy),

      .data_out(buf_ariane_bootrom_noc2_data),           // Data
      .valid_out(buf_ariane_bootrom_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_bootrom_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_ariane_bootrom_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_bootrom_buf_noc3_data),
      .valid_in(ariane_bootrom_buf_noc3_valid),
      .ready_in(buf_ariane_bootrom_noc3_ready),

      .data_out(ariane_bootrom_buf_xbar_noc3_data),           // Data
      .valid_out(ariane_bootrom_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_bootrom_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_ariane_bootrom(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_bootrom_noc3_data),
      .valid_in(xbar_buf_ariane_bootrom_noc3_valid),
      .yummy_in(ariane_bootrom_buf_xbar_noc3_yummy),

      .data_out(buf_ariane_bootrom_noc3_data),           // Data
      .valid_out(buf_ariane_bootrom_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_bootrom_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_ariane_clint_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_clint_buf_noc2_data),
      .valid_in(ariane_clint_buf_noc2_valid),
      .ready_in(buf_ariane_clint_noc2_ready),

      .data_out(ariane_clint_buf_xbar_noc2_data),           // Data
      .valid_out(ariane_clint_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_clint_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_ariane_clint(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_clint_noc2_data),
      .valid_in(xbar_buf_ariane_clint_noc2_valid),
      .yummy_in(ariane_clint_buf_xbar_noc2_yummy),

      .data_out(buf_ariane_clint_noc2_data),           // Data
      .valid_out(buf_ariane_clint_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_clint_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_ariane_clint_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_clint_buf_noc3_data),
      .valid_in(ariane_clint_buf_noc3_valid),
      .ready_in(buf_ariane_clint_noc3_ready),

      .data_out(ariane_clint_buf_xbar_noc3_data),           // Data
      .valid_out(ariane_clint_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_clint_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_ariane_clint(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_clint_noc3_data),
      .valid_in(xbar_buf_ariane_clint_noc3_valid),
      .yummy_in(ariane_clint_buf_xbar_noc3_yummy),

      .data_out(buf_ariane_clint_noc3_data),           // Data
      .valid_out(buf_ariane_clint_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_clint_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc2_ariane_plic_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_plic_buf_noc2_data),
      .valid_in(ariane_plic_buf_noc2_valid),
      .ready_in(buf_ariane_plic_noc2_ready),

      .data_out(ariane_plic_buf_xbar_noc2_data),           // Data
      .valid_out(ariane_plic_buf_xbar_noc2_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_plic_noc2_yummy)    // Yummy signal
);

credit_to_valrdy noc2_xbar_to_ariane_plic(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_plic_noc2_data),
      .valid_in(xbar_buf_ariane_plic_noc2_valid),
      .yummy_in(ariane_plic_buf_xbar_noc2_yummy),

      .data_out(buf_ariane_plic_noc2_data),           // Data
      .valid_out(buf_ariane_plic_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_plic_buf_noc2_ready)    // Rdy signal from processor to dynamic network
);

valrdy_to_credit noc3_ariane_plic_to_xbar (
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(ariane_plic_buf_noc3_data),
      .valid_in(ariane_plic_buf_noc3_valid),
      .ready_in(buf_ariane_plic_noc3_ready),

      .data_out(ariane_plic_buf_xbar_noc3_data),           // Data
      .valid_out(ariane_plic_buf_xbar_noc3_valid),       // Val signal
      .yummy_out(xbar_buf_ariane_plic_noc3_yummy)    // Yummy signal
);

credit_to_valrdy noc3_xbar_to_ariane_plic(
      .clk(chipset_clk),
      .reset(~chipset_rst_n),

      .data_in(xbar_buf_ariane_plic_noc3_data),
      .valid_in(xbar_buf_ariane_plic_noc3_valid),
      .yummy_in(ariane_plic_buf_xbar_noc3_yummy),

      .data_out(buf_ariane_plic_noc3_data),           // Data
      .valid_out(buf_ariane_plic_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(ariane_plic_buf_noc3_ready)    // Rdy signal from processor to dynamic network
);




`ifndef PITONSYS_NO_MC
// Memory controller.  Either uses "fake" simulated
// memory controller or FPGA memory controllers
`ifdef PITON_FPGA_MC_DDR3
    `ifdef F1_BOARD
        f1_mc_top mc_top(
            .sys_clk(chipset_clk),
            .sys_rst_n(chipset_rst_n),
            .mc_clk(mc_clk),

            .mc_flit_in_val(buf_mem_noc2_valid),
            .mc_flit_in_data(buf_mem_noc2_data),
            .mc_flit_in_rdy(mem_buf_noc2_ready),

            .mc_flit_out_val(mem_buf_noc3_valid),
            .mc_flit_out_data(mem_buf_noc3_data),
            .mc_flit_out_rdy(buf_mem_noc3_ready),

            .uart_boot_en(uart_boot_en),
            .init_calib_complete_out(init_calib_complete),
            .mc_ui_clk_sync_rst(mc_ui_clk_sync_rst),

            // AXI Write Address Channel Signals
            .m_axi_awid(m_axi_awid),
            .m_axi_awaddr(m_axi_awaddr),
            .m_axi_awlen(m_axi_awlen),
            .m_axi_awsize(m_axi_awsize),
            .m_axi_awburst(m_axi_awburst),
            .m_axi_awlock(m_axi_awlock),
            .m_axi_awcache(m_axi_awcache),
            .m_axi_awprot(m_axi_awprot),
            .m_axi_awqos(m_axi_awqos),
            .m_axi_awregion(m_axi_awregion),
            .m_axi_awuser(m_axi_awuser),
            .m_axi_awvalid(m_axi_awvalid),
            .m_axi_awready(m_axi_awready),

            // AXI Write Data Channel Signals
            .m_axi_wid(m_axi_wid),
            .m_axi_wdata(m_axi_wdata),
            .m_axi_wstrb(m_axi_wstrb),
            .m_axi_wlast(m_axi_wlast),
            .m_axi_wuser(m_axi_wuser),
            .m_axi_wvalid(m_axi_wvalid),
            .m_axi_wready(m_axi_wready),

            // AXI Read Address Channel Signals
            .m_axi_arid(m_axi_arid),
            .m_axi_araddr(m_axi_araddr),
            .m_axi_arlen(m_axi_arlen),
            .m_axi_arsize(m_axi_arsize),
            .m_axi_arburst(m_axi_arburst),
            .m_axi_arlock(m_axi_arlock),
            .m_axi_arcache(m_axi_arcache),
            .m_axi_arprot(m_axi_arprot),
            .m_axi_arqos(m_axi_arqos),
            .m_axi_arregion(m_axi_arregion),
            .m_axi_aruser(m_axi_aruser),
            .m_axi_arvalid(m_axi_arvalid),
            .m_axi_arready(m_axi_arready),

            // AXI Read Data Channel Signals
            .m_axi_rid(m_axi_rid),
            .m_axi_rdata(m_axi_rdata),
            .m_axi_rresp(m_axi_rresp),
            .m_axi_rlast(m_axi_rlast),
            .m_axi_ruser(m_axi_ruser),
            .m_axi_rvalid(m_axi_rvalid),
            .m_axi_rready(m_axi_rready),

            // AXI Write Response Channel Signals
            .m_axi_bid(m_axi_bid),
            .m_axi_bresp(m_axi_bresp),
            .m_axi_buser(m_axi_buser),
            .m_axi_bvalid(m_axi_bvalid),
            .m_axi_bready(m_axi_bready), 
            .ddr_ready(ddr_ready)
        );
    `else
        mc_top mc_top(
            .mc_ui_clk_sync_rst(mc_ui_clk_sync_rst),

            .core_ref_clk(chipset_clk),
            .sys_rst_n(chipset_rst_n),

            .mc_flit_in_val(buf_mem_noc2_valid),
            .mc_flit_in_data(buf_mem_noc2_data),
            .mc_flit_in_rdy(mem_buf_noc2_ready),

            .mc_flit_out_val(mem_buf_noc3_valid),
            .mc_flit_out_data(mem_buf_noc3_data),
            .mc_flit_out_rdy(buf_mem_noc3_ready),

            .uart_boot_en(uart_boot_en),
            .init_calib_complete_out(init_calib_complete),

        `ifdef PITONSYS_DDR4
            .sys_clk_p(mc_clk_p),
            .sys_clk_n(mc_clk_n),
            .ddr_act_n(ddr_act_n),
            .ddr_bg(ddr_bg),
        `else // PITONSYS_DDR4
            .sys_clk(mc_clk),
            .ddr_cas_n(ddr_cas_n),
            .ddr_ras_n(ddr_ras_n),
            .ddr_we_n(ddr_we_n),
        `endif // PITONSYS_DDR4

            .ddr_addr(ddr_addr),
            .ddr_ba(ddr_ba),
            .ddr_ck_n(ddr_ck_n),
            .ddr_ck_p(ddr_ck_p),
            .ddr_cke(ddr_cke),
            .ddr_reset_n(ddr_reset_n),
            .ddr_dq(ddr_dq),
            .ddr_dqs_n(ddr_dqs_n),
            .ddr_dqs_p(ddr_dqs_p),
        `ifndef NEXYSVIDEO_BOARD
            .ddr_cs_n(ddr_cs_n),
        `endif // endif NEXYSVIDEO_BOARD
        `ifdef XUPP3R_BOARD
            .ddr_parity(ddr_parity),
        `else
            .ddr_dm(ddr_dm),
        `endif // XUPP3R_BOARD
            .ddr_odt(ddr_odt)
        );
    `endif // F1_BOARD

`else

`include "cross_module.tmp.h"

// Fake Memory Controller
fake_mem_ctrl fake_mem_ctrl(
    .clk                ( chipset_clk        ),
    .rst_n              ( chipset_rst_n      ),
    .noc_valid_in       ( buf_mem_noc2_valid ),
    .noc_data_in        ( buf_mem_noc2_data  ),
    .noc_ready_in       ( mem_buf_noc2_ready ),
    .noc_valid_out      ( mem_buf_noc3_valid ),
    .noc_data_out       ( mem_buf_noc3_data  ),
    .noc_ready_out      ( buf_mem_noc3_ready )
);

`endif // endif PITON_FPGA_MC_DDR3

`else

`ifdef PITON_FPGA_BRAM_TEST

    fake_boot_ctrl  fake_boot_ctrl(
        .clk            ( chipset_clk        ),
        .rst_n          ( chipset_rst_n      ),

        .noc_valid_in   ( buf_mem_noc2_valid ),
        .noc_data_in    ( buf_mem_noc2_data  ),
        .noc_ready_in   ( mem_buf_noc2_ready ),

        .noc_valid_out  ( mem_buf_noc3_valid ),
        .noc_data_out   ( mem_buf_noc3_data  ),
        .noc_ready_out  ( buf_mem_noc3_ready )
    );

`elsif PITON_FPGA_BRAM_BOOT

    fake_boot_ctrl  fake_boot_ctrl(
        .clk            ( chipset_clk        ),
        .rst_n          ( chipset_rst_n      ),

        .noc_valid_in   ( buf_mem_noc2_valid ),
        .noc_data_in    ( buf_mem_noc2_data  ),
        .noc_ready_in   ( mem_buf_noc2_ready ),

        .noc_valid_out  ( mem_buf_noc3_valid ),
        .noc_data_out   ( mem_buf_noc3_data  ),
        .noc_ready_out  ( buf_mem_noc3_ready )
    );

`endif

`endif // endif PITONSYS_NO_MC


wire net_interrupt;
wire uart_interrupt;

`ifdef PITONSYS_IOCTRL

wire ciop_iob_rst_n;
assign ciop_iob_rst_n = io_ctrl_rst_n & test_start & ~piton_ready_n;

ciop_iob ciop_iob     (
    .chip_clk        ( chipset_clk           ),
    .fpga_clk        ( chipset_clk           ),
    .rst_n           ( ciop_iob_rst_n        ),

    .noc1_in_val     ( intf_chipset_val_noc1 ),
    .noc1_in_data    ( intf_chipset_data_noc1),
    .noc1_in_rdy     ( intf_chipset_rdy_noc1 ),

    .noc2_out_val    ( iob_filter_noc2_valid ),
    .noc2_out_data   ( iob_filter_noc2_data  ),
    .noc2_out_rdy    ( filter_iob_noc2_ready ),

    .noc3_in_val     ( filter_iob_noc3_valid ),
    .noc3_in_data    ( filter_iob_noc3_data  ),
    .noc3_in_rdy     ( iob_filter_noc3_ready ),

    .noc2_in_val     ( buf_iob_noc2_valid    ),
    .noc2_in_data    ( buf_iob_noc2_data     ),
    .noc2_in_rdy     ( iob_buf_noc2_ready    ),

    .noc3_out_val    ( iob_buf_noc3_valid    ),
    .noc3_out_data   ( iob_buf_noc3_data     ),
    .noc3_out_rdy    ( buf_iob_noc3_ready    ),

    .uart_interrupt ( uart_interrupt         ),
    .net_interrupt  ( net_interrupt          )
);


`ifdef PITONSYS_UART

uart_top        uart_top (
    .axi_clk                    ( chipset_clk                           ),
    .rst_n                      ( chipset_rst_n                         ),

    .uart_rx                    ( uart_rx                               ),
    .uart_tx                    ( uart_tx                               ),
    .uart_interrupt             ( uart_interrupt                        ),
`ifdef PITONSYS_UART_LOOBACK
    // Can be used to loobpack UART for testing
    .uart_lb_sw                 ( 1'b1                                  ),
`else // ifndef PITONSYS_UART_LOOBACK
    .uart_lb_sw                 ( 1'b0                                  ),
`endif // endif PITONSYS_UART_LOOBACK

    .uart_boot_en               ( uart_boot_en                          ),
`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
    .init_calib_complete        (init_calib_complete_ff                 ),
`else // PITON_FPGA_MC_DDR3
    .init_calib_complete        (1'b1                                   ),
`endif //PITON_FPGA_MC_DDR3
`else // PITONSYS_NO_MC
    .init_calib_complete        (1'b1                                   ),
`endif // PITONSYS_NO_MC

    // Uncomment to connect to the switch
    // .uart_timeout_en(uart_timeout_en),
    .uart_timeout_en            ( 1'b1                                  ),

    .test_start                 ( test_start                            ),
    .test_good_end              ( test_good_end                         ),
    .test_bad_end               ( test_bad_end                          ),
    .uart_rst_out_n             ( uart_rst_out_n                        ),

    .chip_id                    ( {1'b1, {(`NOC_CHIPID_WIDTH-1){1'b0}}} ),
    .x_id                       ( `NOC_X_WIDTH'd3                      ),
    .y_id                       ( `NOC_Y_WIDTH'd0                       ),
    // input from noc2
    .xbar_uart_noc2_valid       ( buf_uart_noc2_valid                   ),
    .xbar_uart_noc2_data        ( buf_uart_noc2_data                    ),
    .uart_xbar_noc2_ready       ( uart_buf_noc2_ready                   ),

    //output to noc3
    .uart_xbar_noc3_valid       ( uart_buf_noc3_valid                   ),
    .uart_xbar_noc3_data        ( uart_buf_noc3_data                    ),
    .xbar_uart_noc3_ready       ( buf_uart_noc3_ready                   ),

    // output to noc2
    .uart_xbar_noc2_valid       ( uart_filter_noc2_valid                ),
    .uart_xbar_noc2_data        ( uart_filter_noc2_data                 ),
    .xbar_uart_noc2_ready       ( filter_uart_noc2_ready                ),

    // input from noc3
    .xbar_uart_noc3_valid       ( filter_uart_noc3_valid                ),
    .xbar_uart_noc3_data        ( filter_uart_noc3_data                 ),
    .uart_xbar_noc3_ready       ( uart_filter_noc3_ready                )
);

`else // ifndef PITONSYS_UART
    assign uart_interrupt = 1'b0;
    assign test_start = 1'b1;
`endif // endif PITONSYS_UART

// SPI interface
`ifdef PITONSYS_SPI
`ifdef PITON_FPGA_SD_BOOT

    /* Bridge between NOCs and SD Card */
    piton_sd_top piton_sd_top (
        .sys_clk          ( chipset_clk       ),
        .sd_clk           ( sd_clk            ),
        .sys_rst          ( ~chipset_rst_n    ),

        .splitter_sd_val  ( buf_sd_noc2_valid ),
        .splitter_sd_data ( buf_sd_noc2_data  ),
        .sd_splitter_rdy  ( sd_buf_noc2_ready ),

        .sd_splitter_val  ( sd_buf_noc3_valid ),
        .sd_splitter_data ( sd_buf_noc3_data  ),
        .splitter_sd_rdy  ( buf_sd_noc3_ready ),

        .sd_cd            ( sd_cd             ),
        .sd_reset         ( sd_reset          ),
        .sd_clk_out       ( sd_clk_out        ),
        .sd_cmd           ( sd_cmd            ),
        .sd_dat           ( sd_dat            )
        );

`endif
`endif


`ifdef PITON_FPGA_ETHERNETLITE

    eth_top #(
    `ifdef PITON_RV64_PLATFORM
      .SWAP_ENDIANESS(1)
    `else
      .SWAP_ENDIANESS(0)
    `endif
    ) eth_top (
        .chipset_clk     ( chipset_clk        ),
        .rst_n           ( chipset_rst_n      ),

        .net_interrupt   ( net_interrupt      ),

        .noc_in_val      ( buf_net_noc2_valid ),
        .noc_in_data     ( buf_net_noc2_data  ),
        .noc_in_rdy      ( net_buf_noc2_ready ),

        .noc_out_val     ( net_buf_noc3_valid ),
        .noc_out_data    ( net_buf_noc3_data  ),
        .noc_out_rdy     ( buf_net_noc3_ready ),

        .net_axi_clk     ( net_axi_clk        ),
        .net_phy_rst_n   ( net_phy_rst_n      ),

        .net_phy_tx_clk  ( net_phy_tx_clk     ),
        .net_phy_tx_en   ( net_phy_tx_en      ),
        .net_phy_tx_data ( net_phy_tx_data    ),

        .net_phy_rx_clk  ( net_phy_rx_clk     ),
        .net_phy_dv      ( net_phy_dv         ),
        .net_phy_rx_data ( net_phy_rx_data    ),
        .net_phy_rx_er   ( net_phy_rx_er      ),

        .net_phy_mdio_io ( net_phy_mdio_io    ),
        .net_phy_mdc     ( net_phy_mdc        )
    );
`endif // PITON_FPGA_ETHERNETLITE

`else // PITONSYS_IOCTRL

assign net_interrupt  = 1'b0;
assign uart_interrupt = 1'b0;

// Fake iobridge
// Tie noc1 input low because it's unused
assign intf_chipset_rdy_noc1 = 1'b0;
ciop_fake_iob ciop_fake_iob(
    .noc_out_val       ( iob_filter_noc2_valid ),
    .noc_out_rdy       ( filter_iob_noc2_ready ),
    .noc_out_data      ( iob_filter_noc2_data  ),

    
.spc0_inst_done    (`PITON_CORE0_INST_DONE),
.pc_w0             (`PITON_CORE0_PC_W0),


.spc1_inst_done    (`PITON_CORE1_INST_DONE),
.pc_w1             (`PITON_CORE1_PC_W1),


.spc2_inst_done    (`PITON_CORE2_INST_DONE),
.pc_w2             (`PITON_CORE2_PC_W2),


.spc3_inst_done    (`PITON_CORE3_INST_DONE),
.pc_w3             (`PITON_CORE3_PC_W3),


    .clk               (chipset_clk),
    .rst_n             (chipset_rst_n)
//    .rst_n             (`SPARC_CORE0.reset_l)
);

// I/O AXI splitter, needed for uart-hello-world.s
fake_uart fake_uart (
    .clk                ( chipset_clk         ),
    .rst_n              ( chipset_rst_n       ),

    .src_uart_noc2_val  ( buf_uart_noc2_valid ),
    .src_uart_noc2_data ( buf_uart_noc2_data  ),
    .src_uart_noc2_rdy  ( uart_buf_noc2_ready ),

    .uart_dst_noc3_val  ( uart_buf_noc3_valid ),
    .uart_dst_noc3_data ( uart_buf_noc3_data  ),
    .uart_dst_noc3_rdy  ( buf_uart_noc3_ready )
);
`endif // endif PITONSYS_IOCTRL


/////////////////////////////
// Ariane-Specific Chipset //
/////////////////////////////

`ifdef PITON_RV64_PLATFORM

    wire [1:0] irq_sources, irq_le;
    // 0:level 1:edge
    // Eth is edge, Uart is level
    assign irq_le      = {1'b1, 1'b0};
    assign irq_sources = {net_interrupt, uart_interrupt};

    // this is for selecting the right bootrom (1: baremetal, 0: linux)
    wire ariane_boot_sel;
`ifdef PITON_FPGA_SYNTH
  assign ariane_boot_sel   = uart_boot_en;
`else
  `ifdef ARIANE_SIM_LINUX_BOOT
    assign ariane_boot_sel = 1'b0;
  `else
    assign ariane_boot_sel = 1'b1;
  `endif
`endif


    riscv_peripherals #(
        .DataWidth      ( `NOC_DATA_WIDTH ),
        .NumHarts       ( `PITON_NUM_TILES),
        .NumSources     (               2 ),
        .SwapEndianess  (               1 ),
        .DmBase         ( 64'h000000fff1000000 ),
        .RomBase        ( 64'h000000fff1010000 ),
        .ClintBase      ( 64'h000000fff1020000 ),
        .PlicBase       ( 64'h000000fff1100000 )
    ) i_riscv_peripherals (
        .clk_i                           ( chipset_clk                   )
,       .rst_ni                          ( chipset_rst_n                 )
`ifdef PITON_RV64_DEBUGUNIT
,       .testmode_i                      ( 1'b0                          )
,       .buf_ariane_debug_noc2_data_i    ( buf_ariane_debug_noc2_data    )
,       .buf_ariane_debug_noc2_valid_i   ( buf_ariane_debug_noc2_valid   )
,       .ariane_debug_buf_noc2_ready_o   ( ariane_debug_buf_noc2_ready   )
,       .ariane_debug_buf_noc3_data_o    ( ariane_debug_buf_noc3_data    )
,       .ariane_debug_buf_noc3_valid_o   ( ariane_debug_buf_noc3_valid   )
,       .buf_ariane_debug_noc3_ready_i   ( buf_ariane_debug_noc3_ready   )
`endif // ifdef PITON_RV64_DEBUGUNIT
,       .buf_ariane_bootrom_noc2_data_i  ( buf_ariane_bootrom_noc2_data  )
,       .buf_ariane_bootrom_noc2_valid_i ( buf_ariane_bootrom_noc2_valid )
,       .ariane_bootrom_buf_noc2_ready_o ( ariane_bootrom_buf_noc2_ready )
,       .ariane_bootrom_buf_noc3_data_o  ( ariane_bootrom_buf_noc3_data  )
,       .ariane_bootrom_buf_noc3_valid_o ( ariane_bootrom_buf_noc3_valid )
,       .buf_ariane_bootrom_noc3_ready_i ( buf_ariane_bootrom_noc3_ready )
`ifdef PITON_RV64_CLINT
,       .buf_ariane_clint_noc2_data_i    ( buf_ariane_clint_noc2_data    )
,       .buf_ariane_clint_noc2_valid_i   ( buf_ariane_clint_noc2_valid   )
,       .ariane_clint_buf_noc2_ready_o   ( ariane_clint_buf_noc2_ready   )
,       .ariane_clint_buf_noc3_data_o    ( ariane_clint_buf_noc3_data    )
,       .ariane_clint_buf_noc3_valid_o   ( ariane_clint_buf_noc3_valid   )
,       .buf_ariane_clint_noc3_ready_i   ( buf_ariane_clint_noc3_ready   )
`endif // ifdef PITON_RV64_CLINT
`ifdef PITON_RV64_PLIC
,       .buf_ariane_plic_noc2_data_i     ( buf_ariane_plic_noc2_data     )
,       .buf_ariane_plic_noc2_valid_i    ( buf_ariane_plic_noc2_valid    )
,       .ariane_plic_buf_noc2_ready_o    ( ariane_plic_buf_noc2_ready    )
,       .ariane_plic_buf_noc3_data_o     ( ariane_plic_buf_noc3_data     )
,       .ariane_plic_buf_noc3_valid_o    ( ariane_plic_buf_noc3_valid    )
,       .buf_ariane_plic_noc3_ready_i    ( buf_ariane_plic_noc3_ready    )
`endif // ifdef PITON_RV64_PLIC
        // This selects either the BM or linux bootrom
,       .ariane_boot_sel_i               ( ariane_boot_sel               )
`ifdef PITON_RV64_DEBUGUNIT
        // Debug sigs to cores
,       .ndmreset_o                      ( ndmreset_o                    )
,       .dmactive_o                      ( dmactive_o                    )
,       .debug_req_o                     ( debug_req_o                   )
,       .unavailable_i                   ( unavailable_i                 )
        // JTAG
,       .tck_i                           ( tck_i                         )
,       .tms_i                           ( tms_i                         )
,       .trst_ni                         ( trst_ni                       )
,       .td_i                            ( td_i                          )
,       .td_o                            ( td_o                          )
,       .tdo_oe_o                        (                               )
`endif // ifdef PITON_RV64_DEBUGUNIT
`ifdef PITON_RV64_CLINT
        // CLINT
,       .rtc_i                           ( rtc_i                         )
,       .timer_irq_o                     ( timer_irq_o                   )
,       .ipi_o                           ( ipi_o                         )
`endif // ifdef PITON_RV64_CLINT
`ifdef PITON_RV64_PLIC
        // PLIC
,       .irq_le_i                        ( irq_le                        ) // 0:level 1:edge
,       .irq_sources_i                   ( irq_sources                   )
,       .irq_o                           ( irq_o                         )
`endif // ifdef PITON_RV64_PLIC
    );



`else

    // tie off unused sigs
    assign ariane_debug_buf_noc2_ready   = 1'b0;
    assign ariane_debug_buf_noc3_data    = `NOC_DATA_WIDTH'b0;
    assign ariane_debug_buf_noc3_valid   = 1'b0;

    assign ariane_bootrom_buf_noc2_ready = 1'b0;
    assign ariane_bootrom_buf_noc3_data  = `NOC_DATA_WIDTH'b0;
    assign ariane_bootrom_buf_noc3_valid = 1'b0;

    assign ariane_clint_buf_noc2_ready   = 1'b0;
    assign ariane_clint_buf_noc3_data    = `NOC_DATA_WIDTH'b0;
    assign ariane_clint_buf_noc3_valid   = 1'b0;

    assign ariane_plic_buf_noc2_ready    = 1'b0;
    assign ariane_plic_buf_noc3_data     = `NOC_DATA_WIDTH'b0;
    assign ariane_plic_buf_noc3_valid    = 1'b0;

`endif // ifdef PITON_RV64_PLATFORM

endmodule
