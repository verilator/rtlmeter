// ----------------------------------------------------------------------------
//      ___                                   _____                      ___
//     /__/\          ___        ___         /  /::\       ___          /  /\
//     \  \:\        /__/\      /  /\       /  /:/\:\     /  /\        /  /::\
//      \  \:\       \  \:\    /  /:/      /  /:/  \:\   /  /:/       /  /:/\:\
//  _____\__\:\       \  \:\  /__/::\     /__/:/ \__\:| /__/::\      /  /:/~/::\
// /__/::::::::\  ___  \__\:\ \__\/\:\__  \  \:\ /  /:/ \__\/\:\__  /__/:/ /:/\:\
// \  \:\~~\~~\/ /__/\ |  |:|    \  \:\/\  \  \:\  /:/     \  \:\/\ \  \:\/:/__\/
//  \  \:\  ~~~  \  \:\|  |:|     \__\::/   \  \:\/:/       \__\::/  \  \::/
//   \  \:\       \  \:\__|:|     /__/:/     \  \::/        /__/:/    \  \:\
//    \  \:\       \__\::::/      \__\/       \__\/         \__\/      \  \:\
//     \__\/           ~~~~                                             \__\/
//                                     ___                            ___
//         _____                      /  /\             ___          /  /\
//        /  /::\                    /  /::\           /  /\        /  /::\
//       /  /:/\:\                  /  /:/\:\         /  /:/       /  /:/\:\
//      /  /:/  \:\   __      __   /  /:/~/::\       /__/::\      /  /:/~/:/
//     /__/:/ \__\:/ /__/\   /  /\/__/:/ /:/\:\      \__\/\:\__  /__/:/ /:/
//     \  \:\ /  /:/ \  \:\ /  /:/\  \:\/:/__\/         \  \:\/\ \  \:\/:/
//      \  \:\  /:/   \  \:\  /:/  \  \::/               \__\::/  \  \::/
//       \  \:\/:/     \  \:\/:/    \  \:\               /__/:/    \  \:\
//        \  \::/       \  \::/      \  \:\              \__\/      \  \:\
//         \__\/         \__\/        \__\/                          \__\/
// ----------------------------------------------------------------------------
//
// Component: Top-level Module Example Testbench
//
// ----------------------------------------------------------------------------

/// Top-level RTL module for example testbench.

`include "syn_tb_defines.vh"

module tb_top;

   // -----------------
   // PARAMETER DECL
   // -----------------

    localparam simulation_cycle = 20;

   // -----------------
   // CLK/RESET REG DECL
   // -----------------

    reg       reset = 1'b1;    // spyglass disable W402b // System reset
    reg       clk = 1'b1;      // System clock


   // -----------------
   // AXI WIRE DECL
   // -----------------

    wire [63:0]   axi_slave0_araddr;
    wire [7:0]    axi_slave0_arid;
    wire [3:0]    axi_slave0_arlen;
    wire          axi_slave0_arvalid;
    wire          axi_slave0_arready;

    wire [511:0]  axi_slave0_rdata;
    wire [7:0]    axi_slave0_rid;
    wire          axi_slave0_rlast;
    wire          axi_slave0_rvalid;
    wire          axi_slave0_rready;

    wire [63:0]   axi_slave0_awaddr;
    wire [7:0]    axi_slave0_awid;
    wire [3:0]    axi_slave0_awlen;
    wire          axi_slave0_awvalid;
    wire          axi_slave0_awready;

    wire [511:0]  axi_slave0_wdata;
    wire [63:0]   axi_slave0_wstrb;
    wire          axi_slave0_wlast;
    wire          axi_slave0_wvalid;
    wire          axi_slave0_wready;

    wire [7:0]    axi_slave0_bid;
    wire          axi_slave0_bvalid;
    wire          axi_slave0_bready;

    wire [63:0]   axi_slave1_araddr;
    wire [7:0]    axi_slave1_arid;
    wire [3:0]    axi_slave1_arlen;
    wire          axi_slave1_arvalid;
    wire          axi_slave1_arready;

    wire [511:0]  axi_slave1_rdata;
    wire [7:0]    axi_slave1_rid;
    wire          axi_slave1_rlast;
    wire          axi_slave1_rvalid;
    wire          axi_slave1_rready;

    wire [63:0]   axi_slave1_awaddr;
    wire [7:0]    axi_slave1_awid;
    wire [3:0]    axi_slave1_awlen;
    wire          axi_slave1_awvalid;
    wire          axi_slave1_awready;

    wire [511:0]  axi_slave1_wdata;
    wire [63:0]   axi_slave1_wstrb;
    wire          axi_slave1_wlast;
    wire          axi_slave1_wvalid;
    wire          axi_slave1_wready;

    wire [7:0]    axi_slave1_bid;
    wire          axi_slave1_bvalid;
    wire          axi_slave1_bready;

    wire dla_intr;

    // Synthesizable TB: Connectivity wires between master_seq, axi_master and nvdla
    wire        mseq2tb_test_done;
    wire        mcsb2scsb_pvld;
    wire        mcsb2scsb_prdy;
    wire [62:0] mcsb2scsb_pd;

    wire        scsb2mcsb_valid;
    wire [31:0] scsb2mcsb_pd;
    wire        scsb2mcsb_error;
    wire        scsb2mcsb_wr_complete;
    wire        scsb2mcsb_wr_err;
    wire        scsb2mcsb_wr_rdat;

    wire        mseq_pending_req;
    wire [62:0] mseq2mcsb_pd;
    wire        mcsb2mseq_consumed_req;
    wire [31:0] mcsb2mseq_rdata;
    wire        mcsb2mseq_rvalid;

    // CSB Master Sequencer
    csb_master_seq csb_mseq(

        .clk                    (clk)
       ,.reset                  (reset) // spyglass disable W123

       ,.mseq_pending_req       (mseq_pending_req)
       ,.mseq2mcsb_pd           (mseq2mcsb_pd)
       ,.mcsb2mseq_consumed_req (mcsb2mseq_consumed_req)
       ,.mcsb2mseq_rdata        (mcsb2mseq_rdata)
       ,.mcsb2mseq_rvalid       (mcsb2mseq_rvalid)

       ,.dut2mseq_intr0         (dla_intr)
       ,.mseq2tb_test_done      (mseq2tb_test_done)

    ); // syn_master_seq

    // Syn CSB Master
    syn_csb_master csb_master(

        .clk                    (clk)
       ,.reset                  (reset) // spyglass disable UndrivenInTerm-ML

       ,.mcsb2scsb_pvld         (mcsb2scsb_pvld)
       ,.mcsb2scsb_prdy         (mcsb2scsb_prdy)
       ,.mcsb2scsb_pd           (mcsb2scsb_pd)

       ,.scsb2mcsb_valid        (scsb2mcsb_valid)
       ,.scsb2mcsb_pd           (scsb2mcsb_pd)
       ,.scsb2mcsb_error        (scsb2mcsb_error)
       ,.scsb2mcsb_wr_complete  (scsb2mcsb_wr_complete)
       ,.scsb2mcsb_wr_err       (scsb2mcsb_wr_err)
       ,.scsb2mcsb_wr_rdat      (scsb2mcsb_wr_rdat)

       ,.mseq_pending_req       (mseq_pending_req)
       ,.mseq2mcsb_pd           (mseq2mcsb_pd)
       ,.mcsb2mseq_consumed_req (mcsb2mseq_consumed_req)
       ,.mcsb2mseq_rdata        (mcsb2mseq_rdata)
       ,.mcsb2mseq_rvalid       (mcsb2mseq_rvalid)

    );

    axi_memory #(
      .BASE_ADDR(`DBB_ADDR_START),
      .SIZE     (`DBB_MEM_SIZE)
    ) dbb_mem (
      .clk      (clk),
      .reset    (reset),
      .araddr   (axi_slave0_araddr ),
      .arid     (axi_slave0_arid   ),
      .arlen    (axi_slave0_arlen  ),
      .arvalid  (axi_slave0_arvalid),
      .arready  (axi_slave0_arready),
      .rdata    (axi_slave0_rdata  ),
      .rid      (axi_slave0_rid    ),
      .rlast    (axi_slave0_rlast  ),
      .rvalid   (axi_slave0_rvalid ),
      .rready   (axi_slave0_rready ),
      .awaddr   (axi_slave0_awaddr ),
      .awid     (axi_slave0_awid   ),
      .awlen    (axi_slave0_awlen  ),
      .awvalid  (axi_slave0_awvalid),
      .awready  (axi_slave0_awready),
      .wdata    (axi_slave0_wdata  ),
      .wstrb    (axi_slave0_wstrb  ),
      .wlast    (axi_slave0_wlast  ),
      .wvalid   (axi_slave0_wvalid ),
      .wready   (axi_slave0_wready ),
      .bid      (axi_slave0_bid    ),
      .bvalid   (axi_slave0_bvalid ),
      .bready   (axi_slave0_bready )
    );

    axi_memory #(
      .BASE_ADDR(`CVSRAM_ADDR_START),
      .SIZE     (`CVSRAM_MEM_SIZE)
    ) cvsram_mem (
      .clk      (clk),
      .reset    (reset),
      .araddr   (axi_slave1_araddr ),
      .arid     (axi_slave1_arid   ),
      .arlen    (axi_slave1_arlen  ),
      .arvalid  (axi_slave1_arvalid),
      .arready  (axi_slave1_arready),
      .rdata    (axi_slave1_rdata  ),
      .rid      (axi_slave1_rid    ),
      .rlast    (axi_slave1_rlast  ),
      .rvalid   (axi_slave1_rvalid ),
      .rready   (axi_slave1_rready ),
      .awaddr   (axi_slave1_awaddr ),
      .awid     (axi_slave1_awid   ),
      .awlen    (axi_slave1_awlen  ),
      .awvalid  (axi_slave1_awvalid),
      .awready  (axi_slave1_awready),
      .wdata    (axi_slave1_wdata  ),
      .wstrb    (axi_slave1_wstrb  ),
      .wlast    (axi_slave1_wlast  ),
      .wvalid   (axi_slave1_wvalid ),
      .wready   (axi_slave1_wready ),
      .bid      (axi_slave1_bid    ),
      .bvalid   (axi_slave1_bvalid ),
      .bready   (axi_slave1_bready )
    );

   // --------------------------
   // Generated clocks
   // --------------------------

  always #(simulation_cycle/2) clk = ~clk;

  int iterations = 1;

  initial begin
    #(simulation_cycle*20);
    $value$plusargs("iterations=%d", iterations);
    for (int i = 0; i < iterations; ++i) begin
      $display("Iteration %0d", i);
      reset = 1'b0;
      #(simulation_cycle*20);
      reset = 1'b1;
      wait (mseq2tb_test_done === 1'b1);
      #(simulation_cycle*20);
      @(posedge clk);
    end

    $finish;
  end

   // --------------
   // nvdla IP wrapper
   // --------------

   NV_nvdla nvdla_top (

        .dla_core_clk (clk)
        ,.dla_csb_clk (clk)
        ,.global_clk_ovr_on (1'b0)
        ,.tmc2slcg_disable_clock_gating (1'b0)
        ,.dla_reset_rstn (reset)
        ,.direct_reset_ (reset)
        ,.test_mode (1'b0)
        ,.csb2nvdla_valid (mcsb2scsb_pvld)               //|< i
        ,.csb2nvdla_ready (mcsb2scsb_prdy)               //|> o
        ,.csb2nvdla_addr (mcsb2scsb_pd[15:0])            //|< i
        ,.csb2nvdla_wdat (mcsb2scsb_pd[53:22])           //|< i
        ,.csb2nvdla_write (mcsb2scsb_pd[54:54])          //|< i
        ,.csb2nvdla_nposted (mcsb2scsb_pd[55:55])        //|< i
        ,.nvdla2csb_valid (scsb2mcsb_valid)              //|> o
        ,.nvdla2csb_data (scsb2mcsb_pd)               //|> o
        ,.nvdla2csb_wr_complete (scsb2mcsb_wr_complete)  //|> o
        ,.nvdla_core2dbb_aw_awvalid (axi_slave0_awvalid)
        ,.nvdla_core2dbb_aw_awready (axi_slave0_awready)
        ,.nvdla_core2dbb_aw_awaddr (axi_slave0_awaddr)
        ,.nvdla_core2dbb_aw_awid (axi_slave0_awid)
        ,.nvdla_core2dbb_aw_awlen (axi_slave0_awlen)
        ,.nvdla_core2dbb_w_wvalid (axi_slave0_wvalid)
        ,.nvdla_core2dbb_w_wready (axi_slave0_wready)
        ,.nvdla_core2dbb_w_wdata (axi_slave0_wdata)
        ,.nvdla_core2dbb_w_wstrb (axi_slave0_wstrb)
        ,.nvdla_core2dbb_w_wlast (axi_slave0_wlast)
        ,.nvdla_core2dbb_b_bvalid (axi_slave0_bvalid)
        ,.nvdla_core2dbb_b_bready (axi_slave0_bready)
        ,.nvdla_core2dbb_b_bid (axi_slave0_bid)
        ,.nvdla_core2dbb_ar_arvalid (axi_slave0_arvalid)
        ,.nvdla_core2dbb_ar_arready (axi_slave0_arready)
        ,.nvdla_core2dbb_ar_araddr (axi_slave0_araddr)
        ,.nvdla_core2dbb_ar_arid (axi_slave0_arid)
        ,.nvdla_core2dbb_ar_arlen (axi_slave0_arlen)
        ,.nvdla_core2dbb_r_rvalid (axi_slave0_rvalid)
        ,.nvdla_core2dbb_r_rready (axi_slave0_rready)
        ,.nvdla_core2dbb_r_rid (axi_slave0_rid)
        ,.nvdla_core2dbb_r_rlast (axi_slave0_rlast)
        ,.nvdla_core2dbb_r_rdata (axi_slave0_rdata)
        ,.nvdla_core2cvsram_aw_awvalid (axi_slave1_awvalid)
        ,.nvdla_core2cvsram_aw_awready (axi_slave1_awready)
        ,.nvdla_core2cvsram_aw_awaddr (axi_slave1_awaddr)
        ,.nvdla_core2cvsram_aw_awid (axi_slave1_awid)
        ,.nvdla_core2cvsram_aw_awlen (axi_slave1_awlen)
        ,.nvdla_core2cvsram_w_wvalid (axi_slave1_wvalid)
        ,.nvdla_core2cvsram_w_wready (axi_slave1_wready)
        ,.nvdla_core2cvsram_w_wdata (axi_slave1_wdata)
        ,.nvdla_core2cvsram_w_wstrb (axi_slave1_wstrb)
        ,.nvdla_core2cvsram_w_wlast (axi_slave1_wlast)
        ,.nvdla_core2cvsram_b_bvalid (axi_slave1_bvalid)
        ,.nvdla_core2cvsram_b_bready (axi_slave1_bready)
        ,.nvdla_core2cvsram_b_bid (axi_slave1_bid)
        ,.nvdla_core2cvsram_ar_arvalid (axi_slave1_arvalid)
        ,.nvdla_core2cvsram_ar_arready (axi_slave1_arready)
        ,.nvdla_core2cvsram_ar_araddr (axi_slave1_araddr)
        ,.nvdla_core2cvsram_ar_arid (axi_slave1_arid)
        ,.nvdla_core2cvsram_ar_arlen (axi_slave1_arlen)
        ,.nvdla_core2cvsram_r_rvalid (axi_slave1_rvalid)
        ,.nvdla_core2cvsram_r_rready (axi_slave1_rready)
        ,.nvdla_core2cvsram_r_rid (axi_slave1_rid)
        ,.nvdla_core2cvsram_r_rlast (axi_slave1_rlast)
        ,.nvdla_core2cvsram_r_rdata (axi_slave1_rdata)
        ,.dla_intr (dla_intr)
        ,.nvdla_pwrbus_ram_c_pd (32'b0)
        ,.nvdla_pwrbus_ram_ma_pd (32'b0)
        ,.nvdla_pwrbus_ram_mb_pd (32'b0)
        ,.nvdla_pwrbus_ram_p_pd (32'b0)
        ,.nvdla_pwrbus_ram_o_pd (32'b0)
        ,.nvdla_pwrbus_ram_a_pd (32'b0)

   ); // nvdla_top

`include "__rtlmeter_top_include.vh"

endmodule

