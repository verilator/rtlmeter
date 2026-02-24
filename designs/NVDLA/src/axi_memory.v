// Copyright 2025 RTLMeter contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

module axi_memory #(
  parameter logic [63:0] BASE_ADDR,
  parameter logic [63:0] SIZE
) (
  input  logic         clk,
  input  logic         reset,

  input  logic [63:0]  araddr,
  input  logic [7:0]   arid,
  input  logic [3:0]   arlen,
  input  logic         arvalid,
  output logic         arready,

  output logic [511:0] rdata,
  output logic [7:0]   rid,
  output logic         rlast,
  output logic         rvalid,
  input  logic         rready,

  input  logic [63:0]  awaddr,
  input  logic [7:0]   awid,
  input  logic [3:0]   awlen,
  input  logic         awvalid,
  output logic         awready,

  input  logic [511:0] wdata,
  input  logic [63:0]  wstrb,
  input  logic         wlast,
  input  logic         wvalid,
  output logic         wready,

  output logic [7:0]   bid,
  output logic         bvalid,
  input  logic         bready
);

  localparam logic [63:0] LAST_ADDR = BASE_ADDR + SIZE - 64'd1;


  logic [31:0] memory [SIZE];

  logic [63:0] cycle = 64'd0;

  logic [63:0] r_latency = 64'd90;
  logic [63:0] w_latency = 64'd30;

  initial begin
    $value$plusargs("r_latency=%d", r_latency);
    $value$plusargs("w_latency=%d", w_latency);
    //$display("%m r_latency: %0d", r_latency);
    //$display("%m w_latency: %0d", w_latency);
  end

  typedef struct packed {
    logic [7:0]  id;
    logic [63:0] addr;
  } wentry_t;

  typedef struct packed {
    logic [7:0]  id;
    logic [63:0] cycle;
  } bentry_t;

  typedef struct packed {
    logic         last;
    logic [7:0]   id;
    logic [511:0] data;
    logic [63:0]  cycle;
  } rentry_t;

  wentry_t wqueue [$];
  bentry_t bqueue [$];
  rentry_t rqueue [$];
  int wqueue_size = 0;
  int bqueue_size = 0;
  int rqueue_size = 0;

  logic wempty = 1'b1;

  assign arready = 1'b1;
  assign awready = 1'b1;
  assign wready = ~wempty | awvalid;

  always @(posedge clk) begin
    if (!reset) begin
      wempty <= 1'b1;
      cycle <= 64'd0;
      if (wqueue.size() != 0) $error("wqueue not empty at reset");
      if (bqueue.size() != 0) $error("bqueue not empty at reset");
      if (rqueue.size() != 0) $error("rqueue not empty at reset");
    end else begin
      // Reads
      if (arvalid & arready) begin
        rentry_t rentry;
        rentry.id = arid;
        rentry.cycle = cycle + r_latency;
        for (int unsigned beat = 0; beat <= arlen; ++beat) begin : read_beat
          logic [63:0] raddr;
          raddr = (araddr & ~64'd63) + beat*64'd64;
          if (raddr[5:0] != 6'd0) $error("Read address unaligned: %016x", raddr);
          if (raddr < BASE_ADDR || LAST_ADDR < raddr) $error ("Read address out of range: %016x", raddr);
          rentry.last = beat == 32'(arlen);
          for (int unsigned word = 0; word < 16; ++word) begin : read_word
            rentry.data[32*word +: 32] = memory[((raddr - BASE_ADDR) >> 2) + 64'(word)];
          end
          rqueue.push_back(rentry);
        end
      end

      if (rvalid & rready) begin
        rqueue.pop_front();
        rvalid <= 1'b0;
      end

      if (rqueue.size() != 0 && cycle > rqueue[0].cycle) begin
        rvalid  <= 1'b1;
        rlast   <= rqueue[0].last;
        rid     <= rqueue[0].id;
        rdata   <= rqueue[0].data;
      end

      // Writes
      if (awvalid & awready) begin
        wentry_t wentry;
        wentry.id = awid;
        for (int unsigned beat = 0; beat <= awlen; ++beat) begin : write_beat
          logic [63:0] waddr;
          waddr = (awaddr & ~64'd63) + beat*64'd64;
          if (waddr[5:0] != 6'd0) $error("Write address unaligned: %016x", waddr);
          if (waddr < BASE_ADDR || LAST_ADDR < waddr) $error ("Write address out of range: %016x", waddr);
          wentry.addr = waddr - BASE_ADDR;
          wqueue.push_back(wentry);
        end
      end

      if (wvalid & wready) begin
        wentry_t wentry;
        wentry = wqueue.pop_front();
        for (int unsigned word = 0; word < 16; ++word) begin : write_word
          for (int unsigned i = 0; i < 4; ++i) begin : write_byte
            if (wstrb[4*word + i]) begin
              memory[(wentry.addr >> 2) + 64'(word)][8*i +: 8] = wdata[32*word + 8*i +: 8];
            end
          end
        end
        if (wlast) begin
          bentry_t bentry;
          bentry.id = wentry.id;
          bentry.cycle = cycle + w_latency;
          bqueue.push_back(bentry);
        end
      end

      wempty <= wqueue.size() == 0;

      if (bvalid & bready) begin
        bqueue.pop_front();
        bvalid <= 1'b0;
      end

      if (bqueue.size() != 0 && cycle > bqueue[0].cycle) begin
        bvalid <= 1'b1;
        bid    <= bqueue[0].id;
      end
    end

    cycle <= cycle + 64'd1;
    wqueue_size <= wqueue.size();
    bqueue_size <= bqueue.size();
    rqueue_size <= rqueue.size();
  end

endmodule

