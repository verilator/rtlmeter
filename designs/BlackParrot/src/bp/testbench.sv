/**
  *
  * testbench.v
  *
  */


`include "bp_common_defines.svh"
`include "bp_be_defines.svh"
`include "bp_fe_defines.svh"
`include "bp_me_defines.svh"
`include "bp_top_defines.svh"

`ifndef BP_CFG_FLOWVAR
"BSG-ERROR BP_CFG_FLOWVAR must be set"
`endif

module testbench
 import bp_common_pkg::*;
 import bp_be_pkg::*;
 import bp_me_pkg::*;
 import bsg_noc_pkg::*;
 #(parameter bp_params_e bp_params_p = `BP_CFG_FLOWVAR
   `declare_bp_proc_params(bp_params_p)
   `declare_bp_core_if_widths(vaddr_width_p, paddr_width_p, asid_width_p, branch_metadata_fwd_width_p)

   // tb parameters
   , parameter tb_clock_period_p           = 0
   , parameter tb_reset_cycles_lo_p        = 0
   , parameter tb_reset_cycles_hi_p        = 0

   // sim parameters
   , parameter sim_clock_period_p          = 0
   , parameter sim_reset_cycles_lo_p       = 0
   , parameter sim_reset_cycles_hi_p       = 0

   // watchdog parameters
   , parameter watchdog_enable_p           = 0
   , parameter stall_cycles_p              = 0
   , parameter halt_instr_p                = 0
   , parameter heartbeat_instr_p           = 0

   // cosim parameters
   , parameter cosim_trace_p               = 0
   , parameter cosim_check_p               = 0

   // perf parameters
   , parameter perf_enable_p               = 0
   , parameter warmup_instr_p              = 0
   , parameter max_instr_p                 = 0
   , parameter max_cycle_p                 = 0

   // trace parameters
   , parameter icache_trace_p              = 0
   , parameter dcache_trace_p              = 0
   , parameter vm_trace_p                  = 0
   , parameter uce_trace_p                 = 0
   , parameter lce_trace_p                 = 0
   , parameter cce_trace_p                 = 0
   , parameter dev_trace_p                 = 0
   , parameter dram_trace_p                = 0
   );

  `declare_bp_bedrock_if(paddr_width_p, lce_id_width_p, cce_id_width_p, did_width_p, lce_assoc_p);

  // Bit to deal with initial X->0 transition detection
  bit dut_clk, dut_reset;

  bp_bedrock_mem_fwd_header_s mem_fwd_header_lo;
  logic [bedrock_fill_width_p-1:0] mem_fwd_data_lo;
  logic mem_fwd_v_lo, mem_fwd_ready_and_li;
  bp_bedrock_mem_rev_header_s mem_rev_header_li;
  logic [bedrock_fill_width_p-1:0] mem_rev_data_li;
  logic mem_rev_v_li, mem_rev_ready_and_lo;

  bp_bedrock_mem_fwd_header_s mem_fwd_header_li;
  logic [bedrock_fill_width_p-1:0] mem_fwd_data_li;
  logic mem_fwd_v_li, mem_fwd_ready_and_lo;
  bp_bedrock_mem_rev_header_s mem_rev_header_lo;
  logic [bedrock_fill_width_p-1:0] mem_rev_data_lo;
  logic mem_rev_v_lo, mem_rev_ready_and_li;

  `declare_bsg_cache_dma_pkt_s(daddr_width_p, l2_block_size_in_words_p);
  bsg_cache_dma_pkt_s [num_cce_p-1:0][l2_dmas_p-1:0] dma_pkt_lo;
  logic [num_cce_p-1:0][l2_dmas_p-1:0] dma_pkt_v_lo, dma_pkt_yumi_li;
  logic [num_cce_p-1:0][l2_dmas_p-1:0][l2_fill_width_p-1:0] dma_data_lo;
  logic [num_cce_p-1:0][l2_dmas_p-1:0] dma_data_v_lo, dma_data_yumi_li;
  logic [num_cce_p-1:0][l2_dmas_p-1:0][l2_fill_width_p-1:0] dma_data_li;
  logic [num_cce_p-1:0][l2_dmas_p-1:0] dma_data_v_li, dma_data_ready_and_lo;

  wire [mem_noc_did_width_p-1:0] proc_did_li = 1;
  wire [mem_noc_did_width_p-1:0] host_did_li = '1;
  wire [lce_id_width_p-1:0] host_lce_id_li = num_core_p*2+num_cacc_p+num_l2e_p+num_sacc_p+num_io_p;
  wrapper
   #(.bp_params_p(bp_params_p))
   wrapper
    (.clk_i(dut_clk)
     ,.reset_i(dut_reset)

     ,.my_did_i(proc_did_li)
     ,.host_did_i(host_did_li)

     ,.mem_fwd_header_i(mem_fwd_header_li)
     ,.mem_fwd_data_i(mem_fwd_data_li)
     ,.mem_fwd_v_i(mem_fwd_v_li)
     ,.mem_fwd_ready_and_o(mem_fwd_ready_and_lo)

     ,.mem_rev_header_o(mem_rev_header_lo)
     ,.mem_rev_data_o(mem_rev_data_lo)
     ,.mem_rev_v_o(mem_rev_v_lo)
     ,.mem_rev_ready_and_i(mem_rev_ready_and_li)

     ,.mem_fwd_header_o(mem_fwd_header_lo)
     ,.mem_fwd_data_o(mem_fwd_data_lo)
     ,.mem_fwd_v_o(mem_fwd_v_lo)
     ,.mem_fwd_ready_and_i(mem_fwd_ready_and_li)

     ,.mem_rev_header_i(mem_rev_header_li)
     ,.mem_rev_data_i(mem_rev_data_li)
     ,.mem_rev_v_i(mem_rev_v_li)
     ,.mem_rev_ready_and_o(mem_rev_ready_and_lo)

     ,.dma_pkt_o(dma_pkt_lo)
     ,.dma_pkt_v_o(dma_pkt_v_lo)
     ,.dma_pkt_ready_and_i(dma_pkt_yumi_li)

     ,.dma_data_i(dma_data_li)
     ,.dma_data_v_i(dma_data_v_li)
     ,.dma_data_ready_and_o(dma_data_ready_and_lo)

     ,.dma_data_o(dma_data_lo)
     ,.dma_data_v_o(dma_data_v_lo)
     ,.dma_data_ready_and_i(dma_data_yumi_li)
     );

  bsg_nonsynth_clock_gen
   #(.cycle_time_p(sim_clock_period_p))
   dut_clock_gen
    (.o(dut_clk));

  bsg_nonsynth_reset_gen
   #(.reset_cycles_lo_p(sim_reset_cycles_lo_p), .reset_cycles_hi_p(sim_reset_cycles_hi_p))
   dut_reset_gen
    (.clk_i(dut_clk)
     ,.async_reset_o(dut_reset)
     );

  logic loader_done_lo;
  bp_nonsynth_cfg_loader
   #(.bp_params_p(bp_params_p), .ucode_str_p("ucode_mem"))
   loader
    (.clk_i(dut_clk)
     ,.reset_i(dut_reset)

     ,.lce_id_i(host_lce_id_li)
     ,.did_i(host_did_li)

     ,.mem_fwd_header_o(mem_fwd_header_li)
     ,.mem_fwd_data_o(mem_fwd_data_li)
     ,.mem_fwd_v_o(mem_fwd_v_li)
     ,.mem_fwd_ready_and_i(mem_fwd_ready_and_lo)

     ,.mem_rev_header_i(mem_rev_header_lo)
     ,.mem_rev_data_i(mem_rev_data_lo)
     ,.mem_rev_v_i(mem_rev_v_lo)
     ,.mem_rev_ready_and_o(mem_rev_ready_and_li)

     ,.done_o(loader_done_lo)
     );

  bp_nonsynth_dram
   #(.num_dma_p(num_cce_p*l2_dmas_p)
     ,.dma_addr_width_p(daddr_width_p)
     ,.dma_data_width_p(l2_fill_width_p)
     ,.dma_burst_len_p(l2_block_size_in_fill_p)
     ,.dma_mask_width_p(l2_block_size_in_words_p)
     )
   dram
    (.clk_i(dut_clk)
     ,.reset_i(dut_reset)

     ,.dma_pkt_i(dma_pkt_lo)
     ,.dma_pkt_v_i(dma_pkt_v_lo)
     ,.dma_pkt_yumi_o(dma_pkt_yumi_li)

     ,.dma_data_o(dma_data_li)
     ,.dma_data_v_o(dma_data_v_li)
     ,.dma_data_ready_and_i(dma_data_ready_and_lo)

     ,.dma_data_i(dma_data_lo)
     ,.dma_data_v_i(dma_data_v_lo)
     ,.dma_data_yumi_o(dma_data_yumi_li)
     );

  bp_nonsynth_host
   #(.bp_params_p(bp_params_p))
   host
    (.clk_i(dut_clk)
     ,.reset_i(dut_reset)

     ,.mem_fwd_header_i(mem_fwd_header_lo)
     ,.mem_fwd_data_i(mem_fwd_data_lo)
     ,.mem_fwd_v_i(mem_fwd_v_lo)
     ,.mem_fwd_ready_and_o(mem_fwd_ready_and_li)

     ,.mem_rev_header_o(mem_rev_header_li)
     ,.mem_rev_data_o(mem_rev_data_li)
     ,.mem_rev_v_o(mem_rev_v_li)
     ,.mem_rev_ready_and_i(mem_rev_ready_and_lo)
     );

  wire ifverif_en_li = 1'b1;
  bp_nonsynth_if_verif
   #(.bp_params_p(bp_params_p))
   if_verif
    (.clk_i(testbench.dut_clk)
     ,.reset_i(testbench.dut_reset)
     ,.en_i(testbench.ifverif_en_li)
     );

`include  "__rtlmeter_top_include.vh"

endmodule

