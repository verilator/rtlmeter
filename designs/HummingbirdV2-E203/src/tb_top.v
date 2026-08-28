// The RTLMeter testbench for the HummingbirdV2 E203 SoC.
//
// Of the 136 files imported from the repository named in descriptor.yaml, 133
// are byte identical, including the license. Three differ: this testbench, plus
// src/sirv_gnrl_dffs.v and src/i2c_master_byte_ctrl.v, whose 65 inline
// intra-assignment delays are now the RTLMETER_FF_DELAY macro, changed in place
// and nothing else. descriptor.yaml sets that macro to '#1' in the 'default'
// configuration and to nothing in 'nodelay'. It is a legacy waveform idiom that
// does not affect what the design computes, but it stops Verilator statically
// scheduling those processes, and as every E203 register is an instance of one
// of those flop modules, 'default' ends up with 2338 coroutines against
// 'nodelay's 6, and runs the same workload some twenty times slower.
//
// Upstream tb/tb_top.v drives the riscv-tests suite: it takes the image name
// from a '+TESTCASE' plusarg, decides pass or fail from register x3 and from
// hardcoded program counter values inside the riscv-tests startup code, and
// optionally forces random interrupts and bus errors into the design. None of
// that suits a benchmark, so what is kept here is the device instantiation, the
// clock and reset generation, and the ITCM preload, and the rest is replaced:
//
//   - the image is always 'program.hex', so that every test can be named the
//     same way and no plusarg is needed to find it
//   - '+iterations' patches the last word of the loaded image, which is where
//     the linker script puts the benchmark iteration count
//   - a console at the last word of the DTCM prints characters and ends the
//     test, in place of the x3 and program counter checks. This is the same
//     mechanism the VeeR testbenches in RTLMeter use.
//   - the random interrupt and bus error forcing under 'ENABLE_TB_FORCE' is
//     dropped. It is driven by $urandom_range and would make the case
//     nondeterministic across scheduling changes, which is exactly what
//     RTLMeter must not have.
//   - the waveform dumping under '+DUMPWAVE' is dropped, RTLMeter provides its
//     own through the include below

`include "e203_defines.v"

module tb_top();

  `include "__rtlmeter_top_include.vh"

  reg  clk = 1'b0;
  reg  lfextclk = 1'b0;
  reg  rst_n = 1'b1;

  wire hfclk = clk;

  `define U_CPU u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top.u_e203_cpu
  `define ITCM u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram.u_sirv_sim_ram

  // Byte offset within the ITCM of the word holding the benchmark iteration
  // count, patched below from '+iterations'. This is the last word of the ITCM,
  // which is where sw/HummingbirdV2-E203/common/hummingbird.ld puts .iterCount.
  localparam ITERATIONS_OFFSET = 32'h0000_fffc;

  // Byte offset within the DTCM of the testbench console. A write of a
  // printable character emits it, of 8'hff ends the test as passed, and of
  // 8'h01 ends it as failed. This is the last word of the DTCM, which
  // hummingbird.ld reserves and keeps the stack below.
  localparam CONSOLE_OFFSET = `E203_DTCM_ADDR_WIDTH'hfffc;

  // Terminate a simulation whose firmware never reports a result, rather than
  // running until the harness kills it
  localparam TIMEOUT_CYCLES = 32'd1_000_000_000;

  //--------------------------------------------------------------------------
  // Clocks and reset
  //--------------------------------------------------------------------------

  initial begin
    clk = 1'b0;
    lfextclk = 1'b0;
    rst_n = 1'b0;
    #120 rst_n = 1'b1;
  end

  always #2 clk = ~clk;

  always #33 lfextclk = ~lfextclk;

  //--------------------------------------------------------------------------
  // Firmware load
  //
  // The ITCM SRAM is 64 bits wide, so the image is read into a byte array and
  // then packed. Every test's image is called 'program.hex' and is in the
  // format 'objcopy -O verilog' produces, rebased to the ITCM origin.
  //--------------------------------------------------------------------------

  integer i;
  integer iterations;

  reg [7:0] itcm_image [0:(`E203_ITCM_RAM_DP*8)-1];

  initial begin
    $readmemh("program.hex", itcm_image);

    if ($value$plusargs("iterations=%d", iterations)) begin
      $display("Iterations: %0d", iterations);
      itcm_image[ITERATIONS_OFFSET + 0] = iterations[ 7: 0];
      itcm_image[ITERATIONS_OFFSET + 1] = iterations[15: 8];
      itcm_image[ITERATIONS_OFFSET + 2] = iterations[23:16];
      itcm_image[ITERATIONS_OFFSET + 3] = iterations[31:24];
    end

    for (i = 0; i < `E203_ITCM_RAM_DP; i = i + 1) begin
      `ITCM.mem_r[i] = {itcm_image[i*8+7], itcm_image[i*8+6],
                        itcm_image[i*8+5], itcm_image[i*8+4],
                        itcm_image[i*8+3], itcm_image[i*8+2],
                        itcm_image[i*8+1], itcm_image[i*8+0]};
    end
  end

  //--------------------------------------------------------------------------
  // Console and end of test
  //--------------------------------------------------------------------------

  wire console_write = `U_CPU.lsu2dtcm_icb_cmd_valid
                     & `U_CPU.lsu2dtcm_icb_cmd_ready
                     & (~`U_CPU.lsu2dtcm_icb_cmd_read)
                     & (`U_CPU.lsu2dtcm_icb_cmd_addr == CONSOLE_OFFSET);

  wire [7:0] console_data = `U_CPU.lsu2dtcm_icb_cmd_wdata[7:0];

  reg [31:0] cycle_count;

  always @(posedge hfclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      cycle_count <= 32'b0;
    end
    else begin
      cycle_count <= cycle_count + 32'b1;
    end
  end

  always @(posedge hfclk) begin
    if (console_write) begin
      if ((console_data > 8'h05) && (console_data < 8'h7f)) begin
        $write("%c", console_data);
      end
      else if (console_data == 8'hff) begin
        $display("\nFinished : cycles = %0d", cycle_count);
        $display("TEST_PASSED");
        $finish;
      end
      else if (console_data == 8'h01) begin
        $display("TEST_FAILED");
        $finish;
      end
    end
    if (cycle_count == TIMEOUT_CYCLES) begin
      $display("Time Out !!!");
      $finish;
    end
  end

  //--------------------------------------------------------------------------
  // Device under test
  //--------------------------------------------------------------------------

  wire jtag_TDI = 1'b0;
  wire jtag_TDO;
  wire jtag_TCK = 1'b0;
  wire jtag_TMS = 1'b0;
  wire jtag_TRST = 1'b0;

  wire jtag_DRV_TDO = 1'b0;

e203_soc_top u_e203_soc_top(

   .hfextclk(hfclk),
   .hfxoscen(),

   .lfextclk(lfextclk),
   .lfxoscen(),

   .io_pads_jtag_TCK_i_ival (jtag_TCK),
   .io_pads_jtag_TMS_i_ival (jtag_TMS),
   .io_pads_jtag_TDI_i_ival (jtag_TDI),
   .io_pads_jtag_TDO_o_oval (jtag_TDO),
   .io_pads_jtag_TDO_o_oe (),

   .io_pads_gpioA_i_ival(32'b0),
   .io_pads_gpioA_o_oval(),
   .io_pads_gpioA_o_oe  (),

   .io_pads_gpioB_i_ival(32'b0),
   .io_pads_gpioB_o_oval(),
   .io_pads_gpioB_o_oe  (),

   .io_pads_qspi0_sck_o_oval (),
   .io_pads_qspi0_cs_0_o_oval(),
   .io_pads_qspi0_dq_0_i_ival(1'b1),
   .io_pads_qspi0_dq_0_o_oval(),
   .io_pads_qspi0_dq_0_o_oe  (),
   .io_pads_qspi0_dq_1_i_ival(1'b1),
   .io_pads_qspi0_dq_1_o_oval(),
   .io_pads_qspi0_dq_1_o_oe  (),
   .io_pads_qspi0_dq_2_i_ival(1'b1),
   .io_pads_qspi0_dq_2_o_oval(),
   .io_pads_qspi0_dq_2_o_oe  (),
   .io_pads_qspi0_dq_3_i_ival(1'b1),
   .io_pads_qspi0_dq_3_o_oval(),
   .io_pads_qspi0_dq_3_o_oe  (),

   .io_pads_aon_erst_n_i_ival (rst_n),//This is the real reset, active low
   .io_pads_aon_pmu_dwakeup_n_i_ival (1'b1),

   .io_pads_aon_pmu_vddpaden_o_oval (),
    .io_pads_aon_pmu_padrst_o_oval    (),

    .io_pads_bootrom_n_i_ival       (1'b0),// In Simulation we boot from ROM
    .io_pads_dbgmode0_n_i_ival       (1'b1),
    .io_pads_dbgmode1_n_i_ival       (1'b1),
    .io_pads_dbgmode2_n_i_ival       (1'b1)
);


endmodule
