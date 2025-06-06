/*
Copyright (c) 2015 Princeton University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Princeton University nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//==================================================================================================
//  Filename      : l2_pipe1_dpath.v
//  Created On    : 2014-02-24
//  Revision      :
//  Author        : Yaosheng Fu
//  Company       : Princeton University
//  Email         : yfu@princeton.edu
//
//  Description   : The datapath for pipeline1 in the L2 cache
//
//
//==================================================================================================


`include "l2.tmp.h"
`include "define.tmp.h"


// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml


module l2_pipe1_dpath(

    input wire clk,
    input wire rst_n,
    `ifndef NO_RTL_CSM
    input wire csm_en,
    `endif
    input wire [`L2_SMT_BASE_ADDR_WIDTH-1:0] smt_base_addr,

    //Inputs to Stage 1

`ifdef NO_L2_CAM_MSHR
    //inputs from the mshr
    input wire [`L2_MSHR_ADDR_OUT_WIDTH-1:0] mshr_addr_S1,
    input wire [`MSG_MSHRID_WIDTH-1:0] mshr_mshrid_S1,
    input wire [`L2_WAYS_WIDTH-1:0] mshr_way_S1,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] mshr_src_chipid_S1,
    input wire [`MSG_SRC_X_WIDTH-1:0] mshr_src_x_S1,
    input wire [`MSG_SRC_Y_WIDTH-1:0] mshr_src_y_S1,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0] mshr_src_fbits_S1,
    input wire [`MSG_SDID_WIDTH-1:0] mshr_sdid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] mshr_lsid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S1,
    input wire [`MSG_AMO_MASK_WIDTH-1:0] mshr_amo_mask_S1,
    input wire mshr_recycled_S1,
`else
    //inputs from the mshr
    input wire [`L2_MSHR_ADDR_OUT_WIDTH-1:0] cam_mshr_addr_S1,
    input wire [`MSG_MSHRID_WIDTH-1:0] cam_mshr_mshrid_S1,
    input wire [`L2_WAYS_WIDTH-1:0] cam_mshr_way_S1,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] cam_mshr_src_chipid_S1,
    input wire [`MSG_SRC_X_WIDTH-1:0] cam_mshr_src_x_S1,
    input wire [`MSG_SRC_Y_WIDTH-1:0] cam_mshr_src_y_S1,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0] cam_mshr_src_fbits_S1,
    input wire [`MSG_SDID_WIDTH-1:0] cam_mshr_sdid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] cam_mshr_lsid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] cam_mshr_miss_lsid_S1,
    input wire [`MSG_AMO_MASK_WIDTH-1:0] cam_mshr_amo_mask_S1,
    input wire cam_mshr_recycled_S1,
    //inputs from the mshr
    input wire mshr_pending_S1,
    input wire [`L2_MSHR_ADDR_OUT_WIDTH-1:0] pending_mshr_addr_S1,
    input wire [`MSG_MSHRID_WIDTH-1:0] pending_mshr_mshrid_S1,
    input wire [`L2_WAYS_WIDTH-1:0] pending_mshr_way_S1,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] pending_mshr_src_chipid_S1,
    input wire [`MSG_SRC_X_WIDTH-1:0] pending_mshr_src_x_S1,
    input wire [`MSG_SRC_Y_WIDTH-1:0] pending_mshr_src_y_S1,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0] pending_mshr_src_fbits_S1,
    input wire [`MSG_SDID_WIDTH-1:0] pending_mshr_sdid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] pending_mshr_lsid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] pending_mshr_miss_lsid_S1,
    input wire [`MSG_AMO_MASK_WIDTH-1:0] pending_mshr_amo_mask_S1,
    input wire pending_mshr_recycled_S1,
`endif // L2_CAM_MSHR
    input wire dis_flush_S1,

    //msg info from the input buffer
    input wire [`PHY_ADDR_WIDTH-1:0] msg_addr_S1,
    input wire [`MSG_MSHRID_WIDTH-1:0] msg_mshrid_S1,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] msg_src_chipid_S1,
    input wire [`MSG_SRC_X_WIDTH-1:0] msg_src_x_S1,
    input wire [`MSG_SRC_Y_WIDTH-1:0] msg_src_y_S1,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0] msg_src_fbits_S1,
    input wire [`MSG_SDID_WIDTH-1:0] msg_sdid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] msg_lsid_S1,
    input wire [`MSG_AMO_MASK_WIDTH-1:0] msg_amo_mask_S1,

    input wire [`L2_P1_DATA_BUF_IN_WIDTH-1:0] msg_data_S1,

    //control signals from ctrl
    input wire valid_S1,
    input wire stall_S1,
    input wire msg_from_mshr_S1,


    //Inputs to Stage 2
    //input from the input buffer
    input wire [`L2_P1_DATA_BUF_IN_WIDTH-1:0] msg_data_S2,
   //input from the state array
    input wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_S2,

    //input from the tag array
    input wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_S2,


    //control signals from ctrl
    input wire msg_from_mshr_S2,
    input wire special_addr_type_S2,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type_S2,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2,
    input wire [`CS_OP_WIDTH-1:0] dir_op_S2,
    input wire state_owner_en_S2,
    input wire [`CS_OP_WIDTH-1:0] state_owner_op_S2,
    input wire state_subline_en_S2,
    input wire [`CS_OP_WIDTH-1:0] state_subline_op_S2,
    input wire state_di_en_S2,
    input wire state_vd_en_S2,
    input wire [`L2_VD_BITS-1:0] state_vd_S2,
    input wire state_mesi_en_S2,
    input wire [`L2_MESI_BITS-1:0] state_mesi_S2,
    input wire state_lru_en_S2,
    input wire [`L2_LRU_OP_BITS-1:0] state_lru_op_S2,
    input wire state_rb_en_S2,
    input wire l2_ifill_32B_S2,
    input wire l2_load_noshare_32B_S2,
    input wire l2_load_noshare_64B_S2,
    input wire [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2,
    input wire msg_data_16B_amo_S2,
    input wire valid_S2,
    input wire stall_S2,
    input wire stall_before_S2,
    input wire state_load_sdid_S2,
    input wire data_clk_en_S2,
    input wire stall_real_S2,
    input wire [`L2_AMO_ALU_OP_WIDTH-1:0] amo_alu_op_S2,
    input wire msg_data_ready_S2,

    //Inputs to Stage 3

    //input from the data array
    input wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_S3,
    input wire valid_S3,
    input wire stall_S3,
    input wire stall_before_S3,


    //Inputs to Stage 4
    //control signals from ctrl
    input wire valid_S4,
    input wire stall_S4,
    input wire stall_before_S4,
    input wire cas_cmp_en_S4,
    input wire atomic_read_data_en_S4,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] cas_cmp_data_size_S4,
    input wire [`L2_OWNER_BITS-1:0] dir_sharer_S4,
    input wire [`L2_OWNER_BITS-1:0] dir_sharer_counter_S4,
    input wire [`L2_OWNER_BITS-1:0] mshr_inv_counter_out_S4,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_send_type_S4,
    input wire [`MSG_LENGTH_WIDTH-1:0] msg_send_length_S4,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_send_type_pre_S4,
    input wire state_wr_sel_S4,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type_S4,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S4,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S4,
    input wire [`MSG_L2_MISS_BITS-1:0] l2_miss_S4,
    `ifndef NO_RTL_CSM
    input wire smc_miss_S4,
    `endif
    input wire special_addr_type_S4,
    input wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_sel_S4,
    input wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_S4,
    `ifndef NO_RTL_CSM
    input wire stall_smc_buf_S4,
    `endif
    input wire msg_from_mshr_S4,
    input wire req_recycle_S4,
    input wire inv_fwd_pending_S4,

    `ifndef NO_RTL_CSM
    //input from the broadcast counter
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] broadcast_chipid_out_S4,
    input wire [`MSG_SRC_X_WIDTH-1:0] broadcast_x_out_S4,
    input wire [`MSG_SRC_Y_WIDTH-1:0] broadcast_y_out_S4,
    `endif
    //input from the smc
    `ifndef NO_RTL_CSM
    input wire [`L2_SMC_DATA_OUT_WIDTH-1:0] smc_data_out_S4,
    input wire [`L2_SMC_VALID_WIDTH-1:0] smc_valid_out_S4,
    input wire [`L2_SMC_TAG_WIDTH-1:0] smc_tag_out_S4,
    `endif
    //node id from id register
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] my_nodeid_chipid_S4,
    input wire [`MSG_SRC_X_WIDTH-1:0] my_nodeid_x_S4,
    input wire [`MSG_SRC_Y_WIDTH-1:0] my_nodeid_y_S4,
    input wire [`L2_P1_DATA_BUF_IN_WIDTH-1:0] reg_data_out_S4,


    //Outputs from Stage 1

    output reg [`PHY_ADDR_WIDTH-1:0] addr_S1,
    output reg [`L2_MSHR_ADDR_IN_WIDTH-1:0] mshr_addr_in_S1,
    output reg [`L2_TAG_INDEX_WIDTH-1:0] tag_addr_S1,
    output reg [`L2_TAG_INDEX_WIDTH-1:0] state_rd_addr_S1,
    output reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] reg_data_in_S1,

    output reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_in_S1,
    output reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_mask_in_S1,
    //Outputs from Stage 2


    output reg [`PHY_ADDR_WIDTH-1:0] addr_S2,
    output reg l2_tag_hit_S2,
    output reg l2_evict_S2,
    output reg l2_wb_S2,
    output reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S2,
    output reg [`L2_VD_BITS-1:0] l2_way_state_vd_S2,
    output reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S2,
    output reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S2,
    output reg req_from_owner_S2,
    output reg addr_l2_aligned_S2,
    output reg [`MSG_LSID_WIDTH-1:0] lsid_S2,

    output reg [`L2_DIR_INDEX_WIDTH-1:0] dir_addr_S2,
    output reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_in_S2,
    output reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_mask_in_S2,

    output reg [`L2_DATA_INDEX_WIDTH-1:0] data_addr_S2,
    output reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_in_S2,
    output reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_mask_in_S2,

    `ifndef NO_RTL_CSM
    output reg [`L2_SMC_ADDR_WIDTH-1:0] smc_wr_addr_in_S2,
    output reg [`L2_SMC_DATA_IN_WIDTH-1:0] smc_data_in_S2,
    `endif

    //Outputs from Stage 3
    output reg [`PHY_ADDR_WIDTH-1:0] addr_S3,

    //Outputs from Stage 4
    output reg [`PHY_ADDR_WIDTH-1:0] addr_S4,
    output reg [`L2_DATA_INDEX_WIDTH-1:0] data_addr_S4,

    output reg l2_tag_hit_S4,
    output reg l2_evict_S4,
    output reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S4,
    output reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S4,
    output reg [`L2_VD_BITS-1:0] l2_way_state_vd_S4,
    output reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S4,
    output reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S4,
    output reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S4,
    output reg req_from_owner_S4,
    output reg cas_cmp_S4,
    output reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S4,
    output reg [`MSG_LSID_WIDTH-1:0] lsid_S4,
    output reg corr_error_S4,
    output reg uncorr_error_S4,

    output reg [`PHY_ADDR_WIDTH-1:0] msg_send_addr_S4,
    output reg [`MSG_SRC_CHIPID_WIDTH-1:0] msg_send_dst_chipid_S4,
    output reg [`MSG_SRC_X_WIDTH-1:0] msg_send_dst_x_S4,
    output reg [`MSG_SRC_Y_WIDTH-1:0] msg_send_dst_y_S4,
    output reg [`MSG_SRC_FBITS_WIDTH-1:0] msg_send_dst_fbits_S4,
    output reg [`L2_DATA_DATA_WIDTH-1:0] msg_send_data_S4,

    output reg [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_in_S4,
    output wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_mask_in_S4,


    `ifndef NO_RTL_CSM
    output reg [`L2_SMC_ADDR_WIDTH-1:0] smc_rd_addr_in_buf_S4,
    `endif

    output reg [`L2_STATE_INDEX_WIDTH-1:0] state_wr_addr_S4,
    output reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S4,
    output reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S4

);


localparam y = 1'b1;
localparam n = 1'b0;


//used by stage 1
wire [`L2_DATA_DATA_WIDTH-1:0] data_data_ecc_S4;
//============================
// Stage 1
//============================

reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S1;
reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid_S1;
reg [`MSG_SRC_X_WIDTH-1:0] src_x_S1;
reg [`MSG_SRC_Y_WIDTH-1:0] src_y_S1;
reg [`MSG_SRC_FBITS_WIDTH-1:0] src_fbits_S1;
reg [`MSG_SDID_WIDTH-1:0] sdid_S1;
reg [`MSG_LSID_WIDTH-1:0] lsid_S1;
reg [`MSG_AMO_MASK_WIDTH-1:0] amo_mask_S1;
reg [`PHY_ADDR_WIDTH-1:0] addr_trans_S1;
reg recycled_S1;

always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef NO_L2_CAM_MSHR
        addr_S1 = mshr_addr_S1;
        mshrid_S1 = mshr_mshrid_S1;
        src_chipid_S1 = mshr_src_chipid_S1;
        src_x_S1 = mshr_src_x_S1;
        src_y_S1 = mshr_src_y_S1;
        src_fbits_S1 = mshr_src_fbits_S1;
        sdid_S1 = mshr_sdid_S1;
        lsid_S1 = mshr_lsid_S1;
        amo_mask_S1 = mshr_amo_mask_S1;
        recycled_S1 = mshr_recycled_S1;
`else
        addr_S1 = pending_mshr_addr_S1;
        mshrid_S1 = pending_mshr_mshrid_S1;
        src_chipid_S1 = pending_mshr_src_chipid_S1;
        src_x_S1 = pending_mshr_src_x_S1;
        src_y_S1 = pending_mshr_src_y_S1;
        src_fbits_S1 = pending_mshr_src_fbits_S1;
        sdid_S1 = pending_mshr_sdid_S1;
        lsid_S1 = pending_mshr_lsid_S1;
        amo_mask_S1 = pending_mshr_amo_mask_S1;
        recycled_S1 = pending_mshr_recycled_S1;
`endif // L2_CAM_MSHR
    end
    else
    begin
        addr_S1 = msg_addr_S1;
        mshrid_S1 = msg_mshrid_S1;
        src_chipid_S1 = msg_src_chipid_S1;
        src_x_S1 = msg_src_x_S1;
        src_y_S1 = msg_src_y_S1;
        src_fbits_S1 = msg_src_fbits_S1;
        sdid_S1 = msg_sdid_S1;
        lsid_S1 = msg_lsid_S1;
        amo_mask_S1 = msg_amo_mask_S1;
        recycled_S1 = 1'b0;
    end
end

always @ *
begin
    if (dis_flush_S1)
    begin
        //address reorder for displacement flush
        addr_trans_S1 = {addr_S1[5:0],addr_S1[33:6],6'd0};
    end
    else
    begin
        addr_trans_S1 = addr_S1;
    end
end


always @ *
begin
    if (~msg_from_mshr_S1)
    begin
        mshr_addr_in_S1 = addr_trans_S1[`L2_TAG_INDEX];
    end
    else
    begin
        mshr_addr_in_S1 = {`L2_MSHR_ADDR_IN_WIDTH{1'b0}};
    end
end

always @ *
begin
    tag_addr_S1 = addr_trans_S1[`L2_TAG_INDEX];
end

always @ *
begin
    state_rd_addr_S1 = addr_trans_S1[`L2_TAG_INDEX];
end


//the cache line read by the 1st phase of atomic instructions
reg [`L2_DATA_DATA_WIDTH-1:0] atomic_read_data_S1_f;
reg [`L2_DATA_DATA_WIDTH-1:0] atomic_read_data_S1_next;

always @ *
begin
    if (!rst_n)
    begin
        atomic_read_data_S1_next = 0;
    end
    else if (atomic_read_data_en_S4)
    begin
        atomic_read_data_S1_next = data_data_ecc_S4;
    end
    else
    begin
        atomic_read_data_S1_next = atomic_read_data_S1_f;
    end
end


always @ (posedge clk)
begin
    atomic_read_data_S1_f <= atomic_read_data_S1_next;
end

always @ *
begin
    reg_data_in_S1 = msg_data_S1;
end


always @ *
begin
    tag_data_in_S1 = {`L2_WAYS{msg_data_S1[`L2_TAG_WAY_WIDTH-1:0]}};
end

always @ *
begin
    tag_data_mask_in_S1 = {{(`L2_WAYS-1)*`L2_TAG_WAY_WIDTH{1'b0}},{`L2_TAG_WAY_WIDTH{1'b1}}}
                       << (addr_trans_S1[`L2_ADDR_WAY] * `L2_TAG_WAY_WIDTH);
end


//============================
// Stage 1 -> Stage 2
//============================


reg [`PHY_ADDR_WIDTH-1:0] addr_S2_f;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S2_f;
reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid_S2_f;
reg [`MSG_SRC_X_WIDTH-1:0] src_x_S2_f;
reg [`MSG_SRC_Y_WIDTH-1:0] src_y_S2_f;
reg [`MSG_SRC_FBITS_WIDTH-1:0] src_fbits_S2_f;
reg [`MSG_SDID_WIDTH-1:0] sdid_S2_f;
reg [`MSG_LSID_WIDTH-1:0] lsid_S2_f;
reg [`MSG_AMO_MASK_WIDTH-1:0] amo_mask_S2_f;
reg [`L2_WAYS_WIDTH-1:0] mshr_way_S2_f;
reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S2_f;
reg [`L2_DATA_DATA_WIDTH-1:0] atomic_read_data_S2_f;
reg recycled_S2_f;

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        addr_S2_f <= 0;
        mshrid_S2_f <= 0;
        src_chipid_S2_f <= 0;
        src_x_S2_f <= 0;
        src_y_S2_f <= 0;
        src_fbits_S2_f <= 0;
        sdid_S2_f <= 0;
        lsid_S2_f <= 0;
        amo_mask_S2_f <= 0;
        mshr_way_S2_f <= 0;
        mshr_miss_lsid_S2_f <= 0;
        atomic_read_data_S2_f <= 0;
        recycled_S2_f <= 0;
    end
    else if (!stall_S2)
    begin
        addr_S2_f <= addr_trans_S1;
        mshrid_S2_f <= mshrid_S1;
        src_chipid_S2_f <= src_chipid_S1;
        src_x_S2_f <= src_x_S1;
        src_y_S2_f <= src_y_S1;
        src_fbits_S2_f <= src_fbits_S1;
        sdid_S2_f <= sdid_S1;
        lsid_S2_f <= lsid_S1;
        amo_mask_S2_f <= amo_mask_S1;
`ifdef NO_L2_CAM_MSHR
        mshr_way_S2_f <= mshr_way_S1;
        mshr_miss_lsid_S2_f <= mshr_miss_lsid_S1;
`else
        // trin: ambiguous??
        mshr_way_S2_f <= (mshr_pending_S1 == 1'b1) ? pending_mshr_way_S1 : cam_mshr_way_S1;
        mshr_miss_lsid_S2_f <= (mshr_pending_S1 == 1'b1) ? pending_mshr_miss_lsid_S1 : cam_mshr_miss_lsid_S1;
`endif // L2_CAM_MSHR
        atomic_read_data_S2_f <= atomic_read_data_S1_f;
        recycled_S2_f <= recycled_S1;
    end
end


//============================
// Stage 2
//============================


reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] return_data_S2;
reg [`L2_WAYS_WIDTH-1:0] l2_way_sel_S2;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S2;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S2;


always @ *
begin
    addr_S2 = addr_S2_f;
    lsid_S2 = lsid_S2_f;
end

reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_buf_S2_f;
reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_buf_S2_next;
reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_trans_S2;

always @ *
begin
    if (!rst_n)
    begin
        tag_data_buf_S2_next = 0;
    end
    else if (stall_S2 && !stall_before_S2)
    begin
        tag_data_buf_S2_next = tag_data_S2;
    end
    else
    begin
        tag_data_buf_S2_next = tag_data_buf_S2_f;
    end
end


always @ (posedge clk)
begin
    tag_data_buf_S2_f <= tag_data_buf_S2_next;
end


//choose between the direct output and buffered output of the tag array based on stall situation
always @ *
begin
    if (stall_before_S2)
    begin
        tag_data_trans_S2 = tag_data_buf_S2_f;
    end
    else
    begin
        tag_data_trans_S2 = tag_data_S2;
    end
end

wire [`L2_OWNER_BITS-1:0] flat_id_S2;

xy_to_flat_id flat_id_gen(
    .flat_id    (flat_id_S2),
    .x_coord    (src_x_S2_f),
    .y_coord    (src_y_S2_f)
);


reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_buf_S2_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_buf_S2_next;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_trans_S2;

always @ *
begin
    if (!rst_n)
    begin
        state_data_buf_S2_next = 0;
    end
    else if (stall_S2 && !stall_before_S2)
    begin
        state_data_buf_S2_next = state_data_S2;
    end
    else
    begin
        state_data_buf_S2_next = state_data_buf_S2_f;
    end
end


always @ (posedge clk)
begin
    state_data_buf_S2_f <= state_data_buf_S2_next;
end


//choose between the direct output and buffered output of the state array based on stall situation
always @ *
begin
    if (stall_before_S2)
    begin
        state_data_trans_S2 = state_data_buf_S2_f;
    end
    else
    begin
        state_data_trans_S2 = state_data_S2;
    end
end


wire [`L2_WAYS_WIDTH-1:0] l2_hit_way_sel_S2;
reg [`L2_WAYS_WIDTH-1:0] l2_evict_way_sel_S2;
reg [`L2_RB_BITS-1:0] l2_rb_bits_S2;
reg [`L2_LRU_BITS-1:0] l2_lru_bits_S2;


always @ *
begin
    l2_rb_bits_S2 = state_data_trans_S2[`L2_STATE_RB];
    l2_lru_bits_S2 = state_data_trans_S2[`L2_STATE_LRU];
end


reg [`L2_TAG_WAY_WIDTH - 1:0] tag_data_way_S2 [3:0];


reg [3:0] tag_hit_way_S2;


reg [`L2_STATE_WAY_WIDTH - 1:0] state_way_S2 [3:0];







always @ *
begin
    tag_data_way_S2[0] = tag_data_trans_S2[`L2_TAG_WAY_WIDTH * 1 - 1: `L2_TAG_WAY_WIDTH * 0];
    tag_data_way_S2[1] = tag_data_trans_S2[`L2_TAG_WAY_WIDTH * 2 - 1: `L2_TAG_WAY_WIDTH * 1];
    tag_data_way_S2[2] = tag_data_trans_S2[`L2_TAG_WAY_WIDTH * 3 - 1: `L2_TAG_WAY_WIDTH * 2];
    tag_data_way_S2[3] = tag_data_trans_S2[`L2_TAG_WAY_WIDTH * 4 - 1: `L2_TAG_WAY_WIDTH * 3];

end

always @ *
begin
    state_way_S2[0] = state_data_trans_S2[`L2_STATE_WAY_WIDTH * 1 - 1:
`L2_STATE_WAY_WIDTH * 0];
    state_way_S2[1] = state_data_trans_S2[`L2_STATE_WAY_WIDTH * 2 - 1:
`L2_STATE_WAY_WIDTH * 1];
    state_way_S2[2] = state_data_trans_S2[`L2_STATE_WAY_WIDTH * 3 - 1:
`L2_STATE_WAY_WIDTH * 2];
    state_way_S2[3] = state_data_trans_S2[`L2_STATE_WAY_WIDTH * 4 - 1:
`L2_STATE_WAY_WIDTH * 3];

end

always @ *
begin
    if ((addr_S2_f[`L2_TAG] == tag_data_way_S2[0]) &&
(state_way_S2[0][`L2_STATE_VD] == `L2_VD_CLEAN || state_way_S2[0][`L2_STATE_VD] == `L2_VD_DIRTY ))
    begin
        tag_hit_way_S2[0] = 1'b1;
    end
    else
    begin
        tag_hit_way_S2[0] = 1'b0;
    end
end
always @ *
begin
    if ((addr_S2_f[`L2_TAG] == tag_data_way_S2[1]) &&
(state_way_S2[1][`L2_STATE_VD] == `L2_VD_CLEAN || state_way_S2[1][`L2_STATE_VD] == `L2_VD_DIRTY ))
    begin
        tag_hit_way_S2[1] = 1'b1;
    end
    else
    begin
        tag_hit_way_S2[1] = 1'b0;
    end
end
always @ *
begin
    if ((addr_S2_f[`L2_TAG] == tag_data_way_S2[2]) &&
(state_way_S2[2][`L2_STATE_VD] == `L2_VD_CLEAN || state_way_S2[2][`L2_STATE_VD] == `L2_VD_DIRTY ))
    begin
        tag_hit_way_S2[2] = 1'b1;
    end
    else
    begin
        tag_hit_way_S2[2] = 1'b0;
    end
end
always @ *
begin
    if ((addr_S2_f[`L2_TAG] == tag_data_way_S2[3]) &&
(state_way_S2[3][`L2_STATE_VD] == `L2_VD_CLEAN || state_way_S2[3][`L2_STATE_VD] == `L2_VD_DIRTY ))
    begin
        tag_hit_way_S2[3] = 1'b1;
    end
    else
    begin
        tag_hit_way_S2[3] = 1'b0;
    end
end



wire l2_tag_cmp_hit_S2;


l2_priority_encoder_2 priority_encoder_tag_cmp_2bits( 

    .data_in        (tag_hit_way_S2),
    .data_out       (l2_hit_way_sel_S2),
    .data_out_mask  (),
    .nonzero_out    (l2_tag_cmp_hit_S2)
);



always @ *
begin
    if (special_addr_type_S2 || msg_type_S2 == `MSG_TYPE_L2_LINE_FLUSH_REQ)
    begin
        l2_tag_hit_S2 = 1'b0;
    end
    else
    begin
        l2_tag_hit_S2 = l2_tag_cmp_hit_S2;
    end
end
/*
            l2_tag_hit_S2 = tag_hit_way_S2[0] || tag_hit_way_S2[1] || tag_hit_way_S2[2] || tag_hit_way_S2[3];

    end
end



always @ *
begin
    l2_hit_way_sel_S2 = {`L2_WAYS_WIDTH{1'b0}};
    if (tag_hit_way_S2[0])
    begin
        l2_hit_way_sel_S2 = `L2_WAY_0;
    end
    if (tag_hit_way_S2[1])
    begin
        l2_hit_way_sel_S2 = `L2_WAY_1;
    end
    if (tag_hit_way_S2[2])
    begin
        l2_hit_way_sel_S2 = `L2_WAY_2;
    end
    if (tag_hit_way_S2[3])
    begin
        l2_hit_way_sel_S2 = `L2_WAY_3;
    end

end
*/

//pseudo LRU algorithm
always @ *
begin

     if (!state_way_S2[0][`L2_STATE_VD]) 
        begin
            l2_evict_way_sel_S2 = `L2_WAY_0;
        end
     else if (!state_way_S2[1][`L2_STATE_VD]) 
        begin
            l2_evict_way_sel_S2 = `L2_WAY_1;
        end
     else if (!state_way_S2[2][`L2_STATE_VD]) 
        begin
            l2_evict_way_sel_S2 = `L2_WAY_2;
        end
     else if (!state_way_S2[3][`L2_STATE_VD]) 
        begin
            l2_evict_way_sel_S2 = `L2_WAY_3;
        end

    else
    begin
    case (l2_rb_bits_S2)
    2'd0:
    begin
        if (!l2_lru_bits_S2[0])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_0;
        end
        else if (!l2_lru_bits_S2[1])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_1;
        end
        else if (!l2_lru_bits_S2[2])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_2;
        end
        else
        begin
            l2_evict_way_sel_S2 = `L2_WAY_3;
        end
    end
    2'd1:
    begin
        if (!l2_lru_bits_S2[1])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_1;
        end
        else if (!l2_lru_bits_S2[2])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_2;
        end
        else if (!l2_lru_bits_S2[3])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_3;
        end
        else
        begin
            l2_evict_way_sel_S2 = `L2_WAY_0;
        end
    end
    2'd2:
    begin
        if (!l2_lru_bits_S2[2])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_2;
        end
        else if (!l2_lru_bits_S2[3])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_3;
        end
        else if (!l2_lru_bits_S2[0])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_0;
        end
        else
        begin
            l2_evict_way_sel_S2 = `L2_WAY_1;
        end
    end
    2'd3:
    begin
        if (!l2_lru_bits_S2[3])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_3;
        end
        else if (!l2_lru_bits_S2[0])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_0;
        end
        else if (!l2_lru_bits_S2[1])
        begin
            l2_evict_way_sel_S2 = `L2_WAY_1;
        end
        else
        begin
            l2_evict_way_sel_S2 = `L2_WAY_2;
        end
    end

    default:
    begin
        l2_evict_way_sel_S2 = `L2_WAY_0;
    end
    endcase
    end
end


always @ *
begin
/*
    if (msg_from_mshr_S2)
    begin
        l2_way_sel_S2 = mshr_way_S2_f;
    end
    else
*/
    if (special_addr_type_S2 || msg_type_S2 == `MSG_TYPE_L2_LINE_FLUSH_REQ)
    begin
        l2_way_sel_S2 = addr_S2[`L2_ADDR_WAY];
    end
    else if (l2_tag_hit_S2)
    begin
        l2_way_sel_S2 = l2_hit_way_sel_S2;
    end
    else
    begin
        l2_way_sel_S2 = l2_evict_way_sel_S2;
    end
end

always @ *
begin
    if (special_addr_type_S2
     || msg_type_S2 == `MSG_TYPE_WBGUARD_REQ
     || msg_type_S2 == `MSG_TYPE_NC_STORE_REQ)
    begin
        l2_evict_S2 = 1'b0;
    end
    else if (!l2_tag_hit_S2 && (state_way_S2[l2_way_sel_S2][`L2_STATE_VD] == `L2_VD_CLEAN ||
        state_way_S2[l2_way_sel_S2][`L2_STATE_VD] == `L2_VD_DIRTY))
    begin
        l2_evict_S2 = 1'b1;
    end
    else
    begin
        l2_evict_S2 = 1'b0;
    end
end

always @ *
begin
    if (special_addr_type_S2
     || msg_type_S2 == `MSG_TYPE_WBGUARD_REQ)
    begin
        l2_wb_S2 = 1'b0;
    end
    else if (((!l2_tag_hit_S2 && (msg_type_S2 != `MSG_TYPE_NC_STORE_REQ))
           || (msg_type_S2 == `MSG_TYPE_NC_LOAD_REQ || msg_type_S2 == `MSG_TYPE_L2_DIS_FLUSH_REQ)
           || (l2_tag_hit_S2 && msg_type_S2 == `MSG_TYPE_NC_STORE_REQ))
    && (state_way_S2[l2_way_sel_S2][`L2_STATE_MESI] == `L2_MESI_I)
    && (state_way_S2[l2_way_sel_S2][`L2_STATE_VD] == `L2_VD_DIRTY))
    begin
        l2_wb_S2 = 1'b1;
    end
    else
    begin
        l2_wb_S2 = 1'b0;
    end
end


reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S2;

always @ *
begin
    l2_way_state_mesi_S2 = state_way_S2[l2_way_sel_S2][`L2_STATE_MESI];
    l2_way_state_vd_S2 = state_way_S2[l2_way_sel_S2][`L2_STATE_VD];
    l2_way_state_subline_S2 = state_way_S2[l2_way_sel_S2][`L2_STATE_SUBLINE];
    l2_way_state_cache_type_S2 = state_way_S2[l2_way_sel_S2][`L2_STATE_DI];
    l2_way_state_owner_S2 = state_way_S2[l2_way_sel_S2][`L2_STATE_OWNER];
end



always @ *
begin
    `ifndef NO_RTL_CSM
    if (csm_en)
    begin
        req_from_owner_S2 = (l2_way_state_owner_S2 == lsid_S2_f) && (lsid_S2_f != `L2_PUBLIC_SHARER);
    end
    else
    `endif
    begin
        req_from_owner_S2 = (l2_way_state_owner_S2 == flat_id_S2);
    end
end


always @ *
begin
    dir_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2};
end

always @ *
begin
    if (l2_wb_S2 || l2_load_noshare_64B_S2)
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2, l2_load_data_subline_S2};
    end
    else if (l2_ifill_32B_S2 || l2_load_noshare_32B_S2)
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2,
                        addr_S2_f[`L2_INS_SUBLINE], l2_load_data_subline_S2[0]};
    end
    else
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2, addr_S2_f[`L2_DATA_SUBLINE]};
    end
end

reg [`PHY_ADDR_WIDTH-1:0] evict_addr_S2;

always @ *
begin
    evict_addr_S2 = {tag_data_way_S2[l2_way_sel_S2], addr_S2_f[`L2_TAG_INDEX], {`L2_OFFSET_WIDTH{1'b0}}};
end



always @ *
begin
    addr_l2_aligned_S2 = (addr_S2_f[`L2_TAG_OFFSET] == {`L2_OFFSET_WIDTH{1'b0}});
end



always @ *
begin
    if (special_addr_type_S2)
    begin
        if (addr_S2[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_TAG_ACCESS)
        begin
            return_data_S2 = {{(`L2_P1_DATA_BUF_IN_WIDTH - `L2_TAG_WAY_WIDTH){1'b0}}, tag_data_way_S2[l2_way_sel_S2]};
        end
        else if (addr_S2[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_STATE_ACCESS)
        begin
        // State access is only available when L2_WAYS is less than 8
            if (addr_S2[`L2_ADDR_OP] == {`L2_ADDR_OP_WIDTH{1'b0}})
            begin
                return_data_S2 = {{(`L2_P1_DATA_BUF_IN_WIDTH - `L2_STATE_DATA_WIDTH){1'b0}}, state_data_trans_S2[`L2_STATE_DATA]};
            end
            else
            begin
                return_data_S2 = {{(`L2_P1_DATA_BUF_IN_WIDTH - `L2_RB_BITS - `L2_LRU_BITS){1'b0}}, l2_rb_bits_S2, l2_lru_bits_S2};
            end
        end
        else
        begin
            return_data_S2 = {`L2_P1_DATA_BUF_IN_WIDTH{1'b0}};
        end
    end
    else
    begin
        return_data_S2 = {`L2_P1_DATA_BUF_IN_WIDTH{1'b0}};
    end
end




always @ *
begin
    if (special_addr_type_S2)
    begin
        dir_data_in_S2 = msg_data_S2;
    end
    else
    begin
        //track owner beyond the domain scope
        `ifndef NO_RTL_CSM
        if (csm_en && (dir_op_S2 == `OP_LD))
        begin
            dir_data_in_S2 = {sdid_S2_f, src_chipid_S2_f, src_y_S2_f,src_x_S2_f};
        end
        else
        `endif
        begin
            dir_data_in_S2 = {`L2_DIR_ARRAY_WIDTH{1'b1}};
        end
    end
end

always @ *
begin
    if (special_addr_type_S2)
    begin
        dir_data_mask_in_S2 = {`L2_DIR_ARRAY_WIDTH{1'b1}};
    end
    else
    begin
        `ifndef NO_RTL_CSM
        if (csm_en)
        begin
            if (dir_op_S2 == `OP_LD)
            begin
                dir_data_mask_in_S2 = {`L2_DIR_ARRAY_WIDTH{1'b1}};
            end
            else
            begin
                dir_data_mask_in_S2 = {{(`L2_DIR_ARRAY_WIDTH-1){1'b0}},1'b1} << lsid_S2_f;
            end
        end
        else
        `endif
        begin
            dir_data_mask_in_S2 = {{(`L2_DIR_ARRAY_WIDTH-1){1'b0}},1'b1} << flat_id_S2;
        end
    end
end



reg [`L2_DATA_DATA_WIDTH-1:0] msg_data_mask_in_S2;
wire [`L2_DATA_DATA_WIDTH-1:0] amo_bitmask_S2;
reg [`L2_DATA_DATA_WIDTH-1:0] data_data_merge_S2;
wire [`L2_DATA_ECC_PARITY_WIDTH-1:0] data_data_parity1_S2;
wire [`L2_DATA_ECC_PARITY_WIDTH-1:0] data_data_parity2_S2;
wire [`L2_DATA_DATA_WIDTH-1:0] amo_result_S2;
reg [`L2_DATA_DATA_WIDTH-1:0] amo_msg_data_S2;

reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] amo_msg_data_S2_buf;

always @(posedge clk)
begin
    if (~rst_n) begin
        amo_msg_data_S2_buf <= {`L2_P1_DATA_BUF_IN_WIDTH{1'b0}};
    end
    else if (valid_S2 && !stall_S2 && msg_data_16B_amo_S2)
    begin
        amo_msg_data_S2_buf <= msg_data_S2;
    end
end

always @ *
begin
    if (msg_data_16B_amo_S2)
    begin
        amo_msg_data_S2 = {msg_data_S2, amo_msg_data_S2_buf};
    end
    else
    begin
        amo_msg_data_S2 = {msg_data_S2, msg_data_S2};
    end
end

// transfer the amo_msg_data byte mask into bit mask
genvar i;
generate
for (i=0; i<`MSG_AMO_MASK_WIDTH; i=i+1) begin : amo_bitmask_S2_gen
    assign amo_bitmask_S2[8*i +: 8] = (amo_mask_S2_f[i] == 1'b1) ? 8'b11111111 : 8'b00000000;
end
endgenerate

always @ *
begin
    if (data_size_S2 == `MSG_DATA_SIZE_1B)
    begin
        msg_data_mask_in_S2 = {{8{1'b1}}, {(`L2_DATA_DATA_WIDTH-8){1'b0}}};
        msg_data_mask_in_S2 = msg_data_mask_in_S2 >> (8*addr_S2_f[3:0]);
    end
    else if (data_size_S2 == `MSG_DATA_SIZE_2B)
    begin
        msg_data_mask_in_S2 = {{16{1'b1}}, {(`L2_DATA_DATA_WIDTH-16){1'b0}}};
        msg_data_mask_in_S2 = msg_data_mask_in_S2 >> (16*addr_S2_f[3:1]);
    end
    else if (data_size_S2 == `MSG_DATA_SIZE_4B)
    begin
        msg_data_mask_in_S2 = {{32{1'b1}}, {(`L2_DATA_DATA_WIDTH-32){1'b0}}};
        msg_data_mask_in_S2 = msg_data_mask_in_S2 >> (32*addr_S2_f[3:2]);
    end
    else if (msg_data_16B_amo_S2 & ((msg_type_S2 == `MSG_TYPE_SWAPWB_P1_REQ) | (msg_type_S2 == `MSG_TYPE_SWAPWB_P2_REQ) ))
    begin
        msg_data_mask_in_S2 = amo_bitmask_S2;
    end
    else
    begin
        msg_data_mask_in_S2 = {`L2_DATA_DATA_WIDTH{1'b1}};
    end
    msg_data_mask_in_S2 = {msg_data_mask_in_S2[63:0], msg_data_mask_in_S2[127:64]};
end

l2_amo_alu l2_amo_alu (
    .amo_alu_op     (amo_alu_op_S2),
    .address        (addr_S2_f),
    .data_size      (data_size_S2),
    .memory_operand (atomic_read_data_S2_f),
    .cpu_operand    (amo_msg_data_S2),
    .amo_result     (amo_result_S2)
);

always @ *
begin
    data_data_merge_S2 = (amo_msg_data_S2 & msg_data_mask_in_S2)
                       | (atomic_read_data_S2_f & ~msg_data_mask_in_S2);

    if (amo_alu_op_S2 != `L2_AMO_ALU_NOP)
    begin
        data_data_merge_S2 = amo_result_S2;
    end
end

l2_data_pgen data_pgen1(
    .din            (data_data_merge_S2[`L2_DATA_ECC_DATA_WIDTH-1:0]),
    .parity         (data_data_parity1_S2)
);

l2_data_pgen data_pgen2(
    .din            (data_data_merge_S2[`L2_DATA_DATA_WIDTH-1:`L2_DATA_ECC_DATA_WIDTH]),
    .parity         (data_data_parity2_S2)
);


always @ *
begin
    if (special_addr_type_S2)
    begin
        data_data_in_S2 = {msg_data_S2[`L2_DATA_ECC_PARITY_WIDTH-1:0], msg_data_S2,
                           msg_data_S2[`L2_DATA_ECC_PARITY_WIDTH-1:0], msg_data_S2};
    end
    else
    begin
        data_data_in_S2 = {data_data_parity2_S2, data_data_merge_S2[127:64], data_data_parity1_S2, data_data_merge_S2[63:0]};
    end
end

always @ *
begin
    if (special_addr_type_S2)
    begin
        if (addr_S2_f[`L2_ADDR_OP] == {`L2_ADDR_OP_WIDTH{1'b0}})
        begin
            data_data_mask_in_S2 = {{(`L2_DATA_ARRAY_WIDTH-`L2_DATA_ECC_TOTAL_WIDTH){1'b0}},
                                    {`L2_DATA_ECC_PARITY_WIDTH{1'b0}}, {`L2_DATA_ECC_DATA_WIDTH{1'b1}}};
        end
        else
        begin
            data_data_mask_in_S2 = {{(`L2_DATA_ARRAY_WIDTH-`L2_DATA_ECC_TOTAL_WIDTH){1'b0}},
                                    {`L2_DATA_ECC_PARITY_WIDTH{1'b1}}, {`L2_DATA_ECC_DATA_WIDTH{1'b0}}};
        end
        data_data_mask_in_S2 = data_data_mask_in_S2 << (`L2_DATA_ECC_TOTAL_WIDTH*addr_S2_f[3]);
    end
    else if (data_size_S2 == `MSG_DATA_SIZE_1B || data_size_S2 == `MSG_DATA_SIZE_2B
    ||  data_size_S2 == `MSG_DATA_SIZE_4B || data_size_S2 == `MSG_DATA_SIZE_8B
    )
    begin
        data_data_mask_in_S2 = {{(`L2_DATA_ARRAY_WIDTH-`L2_DATA_ECC_TOTAL_WIDTH){1'b0}},{`L2_DATA_ECC_TOTAL_WIDTH{1'b1}}};
        data_data_mask_in_S2 = data_data_mask_in_S2 << (`L2_DATA_ECC_TOTAL_WIDTH*addr_S2_f[3]);
    end
    else
    begin
        data_data_mask_in_S2 = {`L2_DATA_ARRAY_WIDTH{1'b1}};
    end
end




reg [`L2_OWNER_BITS-1:0] state_owner_S2;
reg [`L2_SUBLINE_BITS-1:0] state_subline_S2;
reg [`L2_RB_BITS-1:0] state_rb_S2;
reg [`L2_LRU_BITS-1:0] state_lru_S2;

always @ *
begin
    state_owner_S2 = l2_way_state_owner_S2;
    if (state_owner_op_S2 == `OP_LD)
    begin
        `ifndef NO_RTL_CSM
        if (csm_en)
        begin
            if (state_load_sdid_S2)
            begin
                state_owner_S2 = sdid_S2_f[`L2_STATE_OWNER];
            end
            else
            begin
                state_owner_S2 = lsid_S2_f;
            end
        end
        else
        `endif
        begin
            state_owner_S2 = flat_id_S2; // {src_y_S2_f[`L2_OWNER_XY], src_x_S2_f[`L2_OWNER_XY]};
        end
    end
    else if (state_owner_op_S2 == `OP_ADD)
    begin
        state_owner_S2 = l2_way_state_owner_S2 + 1;
    end
    else if (state_owner_op_S2 == `OP_SUB)
    begin
        state_owner_S2 = l2_way_state_owner_S2 - 1;
    end
    else if (state_owner_op_S2 == `OP_CLR)
    begin
        state_owner_S2 = 0;
    end
end

reg [`L2_SUBLINE_BITS-1:0] addr_subline_S2;

always @ *
begin
    if (cache_type_S2 == `MSG_CACHE_TYPE_DATA)
    begin
        //addr_subline_S2= {1'b1, {(`L2_SUBLINE_BITS-1){1'b0}}} >> addr_S2_f[`L2_DATA_SUBLINE];
        addr_subline_S2= {{(`L2_SUBLINE_BITS-1){1'b0}},1'b1} << addr_S2_f[`L2_DATA_SUBLINE];
    end
    else
    begin
        addr_subline_S2= {{(`L2_SUBLINE_BITS-2){1'b0}},2'b11} << (2*addr_S2_f[`L2_INS_SUBLINE]);
        //addr_subline_S2= {2'b11, {(`L2_SUBLINE_BITS-2){1'b0}}} >> (2*addr_S2_f[`L2_INS_SUBLINE]);
    end
end


always @ *
begin
    if (state_load_sdid_S2)
    begin
        state_subline_S2 = sdid_S2_f[`L2_STATE_SUBLINE];
    end
    else if (state_subline_op_S2 == `OP_ADD)
    begin
        state_subline_S2 = l2_way_state_subline_S2 | addr_subline_S2;
    end
    else if (state_subline_op_S2 == `OP_SUB)
    begin
        state_subline_S2 = l2_way_state_subline_S2 & (~addr_subline_S2);
    end
    else if (state_subline_op_S2 == `OP_CLR)
    begin
        state_subline_S2 = {`L2_SUBLINE_BITS{1'b0}};
    end
    else
    begin
        state_subline_S2 = {`L2_SUBLINE_BITS{1'bx}};
    end
end

always @ *
begin
    state_rb_S2 = l2_rb_bits_S2 + 1;
end


always @ *
begin
    if (state_lru_en_S2)
    begin
        if (state_lru_op_S2 == `L2_LRU_CLR)
        begin
            state_lru_S2 = l2_lru_bits_S2 & (~({{(`L2_LRU_BITS-1){1'b0}},1'b1} << l2_way_sel_S2));
        end
        else
        begin
            state_lru_S2 = l2_lru_bits_S2 | ({{(`L2_LRU_BITS-1){1'b0}},1'b1} << l2_way_sel_S2);
            //clear all lru bits if they are all set
            if (state_lru_S2 == {`L2_LRU_BITS{1'b1}})
            begin
                state_lru_S2 = {`L2_LRU_BITS{1'b0}};
            end
        end
    end
    else
    begin
        state_lru_S2 = l2_lru_bits_S2;
    end
end


always @ *
begin
    if (special_addr_type_S2)
    begin
        state_data_in_S2 = {msg_data_S2[`L2_RB_BITS+`L2_LRU_BITS-1:0], msg_data_S2[`L2_STATE_DATA_WIDTH-1:0]};
    end
    else
    begin
        state_data_in_S2 = {state_rb_S2, state_lru_S2,
        {`L2_WAYS{state_mesi_S2, state_vd_S2, cache_type_S2, state_subline_S2, state_owner_S2}}};
    end
end

reg [`L2_STATE_DATA_WIDTH-1:0] state_way_data_mask_in_S2;



always @ *
begin
    state_way_data_mask_in_S2 = {{(`L2_WAYS-1)*`L2_STATE_WAY_WIDTH{1'b0}},
                                {{`L2_MESI_BITS{state_mesi_en_S2}},
                                 {`L2_VD_BITS{state_vd_en_S2}},
                                 {`L2_DI_BIT{state_di_en_S2}},
                                 {`L2_SUBLINE_BITS{state_subline_en_S2}},
                                 {`L2_OWNER_BITS{state_owner_en_S2}}}}
    << (l2_way_sel_S2 * `L2_STATE_WAY_WIDTH);
end


always @ *
begin
    if (special_addr_type_S2)
    begin
        if (addr_S2_f[`L2_ADDR_OP] == {`L2_ADDR_OP_WIDTH{1'b0}})
        begin
            state_data_mask_in_S2 = {{(`L2_RB_BITS+`L2_LRU_BITS){1'b0}}, {`L2_STATE_DATA_WIDTH{1'b1}}};
        end
        else
        begin
            state_data_mask_in_S2 = {{(`L2_RB_BITS+`L2_LRU_BITS){1'b1}}, {`L2_STATE_DATA_WIDTH{1'b0}}};
        end
    end
    else
    begin
        state_data_mask_in_S2 = {{`L2_RB_BITS{state_rb_en_S2}},
                                {`L2_LRU_BITS{state_lru_en_S2}},
                                state_way_data_mask_in_S2};
    end
end


reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] msg_data_S2_next;

always @ *
begin
    if (special_addr_type_S2)
    begin
        msg_data_S2_next = return_data_S2;
    end
    else
    begin
        msg_data_S2_next = msg_data_S2;
    end
end

`ifndef NO_RTL_CSM
always @ *
begin
    smc_wr_addr_in_S2 = addr_S2[`L2_SMC_ADDR_WIDTH+3:4];
end

always @ *
begin
    smc_data_in_S2 = {msg_data_S2, msg_data_S2};
end
`endif

//============================
// Stage 2 > Stage 3
//============================

reg [`PHY_ADDR_WIDTH-1:0] addr_S3_f;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S3_f;
reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid_S3_f;
reg [`MSG_SRC_X_WIDTH-1:0] src_x_S3_f;
reg [`MSG_SRC_Y_WIDTH-1:0] src_y_S3_f;
reg [`MSG_SRC_FBITS_WIDTH-1:0] src_fbits_S3_f;
reg [`MSG_SDID_WIDTH-1:0] sdid_S3_f;
reg [`MSG_LSID_WIDTH-1:0] lsid_S3_f;
reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S3_f;
reg [`PHY_ADDR_WIDTH-1:0] evict_addr_S3_f;
reg l2_tag_hit_S3_f;
reg l2_evict_S3_f;
reg [`L2_WAYS_WIDTH-1:0] l2_way_sel_S3_f;
reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S3_f;
reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S3_f;
reg [`L2_VD_BITS-1:0] l2_way_state_vd_S3_f;
reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S3_f;
reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S3_f;
reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] msg_data_S3_f;
reg req_from_owner_S3_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S3_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S3_f;
reg [`L2_DATA_INDEX_WIDTH-1:0] data_addr_S3_f;
reg recycled_S3_f;
reg data_clk_en_S3_f; // trin: added for stalled skid buffer

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        addr_S3_f <= 0;
        mshrid_S3_f <= 0;
        src_chipid_S3_f <= 0;
        src_x_S3_f <= 0;
        src_y_S3_f <= 0;
        src_fbits_S3_f <= 0;
        sdid_S3_f <= 0;
        lsid_S3_f <= 0;
        mshr_miss_lsid_S3_f <= 0;
        evict_addr_S3_f <= 0;
        l2_tag_hit_S3_f <= 0;
        l2_evict_S3_f <= 0;
        l2_way_sel_S3_f <= 0;
        l2_way_state_owner_S3_f <= 0;
        l2_way_state_mesi_S3_f <= 0;
        l2_way_state_vd_S3_f <= 0;
        l2_way_state_subline_S3_f <= 0;
        l2_way_state_cache_type_S3_f <= 0;
        msg_data_S3_f <= 0;
        req_from_owner_S3_f <= 0;
        state_data_in_S3_f <= 0;
        state_data_mask_in_S3_f <= 0;
        data_addr_S3_f <= 0;
        recycled_S3_f <= 0;
        data_clk_en_S3_f <= 0;
    end
    else if (!stall_S3)
    begin
        addr_S3_f <= addr_S2;
        mshrid_S3_f <= mshrid_S2_f;
        src_chipid_S3_f <= src_chipid_S2_f;
        src_x_S3_f <= src_x_S2_f;
        src_y_S3_f <= src_y_S2_f;
        src_fbits_S3_f <= src_fbits_S2_f;
        sdid_S3_f <= sdid_S2_f;
        lsid_S3_f <= lsid_S2_f;
        mshr_miss_lsid_S3_f <= mshr_miss_lsid_S2_f;
        evict_addr_S3_f <= evict_addr_S2;
        l2_tag_hit_S3_f <= l2_tag_hit_S2;
        l2_evict_S3_f <= l2_evict_S2;
        l2_way_sel_S3_f <= l2_way_sel_S2;
        l2_way_state_owner_S3_f <= l2_way_state_owner_S2;
        l2_way_state_mesi_S3_f <= l2_way_state_mesi_S2;
        l2_way_state_vd_S3_f <= l2_way_state_vd_S2;
        l2_way_state_subline_S3_f <= l2_way_state_subline_S2;
        l2_way_state_cache_type_S3_f <= l2_way_state_cache_type_S2;
        msg_data_S3_f <= msg_data_S2_next;
        req_from_owner_S3_f <= req_from_owner_S2;
        state_data_in_S3_f <= state_data_in_S2;
        state_data_mask_in_S3_f <= state_data_mask_in_S2;
        data_addr_S3_f <= data_addr_S2;
        recycled_S3_f <= recycled_S2_f;
    end
    data_clk_en_S3_f <= (data_clk_en_S2 && valid_S2 && !stall_real_S2); // note: should not be qualified by stall_S3
end


//============================
// Stage 3
//============================

always @ *
begin
    addr_S3 = addr_S3_f;
end
//============================
// Stage 3 > Stage 4
//============================

reg [`PHY_ADDR_WIDTH-1:0] addr_S4_f;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S4_f;
reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid_S4_f;
reg [`MSG_SRC_X_WIDTH-1:0] src_x_S4_f;
reg [`MSG_SRC_Y_WIDTH-1:0] src_y_S4_f;
reg [`MSG_SRC_FBITS_WIDTH-1:0] src_fbits_S4_f;
reg [`MSG_SDID_WIDTH-1:0] sdid_S4_f;
reg [`MSG_LSID_WIDTH-1:0] lsid_S4_f;
reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S4_f;
reg [`PHY_ADDR_WIDTH-1:0] evict_addr_S4_f;
reg l2_tag_hit_S4_f;
reg l2_evict_S4_f;
reg [`L2_WAYS_WIDTH-1:0] l2_way_sel_S4_f;
reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S4_f;
reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S4_f;
reg [`L2_VD_BITS-1:0] l2_way_state_vd_S4_f;
reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S4_f;
reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S4_f;
reg [`L2_P1_DATA_BUF_IN_WIDTH-1:0] msg_data_S4_f;
reg req_from_owner_S4_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S4_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S4_f;
reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_S4_f;
reg [`L2_DATA_INDEX_WIDTH-1:0] data_addr_S4_f;
reg recycled_S4_f;

reg data_stalled_skid_buffer_en_S3_f;
reg [`L2_DATA_ARRAY_WIDTH-1:0] data_stalled_skid_buffer_S3_f;

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        addr_S4_f <= 0;
        mshrid_S4_f <= 0;
        src_chipid_S4_f <= 0;
        src_x_S4_f <= 0;
        src_y_S4_f <= 0;
        src_fbits_S4_f <= 0;
        sdid_S4_f <= 0;
        lsid_S4_f <= 0;
        mshr_miss_lsid_S4_f <= 0;
        evict_addr_S4_f <= 0;
        l2_tag_hit_S4_f <= 0;
        l2_evict_S4_f <= 0;
        l2_way_sel_S4_f <= 0;
        l2_way_state_owner_S4_f <= 0;
        l2_way_state_mesi_S4_f <= 0;
        l2_way_state_vd_S4_f <= 0;
        l2_way_state_subline_S4_f <= 0;
        l2_way_state_cache_type_S4_f <= 0;
        msg_data_S4_f <= 0;
        req_from_owner_S4_f <= 0;
        state_data_in_S4_f <= 0;
        state_data_mask_in_S4_f <= 0;
        data_data_S4_f <= 0;
        data_addr_S4_f <= 0;
        recycled_S4_f <= 0;
    end
    else if (!stall_S4)
    begin
        addr_S4_f <= addr_S3_f;
        mshrid_S4_f <= mshrid_S3_f;
        src_chipid_S4_f <= src_chipid_S3_f;
        src_x_S4_f <= src_x_S3_f;
        src_y_S4_f <= src_y_S3_f;
        src_fbits_S4_f <= src_fbits_S3_f;
        sdid_S4_f <= sdid_S3_f;
        lsid_S4_f <= lsid_S3_f;
        mshr_miss_lsid_S4_f <= mshr_miss_lsid_S3_f;
        evict_addr_S4_f <= evict_addr_S3_f;
        l2_tag_hit_S4_f <= l2_tag_hit_S3_f;
        l2_evict_S4_f <= l2_evict_S3_f;
        l2_way_sel_S4_f <= l2_way_sel_S3_f;
        l2_way_state_owner_S4_f <= l2_way_state_owner_S3_f;
        l2_way_state_mesi_S4_f <= l2_way_state_mesi_S3_f;
        l2_way_state_vd_S4_f <= l2_way_state_vd_S3_f;
        l2_way_state_subline_S4_f <= l2_way_state_subline_S3_f;
        l2_way_state_cache_type_S4_f <= l2_way_state_cache_type_S3_f;
        msg_data_S4_f <= msg_data_S3_f;
        req_from_owner_S4_f <= req_from_owner_S3_f;
        state_data_in_S4_f <= state_data_in_S3_f;
        state_data_mask_in_S4_f <= state_data_mask_in_S3_f;
        data_data_S4_f <= data_data_S3;
        data_addr_S4_f <= data_addr_S3_f;
        recycled_S4_f <= recycled_S3_f;
        if (data_stalled_skid_buffer_en_S3_f) begin
            data_data_S4_f <= data_stalled_skid_buffer_S3_f;
        end
    end
end

// trin: skid buffer for data read (bug 7/11/18)
wire data_stalled_skid_buffer_en_S3 = data_clk_en_S3_f && valid_S3 && stall_S3;
wire data_stalled_skid_buffer_consume_S3 = valid_S3 && !stall_S3;

always @ (posedge clk) begin
    if (data_stalled_skid_buffer_en_S3) begin
        data_stalled_skid_buffer_S3_f <= data_data_S3;
        data_stalled_skid_buffer_en_S3_f <= 1'b1;
    end
    if (data_stalled_skid_buffer_consume_S3) begin
        data_stalled_skid_buffer_en_S3_f <= 1'b0;
    end
end


`ifndef SYNTHESIS
`ifdef NO_L2_CAM_MSHR
// monitor for checking race condition
always @ (posedge clk) begin
    if (data_stalled_skid_buffer_en_S3_f) begin
        if (data_stalled_skid_buffer_S3_f != data_data_S3) begin
            // check whether the saved data is equaled to the current data
            $display("Error: L2 pipe1 data access race condition!");
            $finish();
        end
    end
end
`endif // L2_CAM_MSHR
`endif


//============================
// Stage 4
//============================

reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_real_S4;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_real_S4;
`ifndef NO_RTL_CSM
reg [`L2_SMC_ADDR_WIDTH-1:0] smc_rd_addr_in_S4;
`endif
reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_S4;
reg [`MSG_SDID_WIDTH-1:0] sdid_S4;

always @ *
begin
    addr_S4 = addr_S4_f;
    mshrid_S4 = mshrid_S4_f;
    l2_evict_S4 = l2_evict_S4_f;
    l2_tag_hit_S4 = l2_tag_hit_S4_f;
    l2_way_state_mesi_S4 = l2_way_state_mesi_S4_f;
    l2_way_state_owner_S4 = l2_way_state_owner_S4_f;
    l2_way_state_vd_S4 = l2_way_state_vd_S4_f;
    l2_way_state_subline_S4 = l2_way_state_subline_S4_f;
    l2_way_state_cache_type_S4 = l2_way_state_cache_type_S4_f;
    mshr_miss_lsid_S4 = mshr_miss_lsid_S4_f;
    lsid_S4 = lsid_S4_f;
    data_data_S4 = data_data_S4_f;
    data_addr_S4 = data_addr_S4_f;
end


always @ *
begin
    `ifndef NO_RTL_CSM
    if (csm_en && (!msg_from_mshr_S4 || recycled_S4_f) && l2_evict_S4)
    begin
        if (l2_way_state_mesi_S4 == `L2_MESI_E)
        begin
            sdid_S4 = dir_data_S4[`L2_DIR_SDID];
        end
        else if (l2_way_state_mesi_S4 == `L2_MESI_S || l2_way_state_mesi_S4 == `L2_MESI_B)
        begin
            sdid_S4 = {l2_way_state_subline_S4, l2_way_state_owner_S4};
        end
        else
        begin
            sdid_S4 = sdid_S4_f;
        end
    end
    else
    `endif
    begin
        sdid_S4 = sdid_S4_f;
    end
end

always @ *
begin
    `ifndef NO_RTL_CSM
    if (csm_en && (msg_type_S4 == `MSG_TYPE_WBGUARD_REQ) && l2_tag_hit_S4
     && (l2_way_state_mesi_S4 == `L2_MESI_E) && l2_way_state_subline_S4[addr_S4[`L2_DATA_SUBLINE]])
    begin
        req_from_owner_S4 = (src_chipid_S4_f == dir_data_S4[`L2_DIR_CORE_CHIPID])
                         && (src_x_S4_f == dir_data_S4[`L2_DIR_CORE_X])
                         && (src_y_S4_f == dir_data_S4[`L2_DIR_CORE_Y]);
    end
    else
    `endif
    begin
        req_from_owner_S4 = req_from_owner_S4_f;
    end
end


`ifndef NO_RTL_CSM
reg [`L2_SMC_ADDR_WIDTH-1:0] smc_rd_addr_in_buf_S4_next;
reg [`L2_SMC_ADDR_WIDTH-1:0] smc_rd_addr_in_buf_S4_f;

always @ *
begin
    if (!rst_n)
    begin
        smc_rd_addr_in_buf_S4_next = 0;
    end
    else if (!stall_smc_buf_S4)
    begin
        smc_rd_addr_in_buf_S4_next = smc_rd_addr_in_S4;
    end
    else
    begin
        smc_rd_addr_in_buf_S4_next = smc_rd_addr_in_buf_S4_f;
    end
end

always @ (posedge clk)
begin
    smc_rd_addr_in_buf_S4_f <= smc_rd_addr_in_buf_S4_next;
end

always @ *
begin
    smc_rd_addr_in_buf_S4 = smc_rd_addr_in_buf_S4_f;
end
/*
reg [`L2_SMC_DATA_OUT_WIDTH-1:0] smc_data_out_buf_S4_next;
reg [`L2_SMC_VALID_WIDTH-1:0] smc_valid_out_buf_S4_next;
reg [`L2_SMC_TAG_WIDTH-1:0] smc_tag_out_buf_S4_next;
reg [`L2_SMC_DATA_OUT_WIDTH-1:0] smc_data_out_buf_S4_f;
reg [`L2_SMC_VALID_WIDTH-1:0] smc_valid_out_buf_S4_f;
reg [`L2_SMC_TAG_WIDTH-1:0] smc_tag_out_buf_S4_f;


always @ *
begin
    if (!rst_n)
    begin
        smc_data_out_buf_S4_next = 0;
        smc_tag_out_buf_S4_next = 0;
        smc_valid_out_buf_S4_next = 0;
    end
    else if (!stall_smc_buf_S4)
    begin
        smc_data_out_buf_S4_next = smc_data_out_S4;
        smc_tag_out_buf_S4_next = smc_tag_out_S4;
        smc_valid_out_buf_S4_next = smc_valid_out_S4;
    end
    else
    begin
        smc_data_out_buf_S4_next = smc_data_out_buf_S4_f;
        smc_tag_out_buf_S4_next = smc_tag_out_buf_S4_f;
        smc_valid_out_buf_S4_next = smc_valid_out_buf_S4_f;
    end
end

always @ (posedge clk)
begin
    smc_data_out_buf_S4_f <= smc_data_out_buf_S4_next;
    smc_tag_out_buf_S4_f <= smc_tag_out_buf_S4_next;
    smc_valid_out_buf_S4_f <= smc_valid_out_buf_S4_next;
end
*/
`endif

always @ *
begin
    state_wr_addr_S4 = addr_S4_f[`L2_TAG_INDEX];
end

always @ *
begin
    //invalidations may be interrupted by smc misses so the number of sharers may
    //not be the same as the total number. In addition, the counter needs to
    //consider the case that inv_acks for early invs come back before later invs
    //are sent out
    if(!msg_from_mshr_S4 || recycled_S4_f)
    begin
        `ifndef NO_RTL_CSM
        if (smc_miss_S4)
        begin
            state_data_in_real_S4 = {{`L2_RB_BITS{1'b0}}, {`L2_LRU_BITS{1'b0}},
            {`L2_WAYS{{`L2_MESI_BITS{1'b0}}, {`L2_VD_BITS{1'b0}}, {`L2_DI_BIT{1'b0}}, {`L2_SUBLINE_BITS{1'b0}},
            (dir_sharer_counter_S4 - mshr_inv_counter_out_S4 - `L2_OWNER_BITS'b1)}}};
        end
        else
        `endif
        begin
            state_data_in_real_S4 = {{`L2_RB_BITS{1'b0}}, {`L2_LRU_BITS{1'b0}},
            {`L2_WAYS{{`L2_MESI_BITS{1'b0}}, {`L2_VD_BITS{1'b0}}, {`L2_DI_BIT{1'b0}}, {`L2_SUBLINE_BITS{1'b0}},
            (dir_sharer_counter_S4 - mshr_inv_counter_out_S4)}}};
        end
    end
    else
    begin
        `ifndef NO_RTL_CSM
        if (smc_miss_S4)
        begin
            state_data_in_real_S4 = {{`L2_RB_BITS{1'b0}}, {`L2_LRU_BITS{1'b0}},
            {`L2_WAYS{{`L2_MESI_BITS{1'b0}}, {`L2_VD_BITS{1'b0}}, {`L2_DI_BIT{1'b0}}, {`L2_SUBLINE_BITS{1'b0}},
            (dir_sharer_counter_S4 + l2_way_state_owner_S4_f - mshr_inv_counter_out_S4 - `L2_OWNER_BITS'b1)}}};
        end
        else
        `endif
        begin
            state_data_in_real_S4 = {{`L2_RB_BITS{1'b0}}, {`L2_LRU_BITS{1'b0}},
            {`L2_WAYS{{`L2_MESI_BITS{1'b0}}, {`L2_VD_BITS{1'b0}}, {`L2_DI_BIT{1'b0}}, {`L2_SUBLINE_BITS{1'b0}},
            (dir_sharer_counter_S4 + l2_way_state_owner_S4_f - mshr_inv_counter_out_S4)}}};
        end
    end
end

reg [`L2_WAYS*`L2_STATE_WAY_WIDTH-1:0] state_way_data_mask_in_S4;



always @ *
begin
    state_way_data_mask_in_S4 = {{(`L2_WAYS-1)*`L2_STATE_WAY_WIDTH{1'b0}},
                                {{`L2_MESI_BITS{1'b0}},
                                 {`L2_VD_BITS{1'b0}},
                                 {`L2_DI_BIT{1'b0}},
                                 {`L2_SUBLINE_BITS{1'b0}},
                                 {`L2_OWNER_BITS{state_wr_sel_S4}}}}
    << (l2_way_sel_S4_f * `L2_STATE_WAY_WIDTH);
end


always @ *
begin
    state_data_mask_in_real_S4 = {{`L2_RB_BITS{1'b0}},
                                 {`L2_LRU_BITS{1'b0}},
                                 state_way_data_mask_in_S4};
end


always @ *
begin
    state_data_mask_in_S4 = state_data_mask_in_S4_f | state_data_mask_in_real_S4;
end

always @ *
begin
    state_data_in_S4 = (state_data_in_S4_f & state_data_mask_in_S4_f) |
                       (state_data_in_real_S4 & state_data_mask_in_real_S4);
end

reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_buf_S4_f;
reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_buf_S4_next;
reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_trans_S4;
reg [`L2_DATA_DATA_WIDTH-1:0] data_data_shift_S4;
wire corr_error1_S4, corr_error2_S4;
wire uncorr_error1_S4, uncorr_error2_S4;

always @ *
begin
    if (!rst_n)
    begin
        data_data_buf_S4_next = 0;
    end
    else if (stall_S4 && !stall_before_S4)
    begin
        data_data_buf_S4_next = data_data_S4;
    end
    else
    begin
        data_data_buf_S4_next = data_data_buf_S4_f;
    end
end



always @ (posedge clk)
begin
    data_data_buf_S4_f <= data_data_buf_S4_next;
end


always @ *
begin
    if (stall_before_S4)
    begin
        data_data_trans_S4 = data_data_buf_S4_f;
    end
    else
    begin
        data_data_trans_S4 = data_data_S4;
    end
end

l2_data_ecc data_ecc1 (
    .din                (data_data_trans_S4[63:0]),
    .parity             (data_data_trans_S4[71:64]),
    .dout               (data_data_ecc_S4[63:0]),
    .corr_error         (corr_error1_S4),
    .uncorr_error       (uncorr_error1_S4)
);

l2_data_ecc data_ecc2 (
    .din                (data_data_trans_S4[135:72]),
    .parity             (data_data_trans_S4[143:136]),
    .dout               (data_data_ecc_S4[127:64]),
    .corr_error         (corr_error2_S4),
    .uncorr_error       (uncorr_error2_S4)
);


always @ *
begin
    corr_error_S4 = corr_error1_S4 | corr_error2_S4;
    uncorr_error_S4 = uncorr_error1_S4 | uncorr_error2_S4;
end


always @ *
begin
    case (cas_cmp_data_size_S4)
    `MSG_DATA_SIZE_4B:
    begin
        data_data_shift_S4 = {data_data_ecc_S4[63:0],data_data_ecc_S4[127:64]} << 32*addr_S4_f[3:2];
    end
    `MSG_DATA_SIZE_8B:
    begin
        data_data_shift_S4 = {data_data_ecc_S4[63:0], data_data_ecc_S4[127:64]} << 64*addr_S4_f[3];
    end
    default:
    begin
        data_data_shift_S4 = {data_data_ecc_S4[63:0], data_data_ecc_S4[127:64]};
    end
    endcase
end



always @ *
begin
    if (cas_cmp_en_S4)
    begin
    case (cas_cmp_data_size_S4)
        `MSG_DATA_SIZE_4B:
        begin
            if (data_data_shift_S4[127:96] == msg_data_S4_f[31:0])
            begin
                cas_cmp_S4 = y;
            end
            else
            begin
                cas_cmp_S4 = n;
            end
        end
        `MSG_DATA_SIZE_8B:
        begin
            if (data_data_shift_S4[127:64] == msg_data_S4_f[63:0])
            begin
                cas_cmp_S4 = y;
            end
            else
            begin
                cas_cmp_S4 = n;
            end
        end
        default:
        begin
            cas_cmp_S4 = n;
        end
    endcase
    end
    else
    begin
        cas_cmp_S4 = n;
    end
end

always @ *
begin
    if (l2_evict_S4
    && (msg_send_type_S4 == `MSG_TYPE_STORE_MEM
    ||  msg_send_type_S4 == `MSG_TYPE_INV_FWD
    ||  msg_send_type_S4 == `MSG_TYPE_STORE_FWD))
    begin
        msg_send_addr_S4 = evict_addr_S4_f;
    end
    else if (msg_send_type_S4 == `MSG_TYPE_STORE_FWD
         ||  msg_send_type_S4 == `MSG_TYPE_INV_FWD
         ||  msg_send_type_S4 == `MSG_TYPE_LOAD_FWD)
    begin
        msg_send_addr_S4 = {addr_S4_f[`L2_TAG], addr_S4_f[`L2_TAG_INDEX], {`L2_OFFSET_WIDTH{1'b0}}};
    end
    else if (msg_send_type_S4 == `MSG_TYPE_NC_LOAD_REQ)
    begin
        `ifndef NO_RTL_CSM
        if (csm_en)
        begin
            if (smc_miss_S4)
            begin
                msg_send_addr_S4 = {smt_base_addr, smc_rd_addr_in_S4[`L2_SMC_ADDR_TAG], 4'd0};
            end
            else
            begin
                msg_send_addr_S4 = addr_S4_f;
            end
        end
        else
        `endif
        begin
            msg_send_addr_S4 = addr_S4_f;
        end
    end
    else
    begin
        msg_send_addr_S4 = addr_S4_f;
    end
end

wire [(`NOC_X_WIDTH-1) : 0] owner_x_S4; 
wire [(`NOC_Y_WIDTH-1) : 0] owner_y_S4; 
wire [(`NOC_X_WIDTH-1) : 0] sharer_x_S4; 
wire [(`NOC_Y_WIDTH-1) : 0] sharer_y_S4; 
flat_id_to_xy owner_xy_gen(
    .flat_id            (l2_way_state_owner_S4_f),
    .x_coord            (owner_x_S4),
    .y_coord            (owner_y_S4)
);
flat_id_to_xy sharer_xy_gen(
    .flat_id            (dir_sharer_S4),
    .x_coord            (sharer_x_S4),
    .y_coord            (sharer_y_S4)
);

always @ *
begin
    case (msg_send_type_S4)
    `MSG_TYPE_LOAD_FWD, `MSG_TYPE_STORE_FWD:
    begin
        `ifndef NO_RTL_CSM
        if (csm_en)
        begin
            msg_send_dst_chipid_S4 = dir_data_S4[`L2_DIR_CORE_CHIPID];
            msg_send_dst_x_S4 = dir_data_S4[`L2_DIR_CORE_X];
            msg_send_dst_y_S4 = dir_data_S4[`L2_DIR_CORE_Y];
        end
        else
        `endif
        begin
`ifdef PITON_ASIC_RTL
            msg_send_dst_chipid_S4 = src_chipid_S4_f;
`else
            msg_send_dst_chipid_S4 = my_nodeid_chipid_S4;
`endif
            msg_send_dst_x_S4 = owner_x_S4;
            msg_send_dst_y_S4 = owner_y_S4;
        end
        msg_send_dst_fbits_S4 = `NOC_FBITS_L1;
    end
    `MSG_TYPE_INV_FWD:
    begin
        `ifndef NO_RTL_CSM
        if (csm_en)
        begin
            if (l2_way_state_mesi_S4_f == `L2_MESI_B)
            begin
                msg_send_dst_chipid_S4 = broadcast_chipid_out_S4;
                msg_send_dst_x_S4 = broadcast_x_out_S4;
                msg_send_dst_y_S4 = broadcast_y_out_S4;
            end
            else
            begin
                msg_send_dst_chipid_S4 = smc_data_out_S4[`L2_SMC_DATA_CHIPID];
                msg_send_dst_x_S4 = smc_data_out_S4[`L2_SMC_DATA_X];
                msg_send_dst_y_S4 = smc_data_out_S4[`L2_SMC_DATA_Y];
            end
        end
        else
        `endif
        begin
            msg_send_dst_chipid_S4 = my_nodeid_chipid_S4;
            msg_send_dst_x_S4 = sharer_x_S4;
            msg_send_dst_y_S4 = sharer_y_S4;
        end
        msg_send_dst_fbits_S4 = `NOC_FBITS_L1;
    end
    `MSG_TYPE_NODATA_ACK, `MSG_TYPE_DATA_ACK:
    begin
        msg_send_dst_chipid_S4 = src_chipid_S4_f;
        msg_send_dst_x_S4 = src_x_S4_f;
        msg_send_dst_y_S4 = src_y_S4_f;
        // Reqs may come from other on-chip devices
        msg_send_dst_fbits_S4 = src_fbits_S4_f;

    end
    `MSG_TYPE_LOAD_MEM, `MSG_TYPE_NC_LOAD_REQ, `MSG_TYPE_NC_STORE_REQ, `MSG_TYPE_STORE_MEM:
    begin
        msg_send_dst_chipid_S4 = {1'b1, my_nodeid_chipid_S4[`NOC_CHIPID_ONCHIP]};
        msg_send_dst_x_S4 = 0;
        msg_send_dst_y_S4 = 0;
        msg_send_dst_fbits_S4 = `NOC_FBITS_MEM;
    end
    `MSG_TYPE_INTERRUPT:
    begin
        msg_send_dst_chipid_S4 = my_nodeid_chipid_S4;
        msg_send_dst_x_S4 = my_nodeid_x_S4;
        msg_send_dst_y_S4 = my_nodeid_y_S4;
        msg_send_dst_fbits_S4 = `NOC_FBITS_L1;
    end
    default:
    begin
        msg_send_dst_chipid_S4 = my_nodeid_chipid_S4;
        msg_send_dst_x_S4 = my_nodeid_x_S4;
        msg_send_dst_y_S4 = my_nodeid_y_S4;
        msg_send_dst_fbits_S4 = `NOC_FBITS_L1;
    end
    endcase
end

always @ *
begin
    if (special_addr_type_S4)
    begin
        if (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_DATA_ACCESS)
        begin
            if (addr_S4[`L2_ADDR_OP] == {`L2_ADDR_OP_WIDTH{1'b0}})
            begin
                if (addr_S4[3] == 0)
                begin
                    msg_send_data_S4 = {2{data_data_trans_S4[63:0]}};
                end
                else
                begin
                    msg_send_data_S4 = {2{data_data_trans_S4[135:72]}};
                end
            end
            else
            begin
                if (addr_S4[3] == 0)
                begin
                    msg_send_data_S4 = {2{56'b0, data_data_trans_S4[71:64]}};
                end
                else
                begin
                    msg_send_data_S4 = {2{56'b0, data_data_trans_S4[143:136]}};
                end
            end
        end
        else if (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_DIR_ACCESS)
        begin
            msg_send_data_S4 = {2{dir_data_sel_S4}}; 
        end
        `ifndef NO_RTL_CSM
        else if (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_SMC_ACCESS)
        begin
            case (addr_S4[`L2_ADDR_OP])
            2'd0:
            begin
                msg_send_data_S4 = {2{{(`NOC_DATA_WIDTH-`L2_SMC_DATA_OUT_WIDTH){1'b0}}, smc_data_out_S4}};
            end
            2'd1:
            begin
                msg_send_data_S4 = {2{{(`NOC_DATA_WIDTH-`L2_SMC_VALID_WIDTH){1'b0}}, smc_valid_out_S4}};
            end
            2'd2:
            begin
                msg_send_data_S4 = {2{{(`NOC_DATA_WIDTH-`L2_SMC_TAG_WIDTH){1'b0}}, smc_tag_out_S4}};
            end
            default:
            begin
                msg_send_data_S4 = {`L2_DATA_DATA_WIDTH{1'b0}};
            end
            endcase
        end
        `endif
        else if (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_CTRL_REG
              || addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_COREID_REG
              || addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_ERROR_STATUS_REG
              || addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_ACCESS_COUNTER
              || addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_MISS_COUNTER)
        begin
            msg_send_data_S4 = {2{reg_data_out_S4}};
        end
        else
        begin
            msg_send_data_S4 = {2{msg_data_S4_f}};
        end
    end
    else if ((msg_type_S4 == `MSG_TYPE_L2_LINE_FLUSH_REQ || msg_type_S4 == `MSG_TYPE_L2_DIS_FLUSH_REQ)
         &&  (msg_send_type_S4 == `MSG_TYPE_DATA_ACK))
    begin
        msg_send_data_S4 = {`L2_DATA_DATA_WIDTH{1'b0}};
    end
    else if (msg_send_type_S4 == `MSG_TYPE_NC_STORE_REQ || (msg_send_type_S4 == `MSG_TYPE_INTERRUPT))
    begin
        msg_send_data_S4 = {2{msg_data_S4_f}};
    end
`ifdef L2_SEND_NC_REQ
    else if (msg_type_S4 == `MSG_TYPE_NC_LOAD_REQ && msg_send_type_S4 == `MSG_TYPE_DATA_ACK && msg_send_length_S4 == 1)
    begin
        msg_send_data_S4 = addr_S4[3] ? {2{data_data_ecc_S4[127:64]}} : {2{data_data_ecc_S4[63:0]}};
    end
`endif
    else
    begin
        msg_send_data_S4 = data_data_ecc_S4;
    end
end


`ifndef NO_RTL_CSM
always @ *
begin
    if (special_addr_type_S4 && (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_SMC_ACCESS))
    begin
        smc_rd_addr_in_S4 = addr_S4[`L2_SMC_ADDR_WIDTH+3:4];
    end
    else if (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD)
    begin
        smc_rd_addr_in_S4 = {sdid_S4, dir_sharer_S4};
    end
    else
    begin
        smc_rd_addr_in_S4 = {sdid_S4, l2_way_state_owner_S4_f};
    end
end
`endif


`ifndef NO_RTL_CSM
always @ *
begin
    mshr_data_in_S4 = {inv_fwd_pending_S4,
                       (req_recycle_S4 && (!msg_from_mshr_S4 || recycled_S4_f)),
                       smc_miss_S4,
                       smc_rd_addr_in_S4[`L2_SMC_ADDR_LSID],
                       lsid_S4_f, 
                       sdid_S4,
                       src_fbits_S4_f,
                       src_y_S4_f,
                       src_x_S4_f,
                       src_chipid_S4_f,
                       l2_miss_S4,
                       msg_type_S4,
                       data_size_S4,
                       cache_type_S4,
                       mshrid_S4_f,
                       l2_way_sel_S4_f,
                       addr_S4_f};
end
`else
always @ *
begin
    mshr_data_in_S4 = {inv_fwd_pending_S4,
                       (req_recycle_S4 && (!msg_from_mshr_S4 || recycled_S4_f)),
                       1'b0,
                       {`MSG_LSID_WIDTH{1'b0}},
                       lsid_S4_f,
                       sdid_S4,
                       src_fbits_S4_f,
                       src_y_S4_f,
                       src_x_S4_f,
                       src_chipid_S4_f,
                       l2_miss_S4,
                       msg_type_S4,
                       data_size_S4,
                       cache_type_S4,
                       mshrid_S4_f,
                       l2_way_sel_S4_f,
                       addr_S4_f};
end

`endif
/*
always @ *
begin
    mshr_data_mask_in_S2 = {`L2_MSHR_ARRAY_WIDTH{1'b1}};
end
*/
assign mshr_data_mask_in_S4 = {`L2_MSHR_ARRAY_WIDTH{1'b1}};



endmodule
