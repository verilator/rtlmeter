`default_nettype none
module servant_sim
  (input wire	      wb_clk,
   input wire	      wb_rst,
   output wire [31:0] pc_adr,
   output wire	      pc_vld,
   output wire	      q);

   parameter memfile = "";
   parameter memsize = 8192;
   parameter width = 1;
   parameter with_csr = 1;
   parameter compressed = 0;
   parameter align = compressed;

   localparam iterations_addr = memsize/4 - 1;

   integer iterations;

   initial begin
      $readmemh("program.hex", dut.ram.mem);
      if ($value$plusargs("iterations=%d", iterations)) begin
         $display("Iterations: %0d", iterations);
         dut.ram.mem[iterations_addr] = iterations;
      end
   end

   servant
     #(.memfile  (memfile),
       .memsize  (memsize),
       .width    (width),
       .debug    (1'b1),
       .sim      (1),
       .with_csr (with_csr),
       .compress (compressed[0:0]),
       .align    (align[0:0]))
   dut(wb_clk, wb_rst, q);

   assign pc_adr = dut.wb_mem_adr;
   assign pc_vld = dut.wb_mem_ack;

endmodule
