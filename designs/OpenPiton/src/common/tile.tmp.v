// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: iop.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
//
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// The above named program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
//
// ========== Copyright Header End ============================================
`include "define.tmp.h"
`include "dmbr_define.v"
`include "l15.tmp.h"
`include "jtag.vh"
// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml


module tile(
    input                               clk,
    input                               rst_n,    // trin: assumed to be synchronous
    input                               clk_en,   // trin: assumed to be asynchronous
    input wire [`NOC_CHIPID_WIDTH-1:0]  default_chipid,
    input wire [`NOC_X_WIDTH-1:0]       default_coreid_x,
    input wire [`NOC_Y_WIDTH-1:0]       default_coreid_y,
    input wire [31:0]                   default_total_num_tiles,
    input wire [`JTAG_FLATID_WIDTH-1:0] flat_tileid,

    // UCB interface for test access port
    input                               jtag_tiles_ucb_val,
    input [`UCB_BUS_WIDTH-1:0]          jtag_tiles_ucb_data,
    output                              tile_jtag_ucb_val,
    output [`UCB_BUS_WIDTH-1:0]         tile_jtag_ucb_data,

    // Dynamic Network Inputs 0 (User Dynamic Network)
    input [`NOC_DATA_WIDTH-1:0]         dyn0_dataIn_N,
    input [`NOC_DATA_WIDTH-1:0]         dyn0_dataIn_E,
    input [`NOC_DATA_WIDTH-1:0]         dyn0_dataIn_W,
    input [`NOC_DATA_WIDTH-1:0]         dyn0_dataIn_S,
    input                               dyn0_validIn_N,
    input                               dyn0_validIn_E,
    input                               dyn0_validIn_W,
    input                               dyn0_validIn_S,
    input                               dyn0_dNo_yummy,
    input                               dyn0_dEo_yummy,
    input                               dyn0_dWo_yummy,
    input                               dyn0_dSo_yummy,

    // Dynamic Network Inputs 1 (User Dynamic Network)
    input [`NOC_DATA_WIDTH-1:0]         dyn1_dataIn_N,
    input [`NOC_DATA_WIDTH-1:0]         dyn1_dataIn_E,
    input [`NOC_DATA_WIDTH-1:0]         dyn1_dataIn_W,
    input [`NOC_DATA_WIDTH-1:0]         dyn1_dataIn_S,
    input                               dyn1_validIn_N,
    input                               dyn1_validIn_E,
    input                               dyn1_validIn_W,
    input                               dyn1_validIn_S,
    input                               dyn1_dNo_yummy,
    input                               dyn1_dEo_yummy,
    input                               dyn1_dWo_yummy,
    input                               dyn1_dSo_yummy,

    // Dynamic Network 2 Inputs (User Dynamic Network)
    input [`NOC_DATA_WIDTH-1:0]         dyn2_dataIn_N,
    input [`NOC_DATA_WIDTH-1:0]         dyn2_dataIn_E,
    input [`NOC_DATA_WIDTH-1:0]         dyn2_dataIn_W,
    input [`NOC_DATA_WIDTH-1:0]         dyn2_dataIn_S,
    input                               dyn2_validIn_N,
    input                               dyn2_validIn_E,
    input                               dyn2_validIn_W,
    input                               dyn2_validIn_S,
    input                               dyn2_dNo_yummy,
    input                               dyn2_dEo_yummy,
    input                               dyn2_dWo_yummy,
    input                               dyn2_dSo_yummy,

    // Dynamic network Outputs 0
    output [`NOC_DATA_WIDTH-1:0]        dyn0_dNo,
    output [`NOC_DATA_WIDTH-1:0]        dyn0_dEo,
    output [`NOC_DATA_WIDTH-1:0]        dyn0_dWo,
    output [`NOC_DATA_WIDTH-1:0]        dyn0_dSo,
    output                              dyn0_dNo_valid,
    output                              dyn0_dEo_valid,
    output                              dyn0_dWo_valid,
    output                              dyn0_dSo_valid,
    output                              dyn0_yummyOut_N,
    output                              dyn0_yummyOut_E,
    output                              dyn0_yummyOut_W,
    output                              dyn0_yummyOut_S,
    //output [4:0]                        ec_dyn0,

    // Dynamic network Outputs 1
    output [`NOC_DATA_WIDTH-1:0]        dyn1_dNo,
    output [`NOC_DATA_WIDTH-1:0]        dyn1_dEo,
    output [`NOC_DATA_WIDTH-1:0]        dyn1_dWo,
    output [`NOC_DATA_WIDTH-1:0]        dyn1_dSo,
    output                              dyn1_dNo_valid,
    output                              dyn1_dEo_valid,
    output                              dyn1_dWo_valid,
    output                              dyn1_dSo_valid,
    output                              dyn1_yummyOut_N,
    output                              dyn1_yummyOut_E,
    output                              dyn1_yummyOut_W,
    output                              dyn1_yummyOut_S,
    //output [4:0]                        ec_dyn1,

    // Dynamic network Outputs 2
    output [`NOC_DATA_WIDTH-1:0]        dyn2_dNo,
    output [`NOC_DATA_WIDTH-1:0]        dyn2_dEo,
    output [`NOC_DATA_WIDTH-1:0]        dyn2_dWo,
    output [`NOC_DATA_WIDTH-1:0]        dyn2_dSo,
    output                              dyn2_dNo_valid,
    output                              dyn2_dEo_valid,
    output                              dyn2_dWo_valid,
    output                              dyn2_dSo_valid,
    output                              dyn2_yummyOut_N,
    output                              dyn2_yummyOut_E,
    output                              dyn2_yummyOut_W,
    output                              dyn2_yummyOut_S
    //output [4:0]                        ec_dyn2


`ifdef PITON_RV64_PLATFORM
`ifdef PITON_RV64_DEBUGUNIT
    // Debug
,   input                               debug_req_i    // async debug request
,   output                              unavailable_o  // communicate whether the hart is unavailable (e.g.: power down)
`endif // ifdef PITON_RV64_DEBUGUNIT

`ifdef PITON_RV64_CLINT
    // CLINT
,   input                               timer_irq_i    // Timer interrupts
,   input                               ipi_i          // software interrupt (a.k.a inter-process-interrupt)
`endif // ifdef PITON_RV64_CLINT

`ifdef PITON_RV64_PLIC
    // PLIC
,   input   [1:0]                       irq_i          // level sensitive IR lines, mip & sip (async)
`endif // ifdef PITON_RV64_PLIC
`endif // ifdef PITON_RV64_PLATFORM
);
    // clock gating
    wire clk_gated;
    clk_gating_latch clk_gating_latch(
        .clk(clk),
        .clk_en(clk_en),
        .clk_out(clk_gated)
    );

    // flop reset signal
    reg rst_n_f;
    always @ (posedge clk)
    begin
      rst_n_f <= rst_n;
    end

    // configured X/Y/CHIPID
    wire [`NOC_CHIPID_WIDTH-1:0]        config_chipid;
    wire [`NOC_X_WIDTH-1:0]             config_coreid_x;
    wire [`NOC_Y_WIDTH-1:0]             config_coreid_y;

    wire [`DATA_WIDTH-1:0]              buffer_processor_data_noc1;
    wire [`DATA_WIDTH-1:0]              buffer_processor_data_noc2;
    wire [`DATA_WIDTH-1:0]              buffer_processor_data_noc3;

    wire                                buffer_processor_valid_noc1;
    wire                                buffer_processor_valid_noc2;
    wire                                buffer_processor_valid_noc3;
    wire                                processor_router_ready_noc1;
    wire                                processor_router_ready_noc2;
    wire                                processor_router_ready_noc3;

    wire                                router_processor_ready_noc1;
    wire                                router_processor_ready_noc2;
    wire                                router_processor_ready_noc3;

    // Processor val/rdy interface

    wire [`NOC_DATA_WIDTH-1:0]          processor_router_data_noc1;
    wire                                processor_router_valid_noc1;
    wire                                buffer_router_yummy_noc1;

    wire [`NOC_DATA_WIDTH-1:0]          buffer_router_data_noc1;
    wire                                buffer_router_valid_noc1;


    wire [`NOC_DATA_WIDTH-1:0]          processor_router_data_noc2;
    wire                                processor_router_valid_noc2;
    wire                                buffer_router_yummy_noc2;

    wire [`NOC_DATA_WIDTH-1:0]          buffer_router_data_noc2;
    wire                                buffer_router_valid_noc2;

    wire [`NOC_DATA_WIDTH-1:0]          processor_router_data_noc3;
    wire                                processor_router_valid_noc3;
    wire                                buffer_router_yummy_noc3;

    wire [`NOC_DATA_WIDTH-1:0]          buffer_router_data_noc3;
    wire                                buffer_router_valid_noc3;

    wire [`NOC_DATA_WIDTH-1:0]          router_buffer_data_noc1;
    wire                                router_buffer_data_val_noc1;
    wire                                router_buffer_consumed_noc1;
    wire                                thanksIn_CGNO0;

    wire [`NOC_DATA_WIDTH-1:0]          router_buffer_data_noc2;
    wire                                router_buffer_data_val_noc2;
    wire                                router_buffer_consumed_noc2;
    wire                                thanksIn_CGNO1;


    wire [`NOC_DATA_WIDTH-1:0]          router_buffer_data_noc3;
    wire                                router_buffer_data_val_noc3;
    wire                                router_buffer_consumed_noc3;
    wire                                thanksIn_CGNO2;

    wire   [4:0]                        pcx_transducer_req;
    wire                                pcx_transducer_atomic_req;
    wire   [123:0]                      pcx_transducer_data;

    `ifndef NO_RTL_CSM
    wire   [`TLB_CSM]                   pcx_transducer_csm;
    `endif

    wire [4:0]                          transducer_pcx_grant;
    // is actually cpx_data_valid
    wire                                transducer_cpx_data_ready;
    wire [144:0]                        transducer_cpx_data;

    wire                                spc_grst_l;
    wire                                cpx_arb_spc_data_rdy;
    wire [144:0]                        cpx_arb_spc_data;
    wire [4:0]                          cpx_arb_spc_grant;

    wire [`PCX_REQTYPE_WIDTH-1:0]       transducer_l15_rqtype;
    wire [`L15_AMO_OP_WIDTH-1:0]        transducer_l15_amo_op;

    wire                                transducer_l15_nc;
    wire [`PCX_SIZE_FIELD_WIDTH-1:0]    transducer_l15_size;
    wire [`L15_THREADID_MASK]           transducer_l15_threadid;
    wire                                transducer_l15_prefetch;
    wire                                transducer_l15_invalidate_cacheline;
    wire                                transducer_l15_blockstore;
    wire                                transducer_l15_blockinitstore;
    wire [1:0]                          transducer_l15_l1rplway;
    wire                                transducer_l15_val;
    wire [`L15_PADDR_HI:0]              transducer_l15_address;
    wire [63:0]                         transducer_l15_data;
    wire [63:0]                         transducer_l15_data_next_entry;
    wire [`TLB_CSM_WIDTH-1:0]           transducer_l15_csm_data;

    wire                                l15_transducer_ack;
    wire                                l15_transducer_header_ack;

    wire                                l15_transducer_val;
    wire [3:0]                          l15_transducer_returntype;
    wire                                l15_transducer_l2miss;
    wire [1:0]                          l15_transducer_error;
    wire                                l15_transducer_noncacheable;
    wire                                l15_transducer_atomic;
    wire [`L15_THREADID_MASK]           l15_transducer_threadid;
    wire                                l15_transducer_prefetch;
    wire                                l15_transducer_f4b;
    wire [63:0]                         l15_transducer_data_0;
    wire [63:0]                         l15_transducer_data_1;
    wire [63:0]                         l15_transducer_data_2;
    wire [63:0]                         l15_transducer_data_3;
    wire                                l15_transducer_inval_icache_all_way;
    wire                                l15_transducer_inval_dcache_all_way;
    wire [15:4]                         l15_transducer_inval_address_15_4;
    wire                                l15_transducer_cross_invalidate;
    wire [1:0]                          l15_transducer_cross_invalidate_way;
    wire                                l15_transducer_inval_dcache_inval;
    wire                                l15_transducer_inval_icache_inval;
    wire [1:0]                          l15_transducer_inval_way;
    wire                                l15_transducer_blockinitstore;

    wire                                transducer_l15_req_ack;


    wire [`CORE_JTAG_BUS_WIDTH-1:0] core_rtap_data;
    wire rtap_core_val;
    wire [1:0] rtap_core_threadid;
    wire [`JTAG_CORE_ID_WIDTH-1:0]  rtap_core_id;
    wire [`CORE_JTAG_BUS_WIDTH-1:0] rtap_core_data;

    // the cpx arbitrator should give priority to the L1.5
    // when communicating with the sparc core
    wire [144:0]                        fpu_arb_data;
    wire                                fpu_arb_data_rdy;
    wire                                fpu_arb_grant;

    wire                                l15_dmbr_l1missIn;
    wire [`DMBR_TAG_WIDTH-1:0]          l15_dmbr_l1missTag;
    wire                                l15_dmbr_l2responseIn;
    wire                                l15_dmbr_l2missIn;
    wire [`DMBR_TAG_WIDTH-1:0]          l15_dmbr_l2missTag;
    wire                                dmbr_l15_stall; // outgoing signal stalling L1.5

    wire                                l15_config_req_val_s2;
    wire                                l15_config_req_rw_s2;
    wire [63:0]                         l15_config_write_req_data_s2;
    wire [`CONFIG_REG_ADDRESS_MASK]     l15_config_req_address_s2;
    wire [63:0]                         config_l15_read_res_data_s3;


    wire                                config_dmbr_func_en;
    wire                                config_dmbr_stall_en;
    wire                                config_dmbr_proc_ld;
    wire [`REPLENISH_WIDTH-1:0]         config_dmbr_replenish_cycles;
    wire [`SCALE_WIDTH-1:0]             config_dmbr_bin_scale;
    wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_0;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_1;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_2;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_3;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_4;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_5;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_6;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_7;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_8;
wire [`CREDIT_WIDTH-1:0] config_dmbr_cred_bin_9;


    wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_0;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_1;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_2;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_3;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_4;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_5;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_6;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_7;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_8;
wire [`CREDIT_WIDTH-1:0] from_dmbr_cred_bin_9;

    wire                                config_csm_en;
    wire [31:0]                         config_system_tile_count;
    wire [`HOME_ALLOC_METHOD_WIDTH-1:0] config_home_alloc_method;
    wire [`L15_HMT_BASE_ADDR_WIDTH-1:0] config_hmt_base;


    // SRAM wrapper interfaces
    wire [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
    wire [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
    wire [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
    wire [`SRAM_WRAPPER_BUS_WIDTH-1:0] l15_rtap_data;
    wire [`SRAM_WRAPPER_BUS_WIDTH-1:0] sparc_rtap_data;
    wire [`SRAM_WRAPPER_BUS_WIDTH-1:0] l2_rtap_data;

    wire [3:0] rtap_lsu_ctlbits_wr_en;
    wire [13:0] rtap_lsu_ctlbits_data;


    wire        rtap_arb_req_val;
    wire [63:0] rtap_arb_req_data;
    wire [1:0]  rtap_arb_req_threadid;

    // r/w port for jtag to config regs
    wire rtap_config_req_val;
    wire rtap_config_req_rw;
    wire [63:0] rtap_config_write_req_data;
    wire [`CONFIG_REG_ADDRESS_MASK] rtap_config_req_address;
    wire [63:0] config_rtap_read_res_data;

    /////////////////////////////////////////////////////
    // Configuration Registers Needing to be Hooked Up //
    /////////////////////////////////////////////////////

    /////////////
    // Routers //
    // //////////

    dynamic_node_top_wrap user_dynamic_network0
      (.clk(clk_gated),
       .reset_in(~rst_n_f),
       // dataIn (to input blocks)
       .dataIn_N(dyn0_dataIn_N),
       .dataIn_E(dyn0_dataIn_E),
       .dataIn_S(dyn0_dataIn_S),
       .dataIn_W(dyn0_dataIn_W),
       .dataIn_P(buffer_router_data_noc1),
       // validIn (to input blocks)
       .validIn_N(dyn0_validIn_N),
       .validIn_E(dyn0_validIn_E),
       .validIn_S(dyn0_validIn_S),
       .validIn_W(dyn0_validIn_W),
       .validIn_P(buffer_router_valid_noc1),
       // yummy (from nighboring input blocks)
       .yummyIn_N(dyn0_dNo_yummy),
       .yummyIn_E(dyn0_dEo_yummy),
       .yummyIn_S(dyn0_dSo_yummy),
       .yummyIn_W(dyn0_dWo_yummy),
       .yummyIn_P(buffer_router_yummy_noc1),
       // My Absolute Address
       .myLocX(config_coreid_x),
       .myLocY(config_coreid_y),
       .myChipID(config_chipid),
       //.ec_cfg(15'b0),//ec_dyn_cfg[14:0]),
       //.store_meter_partner_address_X(5'b0),
       //.store_meter_partner_address_Y(5'b0),
       // DataOut (from crossbar)
       .dataOut_N(dyn0_dNo),
       .dataOut_E(dyn0_dEo),
       .dataOut_S(dyn0_dSo),
       .dataOut_W(dyn0_dWo),
       .dataOut_P(router_buffer_data_noc1), //data output to processor
       // validOut (from crossbar)
       .validOut_N(dyn0_dNo_valid),
       .validOut_E(dyn0_dEo_valid),
       .validOut_S(dyn0_dSo_valid),
       .validOut_W(dyn0_dWo_valid),
       .validOut_P(router_buffer_data_val_noc1), //data valid to processor
       // yummyOut (to neighboring output blocks)
       .yummyOut_N(dyn0_yummyOut_N),
       .yummyOut_E(dyn0_yummyOut_E),
       .yummyOut_W(dyn0_yummyOut_W),
       .yummyOut_S(dyn0_yummyOut_S),
       .yummyOut_P(router_buffer_consumed_noc1), //yummy out to neighboring
       // thanksIn (to CGNO)
       .thanksIn_P(thanksIn_CGNO0));
       //.external_interrupt(),
       //.store_meter_ack_partner(),
       //.store_meter_ack_non_partner(),
       //.ec_out(ec_dyn0));

    dynamic_node_top_wrap user_dynamic_network1
      (.clk(clk_gated),
       .reset_in(~rst_n_f),
       // dataIn (to input blocks)
       .dataIn_N(dyn1_dataIn_N),
       .dataIn_E(dyn1_dataIn_E),
       .dataIn_S(dyn1_dataIn_S),
       .dataIn_W(dyn1_dataIn_W),
       .dataIn_P(buffer_router_data_noc2),
       // validIn (to input blocks)
       .validIn_N(dyn1_validIn_N),
       .validIn_E(dyn1_validIn_E),
       .validIn_S(dyn1_validIn_S),
       .validIn_W(dyn1_validIn_W),
       .validIn_P(buffer_router_valid_noc2),
       // yummy (from nighboring input blocks)
       .yummyIn_N(dyn1_dNo_yummy),
       .yummyIn_E(dyn1_dEo_yummy),
       .yummyIn_S(dyn1_dSo_yummy),
       .yummyIn_W(dyn1_dWo_yummy),
       .yummyIn_P(buffer_router_yummy_noc2),
       // My Absolute Address
       .myLocX(config_coreid_x),
       .myLocY(config_coreid_y),
       .myChipID(config_chipid),
       //.ec_cfg(15'b0),//ec_dyn_cfg[14:0]),
       //.store_meter_partner_address_X(5'b0),
       //.store_meter_partner_address_Y(5'b0),
       // DataOut (from crossbar)
       .dataOut_N(dyn1_dNo),
       .dataOut_E(dyn1_dEo),
       .dataOut_S(dyn1_dSo),
       .dataOut_W(dyn1_dWo),
       .dataOut_P(router_buffer_data_noc2), //data output to processor
       // validOut (from crossbar)
       .validOut_N(dyn1_dNo_valid),
       .validOut_E(dyn1_dEo_valid),
       .validOut_S(dyn1_dSo_valid),
       .validOut_W(dyn1_dWo_valid),
       .validOut_P(router_buffer_data_val_noc2), //data valid to processor
       // yummyOut (to neighboring output blocks)
       .yummyOut_N(dyn1_yummyOut_N),
       .yummyOut_E(dyn1_yummyOut_E),
       .yummyOut_W(dyn1_yummyOut_W),
       .yummyOut_S(dyn1_yummyOut_S),
       .yummyOut_P(router_buffer_consumed_noc2), //yummy out to neighboring
       // thanksIn (to CGNO)
       .thanksIn_P(thanksIn_CGNO1));
       //.external_interrupt(),
       //.store_meter_ack_partner(),
       //.store_meter_ack_non_partner(),
       //.ec_out(ec_dyn1));

    dynamic_node_top_wrap user_dynamic_network2
      (.clk(clk_gated),
       .reset_in(~rst_n_f),
       // dataIn (to input blocks)
       .dataIn_N(dyn2_dataIn_N),
       .dataIn_E(dyn2_dataIn_E),
       .dataIn_S(dyn2_dataIn_S),
       .dataIn_W(dyn2_dataIn_W),
       .dataIn_P(buffer_router_data_noc3),
       // validIn (to input blocks)
       .validIn_N(dyn2_validIn_N),
       .validIn_E(dyn2_validIn_E),
       .validIn_S(dyn2_validIn_S),
       .validIn_W(dyn2_validIn_W),
       .validIn_P(buffer_router_valid_noc3),
       // yummy (from nighboring input blocks)
       .yummyIn_N(dyn2_dNo_yummy),
       .yummyIn_E(dyn2_dEo_yummy),
       .yummyIn_S(dyn2_dSo_yummy),
       .yummyIn_W(dyn2_dWo_yummy),
       .yummyIn_P(buffer_router_yummy_noc3),
       // My Absolute Address
       .myLocX(config_coreid_x),
       .myLocY(config_coreid_y),
       .myChipID(config_chipid),
       //.ec_cfg(15'b0),//ec_dyn_cfg[14:0]),
       //.store_meter_partner_address_X(5'b0),
       //.store_meter_partner_address_Y(5'b0),
       // DataOut (from crossbar)
       .dataOut_N(dyn2_dNo),
       .dataOut_E(dyn2_dEo),
       .dataOut_S(dyn2_dSo),
       .dataOut_W(dyn2_dWo),
       .dataOut_P(router_buffer_data_noc3), //data output to processor
       // validOut (from crossbar)
       .validOut_N(dyn2_dNo_valid),
       .validOut_E(dyn2_dEo_valid),
       .validOut_S(dyn2_dSo_valid),
       .validOut_W(dyn2_dWo_valid),
       .validOut_P(router_buffer_data_val_noc3), //data valid to processor
       // yummyOut (to neighboring output blocks)
       .yummyOut_N(dyn2_yummyOut_N),
       .yummyOut_E(dyn2_yummyOut_E),
       .yummyOut_W(dyn2_yummyOut_W),
       .yummyOut_S(dyn2_yummyOut_S),
       .yummyOut_P(router_buffer_consumed_noc3), //yummy out to processor
       // thanksIn (to CGNO)
       .thanksIn_P(thanksIn_CGNO2));
       //.external_interrupt(),
       //.store_meter_ack_partner(),
       //.store_meter_ack_non_partner(),
       //.ec_out(ec_dyn2));


    ////////////////////////////////////////////
    // Credit - Val/Rdy Interface Transducers //
    ///////////////////////////////////////////

    valrdy_to_credit #(16, 5) cgno_blk1(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(processor_router_data_noc1),
        .valid_in(processor_router_valid_noc1),
        .ready_in(router_processor_ready_noc1),

        .data_out(buffer_router_data_noc1),           // Data
        .valid_out(buffer_router_valid_noc1),       // Val signal
        .yummy_out(router_buffer_consumed_noc1)    // Yummy signal
    );

    valrdy_to_credit #(16, 5) cgno_blk2(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(processor_router_data_noc2),
        .valid_in(processor_router_valid_noc2),
        .ready_in(router_processor_ready_noc2),

        .data_out(buffer_router_data_noc2),           // Data
        .valid_out(buffer_router_valid_noc2),       // Val signal
        .yummy_out(router_buffer_consumed_noc2)    // Yummy signal
    );

    valrdy_to_credit #(16, 5) cgno_blk3(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(processor_router_data_noc3),
        .valid_in(processor_router_valid_noc3),
        .ready_in(router_processor_ready_noc3),

        .data_out(buffer_router_data_noc3),           // Data
        .valid_out(buffer_router_valid_noc3),       // Val signal
        .yummy_out(router_buffer_consumed_noc3)    // Yummy signal
    );


    credit_to_valrdy cgni_blk1(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(router_buffer_data_noc1),
        .valid_in(router_buffer_data_val_noc1),
        .yummy_in(buffer_router_yummy_noc1),

        .data_out(buffer_processor_data_noc1),           // Data
        .valid_out(buffer_processor_valid_noc1),       // Val signal from dynamic network to processor
        .ready_out(processor_router_ready_noc1)    // Rdy signal from processor to dynamic network
    );

    credit_to_valrdy cgni_blk2(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(router_buffer_data_noc2),
        .valid_in(router_buffer_data_val_noc2),
        .yummy_in(buffer_router_yummy_noc2),

        .data_out(buffer_processor_data_noc2),           // Data
        .valid_out(buffer_processor_valid_noc2),       // Val signal from dynamic network to processor
        .ready_out(processor_router_ready_noc2)    // Rdy signal from processor to dynamic network
    );

    credit_to_valrdy cgni_blk3(
        .clk(clk_gated),
        .reset(~rst_n_f),
        .data_in(router_buffer_data_noc3),
        .valid_in(router_buffer_data_val_noc3),
        .yummy_in(buffer_router_yummy_noc3),

        .data_out(buffer_processor_data_noc3),           // Data
        .valid_out(buffer_processor_valid_noc3),       // Val signal from dynamic network to processor
        .ready_out(processor_router_ready_noc3)    // Rdy signal from processor to dynamic network
    );

///////////////////////
// Instantiate Cores //
///////////////////////
generate
if (1) begin : g_ariane_core
    //////////////////////
    // Ariane RV64 Core //
    //////////////////////

`ifdef PITON_ARIANE

    // TODO: add debug module and CLINT

    // native L15 interface, used in case of ARIANE_RV64, otherwise tied to zero
    wire [`L15_REQ_WIDTH-1:0]  l15_req;
    wire [`L15_RTRN_WIDTH-1:0] l15_rtrn;

    // see serpent_cache_pkg.sv for definition of the packed struct type "l15_rtrn_t",
    // note that the constants defined in l15.tmp.h and serpent_cache_pkg.sv need to coincide!
    assign l15_rtrn = { l15_transducer_ack,
                        l15_transducer_header_ack,
                        l15_transducer_val,
                        l15_transducer_returntype,
                        l15_transducer_l2miss,
                        l15_transducer_error,
                        l15_transducer_noncacheable,
                        l15_transducer_atomic,
                        l15_transducer_threadid,
                        l15_transducer_prefetch,
                        l15_transducer_f4b,
                        l15_transducer_data_0,
                        l15_transducer_data_1,
                        l15_transducer_data_2,
                        l15_transducer_data_3,
                        l15_transducer_inval_icache_all_way,
                        l15_transducer_inval_dcache_all_way,
                        l15_transducer_inval_address_15_4,
                        l15_transducer_cross_invalidate,
                        l15_transducer_cross_invalidate_way,
                        l15_transducer_inval_dcache_inval,
                        l15_transducer_inval_icache_inval,
                        l15_transducer_inval_way,
                        l15_transducer_blockinitstore };

    wire [2:0] transducer_l15_size_pcx_standard;
    // see serpent_cache_pkg.sv for definition of the packed struct type "l15_req_t",
    // note that the constants defined in l15.tmp.h and serpent_cache_pkg.sv need to coincide!
    assign { transducer_l15_val,
             transducer_l15_req_ack,
             transducer_l15_rqtype,
             transducer_l15_nc,
             transducer_l15_size_pcx_standard,
             transducer_l15_threadid,
             transducer_l15_prefetch,
             transducer_l15_invalidate_cacheline,
             transducer_l15_blockstore,
             transducer_l15_blockinitstore,
             transducer_l15_l1rplway,
             transducer_l15_address,
             transducer_l15_data,
             transducer_l15_data_next_entry,
             transducer_l15_csm_data,
             transducer_l15_amo_op} = l15_req;

    // Could remove this converter after Ariane is changed to send the 
    // PMesh standard data size
    assign transducer_l15_size = (transducer_l15_size_pcx_standard == `PCX_SZ_1B) ? `MSG_DATA_SIZE_1B :
                                    (transducer_l15_size_pcx_standard == `PCX_SZ_2B) ? `MSG_DATA_SIZE_2B : 
                                    (transducer_l15_size_pcx_standard == `PCX_SZ_4B) ? `MSG_DATA_SIZE_4B : 
                                    (transducer_l15_size_pcx_standard == `PCX_SZ_8B) ? `MSG_DATA_SIZE_8B : 
                                    (transducer_l15_size_pcx_standard == `PCX_SZ_16B && 
                                     transducer_l15_rqtype == `PCX_REQTYPE_IFILL && 
                                    ~transducer_l15_invalidate_cacheline) ? `MSG_DATA_SIZE_32B : `MSG_DATA_SIZE_16B; 

    wire [63:0] ariane_bootaddr;

    assign ariane_bootaddr  =  64'hFFF1010000;



    ariane_verilog_wrap #(

        .NrPMPEntries           ( 4    ),
        .DmBaseAddress          ( 64'hFFF1000000 ),
        .SwapEndianess          ( 1'b1 ),
        .NrExecuteRegionRules   ( 3   ),
        .ExecuteRegionAddrBase  ( {64'h80000000, 64'hFFF1000000, 64'hFFF1010000}   ),
        .ExecuteRegionLength    ( {64'h40000000, 64'h1000, 64'h10000}   ),
        .NrCachedRegionRules    (  1   ),
        .CachedRegionAddrBase   ( {64'h80000000} ),
        .CachedRegionLength     ( {64'h40000000} )

    ) core (
        .clk_i       ( clk_gated              ),
        .reset_l     ( rst_n_f                ),
        .spc_grst_l  ( spc_grst_l             ),
        .boot_addr_i ( ariane_bootaddr        ),
        .hart_id_i   ( {{64-`JTAG_FLATID_WIDTH{1'b0}}, flat_tileid} ),
        .irq_i       ( irq_i                  ),
        .ipi_i       ( ipi_i                  ),
        .time_irq_i  ( timer_irq_i            ),
        .debug_req_i ( debug_req_i            ),
        .l15_req_o   ( l15_req                ),
        .l15_rtrn_i  ( l15_rtrn               )
    );

    assign unavailable_o = 1'b0;

`endif // ifdef PITON_ARIANE
  end
  endgenerate


    //////////
    // L1.5 //
    //////////

    l15_wrap l15(
        .clk(clk_gated),
        .rst_n(spc_grst_l),

        .transducer_l15_rqtype              (transducer_l15_rqtype),
        .transducer_l15_amo_op              (transducer_l15_amo_op),
        .transducer_l15_nc                  (transducer_l15_nc),
        .transducer_l15_size                (transducer_l15_size),
        // .pcxdecoder_l15_invalall         (transducer_l15_invalall),
        .transducer_l15_threadid            (transducer_l15_threadid),
        .transducer_l15_prefetch            (transducer_l15_prefetch),
        .transducer_l15_blockstore          (transducer_l15_blockstore),
        .transducer_l15_blockinitstore      (transducer_l15_blockinitstore),
        .transducer_l15_l1rplway            (transducer_l15_l1rplway),
        .transducer_l15_val                 (transducer_l15_val),
        .transducer_l15_invalidate_cacheline(transducer_l15_invalidate_cacheline),
        .transducer_l15_address             (transducer_l15_address),
        .transducer_l15_csm_data            (transducer_l15_csm_data),
        .transducer_l15_data                (transducer_l15_data),
        .transducer_l15_data_next_entry     (transducer_l15_data_next_entry),

        .l15_transducer_ack                 (l15_transducer_ack),
        .l15_transducer_header_ack          (l15_transducer_header_ack),

        .l15_transducer_val                 (l15_transducer_val),
        .l15_transducer_returntype          (l15_transducer_returntype),
        .l15_transducer_l2miss              (l15_transducer_l2miss),
        .l15_transducer_error               (l15_transducer_error),
        .l15_transducer_noncacheable        (l15_transducer_noncacheable),
        .l15_transducer_atomic              (l15_transducer_atomic),
        .l15_transducer_threadid            (l15_transducer_threadid),
        .l15_transducer_prefetch            (l15_transducer_prefetch),
        .l15_transducer_f4b                 (l15_transducer_f4b),
        .l15_transducer_data_0              (l15_transducer_data_0),
        .l15_transducer_data_1              (l15_transducer_data_1),
        .l15_transducer_data_2              (l15_transducer_data_2),
        .l15_transducer_data_3              (l15_transducer_data_3),
        .l15_transducer_inval_icache_all_way(l15_transducer_inval_icache_all_way),
        .l15_transducer_inval_dcache_all_way(l15_transducer_inval_dcache_all_way),
        .l15_transducer_inval_address_15_4  (l15_transducer_inval_address_15_4),
        .l15_transducer_cross_invalidate    (l15_transducer_cross_invalidate),
        .l15_transducer_cross_invalidate_way(l15_transducer_cross_invalidate_way),
        .l15_transducer_inval_dcache_inval  (l15_transducer_inval_dcache_inval),
        .l15_transducer_inval_icache_inval  (l15_transducer_inval_icache_inval),
        .l15_transducer_inval_way           (l15_transducer_inval_way),
        .l15_transducer_blockinitstore      (l15_transducer_blockinitstore),

        .transducer_l15_req_ack             (transducer_l15_req_ack),


        .noc1_out_rdy(router_processor_ready_noc1),
        .noc2_in_val(buffer_processor_valid_noc2),
        .noc2_in_data(buffer_processor_data_noc2),
        .noc3_out_rdy(router_processor_ready_noc3),
        .dmbr_l15_stall(dmbr_l15_stall),
        .chipid(config_chipid),
        .coreid_x(config_coreid_x),
        .coreid_y(config_coreid_y),

        .noc1_out_val(processor_router_valid_noc1),
        .noc1_out_data(processor_router_data_noc1),
        .noc2_in_rdy(processor_router_ready_noc2),
        .noc3_out_val(processor_router_valid_noc3),
        .noc3_out_data(processor_router_data_noc3),
        .l15_dmbr_l1missIn(l15_dmbr_l1missIn),
        .l15_dmbr_l1missTag(l15_dmbr_l1missTag),
        .l15_dmbr_l2missIn(l15_dmbr_l2missIn),
        .l15_dmbr_l2missTag(l15_dmbr_l2missTag),
        .l15_dmbr_l2responseIn(l15_dmbr_l2responseIn),

        // config registers
        .l15_config_req_val_s2(l15_config_req_val_s2),
        .l15_config_req_rw_s2(l15_config_req_rw_s2),
        .l15_config_write_req_data_s2(l15_config_write_req_data_s2),
        .l15_config_req_address_s2(l15_config_req_address_s2),
        .config_l15_read_res_data_s3(config_l15_read_res_data_s3),

        // config regs
        .config_csm_en(config_csm_en),
        .config_hmt_base(config_hmt_base),
        .config_system_tile_count(config_system_tile_count),
        .config_home_alloc_method(config_home_alloc_method),

        // sram interfaces
        .srams_rtap_data (l15_rtap_data),
        .rtap_srams_bist_command (rtap_srams_bist_command),
        .rtap_srams_bist_data (rtap_srams_bist_data)
    );

    //////////
    // DMBR //
    //////////

    dmbr dmbr_ins (
        .clk                  (clk_gated                      ),
        .rst                  (~spc_grst_l              ),
        .func_en              (config_dmbr_func_en      ),
        .stall_en             (config_dmbr_stall_en     ),
        //.dmbr_en(dmbr_en),
        .proc_ld              (config_dmbr_proc_ld      ),

        //inputs (the credits should take into account credit scaling factor,
        //which means creditIn_0 should be 1/10 of the original credit) ???
        // are you shure that a scale factor can be 10? //alavrov
        .creditIn_0		(config_dmbr_cred_bin_0),
.creditIn_1		(config_dmbr_cred_bin_1),
.creditIn_2		(config_dmbr_cred_bin_2),
.creditIn_3		(config_dmbr_cred_bin_3),
.creditIn_4		(config_dmbr_cred_bin_4),
.creditIn_5		(config_dmbr_cred_bin_5),
.creditIn_6		(config_dmbr_cred_bin_6),
.creditIn_7		(config_dmbr_cred_bin_7),
.creditIn_8		(config_dmbr_cred_bin_8),
.creditIn_9		(config_dmbr_cred_bin_9),


        //scale factor for replenishment (shoud be 1000)
        .replenishCyclesIn    (config_dmbr_replenish_cycles ),

        //scale factor for arrival interval checking (shoud be 3)
        .binScaleIn           (config_dmbr_bin_scale        ),

        // Input from L1.5
        .l1missIn             (l15_dmbr_l1missIn            ),
        .l1missTag            (l15_dmbr_l1missTag           ),

        // Input from L2
        .l2missIn             (l15_dmbr_l2missIn            ),
        .l2missTag            (l15_dmbr_l2missTag           ),
        .l2responseIn         (l15_dmbr_l2responseIn        ),

        //outputs
        .curr_cred_bin_0			(from_dmbr_cred_bin_0),
.curr_cred_bin_1			(from_dmbr_cred_bin_1),
.curr_cred_bin_2			(from_dmbr_cred_bin_2),
.curr_cred_bin_3			(from_dmbr_cred_bin_3),
.curr_cred_bin_4			(from_dmbr_cred_bin_4),
.curr_cred_bin_5			(from_dmbr_cred_bin_5),
.curr_cred_bin_6			(from_dmbr_cred_bin_6),
.curr_cred_bin_7			(from_dmbr_cred_bin_7),
.curr_cred_bin_8			(from_dmbr_cred_bin_8),
.curr_cred_bin_9			(from_dmbr_cred_bin_9),


        .stallOut             (dmbr_l15_stall           )
    );

    ////////
    // L2 //
    ////////

    l2 l2(
        .clk(clk_gated),
        .rst_n(rst_n_f),
        .chipid(config_chipid),
        .coreid_x(config_coreid_x),
        .coreid_y(config_coreid_y),
        .noc1_valid_in(buffer_processor_valid_noc1),
        .noc3_valid_in(buffer_processor_valid_noc3),
        .noc1_data_in(buffer_processor_data_noc1),
        .noc3_data_in(buffer_processor_data_noc3),
        .noc2_ready_out(router_processor_ready_noc2),

        .noc1_ready_in(processor_router_ready_noc1),
        .noc3_ready_in(processor_router_ready_noc3),
        .noc2_valid_out(processor_router_valid_noc2),
        .noc2_data_out(processor_router_data_noc2),

        // interface to srams
        .srams_rtap_data (l2_rtap_data),
        .rtap_srams_bist_command (rtap_srams_bist_command),
        .rtap_srams_bist_data (rtap_srams_bist_data)
    );

    ////////////////////////////////////
    // Uncore Configuration Registers //
    ////////////////////////////////////

    config_regs uncore_config(
        .clk                          (clk_gated                          ),
        .rst_n                        (rst_n_f                        ),

        .l15_config_req_val_s2        (l15_config_req_val_s2        ),
        .l15_config_req_rw_s2         (l15_config_req_rw_s2         ),
        .l15_config_write_req_data_s2 (l15_config_write_req_data_s2 ),
        .l15_config_req_address_s2    (l15_config_req_address_s2    ),
        .config_l15_read_res_data_s3  (config_l15_read_res_data_s3  ),

        .default_chipid               (default_chipid               ),
        .default_coreid_x             (default_coreid_x             ),
        .default_coreid_y             (default_coreid_y             ),
        .default_total_num_tiles      (default_total_num_tiles      ),

        .config_hmt_base              (config_hmt_base              ),

        .config_dmbr_func_en          (config_dmbr_func_en          ),
        .config_dmbr_stall_en         (config_dmbr_stall_en         ),
        .config_dmbr_proc_ld          (config_dmbr_proc_ld          ),
        .config_dmbr_replenish_cycles (config_dmbr_replenish_cycles ),
        .config_dmbr_bin_scale        (config_dmbr_bin_scale        ),

        // config_registers -> DMBR
        .config_dmbr_cred_bin_0			(config_dmbr_cred_bin_0),
.config_dmbr_cred_bin_1			(config_dmbr_cred_bin_1),
.config_dmbr_cred_bin_2			(config_dmbr_cred_bin_2),
.config_dmbr_cred_bin_3			(config_dmbr_cred_bin_3),
.config_dmbr_cred_bin_4			(config_dmbr_cred_bin_4),
.config_dmbr_cred_bin_5			(config_dmbr_cred_bin_5),
.config_dmbr_cred_bin_6			(config_dmbr_cred_bin_6),
.config_dmbr_cred_bin_7			(config_dmbr_cred_bin_7),
.config_dmbr_cred_bin_8			(config_dmbr_cred_bin_8),
.config_dmbr_cred_bin_9			(config_dmbr_cred_bin_9),


        // DMBR -> config registers
        .from_dmbr_cred_bin_0			(from_dmbr_cred_bin_0),
.from_dmbr_cred_bin_1			(from_dmbr_cred_bin_1),
.from_dmbr_cred_bin_2			(from_dmbr_cred_bin_2),
.from_dmbr_cred_bin_3			(from_dmbr_cred_bin_3),
.from_dmbr_cred_bin_4			(from_dmbr_cred_bin_4),
.from_dmbr_cred_bin_5			(from_dmbr_cred_bin_5),
.from_dmbr_cred_bin_6			(from_dmbr_cred_bin_6),
.from_dmbr_cred_bin_7			(from_dmbr_cred_bin_7),
.from_dmbr_cred_bin_8			(from_dmbr_cred_bin_8),
.from_dmbr_cred_bin_9			(from_dmbr_cred_bin_9),


        .config_csm_en                (config_csm_en                ),
        .config_system_tile_count     (config_system_tile_count     ),
        .config_home_alloc_method     (config_home_alloc_method     ),
        .config_chipid                (config_chipid                ),
        .config_coreid_x              (config_coreid_x              ),
        .config_coreid_y              (config_coreid_y              ),

        // jtag-config_regs interface
        .rtap_config_req_val (rtap_config_req_val),
        .rtap_config_req_rw (rtap_config_req_rw),
        .rtap_config_write_req_data (rtap_config_write_req_data),
        .rtap_config_req_address (rtap_config_req_address),
        .config_rtap_read_res_data (config_rtap_read_res_data)
    );

    // RTAP module

    // merge sram reponses
    assign srams_rtap_data = l15_rtap_data
                                | sparc_rtap_data
                                | l2_rtap_data;


    rtap rtap(
        .clk(clk_gated),
        .rst_n(rst_n_f),
        .own_tileid(flat_tileid),

        // UCB bus interface
        .tile_jtag_ucb_val(tile_jtag_ucb_val),
        .tile_jtag_ucb_data(tile_jtag_ucb_data),
        .jtag_tiles_ucb_val(jtag_tiles_ucb_val),
        .jtag_tiles_ucb_data(jtag_tiles_ucb_data),

        // interface to srams
        .srams_rtap_data (srams_rtap_data),
        .rtap_srams_bist_command (rtap_srams_bist_command),
        .rtap_srams_bist_data (rtap_srams_bist_data),

        // insert interrupt packets for jtag
        .rtap_arb_req_val (rtap_arb_req_val),
        .rtap_arb_req_data (rtap_arb_req_data),
        .rtap_arb_req_threadid (rtap_arb_req_threadid),

        // jtag-config_regs interface
        .rtap_config_req_val (rtap_config_req_val),
        .rtap_config_req_rw (rtap_config_req_rw),
        .rtap_config_write_req_data (rtap_config_write_req_data),
        .rtap_config_req_address (rtap_config_req_address),
        .config_rtap_read_res_data (config_rtap_read_res_data),

        .core_rtap_data          (core_rtap_data),
        .rtap_core_val         (rtap_core_val),
        .rtap_core_threadid         (rtap_core_threadid),
        .rtap_core_id         (rtap_core_id),
        .rtap_core_data         (rtap_core_data)
        );

endmodule
