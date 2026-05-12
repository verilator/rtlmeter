`include "VX_define.vh"

import VX_gpu_pkg::*;

module tb;
  logic                             clk = 1'b0;
  logic                             reset = 1'b1;

  logic                             mem_req_valid;
  logic                             mem_req_rw;
  logic [`VX_MEM_BYTEEN_WIDTH-1:0]  mem_req_byteen;
  logic [`VX_MEM_ADDR_WIDTH-1:0]    mem_req_addr;
  logic [`VX_MEM_DATA_WIDTH-1:0]    mem_req_data;
  logic [`VX_MEM_TAG_WIDTH-1:0]     mem_req_tag;
  logic                             mem_req_ready = 1'b0;

  logic                             mem_rsp_valid;
  logic [`VX_MEM_DATA_WIDTH-1:0]    mem_rsp_data;
  logic [`VX_MEM_TAG_WIDTH-1:0]     mem_rsp_tag;
  logic                             mem_rsp_ready;

  logic                             dcr_wr_valid = 1'b0;
  logic [`VX_DCR_ADDR_WIDTH-1:0]    dcr_wr_addr;
  logic [`VX_DCR_DATA_WIDTH-1:0]    dcr_wr_data;

  logic                             busy;

  Vortex dut (
    .clk            /* <- */  (clk           ),
    .reset          /* <- */  (reset         ),
    // Memory request
    .mem_req_valid  /* -> */  (mem_req_valid ),
    .mem_req_rw     /* -> */  (mem_req_rw    ),
    .mem_req_byteen /* -> */  (mem_req_byteen),
    .mem_req_addr   /* -> */  (mem_req_addr  ),
    .mem_req_data   /* -> */  (mem_req_data  ),
    .mem_req_tag    /* -> */  (mem_req_tag   ),
    .mem_req_ready  /* <- */  (mem_req_ready ),
    // Memory response
    .mem_rsp_valid  /* <- */  (mem_rsp_valid ),
    .mem_rsp_data   /* <- */  (mem_rsp_data  ),
    .mem_rsp_tag    /* <- */  (mem_rsp_tag   ),
    .mem_rsp_ready  /* -> */  (mem_rsp_ready ),
    // DCR write request
    .dcr_wr_valid   /* <- */  (dcr_wr_valid  ),
    .dcr_wr_addr    /* <- */  (dcr_wr_addr   ),
    .dcr_wr_data    /* <- */  (dcr_wr_data   ),
    // Status
    .busy           /* -> */  (busy          )
  );

  always #5 clk = ~clk;

  import "DPI-C" function void mem_load(input string fileName);
  import "DPI-C" function bit mem_check(input string fileName, input bit verbose);


  initial begin
    int errors = 0;

    int unsigned iterations = 1;
    if ($value$plusargs("iterations=%d", iterations)) begin
      $display("Iterations: %0d", iterations);
    end

    for (int unsigned i = 0; i < iterations; ++i) begin
      // Assert reset
      reset = 1;
      #100;

      // Load memory
      mem_load("init.bin");
      if (mem_check("post.bin", 1'b0)) begin
        $display("Error: Initial state of memory matches expected state");
        $finish;
        $stop;
      end

      // Apply DCR wrties
      begin
        int fd;
        fd = $fopen("dcrs.bin", "r");
        while (1'b1) begin
          int code;
          int unsigned addr;
          int unsigned data;
          code = $fread(addr, fd);
          if (code == 0) break;
          if (code != 4) begin
            $display("Error: reading DCR address");
            $finish;
            $stop;
          end
          code = $fread(data, fd);
          if (code != 4) begin
            $display("Error: reading DCR data");
            $finish;
            $stop;
          end
          $display("DCR write: *%08x = %08x", addr, data);
          dcr_wr_valid = 1'b1;
          dcr_wr_addr = `VX_DCR_ADDR_WIDTH'(addr);
          dcr_wr_data = `VX_DCR_DATA_WIDTH'(data);
          #10;
          dcr_wr_valid = 1'b0;
        end
        $fclose(fd);
      end

      // Deassert reset
      #10;
      reset = 0;

      // Wait for busy to go low
      while (!busy) #10;

      // Wait for busy to go high
      while (busy) #10;
      #100;
      $display("Done");

      // Check stat of memory
      if (!mem_check("post.bin", 1'b1)) begin
        $display("Error: Final state of memory is incorrect");
        ++errors;
      end
    end

    if (errors == 0) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end
    $finish;
  end

  // Memory response pipe
  localparam int MEM_STAGES = 20;

  for (genvar i = 0; i < MEM_STAGES; ++i) begin : mem_rsp
    logic                             valid_q;
    logic [`VX_MEM_DATA_WIDTH-1:0]    data_q;
    logic [`VX_MEM_TAG_WIDTH-1:0]     tag_q;

    logic                             valid_d;
    logic [`VX_MEM_DATA_WIDTH-1:0]    data_d;
    logic [`VX_MEM_TAG_WIDTH-1:0]     tag_d;

    logic                             ready;
    logic                             move;

    always @(posedge clk) begin
      if (reset) begin
        valid_q <= 1'b0;
        data_q <= `VX_MEM_DATA_WIDTH'(0);
        tag_q <= `VX_MEM_TAG_WIDTH'(0);
      end else if (move) begin
        valid_q <= valid_d;
        data_q <= data_d;
        tag_q <= tag_d;
      end
    end
  end

  // First stage fed from DPI memory model
  import "DPI-C" function void mem_access(
    input  bit                            req_rw,
    input  longint unsigned               req_byteen,
    input  longint unsigned               req_addr,
    input  bit [`VX_MEM_DATA_WIDTH-1:0]   req_data,
    output bit [`VX_MEM_DATA_WIDTH-1:0]   rsp_data,
  );

  assign mem_rsp[0].tag_d = mem_req_tag;

  always @(negedge clk) begin
    mem_req_ready <= 1'b0;
    mem_rsp[0].valid_d <= 1'b0;
    if (mem_req_valid && mem_rsp[0].ready) begin
      mem_req_ready <= 1'b1;
      if (!mem_req_rw) mem_rsp[0].valid_d <= 1'b1;
      mem_access(mem_req_rw, 64'(mem_req_byteen), 64'(mem_req_addr), mem_req_data, mem_rsp[0].data_d);
    end
  end

  // Internal stages chained
  for (genvar i = 1; i < MEM_STAGES; ++i) begin : mem_connect
    assign mem_rsp[i].valid_d = mem_rsp[i-1].valid_q;
    assign mem_rsp[i].data_d = mem_rsp[i-1].data_q;
    assign mem_rsp[i].tag_d = mem_rsp[i-1].tag_q;
    assign mem_rsp[i-1].ready = ~mem_rsp[i-1].valid_q | mem_rsp[i].ready;
    assign mem_rsp[i-1].move = mem_rsp[i-1].valid_q & mem_rsp[i].ready | ~mem_rsp[i-1].valid_q;
  end

  // Last stage drives dut
  assign mem_rsp_valid = mem_rsp[MEM_STAGES-1].valid_q;
  assign mem_rsp_data = mem_rsp[MEM_STAGES-1].data_q;
  assign mem_rsp_tag = mem_rsp[MEM_STAGES-1].tag_q;
  assign mem_rsp[MEM_STAGES-1].ready = ~mem_rsp[MEM_STAGES-1].valid_q | mem_rsp_ready;
  assign mem_rsp[MEM_STAGES-1].move = mem_rsp[MEM_STAGES-1].valid_q & mem_rsp_ready | ~mem_rsp[MEM_STAGES-1].valid_q;

`include "__rtlmeter_top_include.vh"

endmodule
