// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module chip_sim_tb;
  // Clock and Reset
  logic clk_i = 0;
  logic rst_ni = 1;

  logic [31:0]  cio_gpio_p2d, cio_gpio_d2p, cio_gpio_en_d2p;
  logic [31:0]  cio_gpio_pull_en, cio_gpio_pull_select;
  logic cio_uart_rx_p2d, cio_uart_tx_d2p, cio_uart_tx_en_d2p;

  logic cio_spi_device_sck_p2d, cio_spi_device_csb_p2d;
  logic cio_spi_device_sdi_p2d;
  logic cio_spi_device_sdo_d2p, cio_spi_device_sdo_en_d2p;

  logic cio_usbdev_sense_p2d;
  logic cio_usbdev_se0_d2p;
  logic cio_usbdev_dp_pullup_d2p;
  logic cio_usbdev_dn_pullup_d2p;
  logic cio_usbdev_rx_enable_d2p;
  logic cio_usbdev_tx_use_d_se0_d2p;
  logic cio_usbdev_d_p2d, cio_usbdev_d_d2p, cio_usbdev_d_en_d2p;
  logic cio_usbdev_dp_p2d, cio_usbdev_dp_d2p, cio_usbdev_dp_en_d2p;
  logic cio_usbdev_dn_p2d, cio_usbdev_dn_d2p, cio_usbdev_dn_en_d2p;

  chip_earlgrey_verilator u_dut (
    .clk_i,
    .rst_ni,

    // communication with GPIO
    .cio_gpio_p2d_i(cio_gpio_p2d),
    .cio_gpio_d2p_o(cio_gpio_d2p),
    .cio_gpio_en_d2p_o(cio_gpio_en_d2p),
    .cio_gpio_pull_en_o(cio_gpio_pull_en),
    .cio_gpio_pull_select_o(cio_gpio_pull_select),

    // communication with UART
    .cio_uart_rx_p2d_i(cio_uart_rx_p2d),
    .cio_uart_tx_d2p_o(cio_uart_tx_d2p),

    // communication with SPI
    .cio_spi_device_sck_p2d_i(cio_spi_device_sck_p2d),
    .cio_spi_device_csb_p2d_i(cio_spi_device_csb_p2d),
    .cio_spi_device_sdi_p2d_i(cio_spi_device_sdi_p2d),
    .cio_spi_device_sdo_d2p_o(cio_spi_device_sdo_d2p),
    .cio_spi_device_sdo_en_d2p_o(cio_spi_device_sdo_en_d2p),

    // communication with USB
    .cio_usbdev_sense_p2d_i(cio_usbdev_sense_p2d),
    .cio_usbdev_dp_pullup_d2p_o(cio_usbdev_dp_pullup_d2p),
    .cio_usbdev_dn_pullup_d2p_o(cio_usbdev_dn_pullup_d2p),
    .cio_usbdev_dp_p2d_i(cio_usbdev_dp_p2d),
    .cio_usbdev_dp_d2p_o(cio_usbdev_dp_d2p),
    .cio_usbdev_dp_en_d2p_o(cio_usbdev_dp_en_d2p),
    .cio_usbdev_dn_p2d_i(cio_usbdev_dn_p2d),
    .cio_usbdev_dn_d2p_o(cio_usbdev_dn_d2p),
    .cio_usbdev_dn_en_d2p_o(cio_usbdev_dn_en_d2p),
    .cio_usbdev_d_p2d_i(cio_usbdev_d_p2d),
    .cio_usbdev_d_d2p_o(cio_usbdev_d_d2p),
    .cio_usbdev_d_en_d2p_o(cio_usbdev_d_en_d2p),
    .cio_usbdev_se0_d2p_o(cio_usbdev_se0_d2p),
    .cio_usbdev_rx_enable_d2p_o(cio_usbdev_rx_enable_d2p),
    .cio_usbdev_tx_use_d_se0_d2p_o(cio_usbdev_tx_use_d_se0_d2p)
  );

  assign cio_gpio_p2d = 32'h0;

  // UART DPI
`define UART0_PATH u_dut.top_earlgrey.u_uart0.uart_core.uart_tx
  always @(posedge `UART0_PATH.clk_i) begin
    if (`UART0_PATH.rst_ni) begin
      if (`UART0_PATH.wr) begin
        $write("%c", `UART0_PATH.wr_data);
      end
    end
  end

  // SPI DPI
  assign cio_spi_device_sck_p2d = 1'b0;
  assign cio_spi_device_csb_p2d = 1'b0;
  assign cio_spi_device_sdi_p2d = 1'b0;

  // USB DPI
  assign cio_usbdev_dp_p2d = 1'b0;
  assign cio_usbdev_dn_p2d = 1'b0;
  assign cio_usbdev_d_p2d = 1'b0;
  assign cio_usbdev_sense_p2d = 1'b0;

  `define RV_CORE_IBEX      u_dut.top_earlgrey.u_rv_core_ibex
  `define SIM_SRAM_IF       u_sim_sram.u_sim_sram_if

  // Detect SW test termination.
  sim_sram u_sim_sram (
    .clk_i    (`RV_CORE_IBEX.clk_i),
    .rst_ni   (`RV_CORE_IBEX.rst_ni),
    .tl_in_i  (tlul_pkg::tl_h2d_t'(`RV_CORE_IBEX.u_tlul_req_buf.out_o)),
    .tl_in_o  (),
    .tl_out_o (),
    .tl_out_i ()

  );

  // Connect the sim SRAM directly inside rv_core_ibex.
  assign `RV_CORE_IBEX.tl_win_d2h = u_sim_sram.tl_in_o;

  // Instantiate the SW test status interface & connect signals from sim_sram_if instance
  // instantiated inside sim_sram. Bind would have worked nicely here, but Verilator segfaults
  // when trace is enabled (#3951).
  sw_test_status_if u_sw_test_status_if (
    .clk_i    (`SIM_SRAM_IF.clk_i),
    .rst_ni   (`SIM_SRAM_IF.rst_ni),
    .fetch_en (1'b0),
    .wr_valid (`SIM_SRAM_IF.wr_valid),
    .addr     (`SIM_SRAM_IF.tl_h2d.a_address),
    .data     (`SIM_SRAM_IF.tl_h2d.a_data[15:0])
  );

  // Set the start address of the simulation SRAM.
  // Use offset 0 within the sim SRAM for SW test status indication.
  initial begin
    `SIM_SRAM_IF.start_addr = `VERILATOR_TEST_STATUS_ADDR;
    u_sw_test_status_if.sw_test_status_addr = `SIM_SRAM_IF.start_addr;
  end

  always @(posedge clk_i) begin
    if (u_sw_test_status_if.sw_test_done_q) begin
      $display("%0t: Verilator sim termination requested", $time);
      $display("Your simulation wrote to 0x%h", u_sw_test_status_if.sw_test_status_addr);
      dv_test_status_pkg::dv_test_status(u_sw_test_status_if.sw_test_passed);
      $finish;
    end
  end

  `undef RV_CORE_IBEX
  `undef SIM_SRAM_IF

  // The workload images contain only flash data. Initialize the information
  // pages read during boot explicitly, matching the zero contents used by
  // these benchmarks under Verilator's default initialization policy.
  `define FLASH_INFO_MEM(bank, info_type) \
    u_dut.top_earlgrey.u_flash_ctrl.u_eflash.u_flash.gen_generic.u_impl_generic \
      .gen_prim_flash_banks[bank].u_prim_flash_bank.gen_info_types[info_type] \
      .u_info_mem.gen_generic.u_impl_generic.mem
  for (genvar bank = 0; bank < flash_ctrl_pkg::NumBanks; bank++) begin : gen_flash_info_init
    for (genvar info_type = 0; info_type < flash_ctrl_pkg::InfoTypes; info_type++) begin : gen_type
      initial begin
        for (int word_idx = 0; word_idx < $size(`FLASH_INFO_MEM(bank, info_type)); word_idx++) begin
          `FLASH_INFO_MEM(bank, info_type)[word_idx] = '0;
        end
      end
    end
  end
  `undef FLASH_INFO_MEM

  initial begin
    $readmemh(
      "rom.vmem",
      u_dut.top_earlgrey.u_rom_ctrl.gen_rom_scramble_enabled.u_rom.u_rom
        .u_prim_rom.gen_generic.u_impl_generic.mem
    );
    $readmemh(
      "otp.vmem",
      u_dut.top_earlgrey.u_otp_ctrl.u_otp.gen_generic.u_impl_generic
        .u_prim_ram_1p_adv.gen_ram_inst[0].u_mem.gen_generic.u_impl_generic.mem
    );
    $readmemh(
      "flash0.vmem",
      u_dut.top_earlgrey.u_flash_ctrl.u_eflash.u_flash.gen_generic.u_impl_generic
        .gen_prim_flash_banks[0].u_prim_flash_bank.u_mem.gen_generic.u_impl_generic.mem
    );

    begin
      int unsigned iterations;
      if ($value$plusargs("iterations=%d", iterations)) begin
        $display("Iterations: %0d", iterations);
        u_dut.top_earlgrey.u_flash_ctrl.u_eflash.u_flash.gen_generic.u_impl_generic
          .gen_prim_flash_banks[0].u_prim_flash_bank.u_mem.gen_generic.u_impl_generic.mem[16'hf1ff][31:0] = iterations;
      end
    end

    #10000;
    rst_ni = 0;
    #100;
    rst_ni = 1;
  end

  always #5 clk_i = ~clk_i;

`include "__rtlmeter_top_include.vh"

endmodule // chip_sim_tb
