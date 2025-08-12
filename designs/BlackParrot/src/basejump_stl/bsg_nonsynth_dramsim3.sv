/**
 *  bsg_nonsynth_dramsim3.sv
 *
 */

`include "bsg_defines.sv"

module bsg_nonsynth_dramsim3
  #(parameter `BSG_INV_PARAM(channel_addr_width_p)
    , parameter `BSG_INV_PARAM(data_width_p)
    , parameter `BSG_INV_PARAM(num_channels_p)
    , parameter `BSG_INV_PARAM(num_columns_p)
    , parameter `BSG_INV_PARAM(num_rows_p)
    , parameter `BSG_INV_PARAM(num_ba_p)
    , parameter `BSG_INV_PARAM(num_bg_p)
    , parameter `BSG_INV_PARAM(num_ranks_p)
    , parameter `BSG_INV_PARAM(address_mapping_p)
    , parameter size_in_bits_p=0
    , parameter masked_p=0
    , parameter debug_p=0
    , parameter init_mem_p=0 // zero out values in memory at the beginning
    , parameter `BSG_INV_PARAM(string config_p)
    , parameter string trace_file_p="bsg_nonsynth_dramsim3_trace.txt"
    , parameter base_id_p=0 // use this for multiple instances of this module
    , parameter mem_addr_width_lp=$clog2(num_channels_p)+channel_addr_width_p
    , parameter data_mask_width_lp=(data_width_p>>3)
    , parameter byte_offset_width_lp=`BSG_SAFE_CLOG2(data_width_p>>3)
    , parameter tag_width_p=32
  )
  (
    input clk_i
    , input reset_i

    , input [num_channels_p-1:0] v_i
    , input [num_channels_p-1:0] write_not_read_i
    , input [num_channels_p-1:0][channel_addr_width_p-1:0] ch_addr_i
    , output logic [num_channels_p-1:0] yumi_o

    , input [num_channels_p-1:0] data_v_i
    , input [num_channels_p-1:0][data_width_p-1:0] data_i
    , input [num_channels_p-1:0][data_mask_width_lp-1:0] mask_i

    //stats info
    // print_stat clk can be asynchronous to the dram clk.
    , input print_stat_clk_i
    , input print_stat_reset_i
    , input print_stat_v_i
    , input [tag_width_p-1:0] print_stat_tag_i

    , output logic [num_channels_p-1:0] data_yumi_o 

    , output logic [num_channels_p-1:0] data_v_o
    , output logic [num_channels_p-1:0][data_width_p-1:0] data_o
    , output logic [num_channels_p-1:0][channel_addr_width_p-1:0] read_done_ch_addr_o

    // this is for debugging/measuring performance.
    // its usage is optional.
    , output logic [num_channels_p-1:0] write_done_o
    , output logic [num_channels_p-1:0][channel_addr_width_p-1:0] write_done_ch_addr_o
  );

  // memory addr
  logic [num_channels_p-1:0][mem_addr_width_lp-1:0] mem_addr;

  // request tracking registers
  logic [num_channels_p-1:0] read_req_r, read_req_n;
  logic [num_channels_p-1:0] write_req_r, write_req_n;
  logic [num_channels_p-1:0][mem_addr_width_lp-1:0] read_addr_r, read_addr_n;
  logic [num_channels_p-1:0][mem_addr_width_lp-1:0] write_addr_r, write_addr_n;

  for (genvar i = 0; i < num_channels_p; i++) begin
    bsg_nonsynth_dramsim3_map
      #(.channel_addr_width_p(channel_addr_width_p)
        ,.data_width_p(data_width_p)
        ,.num_channels_p(num_channels_p)
        ,.num_columns_p(num_columns_p)
        ,.num_rows_p(num_rows_p)
        ,.num_ba_p(num_ba_p)
        ,.num_bg_p(num_bg_p)
        ,.num_ranks_p(num_ranks_p)
        ,.address_mapping_p(address_mapping_p)
        ,.channel_select_p(i)
        ,.debug_p(debug_p))
    map
      (.ch_addr_i(ch_addr_i[i])
       ,.mem_addr_o(mem_addr[i]));
  end


  // request yumi
  logic [num_channels_p-1:0] yumi_lo;
  for (genvar i = 0; i < num_channels_p; i++)
    assign yumi_o[i] = yumi_lo[i] & v_i[i];
    
  // read channel signal
  logic [num_channels_p-1:0] read_done;
  logic [num_channels_p-1:0][mem_addr_width_lp-1:0] read_done_addr;
  logic [num_channels_p-1:0][channel_addr_width_p-1:0] read_done_ch_addr;

  for (genvar i = 0; i < num_channels_p; i++) begin
    bsg_nonsynth_dramsim3_unmap
     #(.channel_addr_width_p(channel_addr_width_p)
       ,.data_width_p(data_width_p)
       ,.num_channels_p(num_channels_p)
       ,.num_columns_p(num_columns_p)
       ,.num_rows_p(num_rows_p)
       ,.num_ba_p(num_ba_p)
       ,.num_bg_p(num_bg_p)
       ,.num_ranks_p(num_ranks_p)
       ,.address_mapping_p(address_mapping_p)
       ,.channel_select_p(i)
       ,.debug_p(debug_p))
    unmap_read_done_addr
      (.mem_addr_i(read_done_addr[i])
       ,.ch_addr_o(read_done_ch_addr[i]));

  end

  // write channel signal
  logic [num_channels_p-1:0][mem_addr_width_lp-1:0] write_done_addr;

  for (genvar i = 0; i < num_channels_p; i++) begin

    bsg_nonsynth_dramsim3_unmap
     #(.channel_addr_width_p(channel_addr_width_p)
       ,.data_width_p(data_width_p)
       ,.num_channels_p(num_channels_p)
       ,.num_columns_p(num_columns_p)
       ,.num_rows_p(num_rows_p)
       ,.num_ba_p(num_ba_p)
       ,.num_bg_p(num_bg_p)
       ,.num_ranks_p(num_ranks_p)
       ,.address_mapping_p(address_mapping_p)
       ,.channel_select_p(i)
       ,.debug_p(debug_p))
    unmap_write_done_addr
      (.mem_addr_i(write_done_addr[i])
       ,.ch_addr_o(write_done_ch_addr_o[i]));

  end


  always_ff @ (posedge clk_i) begin
    if (reset_i) begin
      read_done <= '0;
      read_done_addr <= '0;
      write_done_o <= '0;
      write_done_addr <= '0;
    end
    else begin

      // getting read/write done
      for (integer i = 0; i < num_channels_p; i++) begin
        read_done[i] <= read_req_r[i];
        if (read_req_r[i])
          read_done_addr[i] <= read_addr_r[i];

        write_done_o[i] <= write_req_r[i];
        if (write_req_r[i])
          write_done_addr[i] <= write_addr_r[i];
      end
    end
  end

  always_ff @ (posedge clk_i) begin
    if (reset_i) begin
        write_req_r <= '0;
        read_req_r  <= '0;
        write_addr_r <= '0;
        read_addr_r  <= '0;
    end else begin
        write_req_r <= write_req_n;
        read_req_r  <= read_req_n;
        write_addr_r <= write_addr_n;
        read_addr_r  <= read_addr_n;
    end
  end

  always_comb begin
    write_req_n = '0;
    read_req_n  = '0;
    write_addr_n = '0;
    read_addr_n  = '0;
    for (integer i = 0; i < num_channels_p; i++) begin
        if (v_i[i]) begin
          if (write_not_read_i[i]) begin
            if (data_v_i[i]) begin
              write_req_n[i] = 1'b1;
              write_addr_n[i] = mem_addr[i];
            end
          end
          else begin
            read_req_n[i] = 1'b1;
            read_addr_n[i] = mem_addr[i];
          end
        end
      end
  end
  
  always_ff @ (negedge clk_i) begin
    if (reset_i) begin
      yumi_lo <= '0;
    end
    else begin
      // sending requests
      for (integer i = 0; i < num_channels_p; i++) begin
        if (v_i[i]) begin
          if (write_not_read_i[i]) begin
            if (data_v_i[i])
              yumi_lo[i] <= 1'b1;
            else
              yumi_lo[i] <= 1'b0;
          end
          else begin
            yumi_lo[i] <= 1'b1;
          end
        end
        else begin
          yumi_lo[i] <= 1'b0;
        end
      end
    end
  end

  // channels
  logic [num_channels_p-1:0] read_v_li;
  logic [num_channels_p-1:0][channel_addr_width_p-1:0] read_addr_li;
  logic [num_channels_p-1:0] write_v_li;
  logic [num_channels_p-1:0][data_mask_width_lp-1:0] mask_li;

  for (genvar i = 0; i < num_channels_p; i++) begin: channels
    bsg_nonsynth_mem_1r1w_sync_mask_write_byte_dma
      #(.width_p(data_width_p)
        ,.els_p((size_in_bits_p/num_channels_p)/data_width_p)
        ,.id_p(base_id_p+i)
        ,.init_mem_p(init_mem_p))
    channel
      (.clk_i(clk_i)
      ,.reset_i(reset_i)

      ,.r_v_i(read_v_li[i])
      ,.r_addr_i(read_addr_li[i][channel_addr_width_p-1:byte_offset_width_lp])

      ,.w_v_i(write_v_li[i])
      ,.w_addr_i(ch_addr_i[i][channel_addr_width_p-1:byte_offset_width_lp])
      ,.w_data_i(data_i[i])
      ,.w_mask_i(mask_li[i])

      ,.data_o(data_o[i])
    );

    assign read_v_li[i] = read_done[i];
    assign read_addr_li[i] = read_done_ch_addr[i];

    assign mask_li[i] = masked_p ? mask_i[i] : '1;
  
    assign write_v_li[i] = data_v_i[i] & v_i[i] & write_not_read_i[i] & yumi_o[i];
    assign data_yumi_o[i] = data_v_i[i] & write_not_read_i[i] & yumi_o[i];
  
  end

  // aligning valid and address with the output data
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      data_v_o <= '0;
      read_done_ch_addr_o <= '0;
    end
    else begin
      data_v_o <= read_v_li;
      read_done_ch_addr_o <= read_done_ch_addr;
    end
  end

  // debugging
   integer file;
   initial begin
      if (debug_p) begin
         file = $fopen(trace_file_p, "w");
         $fwrite(file, "request,time,channel,write_not_read,address\n");
      end
   end

  always_ff @ (posedge clk_i) begin
    if (~reset_i & debug_p) begin
      for (integer i = 0; i < num_channels_p; i++) begin
        if (yumi_o[i])
          begin
             $display("req sent:  t=%012t, channel=%0d, write_not_read=%0b, addr=%010x", $time, i, write_not_read_i[i], ch_addr_i[i]);
             $fwrite(file, "send,%t,%0d,%0b,%08h\n", $time, i, write_not_read_i[i], ch_addr_i[i]);
          end
        if (read_done[i])
          begin
             $display("read done: t=%012t, channel=%0d, addr=%010x", $time, i, read_done_ch_addr[i]);
             $fwrite(file, "recv,%t,%0d,,%08h\n", $time, i, read_done_ch_addr[i]);
          end
        if (write_done_o[i])
          begin
             $display("write done: t=%012t, channel=%0d, addr=%010x", $time, i, write_done_ch_addr_o[i]);
          end
      end
    end
  end


endmodule

`BSG_ABSTRACT_MODULE(bsg_nonsynth_dramsim3)
