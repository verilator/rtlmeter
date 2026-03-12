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

module __rtlmeter_utils;

  longint unsigned max_cycles = '1;

  initial begin
    if ($test$plusargs("trace")) begin
`ifdef __RTLMETER_TRACE_VCD
      $display("RTLMeter: enabling VCD waveform tracing");
      $dumpfile("trace.vcd");
      $dumpvars;
`elsif __RTLMETER_TRACE_FST
      $display("RTLMeter: enabling FST waveform tracing");
      $dumpfile("trace.fst");
      $dumpvars;
`else
      $display("RTLMeter: ERROR: this simulation was not compiled with tracing enabled");
      $finish;
      $stop;
`endif
    end
    if ($value$plusargs("max_cycles=%d", max_cycles)) begin
      $display("RTLMeter: Running only %0d initial cycles", max_cycles);
    end
  end

  longint unsigned cycles = 0;
  always @(posedge $root.`__RTLMETER_MAIN_CLOCK) ++cycles;
  always @(negedge $root.`__RTLMETER_MAIN_CLOCK) begin
    if (cycles >= max_cycles) begin
      $display("RTLMeter: +max_cycles reached, exiting");
      $finish;
    end
  end

  final begin
    integer fd;
    fd = $fopen("_rtlmeter_cycles.txt");
    $fwrite(fd, "%0d", cycles);
    $fclose(fd);
  end

endmodule
