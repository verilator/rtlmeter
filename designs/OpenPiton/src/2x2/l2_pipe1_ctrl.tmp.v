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
//  Filename      : l2_pipe1_ctrl.v
//  Created On    : 2014-02-24
//  Revision      :
//  Author        : Yaosheng Fu
//  Company       : Princeton University
//  Email         : yfu@princeton.edu
//
//  Description   : The control unit for pipeline1 in the L2 cache
//
//
//====================================================================================================

`include "l2.tmp.h"
`include "define.tmp.h"

module l2_pipe1_ctrl(

    input wire clk,
    input wire rst_n,
    `ifndef NO_RTL_CSM
    input wire csm_en,
    `endif
    //Inputs to Stage 1

    input wire pipe2_valid_S1,
    input wire pipe2_valid_S2,
    input wire pipe2_valid_S3,
    input wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S1,
    input wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S2,
    input wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S3,
    input wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S1,
    input wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S2,
    input wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S3,

    //global stall from pipeline2
    input wire global_stall_S1,

    //input msg from the input buffer
    input wire msg_header_valid_S1,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type_S1,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] msg_data_size_S1,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] msg_cache_type_S1,

    //input from the mshr
    input wire mshr_hit_S1,
`ifdef NO_L2_CAM_MSHR
    input wire [`MSG_TYPE_WIDTH-1:0] mshr_msg_type_S1,
    input wire [`MSG_L2_MISS_BITS-1:0] mshr_l2_miss_S1,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] mshr_data_size_S1,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] mshr_cache_type_S1,
`endif // L2_CAM_MSHR
    input wire mshr_pending_S1,
    input wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index_S1,
    input wire [`L2_MSHR_INDEX_WIDTH:0] mshr_empty_slots_S1,
    `ifndef NO_RTL_CSM
`ifdef NO_L2_CAM_MSHR
    input wire mshr_smc_miss_S1,
`endif // L2_CAM_MSHR
    `endif

`ifndef NO_L2_CAM_MSHR
    //input from the mshr
    input wire [`MSG_TYPE_WIDTH-1:0] cam_mshr_msg_type_S1,
    input wire [`MSG_L2_MISS_BITS-1:0] cam_mshr_l2_miss_S1,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] cam_mshr_data_size_S1,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cam_mshr_cache_type_S1,
    `ifndef NO_RTL_CSM
    input wire cam_mshr_smc_miss_S1,
    `endif

    //input from the mshr
    input wire [`MSG_TYPE_WIDTH-1:0] pending_mshr_msg_type_S1,
    input wire [`MSG_L2_MISS_BITS-1:0] pending_mshr_l2_miss_S1,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] pending_mshr_data_size_S1,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] pending_mshr_cache_type_S1,
    `ifndef NO_RTL_CSM
    input wire pending_mshr_smc_miss_S1,
    `endif
`endif // L2_CAM_MSHR

    //data valid signal from the input buffer
    input wire msg_data_valid_S1,

    input wire [`PHY_ADDR_WIDTH-1:0] addr_S1,


    //Inputs to Stage 2

    //global stall from pipeline2
    input wire global_stall_S2,

    //tag and state info from dpath
    input wire l2_tag_hit_S2,
    input wire l2_evict_S2,
    input wire l2_wb_S2,
    input wire [`L2_MESI_BITS-1:0] l2_way_state_mesi_S2,
    input wire [`L2_VD_BITS-1:0] l2_way_state_vd_S2,
    input wire [`L2_DI_BIT-1:0] l2_way_state_cache_type_S2,
    input wire [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S2,
    input wire req_from_owner_S2,
    input wire addr_l2_aligned_S2,
    input wire [`MSG_LSID_WIDTH-1:0] lsid_S2,

    //data valid signal from the input buffer
    input wire msg_data_valid_S2,


    input wire [`PHY_ADDR_WIDTH-1:0] addr_S2,

    //Inputs to Stage 3

    //global stall from pipeline2
    //input wire global_stall_S3,
    //sharer list from the directory array
    input wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_S3,
    input wire [`PHY_ADDR_WIDTH-1:0] addr_S3,


    //Inputs to Stage 4
    //global stall from pipeline2
    input wire global_stall_S4,

    //input signals from the mshr
    input wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index_S4,

    //pipelined tag and state info from dpath
    input wire l2_tag_hit_S4,
    input wire l2_evict_S4,
    input wire [`L2_MESI_BITS-1:0] l2_way_state_mesi_S4,
    input wire [`L2_OWNER_BITS-1:0] l2_way_state_owner_S4,
    input wire [`L2_VD_BITS-1:0] l2_way_state_vd_S4,
    input wire [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S4,
    input wire [`L2_DI_BIT-1:0] l2_way_state_cache_type_S4,
    input wire [`MSG_MSHRID_WIDTH-1:0] mshrid_S4,
    input wire req_from_owner_S4,
    input wire [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S4,
    input wire [`MSG_LSID_WIDTH-1:0] lsid_S4,

    `ifndef NO_RTL_CSM
    input wire broadcast_counter_zero_S4,
    input wire broadcast_counter_max_S4,
    input wire broadcast_counter_avail_S4,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] broadcast_chipid_out_S4,
    input wire [`MSG_SRC_X_WIDTH-1:0] broadcast_x_out_S4,
    input wire [`MSG_SRC_Y_WIDTH-1:0] broadcast_y_out_S4,
    `endif

    input wire [`PHY_ADDR_WIDTH-1:0] addr_S4,
    //comparing result of CAS requests
    input wire cas_cmp_S4,

    //ready signal from the output buffer
    input wire msg_send_ready_S4,

    //inputs from the smc
    `ifndef NO_RTL_CSM
    input wire smc_hit_S4,
    `endif

    //Outputs from Stage 1

    output reg valid_S1,
    output reg stall_S1,
    output reg msg_from_mshr_S1,
    output reg dis_flush_S1,

    output reg mshr_cam_en_S1,
    output reg mshr_pending_ready_S1,

    output reg msg_header_ready_S1,

    output reg tag_clk_en_S1,
    output reg tag_rdw_en_S1,

    output reg state_rd_en_S1,

    output reg reg_wr_en_S1,
    output reg [`L2_ADDR_TYPE_WIDTH-1:0] reg_wr_addr_type_S1,


    //Outputs from Stage 2

    output reg valid_S2,
    output reg stall_S2,
    output reg stall_before_S2,
    output reg stall_real_S2,
    output reg [`MSG_TYPE_WIDTH-1:0] msg_type_S2,

    output reg msg_from_mshr_S2,
    output reg special_addr_type_S2,
    output wire state_load_sdid_S2,

    output reg dir_clk_en_S2,
    output reg dir_rdw_en_S2,
    output reg [`CS_OP_WIDTH-1:0] dir_op_S2,


    output reg data_clk_en_S2,
    output reg data_rdw_en_S2,
    output reg [`L2_AMO_ALU_OP_WIDTH-1:0] amo_alu_op_S2,

    output reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2,
    output reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2,
    output reg state_owner_en_S2,
    output reg [`CS_OP_WIDTH-1:0] state_owner_op_S2,
    output reg state_subline_en_S2,
    output reg [`CS_OP_WIDTH-1:0] state_subline_op_S2,
    output reg state_di_en_S2,
    output reg state_vd_en_S2,
    output reg [`L2_VD_BITS-1:0] state_vd_S2,
    output reg state_mesi_en_S2,
    output reg [`L2_MESI_BITS-1:0] state_mesi_S2,
    output reg state_lru_en_S2,
    output reg [`L2_LRU_OP_BITS-1:0] state_lru_op_S2,
    output reg state_rb_en_S2,

    output reg [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2,
    output reg l2_ifill_32B_S2,
    output reg l2_load_noshare_32B_S2,
    output reg l2_load_noshare_64B_S2,

    output reg msg_data_16B_amo_S2_f,

    output reg msg_data_ready_S2,

    `ifndef NO_RTL_CSM
    output reg smc_wr_en_S2,
    output reg smc_wr_diag_en_S2,
    output reg smc_flush_en_S2,
    output reg [`L2_ADDR_OP_WIDTH-1:0] smc_addr_op_S2,
    `endif
    //Outputs from Stage 3

    output reg valid_S3,
    output reg stall_S3,
    output reg stall_before_S3,

    //Outputs from Stage 4

    output reg valid_S4,
    output reg stall_S4,
    output reg stall_before_S4,


    output reg [`MSG_TYPE_WIDTH-1:0] msg_type_S4,
    output reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S4,
    output reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S4,
    output reg [`MSG_L2_MISS_BITS-1:0] l2_miss_S4,
    `ifndef NO_RTL_CSM
    output reg smc_miss_S4,
    output reg stall_smc_buf_S4,
    `endif
    output reg  msg_from_mshr_S4,
    output reg req_recycle_S4,
    output reg inv_fwd_pending_S4,

    output wire [`L2_OWNER_BITS-1:0] dir_sharer_S4,
    output reg [`L2_OWNER_BITS-1:0] dir_sharer_counter_S4,
    output reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_sel_S4,
    output reg cas_cmp_en_S4,
    output reg atomic_read_data_en_S4,
    output reg [`MSG_DATA_SIZE_WIDTH-1:0] cas_cmp_data_size_S4,
    output reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_S4,

    output reg msg_send_valid_S4,
    output reg [`L2_P1_BUF_OUT_MODE_WIDTH-1:0] msg_send_mode_S4,
    output reg [`MSG_TYPE_WIDTH-1:0] msg_send_type_S4,
    output reg [`MSG_TYPE_WIDTH-1:0] msg_send_type_pre_S4,

    output reg [`MSG_LENGTH_WIDTH-1:0] msg_send_length_S4,
    output reg [`MSG_DATA_SIZE_WIDTH-1:0] msg_send_data_size_S4,
    output reg [`MSG_CACHE_TYPE_WIDTH-1:0] msg_send_cache_type_S4,
    output reg [`MSG_MESI_BITS-1:0] msg_send_mesi_S4,
    output reg [`MSG_L2_MISS_BITS-1:0] msg_send_l2_miss_S4,
    output reg [`MSG_MSHRID_WIDTH-1:0] msg_send_mshrid_S4,
    output reg [`MSG_SUBLINE_VECTOR_WIDTH-1:0] msg_send_subline_vector_S4,
    output reg special_addr_type_S4,

    output reg mshr_wr_data_en_S4,
    output reg mshr_wr_state_en_S4,
    output reg [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_S4,
    output reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_inv_counter_rd_index_in_S4,
    output reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_wr_index_in_S4,

    output reg state_wr_sel_S4,
    output reg state_wr_en_S4,

    `ifndef NO_RTL_CSM
    output reg [`CS_OP_WIDTH-1:0] broadcast_counter_op_S4,
    output reg broadcast_counter_op_val_S4,
    `endif

    `ifndef NO_RTL_CSM
    output reg smc_rd_diag_en_buf_S4,
    output reg smc_rd_en_buf_S4,
    `endif

    output reg l2_access_valid_S4,
    output reg l2_miss_valid_S4,
    output reg reg_rd_en_S4,
    output reg [`L2_ADDR_TYPE_WIDTH-1:0] reg_rd_addr_type_S4

);


// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml


localparam y = 1'b1;
localparam n = 1'b0;


localparam rd = 1'b1;
localparam wr = 1'b0;


// pre-declare
reg [`MSG_TYPE_WIDTH-1:0] msg_type_S2_f;
reg msg_from_mshr_S2_f;
reg [`MSG_TYPE_WIDTH-1:0] msg_type_S4_f;

//============================
// Stage 1
//============================

reg stall_pre_S1;
reg stall_hazard_S1;
reg [`MSG_TYPE_WIDTH-1:0] msg_type_mux_S1;
reg [`MSG_TYPE_WIDTH-1:0] msg_type_trans_S1;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S1;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S1;

reg msg_header_ready_real_S1;
reg msg_cas_cmp_S1_f;
reg msg_cas_cmp_S1_next;
reg msg_input_en_S1_f;
reg msg_input_en_S1_next;
reg [`L2_ADDR_TYPE_WIDTH-1:0] addr_type_S1;
reg [`L2_ADDR_OP_WIDTH-1:0] addr_op_S1;
reg special_addr_type_S1;
reg msg_data_rd_S1;
reg msg_data_16B_amo_S1;

always @ *
begin
    valid_S1 = mshr_pending_S1 || (msg_header_valid_S1 && msg_input_en_S1_f);
end



always @ *
begin
    stall_pre_S1 = stall_S2 || global_stall_S1;
end


always @ *
begin
    mshr_pending_ready_S1 = mshr_pending_S1 && (!stall_S1);
end

always @ *
begin
    msg_from_mshr_S1 = mshr_pending_S1;
end

//msgs from mshr have higher priority than those from the input buffer
always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef NO_L2_CAM_MSHR
        msg_type_mux_S1 = mshr_msg_type_S1;
`else
        msg_type_mux_S1 = pending_mshr_msg_type_S1;
`endif // L2_CAM_MSHR
    end
    else
    begin
        msg_type_mux_S1 = msg_type_S1;
    end
end


always @ *
begin
     //Modified for timing
    //mshr_cam_en_S1 = (!mshr_pending_S1) && msg_header_valid_S1 && (!stall_pre_S1);
    // mshr_cam_en_S1 = (!mshr_pending_S1) && msg_header_valid_S1;
    mshr_cam_en_S1 = (!mshr_pending_S1) && msg_header_valid_S1 && (!global_stall_S1);
    // trinn
end


localparam atomic_state0 = 1'b0;
localparam atomic_state1 = 1'b1;
reg atomic_state_S1_f;
reg atomic_state_S1_next;
reg [`L2_AMO_ALU_OP_WIDTH-1:0] amo_alu_op_S1;
reg [`L2_AMO_ALU_OP_WIDTH-1:0] amo_alu_op_S2_f;


always @ *
begin
    amo_alu_op_S1 = `L2_AMO_ALU_NOP;
    if (!rst_n)
    begin
        atomic_state_S1_next = atomic_state0;
    end
    else if (valid_S1 && (!msg_from_mshr_S1) &&
       (msg_type_trans_S1 == `MSG_TYPE_CAS_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_SWAP_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_ADD_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_AND_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_OR_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_XOR_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_MAX_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_MAXU_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_MIN_P1_REQ
        || msg_type_trans_S1 == `MSG_TYPE_AMO_MINU_P1_REQ))
    begin
        atomic_state_S1_next = atomic_state1;
    end
    else if (valid_S1 && (!msg_from_mshr_S1) &&
            (msg_type_trans_S1 == `MSG_TYPE_CAS_P2Y_REQ
            || msg_type_trans_S1 == `MSG_TYPE_CAS_P2N_REQ
            || msg_type_trans_S1 == `MSG_TYPE_SWAP_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_ADD_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_AND_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_OR_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_XOR_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_MAX_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_MAXU_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_MIN_P2_REQ
            || msg_type_trans_S1 == `MSG_TYPE_AMO_MINU_P2_REQ))
    begin
        atomic_state_S1_next = atomic_state0;
        case (msg_type_trans_S1)
            `MSG_TYPE_AMO_ADD_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_ADD;
            end
            `MSG_TYPE_AMO_AND_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_AND;
            end
            `MSG_TYPE_AMO_OR_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_OR;
            end
            `MSG_TYPE_AMO_XOR_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_XOR;
            end
            `MSG_TYPE_AMO_MAX_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_MAX;
            end
            `MSG_TYPE_AMO_MAXU_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_MAXU;
            end
            `MSG_TYPE_AMO_MIN_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_MIN;
            end
            `MSG_TYPE_AMO_MINU_P2_REQ: begin
                amo_alu_op_S1 = `L2_AMO_ALU_MINU;
            end
        endcase
    end
    else
    begin
        atomic_state_S1_next = atomic_state_S1_f;
    end
end


always @ (posedge clk)
begin
    if (!stall_S1)
    begin
        atomic_state_S1_f <= atomic_state_S1_next;
    end
end

//translate atomic instructions into two subtypes based on two phases
always @ *
begin
    case (msg_type_mux_S1)
    `MSG_TYPE_NC_LOAD_REQ:
    begin
        case (addr_type_S1)
        `L2_ADDR_TYPE_DIS_FLUSH:
        begin
            msg_type_trans_S1 = `MSG_TYPE_L2_DIS_FLUSH_REQ;
        end
        `L2_ADDR_TYPE_LINE_FLUSH:
        begin
            msg_type_trans_S1 = `MSG_TYPE_L2_LINE_FLUSH_REQ;
        end
        default:
        begin
            msg_type_trans_S1 = msg_type_mux_S1;
        end
        endcase
    end
    `MSG_TYPE_CAS_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_CAS_P1_REQ;
        end
        else
        begin
            if (msg_cas_cmp_S1_f)
            begin
                msg_type_trans_S1 = `MSG_TYPE_CAS_P2Y_REQ;
            end
            else
            begin
                msg_type_trans_S1 = `MSG_TYPE_CAS_P2N_REQ;
            end
        end
    end
    `MSG_TYPE_SWAP_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_SWAP_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_SWAP_P2_REQ;
        end
    end
    `MSG_TYPE_SWAPWB_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_SWAPWB_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_SWAPWB_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_ADD_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_ADD_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_ADD_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_AND_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_AND_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_AND_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_OR_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_OR_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_OR_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_XOR_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_XOR_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_XOR_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_MAX_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MAX_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MAX_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_MAXU_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MAXU_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MAXU_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_MIN_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MIN_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MIN_P2_REQ;
        end
    end
    `MSG_TYPE_AMO_MINU_REQ:
    begin
        if (atomic_state_S1_f == atomic_state0)
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MINU_P1_REQ;
        end
        else
        begin
            msg_type_trans_S1 = `MSG_TYPE_AMO_MINU_P2_REQ;
        end
    end
    default:
    begin
        msg_type_trans_S1 = msg_type_mux_S1;
    end
    endcase
end


always @ *
begin
    dis_flush_S1 = (msg_type_trans_S1 == `MSG_TYPE_L2_DIS_FLUSH_REQ) && ~msg_from_mshr_S1;
end

always @ *
begin
    addr_type_S1 = addr_S1[`L2_ADDR_TYPE];
    addr_op_S1 = addr_S1[`L2_ADDR_OP];
end


always @ *
begin
    if ((msg_type_trans_S1 == `MSG_TYPE_NC_LOAD_REQ || msg_type_trans_S1 == `MSG_TYPE_NC_STORE_REQ)
    &&  (addr_type_S1 == `L2_ADDR_TYPE_DATA_ACCESS
    ||   addr_type_S1 == `L2_ADDR_TYPE_TAG_ACCESS
    ||   addr_type_S1 == `L2_ADDR_TYPE_STATE_ACCESS
    ||   addr_type_S1 == `L2_ADDR_TYPE_DIR_ACCESS
    ||   addr_type_S1 == `L2_ADDR_TYPE_SMC_ACCESS
    ||   addr_type_S1 == `L2_ADDR_TYPE_SMC_FLUSH
    ||   addr_type_S1 == `L2_ADDR_TYPE_ACCESS_COUNTER
    ||   addr_type_S1 == `L2_ADDR_TYPE_MISS_COUNTER
    ||   addr_type_S1 == `L2_ADDR_TYPE_COREID_REG
    ||   addr_type_S1 == `L2_ADDR_TYPE_ERROR_STATUS_REG
    ||   addr_type_S1 == `L2_ADDR_TYPE_CTRL_REG))
    begin
        special_addr_type_S1 = 1'b1;
    end
    else
    begin
        special_addr_type_S1 = 1'b0;
    end
end

always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef NO_L2_CAM_MSHR
        data_size_S1 = mshr_data_size_S1;
`else
        data_size_S1 = pending_mshr_data_size_S1;
`endif // L2_CAM_MSHR
    end
    else
    begin
        data_size_S1 = msg_data_size_S1;
    end
end

always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef NO_L2_CAM_MSHR
        cache_type_S1 = mshr_cache_type_S1;
`else
        cache_type_S1 = pending_mshr_cache_type_S1;
`endif // L2_CAM_MSHR
    end
    else
    begin
        cache_type_S1 = msg_cache_type_S1;
    end
end


reg [`CS_SIZE_S1-1:0] cs_S1;

always @ *
begin
    cs_S1 = {`CS_SIZE_S1{1'bx}};
    if (valid_S1)
    begin
        if (special_addr_type_S1)
        begin
            case (addr_type_S1)
                `L2_ADDR_TYPE_TAG_ACCESS:
                begin
                    if (msg_type_trans_S1 == `MSG_TYPE_NC_LOAD_REQ)
                    begin
                        //  tag_clk_en      tag_rdw_en    state_rd_en
                        cs_S1 = {y,             rd,       n};
                    end
                    else
                    begin
                        cs_S1 = {y,             wr,        n};
                    end
                end
                `L2_ADDR_TYPE_STATE_ACCESS:
                begin
                    if (msg_type_trans_S1 == `MSG_TYPE_NC_LOAD_REQ)
                    begin
                        //  tag_clk_en      tag_rdw_en   state_rd_en
                        cs_S1 = {y,             rd,      y};
                    end
                    else
                    begin
                        cs_S1 = {n,             rd,       n};
                    end
                end
                default:
                begin
                    cs_S1 = {n,             rd,           n};
                end
            endcase
        end
        else
        begin
            case (msg_type_trans_S1)
                `MSG_TYPE_LOAD_REQ, `MSG_TYPE_NC_LOAD_REQ, `MSG_TYPE_NC_STORE_REQ, `MSG_TYPE_PREFETCH_REQ,
                `MSG_TYPE_STORE_REQ, `MSG_TYPE_LOAD_NOSHARE_REQ,
                `MSG_TYPE_LR_REQ,
                `MSG_TYPE_WBGUARD_REQ, `MSG_TYPE_CAS_P2Y_REQ, `MSG_TYPE_SWAP_P2_REQ,
                `MSG_TYPE_CAS_P1_REQ, `MSG_TYPE_SWAP_P1_REQ, `MSG_TYPE_L2_DIS_FLUSH_REQ,`MSG_TYPE_L2_LINE_FLUSH_REQ,
                `MSG_TYPE_SWAPWB_P1_REQ, `MSG_TYPE_SWAPWB_P2_REQ,
                `MSG_TYPE_AMO_ADD_P1_REQ, `MSG_TYPE_AMO_ADD_P2_REQ,
                `MSG_TYPE_AMO_AND_P1_REQ, `MSG_TYPE_AMO_AND_P2_REQ,
                `MSG_TYPE_AMO_OR_P1_REQ, `MSG_TYPE_AMO_OR_P2_REQ,
                `MSG_TYPE_AMO_XOR_P1_REQ, `MSG_TYPE_AMO_XOR_P2_REQ,
                `MSG_TYPE_AMO_MAX_P1_REQ, `MSG_TYPE_AMO_MAX_P2_REQ,
                `MSG_TYPE_AMO_MAXU_P1_REQ, `MSG_TYPE_AMO_MAXU_P2_REQ,
                `MSG_TYPE_AMO_MIN_P1_REQ, `MSG_TYPE_AMO_MIN_P2_REQ,
                `MSG_TYPE_AMO_MINU_P1_REQ, `MSG_TYPE_AMO_MINU_P2_REQ:
                begin
                //  tag_clk_en      tag_rdw_en      state_rd_en
                    cs_S1 = {y,             rd,     y};
                end
                `MSG_TYPE_ERROR, `MSG_TYPE_CAS_P2N_REQ, `MSG_TYPE_INTERRUPT_FWD:
                begin
                    cs_S1 = {n,             rd,          n};
                end
                default:
                begin
                    cs_S1 = {`CS_SIZE_S1{1'bx}};
                end
            endcase
        end
    end
    else
    begin
        cs_S1 = {`CS_SIZE_S1{1'b0}};
    end
end


//disable inputs from the input buffers for requests with stored data because the stored data cannot be buffered
//if those instructions cause misses
always @ *
begin
    if (!rst_n)
    begin
        msg_input_en_S1_next = y;
    end
    else if ((valid_S1 && !stall_S1)
           &&((msg_type_trans_S1 == `MSG_TYPE_CAS_P2Y_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_SWAP_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_ADD_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_AND_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_OR_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_XOR_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_MAX_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_MAXU_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_MIN_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_AMO_MINU_P2_REQ)
           || (msg_type_trans_S1 == `MSG_TYPE_NC_STORE_REQ))
           && !msg_from_mshr_S1)
    begin
        msg_input_en_S1_next = n;
    end
    else if ((valid_S2 && !stall_S2)
           &&((((msg_type_S2_f == `MSG_TYPE_CAS_P2Y_REQ)
           || (msg_type_S2_f == `MSG_TYPE_SWAP_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_SWAPWB_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_ADD_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_AND_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_OR_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_XOR_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_MAX_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_MAXU_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_MIN_P2_REQ)
           || (msg_type_S2_f == `MSG_TYPE_AMO_MINU_P2_REQ))
                && l2_tag_hit_S2 && (l2_way_state_mesi_S2 == `L2_MESI_I))
            ||((msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ)
                && ((!l2_tag_hit_S2 && !msg_from_mshr_S2_f) || (l2_tag_hit_S2 && (l2_way_state_mesi_S2 == `L2_MESI_I) && (l2_way_state_vd_S2 == `L2_VD_CLEAN))))))
    begin
        msg_input_en_S1_next = y;
    end
    else
    begin
        msg_input_en_S1_next = msg_input_en_S1_f;
    end
end


always @ (posedge clk)
begin
    msg_input_en_S1_f <= msg_input_en_S1_next;
end



always @ *
begin
    msg_data_rd_S1 = valid_S1 && (msg_type_trans_S1 == `MSG_TYPE_NC_STORE_REQ)
                  && (addr_type_S1 == `L2_ADDR_TYPE_COREID_REG
                  ||  addr_type_S1 == `L2_ADDR_TYPE_CTRL_REG
                  ||  addr_type_S1 == `L2_ADDR_TYPE_ERROR_STATUS_REG
                  ||  addr_type_S1 == `L2_ADDR_TYPE_ACCESS_COUNTER
                  ||  addr_type_S1 == `L2_ADDR_TYPE_MISS_COUNTER
                  ||  addr_type_S1 == `L2_ADDR_TYPE_TAG_ACCESS);
end

always @ *
begin
    msg_data_16B_amo_S1 = valid_S1 && ((msg_type_trans_S1 == `MSG_TYPE_SWAP_P1_REQ) || (msg_type_trans_S1 == `MSG_TYPE_SWAP_P2_REQ) || (msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P1_REQ) || (msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P2_REQ)) && (data_size_S1 == `MSG_DATA_SIZE_16B);
    //msg_data_16B_amo_masked_S1 = valid_S1 && ((msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P1_REQ) || (msg_type_trans_S1 == `MSG_TYPE_SWAPWB_P2_REQ)) && (data_size_S1 == `MSG_DATA_SIZE_16B);
end

always @ *
begin
    reg_wr_en_S1 = valid_S1 && ~stall_S1 && (msg_type_trans_S1 == `MSG_TYPE_NC_STORE_REQ)
               && ((addr_type_S1 == `L2_ADDR_TYPE_CTRL_REG)
                || (addr_type_S1 == `L2_ADDR_TYPE_COREID_REG)
                || (addr_type_S1 == `L2_ADDR_TYPE_ERROR_STATUS_REG)
                || (addr_type_S1 == `L2_ADDR_TYPE_ACCESS_COUNTER)
                || (addr_type_S1 == `L2_ADDR_TYPE_MISS_COUNTER));
end

always @ *
begin
    reg_wr_addr_type_S1 = addr_type_S1;
end


//write the comparing result from stage 3
always @ *
begin
    if (!rst_n)
    begin
        msg_cas_cmp_S1_next = n;
    end
    else if (msg_type_S4_f == `MSG_TYPE_CAS_P1_REQ && cas_cmp_en_S4)
    begin
        if (cas_cmp_S4)
        begin
            msg_cas_cmp_S1_next = y;
        end
        else
        begin
            msg_cas_cmp_S1_next = n;
        end
    end
    else
    begin
        msg_cas_cmp_S1_next = msg_cas_cmp_S1_f;
    end
end


always @ (posedge clk)
begin
    msg_cas_cmp_S1_f <= msg_cas_cmp_S1_next;
end


always @ *
begin
    stall_hazard_S1 = (valid_S2 && (addr_S1[`L2_TAG_INDEX] == addr_S2[`L2_TAG_INDEX]))
                   || (valid_S3 && (addr_S1[`L2_TAG_INDEX] == addr_S3[`L2_TAG_INDEX]))
                   || (valid_S4 && (addr_S1[`L2_TAG_INDEX] == addr_S4[`L2_TAG_INDEX]))
                   || (pipe2_valid_S1 && (addr_S1[`L2_TAG_PLUS_INDEX] == pipe2_addr_S1[`L2_TAG_PLUS_INDEX]))
                   || (pipe2_valid_S2 && (addr_S1[`L2_TAG_PLUS_INDEX] == pipe2_addr_S2[`L2_TAG_PLUS_INDEX]))
                   || (pipe2_valid_S3 && (addr_S1[`L2_TAG_PLUS_INDEX] == pipe2_addr_S3[`L2_TAG_PLUS_INDEX]));
end

reg stall_mshr_S1;

always @ *
begin
    // trinn
    // stall_mshr_S1 = ( (mshr_cam_en_S1 && !global_stall_S1) && mshr_hit_S1)
    stall_mshr_S1 = (mshr_cam_en_S1 && mshr_hit_S1)
                 || (~msg_from_mshr_S1
                 //can be optimized
                 &&((mshr_empty_slots_S1 <= 3 && (valid_S2 || valid_S3 || valid_S4))
                 ||  mshr_empty_slots_S1 == 0));
end

reg stall_msg_S1;

always @ *
begin
    stall_msg_S1 = msg_data_rd_S1 && ~msg_data_valid_S1;
end

always @ *
begin
    stall_S1 = valid_S1 && (stall_pre_S1 || stall_hazard_S1 || stall_mshr_S1 || stall_msg_S1);
end


always @ *
begin
    msg_header_ready_real_S1 = (!stall_S1) && (!msg_from_mshr_S1) && msg_input_en_S1_f;
end

always @ *
begin
    msg_header_ready_S1 = msg_header_ready_real_S1
        && ((msg_type_trans_S1 != `MSG_TYPE_CAS_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_SWAP_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_SWAPWB_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_ADD_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_AND_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_OR_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_XOR_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_MAX_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_MAXU_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_MIN_P1_REQ)
         && (msg_type_trans_S1 != `MSG_TYPE_AMO_MINU_P1_REQ)
         );
end


always @ *
begin
    //for timing
    tag_clk_en_S1 = valid_S1 && cs_S1[`CS_TAG_CLK_EN_S1];
    //tag_clk_en_S1 = valid_S1 && !stall_S1 && cs_S1[`CS_TAG_CLK_EN_S1];
end

always @ *
begin
    //for timing
    tag_rdw_en_S1 = valid_S1 && cs_S1[`CS_TAG_RDW_EN_S1];
    //tag_rdw_en_S1 = valid_S1 && !stall_S1 && cs_S1[`CS_TAG_RDW_EN_S1];
end

always @ *
begin
    //for timing
    state_rd_en_S1 = valid_S1 && cs_S1[`CS_STATE_RD_EN_S1];
    //state_rd_en_S1 = valid_S1 && !stall_S1 && cs_S1[`CS_STATE_RD_EN_S1];
end

reg l2_miss_S1;

always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef NO_L2_CAM_MSHR
        l2_miss_S1 = mshr_l2_miss_S1;
`else
        l2_miss_S1 = pending_mshr_l2_miss_S1;
`endif // L2_CAM_MSHR
    end
    else
    begin
        l2_miss_S1 = 0;
    end
end


reg valid_S1_next;

always @ *
begin
    valid_S1_next = valid_S1 && !stall_S1;
end



//============================
// Stage 1 -> Stage 2
//============================

reg valid_S2_f;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2_f;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2_f;
reg [`MSG_L2_MISS_BITS-1:0] l2_miss_S2_f;
`ifndef NO_RTL_CSM
reg mshr_smc_miss_S2_f;
`endif
reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index_S2_f;
reg special_addr_type_S2_f;
reg msg_data_rd_S2_f;

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        valid_S2_f <= 1'b0;
        msg_type_S2_f <= 0;
        data_size_S2_f <= 0;
        cache_type_S2_f <= 0;
        l2_miss_S2_f <= 0;
        `ifndef NO_RTL_CSM
        mshr_smc_miss_S2_f <= 0;
        `endif
        msg_from_mshr_S2_f <= 1'b0;
        mshr_pending_index_S2_f <= 0;
        special_addr_type_S2_f <= 0;
        msg_data_rd_S2_f <= 0;
        msg_data_16B_amo_S2_f <= 1'b0;
        amo_alu_op_S2_f <= `L2_AMO_ALU_OP_WIDTH'b0;
    end
    else if (!stall_S2)
    begin
        valid_S2_f <= valid_S1_next;
        msg_type_S2_f <= msg_type_trans_S1;
        data_size_S2_f <= data_size_S1;
        cache_type_S2_f <= cache_type_S1;
        l2_miss_S2_f <= l2_miss_S1;
        `ifndef NO_RTL_CSM
`ifdef NO_L2_CAM_MSHR
        mshr_smc_miss_S2_f <= mshr_smc_miss_S1;
`else
        mshr_smc_miss_S2_f <= (mshr_pending_S1 == 1'b1) ? pending_mshr_smc_miss_S1 : (mshr_hit_S1 && cam_mshr_smc_miss_S1);
`endif // L2_CAM_MSHR
        `endif
        msg_from_mshr_S2_f <= msg_from_mshr_S1;
        mshr_pending_index_S2_f <= mshr_pending_index_S1;
        special_addr_type_S2_f <= special_addr_type_S1;
        msg_data_rd_S2_f <= msg_data_rd_S1;
        msg_data_16B_amo_S2_f <= msg_data_16B_amo_S1;
        amo_alu_op_S2_f <= amo_alu_op_S1;
    end
end



//============================
// Stage 2
//============================

reg stall_pre_S2;
// reg stall_real_S2;
reg stall_before_S2_f;
reg stall_before_S2_next;
reg state_wr_en_S2;
reg [`MSG_L2_MISS_BITS-1:0] l2_miss_S2;
//re-execute this request
reg req_recycle_S2;
reg req_recycle_cur_S2;
reg req_recycle_buf_S2_f;
reg req_recycle_buf_S2_next;

reg mshr_wr_data_en_S2;
reg mshr_wr_state_en_S2;
reg [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_S2;

reg [`L2_ADDR_TYPE_WIDTH-1:0] addr_type_S2;
reg [`L2_ADDR_OP_WIDTH-1:0] addr_op_S2;


always @ *
begin
    valid_S2 = valid_S2_f;
    data_size_S2 = data_size_S2_f;
    cache_type_S2 = cache_type_S2_f;
    msg_from_mshr_S2 = msg_from_mshr_S2_f;
    stall_before_S2 = stall_before_S2_f;
    msg_type_S2 = msg_type_S2_f;
    special_addr_type_S2 = special_addr_type_S2_f;
    amo_alu_op_S2 = amo_alu_op_S2_f;
end

always @ *
begin
    addr_type_S2 = addr_S2[`L2_ADDR_TYPE];
    addr_op_S2 = addr_S2[`L2_ADDR_OP];
end



always @ *
begin
    if (!rst_n)
    begin
        stall_before_S2_next = 0;
    end
    else
    begin
        stall_before_S2_next = stall_S2;
    end
end


always @ (posedge clk)
begin
    stall_before_S2_f <= stall_before_S2_next;
end


always @ *
begin
    stall_pre_S2 = stall_S3 || global_stall_S2;
end


reg [`CS_SIZE_P1S2-1:0] cs_S2;

always @ *
begin
    // default assignment to prevent latch inferral
    cs_S2 = {`CS_SIZE_P1S2{1'bx}};
    if (valid_S2)
    begin
        if (special_addr_type_S2_f)
        begin
            case (addr_type_S2)
                `L2_ADDR_TYPE_DATA_ACCESS:
                begin
                    if (msg_type_S2_f == `MSG_TYPE_NC_LOAD_REQ)
                    begin
                        //       amo_alu    dir        dir      dir     data    data           mshr     state      state       state       msg
                        //       op         clk_en     rdw_en   op      clk_en  rdw_en         wr_en    owner_en   owner_op    subline_en  data_ready
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,     n,          n,
                        //       state       state   state   state          state    state           state   state
                        //       subline_op  di_en   vd_en   vd             mesi_en  mesi            lru_en  lru
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,     n,          y,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                `L2_ADDR_TYPE_DIR_ACCESS:
                begin
                    if (msg_type_S2_f == `MSG_TYPE_NC_LOAD_REQ)
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          n,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          y,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                `L2_ADDR_TYPE_STATE_ACCESS:
                begin
                    if (msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ)
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       y,         `OP_CLR,     y,          y,
                                 `OP_CLR,    y,      y,      `L2_VD_INVAL,  y,       `L2_MESI_I, y,      `L2_LRU_CLR};
                    end
                    else
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          n,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                `L2_ADDR_TYPE_SMC_ACCESS:
                begin
                    if (msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ)
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          y,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          n,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                default:
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          n,
                             `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                end
            endcase
        end
        else if (req_recycle_S2)
        begin
            cs_S2 = {`CS_SIZE_P1S2{1'b0}};
        end
        else
        begin
            if ((msg_type_S2_f == `MSG_TYPE_CAS_P2N_REQ) || (msg_type_S2_f == `MSG_TYPE_INTERRUPT_FWD))
            begin
                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          y,
                         `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
            end

            else if (l2_evict_S2)
            begin
                case (l2_way_state_mesi_S2)
                `L2_MESI_S:
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                             `OP_CLR,   n,       n,      `L2_VD_ERROR,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                end
                `ifndef NO_RTL_CSM
                `L2_MESI_B:
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                             `OP_CLR,   n,       n,      `L2_VD_ERROR,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                end
                `endif
                `L2_MESI_E:
                begin
                    `ifndef NO_RTL_CSM
                    if (csm_en)
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                 `OP_CLR,   n,       n,      `L2_VD_ERROR,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    `endif
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                 `OP_CLR,   n,       n,      `L2_VD_ERROR,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                `L2_MESI_I:
                begin
                    case (l2_way_state_vd_S2)
                    `L2_VD_CLEAN:
                    begin
                        if (msg_type_S2_f == `MSG_TYPE_L2_LINE_FLUSH_REQ)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                    end
                    `L2_VD_DIRTY:
                    begin
                        if (msg_type_S2_f == `MSG_TYPE_L2_LINE_FLUSH_REQ)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            y,       n,         `OP_CLR,    n,          n,
                                     `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                default:
                begin
                    cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                end
                endcase
            end

            else if (!l2_tag_hit_S2)
            begin
                if (msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ)
                begin
                    if (msg_from_mshr_S2_f)
                    begin
                        //       dir        dir      dir     data    data           mshr     state      state       state       msg
                        //       clk_en     rdw_en   op      clk_en  rdw_en         wr_en    owner_en   owner_op    subline_en  data_ready
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,     n,          n,
                        //       state       state   state   state          state    state           state   state
                        //       subline_op  di_en   vd_en   vd             mesi_en  mesi            lru_en  lru
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,     n,          y,
                                 `OP_CLR,    n,      n,      `L2_VD_ERROR,  n,       `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                else if (msg_type_S2_f == `MSG_TYPE_WBGUARD_REQ
                 || msg_type_S2_f == `MSG_TYPE_L2_LINE_FLUSH_REQ
                 || msg_type_S2_f == `MSG_TYPE_L2_DIS_FLUSH_REQ)
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,    n,          n,
                             `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                end
                else
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                             `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                end
            end

            else begin
            case (msg_type_S2_f)

                `MSG_TYPE_WBGUARD_REQ:
                begin
                    `ifndef NO_RTL_CSM
                    if (csm_en && (l2_way_state_mesi_S2 == `L2_MESI_E) && l2_way_state_subline_S2[addr_S2[`L2_DATA_SUBLINE]])
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,    n,          n,
                                `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    else
                    `endif
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,    n,          n,
                                `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                end
                `MSG_TYPE_L2_DIS_FLUSH_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,          n,
                                `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase

                end
                `MSG_TYPE_NC_LOAD_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S2)
                        `L2_VD_CLEAN:
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        `L2_VD_DIRTY:
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            y,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_CLEAN,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        default:
                        begin
                            cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                        end
                        endcase
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end

                `MSG_TYPE_NC_STORE_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S2)
                        `L2_VD_CLEAN:
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            y,       n,         `OP_CLR,    n,          y,
                                    `OP_CLR,   n,       y,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        `L2_VD_DIRTY:
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            y,       n,         `OP_CLR,    n,          n,
                                    `OP_CLR,   n,       y,      `L2_VD_CLEAN,  n,      `L2_MESI_I, y,      `L2_LRU_CLR};
                        end
                        default:
                        begin
                            cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                        end
                        endcase
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end

                `MSG_TYPE_LOAD_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        if (cache_type_S2_f == `MSG_CACHE_TYPE_DATA)
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_LD, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                         `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_E,   y,     `L2_LRU_SET};
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                         `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_E,   y,     `L2_LRU_SET};
                            end
                        end
                        else
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                if (lsid_S2 == `L2_PUBLIC_SHARER)
                                begin
                                    cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, y,      rd,            n,       y,         `OP_CLR,     y,      n,
                                            `OP_LD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_B,   y,     `L2_LRU_SET};
                                end
                                else
                                begin
                                    cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                            `OP_LD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_S,   y,     `L2_LRU_SET};

                                end
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, y,      rd,            n,       y,         `OP_CLR,     y,      n,
                                         `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_S,   y,     `L2_LRU_SET};
                            end
                        end
                    end
                    `L2_MESI_S:
                    begin
                        if (cache_type_S2_f == l2_way_state_cache_type_S2)
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,      n,
                                        `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    y,      n,
                                        `OP_ADD,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                            end
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        if (cache_type_S2_f == l2_way_state_cache_type_S2)
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         wr,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         wr,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    y,      n,
                                         `OP_ADD,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                            end
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        if (req_from_owner_S2 && (cache_type_S2_f == l2_way_state_cache_type_S2))
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    y,      n,
                                     `OP_ADD,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        else
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                            end
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_LOAD_NOSHARE_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        if (cache_type_S2_f == `MSG_CACHE_TYPE_DATA)
                        begin
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,      n,         `OP_CLR,     n,      n,
                                         `OP_CLR,   y,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I,   y,     `L2_LRU_SET};
                            end
                        end
                        else
                        begin
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,     n,      n,
                                         `OP_CLR,   y,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I,   y,     `L2_LRU_SET};
                            end
                        end
                    end
                    `L2_MESI_S:
                    begin
                        if (cache_type_S2_f == l2_way_state_cache_type_S2)
                        begin
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,      n,
                                        `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                            end
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        if (cache_type_S2_f == l2_way_state_cache_type_S2)
                        begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         wr,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,     `L2_LRU_SET};
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                // Just like a STORE
                `MSG_TYPE_LR_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        if (cache_type_S2_f == `MSG_CACHE_TYPE_DATA)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                     `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_E,   y,     `L2_LRU_SET};
                        end
                        else begin
                            cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                        end
                    end
                    `L2_MESI_S:   // change MESI state to I in pipe2
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `L2_MESI_E:
                    begin
                        if (req_from_owner_S2 && (cache_type_S2_f == l2_way_state_cache_type_S2))
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    y,      n,
                                     `OP_ADD,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        else
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_PREFETCH_REQ:
                begin
                    cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            n,       n,         `OP_CLR,    n,      n,
                             `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                end

                `MSG_TYPE_STORE_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         wr,      `OP_LD, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                     `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_E, y,     `L2_LRU_SET};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       y,         `OP_LD,     y,      n,
                                     `OP_ADD,   y,       n,      `L2_VD_INVAL,  y,      `L2_MESI_E, y,     `L2_LRU_SET};
                        end
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,          n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        if (req_from_owner_S2 && (cache_type_S2_f == l2_way_state_cache_type_S2))
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,    y,      n,
                                     `OP_ADD,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        else
                        begin
                            `ifndef NO_RTL_CSM
                            if (csm_en)
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                            end
                            else
                            `endif
                            begin
                                cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                         `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                            end
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_CAS_P1_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,     n,      y,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I,   y,     `L2_LRU_SET};
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_SWAP_P1_REQ,
                `MSG_TYPE_SWAPWB_P1_REQ,
                `MSG_TYPE_AMO_ADD_P1_REQ,
                `MSG_TYPE_AMO_AND_P1_REQ,
                `MSG_TYPE_AMO_OR_P1_REQ,
                `MSG_TYPE_AMO_XOR_P1_REQ,
                `MSG_TYPE_AMO_MAX_P1_REQ,
                `MSG_TYPE_AMO_MAXU_P1_REQ,
                `MSG_TYPE_AMO_MIN_P1_REQ,
                `MSG_TYPE_AMO_MINU_P1_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      rd,            n,       n,         `OP_CLR,     n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I,   y,     `L2_LRU_SET};
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end

                `MSG_TYPE_CAS_P2Y_REQ,
                `MSG_TYPE_SWAP_P2_REQ,
                `MSG_TYPE_SWAPWB_P2_REQ,
                `MSG_TYPE_AMO_ADD_P2_REQ,
                `MSG_TYPE_AMO_AND_P2_REQ,
                `MSG_TYPE_AMO_OR_P2_REQ,
                `MSG_TYPE_AMO_XOR_P2_REQ,
                `MSG_TYPE_AMO_MAX_P2_REQ,
                `MSG_TYPE_AMO_MAXU_P2_REQ,
                `MSG_TYPE_AMO_MIN_P2_REQ,
                `MSG_TYPE_AMO_MINU_P2_REQ:
                begin
                    case (l2_way_state_mesi_S2)
                    `L2_MESI_I:
                    begin
                        case (msg_type_S2_f)
                        `MSG_TYPE_CAS_P2Y_REQ,
                        `MSG_TYPE_SWAP_P2_REQ,
                        `MSG_TYPE_SWAPWB_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_ADD_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_ADD, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_AND_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_AND, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_OR_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_OR, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_XOR_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_XOR, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_MAX_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_MAX, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_MAXU_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_MAXU, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_MIN_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_MIN, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        `MSG_TYPE_AMO_MINU_P2_REQ:
                        begin
                            cs_S2 = {`L2_AMO_ALU_MINU, n,         rd,      `OP_CLR, y,      wr,            n,       n,         `OP_CLR,    n,      y,
                                 `OP_CLR,   y,       y,      `L2_VD_DIRTY,  n,      `L2_MESI_I, y,      `L2_LRU_SET};
                        end
                        endcase
                    end
                    `L2_MESI_S:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `ifndef NO_RTL_CSM
                    `L2_MESI_B:
                    begin
                        cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                 `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                    end
                    `endif
                    `L2_MESI_E:
                    begin
                        `ifndef NO_RTL_CSM
                        if (csm_en)
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, y,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                        else
                        `endif
                        begin
                            cs_S2 = {`L2_AMO_ALU_NOP, n,         rd,      `OP_CLR, n,      rd,            y,       n,         `OP_CLR,    n,      n,
                                     `OP_CLR,   n,       n,      `L2_VD_INVAL,  n,      `L2_MESI_I, n,      `L2_LRU_CLR};
                        end
                    end
                    default:
                    begin
                        cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                    end
                    endcase
                end

                default:
                begin
                    cs_S2 = {`CS_SIZE_P1S2{1'bx}};
                end
            endcase
            end
        end
    end
    else
    begin
        cs_S2 = {`CS_SIZE_P1S2{1'b0}};
    end
end



reg [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2_f;
reg [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2_next;


always @ *
begin
    dir_clk_en_S2 = !stall_S2 && cs_S2[`CS_DIR_CLK_EN_P1S2];
end

always @ *
begin
    dir_rdw_en_S2 = !stall_S2 && cs_S2[`CS_DIR_RDW_EN_P1S2];
end


always @ *
begin
    dir_op_S2 = cs_S2[`CS_DIR_OP_P1S2];
end

always @ *
begin
    data_clk_en_S2 = !stall_real_S2 && cs_S2[`CS_DATA_CLK_EN_P1S2];
end

always @ *
begin
    data_rdw_en_S2 = !stall_real_S2 && cs_S2[`CS_DATA_RDW_EN_P1S2];
end

always @ *
begin
    mshr_wr_data_en_S2 = !stall_S2 && cs_S2[`CS_MSHR_WR_EN_P1S2];
    mshr_wr_state_en_S2 = !stall_S2 && cs_S2[`CS_MSHR_WR_EN_P1S2];
end



always @ *
begin
    if ( l2_tag_hit_S2 && (msg_type_S2_f == `MSG_TYPE_NC_LOAD_REQ || msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ)
    && (l2_way_state_mesi_S2 == `L2_MESI_I) && (l2_way_state_vd_S2 == `L2_VD_DIRTY))
    begin
        mshr_state_in_S2 = `L2_MSHR_STATE_PENDING;
    end
    else
    begin
        mshr_state_in_S2 = `L2_MSHR_STATE_WAIT;
    end
end


always @ *
begin
    if (!l2_tag_hit_S2)
    begin
        l2_miss_S2 = 1;
    end
    else
    begin
        l2_miss_S2 = l2_miss_S2_f;
    end
end



`ifndef NO_RTL_CSM
always @ *
begin
    if (special_addr_type_S2_f && (addr_type_S2 == `L2_ADDR_TYPE_SMC_ACCESS) && (msg_type_S2_f == `MSG_TYPE_NC_STORE_REQ))
    begin
        smc_wr_en_S2 = 1'b1;
        smc_wr_diag_en_S2 = 1'b1;
    end
    else
    begin
        smc_wr_en_S2 = 1'b0;
        smc_wr_diag_en_S2 = 1'b0;
    end
end

always @ *
begin
    if (special_addr_type_S2_f && (addr_type_S2 == `L2_ADDR_TYPE_SMC_FLUSH))
    begin
        smc_flush_en_S2 = 1'b1;
    end
    else
    begin
        smc_flush_en_S2 = 1'b0;
    end
end


always @ *
begin
    smc_addr_op_S2 = addr_op_S2;
end
`endif

always @ *
begin
    state_owner_en_S2 =  cs_S2[`CS_STATE_OWNER_EN_P1S2];
end


always @ *
begin
    state_owner_op_S2 = cs_S2[`CS_STATE_OWNER_OP_P1S2];
end


always @ *
begin
    state_subline_en_S2 =  cs_S2[`CS_STATE_SL_EN_P1S2];
end

always @ *
begin
    state_subline_op_S2 = cs_S2[`CS_STATE_SL_OP_P1S2];
end


`ifndef NO_RTL_CSM
assign state_load_sdid_S2 = csm_en && state_owner_en_S2 && (state_owner_op_S2 ==`OP_LD)
                                && state_subline_en_S2 && (state_subline_op_S2 == `OP_LD);
`else
assign state_load_sdid_S2 = 1'b0;
`endif

always @ *
begin
    state_di_en_S2 = cs_S2[`CS_STATE_DI_EN_P1S2];
end

always @ *
begin
    state_vd_en_S2 = cs_S2[`CS_STATE_VD_EN_P1S2];
end

always @ *
begin
    state_vd_S2 = cs_S2[`CS_STATE_VD_P1S2];
end

always @ *
begin
    state_mesi_en_S2 = cs_S2[`CS_STATE_MESI_EN_P1S2];
end

always @ *
begin
    if (!cs_S2[`CS_STATE_MESI_EN_P1S2])
    begin
        state_mesi_S2 = l2_way_state_mesi_S2;
    end
    else
    begin
        state_mesi_S2 = cs_S2[`CS_STATE_MESI_P1S2];
    end
end

always @ *
begin
    state_lru_en_S2 =  cs_S2[`CS_STATE_LRU_EN_P1S2];
end

always @ *
begin
    state_lru_op_S2 = cs_S2[`CS_STATE_LRU_OP_P1S2];
end


//TODO
always @ *
begin
    state_rb_en_S2 =  l2_evict_S2  && (l2_way_state_mesi_S2 == `L2_MESI_I)
                 && (msg_type_S2_f != `MSG_TYPE_CAS_P2N_REQ);
end


always @ *
begin
    state_wr_en_S2 = valid_S2 && !stall_S2 && (
                          cs_S2[`CS_STATE_OWNER_EN_P1S2]
                       || cs_S2[`CS_STATE_SL_EN_P1S2]
                       || cs_S2[`CS_STATE_VD_EN_P1S2]
                       || cs_S2[`CS_STATE_DI_EN_P1S2]
                       || cs_S2[`CS_STATE_MESI_EN_P1S2]
                       || cs_S2[`CS_STATE_LRU_EN_P1S2]
                       || (state_rb_en_S2));
end


always @ *
begin
    req_recycle_cur_S2 = valid_S2
    &&  (~special_addr_type_S2_f)
    &&  ((pipe2_valid_S1 && (pipe2_msg_type_S1 == `MSG_TYPE_WB_REQ)
        && (addr_S2[`L2_TAG_PLUS_INDEX] == pipe2_addr_S1[`L2_TAG_PLUS_INDEX]))
    ||   (pipe2_valid_S2 && (pipe2_msg_type_S2 == `MSG_TYPE_WB_REQ)
        && (addr_S2[`L2_TAG_PLUS_INDEX] == pipe2_addr_S2[`L2_TAG_PLUS_INDEX]))
    ||   (pipe2_valid_S3 && (pipe2_msg_type_S3 == `MSG_TYPE_WB_REQ)
        && (addr_S2[`L2_TAG_PLUS_INDEX] == pipe2_addr_S3[`L2_TAG_PLUS_INDEX])));
end


always @ *
begin
    if (!rst_n)
    begin
        req_recycle_buf_S2_next = 1'b0;
    end
    else
    begin
        if (!stall_S2)
        begin
            req_recycle_buf_S2_next = 1'b0;
        end
        else if (req_recycle_cur_S2)
        begin
            req_recycle_buf_S2_next = 1'b1;
        end
        else
        begin
            req_recycle_buf_S2_next = req_recycle_buf_S2_f;
        end
    end
end


always @ (posedge clk)
begin
    req_recycle_buf_S2_f <= req_recycle_buf_S2_next;
end


always @ *
begin
    req_recycle_S2 = req_recycle_cur_S2 | req_recycle_buf_S2_f;
end

reg msg_data_16B_rd_in_advance_S2;
always @(*) 
begin
    // If amo swap data size is 16B, we'll read the first 8B during SWAP_P1, and read the next 8B as usual(during P2)
    // advance read only happens when mshr_en is false, otherwise P1 will go through the flow again.
    msg_data_16B_rd_in_advance_S2 = msg_data_16B_amo_S2_f && 
                                    ((msg_type_S2_f == `MSG_TYPE_SWAP_P1_REQ) || (msg_type_S2_f == `MSG_TYPE_SWAPWB_P1_REQ)) &&
                                    !cs_S2[`CS_MSHR_WR_EN_P1S2];
end

always @ *
begin
    // there are several cases that we need to read msg data
    // msg_data_rd covers the config reg write; cs_S2[`CS_STATE_DATA_RDY_P1S2] covers more generous cases including AMO ops;
    // msg_data_16B_rd_in_advance is for the special case in which data size for SWAP is 16B
    msg_data_ready_S2 = (valid_S2 && !stall_S2 && (cs_S2[`CS_STATE_DATA_RDY_P1S2] || msg_data_rd_S2_f || msg_data_16B_rd_in_advance_S2)); 
end


always @ *
begin
    if (special_addr_type_S2)
    begin
        l2_ifill_32B_S2 = n;
    end
    else if (valid_S2 && l2_tag_hit_S2 && data_clk_en_S2 && (data_rdw_en_S2 == rd) && ~l2_wb_S2
    && (cache_type_S2_f == `MSG_CACHE_TYPE_INS))
    begin
        l2_ifill_32B_S2 = y;
`ifdef L2_SEND_NC_REQ
        // NC ifill is on 4B, and do not need 2 cycles to read out the data.
        // So l2_ifill for it is "n"
        if (msg_type_S2_f == `MSG_TYPE_NC_LOAD_REQ && data_size_S2_f != `MSG_DATA_SIZE_32B)
        begin
            l2_ifill_32B_S2 = n;
        end
`endif
    end
    else
    begin
        l2_ifill_32B_S2 = n;
    end
end

always @ *
begin
    l2_load_noshare_32B_S2 = n;
    l2_load_noshare_64B_S2 = n;
    if (valid_S2 && l2_tag_hit_S2 && data_clk_en_S2 && (data_rdw_en_S2 == rd) && ~l2_wb_S2
    && (msg_type_S2_f == `MSG_TYPE_LOAD_NOSHARE_REQ))
    begin
        if (data_size_S2_f == `MSG_DATA_SIZE_32B)
        begin
            l2_load_noshare_32B_S2 = y;
        end
        else if (data_size_S2_f == `MSG_DATA_SIZE_64B)
        begin
            l2_load_noshare_64B_S2 = y;
        end
    end
end


//writeback reads 64B and required 4 cycles to read out from the data array
//ifill loads 32B and required 2 cycles to read out from the data array
//load noshare may request 32B or 64B
always @ *
begin
    if (!rst_n)
    begin
        l2_load_data_subline_S2_next = `L2_DATA_SUBLINE_0;
    end
    else if (valid_S2 && !(stall_real_S2) && (l2_ifill_32B_S2 || l2_load_noshare_32B_S2) && (l2_load_data_subline_S2_f == `L2_DATA_SUBLINE_1))
    begin
        l2_load_data_subline_S2_next = `L2_DATA_SUBLINE_0;
    end
    else if (valid_S2 && !(stall_real_S2) && (l2_wb_S2 || l2_ifill_32B_S2 || l2_load_noshare_32B_S2 || l2_load_noshare_64B_S2))
    begin
        l2_load_data_subline_S2_next = l2_load_data_subline_S2_f + 1;
    end
    else
    begin
        l2_load_data_subline_S2_next = l2_load_data_subline_S2_f;
    end
end


always @ (posedge clk)
begin
    l2_load_data_subline_S2_f <= l2_load_data_subline_S2_next;
end

reg stall_load_S2;

always @ *
begin
    if (l2_wb_S2 || l2_load_noshare_64B_S2)
    begin
        stall_load_S2 = (l2_load_data_subline_S2_f != `L2_DATA_SUBLINE_3);
    end
    else if (l2_ifill_32B_S2 || l2_load_noshare_32B_S2)
    begin
        stall_load_S2 = (l2_load_data_subline_S2_f != `L2_DATA_SUBLINE_1);
    end
    else
    begin
        stall_load_S2 = n;
    end
end


always @ *
begin
    l2_load_data_subline_S2 = l2_load_data_subline_S2_f;
end

reg stall_msg_S2;

always @ *
begin
    stall_msg_S2 = ((cs_S2[`CS_STATE_DATA_RDY_P1S2] || msg_data_rd_S2_f || msg_data_16B_rd_in_advance_S2) && ~msg_data_valid_S2);
end

always @ *
begin
    stall_real_S2 = valid_S2 && (stall_pre_S2 || stall_msg_S2);
end

always @ *
begin
    stall_S2 = valid_S2 && (stall_real_S2 || stall_load_S2);
end

reg valid_S2_next;

always @ *
begin
    valid_S2_next = valid_S2 && !stall_real_S2;
end



//============================
// Stage 2 -> Stage 3
//============================

reg valid_S3_f;
reg [`MSG_TYPE_WIDTH-1:0] msg_type_S3_f;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S3_f;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S3_f;
reg msg_from_mshr_S3_f;
reg [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S3_f;
reg [`MSG_MESI_BITS-1:0] state_mesi_S3_f;
reg [`MSG_L2_MISS_BITS-1:0] l2_miss_S3_f;
`ifndef NO_RTL_CSM
reg mshr_smc_miss_S3_f;
`endif
reg state_wr_en_S3_f;
reg mshr_wr_data_en_S3_f;
reg mshr_wr_state_en_S3_f;
reg [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_S3_f;
reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index_S3_f;
reg special_addr_type_S3_f;
reg req_recycle_S3_f;

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        valid_S3_f <= 1'b0;
        msg_type_S3_f <= 0;
        data_size_S3_f <= 0;
        cache_type_S3_f <= 0;
        msg_from_mshr_S3_f <= 0;
        l2_load_data_subline_S3_f <= 0;
        state_mesi_S3_f <= 0;
        l2_miss_S3_f <= 0;
        `ifndef NO_RTL_CSM
        mshr_smc_miss_S3_f <= 0;
        `endif
        state_wr_en_S3_f <= 0;
        mshr_wr_data_en_S3_f <= 0;
        mshr_wr_state_en_S3_f <= 0;
        mshr_state_in_S3_f <= 0;
        mshr_pending_index_S3_f <= 0;
        special_addr_type_S3_f <= 0;
        req_recycle_S3_f <= 0;
    end
    else if (!stall_S3)
    begin
        valid_S3_f <= valid_S2_next;
        msg_type_S3_f <= msg_type_S2_f;
        data_size_S3_f <= data_size_S2_f;
        cache_type_S3_f <= cache_type_S2_f;
        msg_from_mshr_S3_f <= msg_from_mshr_S2_f;
        l2_load_data_subline_S3_f <= l2_load_data_subline_S2_f;
        state_mesi_S3_f <= state_mesi_S2;
        l2_miss_S3_f <= l2_miss_S2;
        `ifndef NO_RTL_CSM
        mshr_smc_miss_S3_f <= mshr_smc_miss_S2_f;
        `endif
        state_wr_en_S3_f <= state_wr_en_S2;
        mshr_wr_data_en_S3_f <= mshr_wr_data_en_S2;
        mshr_wr_state_en_S3_f <= mshr_wr_state_en_S2;
        mshr_state_in_S3_f <= mshr_state_in_S2;
        mshr_pending_index_S3_f <= mshr_pending_index_S2_f;
        special_addr_type_S3_f <= special_addr_type_S2_f;
        req_recycle_S3_f <= req_recycle_S2;
    end
end


//============================
// Stage 3
//============================

reg stall_pre_S3;
reg stall_before_S3_f;
reg stall_before_S3_next;
reg req_recycle_S3;
reg req_recycle_cur_S3;
reg req_recycle_buf_S3_f;
reg req_recycle_buf_S3_next;

always @ *
begin
    stall_before_S3 = stall_before_S3_f;
    valid_S3 = valid_S3_f;
end



always @ *
begin
    req_recycle_cur_S3 = valid_S3 && (req_recycle_S3_f
     || (state_wr_en_S3_f
        && ((pipe2_valid_S1 && (pipe2_msg_type_S1 == `MSG_TYPE_WB_REQ)
            && (addr_S3[`L2_TAG_PLUS_INDEX] == pipe2_addr_S1[`L2_TAG_PLUS_INDEX]))
        ||  (pipe2_valid_S2 && (pipe2_msg_type_S2 == `MSG_TYPE_WB_REQ)
            && (addr_S3[`L2_TAG_PLUS_INDEX] == pipe2_addr_S2[`L2_TAG_PLUS_INDEX]))
        ||  (pipe2_valid_S3 && (pipe2_msg_type_S3 == `MSG_TYPE_WB_REQ)
            && (addr_S3[`L2_TAG_PLUS_INDEX] == pipe2_addr_S3[`L2_TAG_PLUS_INDEX])))));
end

always @ *
begin
    if (!rst_n)
    begin
        req_recycle_buf_S3_next = 1'b0;
    end
    else
    begin
        if (!stall_S3)
        begin
            req_recycle_buf_S3_next = 1'b0;
        end
        else if (req_recycle_cur_S3)
        begin
            req_recycle_buf_S3_next = 1'b1;
        end
        else
        begin
            req_recycle_buf_S3_next = req_recycle_buf_S3_f;
        end
    end
end


always @ (posedge clk)
begin
    req_recycle_buf_S3_f <= req_recycle_buf_S3_next;
end


always @ *
begin
    req_recycle_S3 = req_recycle_cur_S3 | req_recycle_buf_S3_f;
end




always @ *
begin
    stall_pre_S3 = stall_S4;
    //stall_pre_S3 = stall_S4 || global_stall_S3;
end

always @ *
begin
    if (!rst_n)
    begin
        stall_before_S3_next = 0;
    end
    else
    begin
        stall_before_S3_next = stall_S3;
    end
end

//used to switch buffered output from arrays
always @ (posedge clk)
begin
    stall_before_S3_f <= stall_before_S3_next;
end



always @ *
begin
    stall_S3 = stall_pre_S3;
end



reg valid_S3_next;

always @ *
begin
    valid_S3_next = valid_S3 && !stall_S3;
end


//============================
// Stage 3 -> Stage 4
//============================

reg valid_S4_f;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S4_f;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S4_f;
reg msg_from_mshr_S4_f;
reg [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S4_f;
reg [`MSG_MESI_BITS-1:0] state_mesi_S4_f;
reg [`MSG_L2_MISS_BITS-1:0] l2_miss_S4_f;
`ifndef NO_RTL_CSM
reg mshr_smc_miss_S4_f;
`endif
reg state_wr_en_S4_f;
reg mshr_wr_data_en_S4_f;
reg mshr_wr_state_en_S4_f;
reg [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_S4_f;
reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index_S4_f;
reg special_addr_type_S4_f;
reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_S4_f;
reg req_recycle_S4_f;


always @ (posedge clk)
begin
    if (!rst_n)
    begin
        valid_S4_f <= 1'b0;
        msg_type_S4_f <= 0;
        data_size_S4_f <= 0;
        cache_type_S4_f <= 0;
        msg_from_mshr_S4_f <= 0;
        l2_load_data_subline_S4_f <= 0;
        state_mesi_S4_f <= 0;
        l2_miss_S4_f <= 0;
        `ifndef NO_RTL_CSM
        mshr_smc_miss_S4_f <= 0;
        `endif
        state_wr_en_S4_f <= 0;
        mshr_wr_data_en_S4_f <= 0;
        mshr_wr_state_en_S4_f <= 0;
        mshr_state_in_S4_f <= 0;
        mshr_pending_index_S4_f <= 0;
        special_addr_type_S4_f <= 0;
        dir_data_S4_f <= 0;
        req_recycle_S4_f <= 0;
    end
    else if (!stall_S4)
    begin
        valid_S4_f <= valid_S3_next;
        msg_type_S4_f <= msg_type_S3_f;
        data_size_S4_f <= data_size_S3_f;
        cache_type_S4_f <= cache_type_S3_f;
        msg_from_mshr_S4_f <= msg_from_mshr_S3_f;
        l2_load_data_subline_S4_f <= l2_load_data_subline_S3_f;
        state_mesi_S4_f <= state_mesi_S3_f;
        l2_miss_S4_f <= l2_miss_S3_f;
        `ifndef NO_RTL_CSM
        mshr_smc_miss_S4_f <= mshr_smc_miss_S3_f;
        `endif
        state_wr_en_S4_f <= state_wr_en_S3_f;
        mshr_wr_data_en_S4_f <= mshr_wr_data_en_S3_f;
        mshr_wr_state_en_S4_f <= mshr_wr_state_en_S3_f;
        mshr_state_in_S4_f <= mshr_state_in_S3_f;
        mshr_pending_index_S4_f <= mshr_pending_index_S3_f;
        special_addr_type_S4_f <= special_addr_type_S3_f;
        dir_data_S4_f <= dir_data_S3;
        req_recycle_S4_f <= req_recycle_S3;
    end
end


//============================
// Stage 4
//============================

reg stall_before_S4_f;
reg stall_before_S4_next;
reg dir_data_stall_S4;
reg state_wr_en_real_S4;
reg stall_inv_counter_S4;
reg msg_stall_S4;
reg load_store_mem_S4;
`ifndef NO_RTL_CSM
reg smc_stall_S4;
reg broadcast_stall_S4;
`endif
reg req_recycle_cur_S4;
reg req_recycle_buf_S4_f;
reg req_recycle_buf_S4_next;

reg [`L2_ADDR_TYPE_WIDTH-1:0] addr_type_S4;
reg [`L2_ADDR_OP_WIDTH-1:0] addr_op_S4;

reg msg0_send_valid_S4;
reg [`MSG_TYPE_WIDTH-1:0] msg0_send_type_S4;
reg msg1_send_valid_S4;
reg [`MSG_TYPE_WIDTH-1:0] msg1_send_type_S4;
//reg msg_send_valid_pre_S4;
//reg [`MSG_TYPE_WIDTH-1:0] msg_send_type_pre_S4;

`ifndef NO_RTL_CSM
reg smc_rd_diag_en_S4;
reg smc_rd_en_S4;
`endif

reg mshr_inv_flag_S4;

always @ *
begin
    valid_S4 = valid_S4_f;
    stall_before_S4 = stall_before_S4_f;
    msg_type_S4 = msg_type_S4_f;
    data_size_S4 = data_size_S4_f;
    cache_type_S4 = cache_type_S4_f;
    l2_miss_S4 = l2_miss_S4_f;
    special_addr_type_S4 = special_addr_type_S4_f;
    dir_data_S4 = dir_data_S4_f;
    msg_from_mshr_S4 = msg_from_mshr_S4_f;
end


always @ *
begin
    if (~special_addr_type_S4_f && req_recycle_S4)
    begin
        mshr_state_in_S4 = `L2_MSHR_STATE_PENDING;
    end
    else if(mshr_inv_flag_S4)
    begin
        mshr_state_in_S4 = `L2_MSHR_STATE_INVAL;
    end
    else
    begin
        mshr_state_in_S4 = mshr_state_in_S4_f;
    end
end

always @ *
begin
    req_recycle_cur_S4 = valid_S4 && (req_recycle_S4_f
     || (state_wr_en_S4_f
        && ((pipe2_valid_S1 && (pipe2_msg_type_S1 == `MSG_TYPE_WB_REQ)
            && (addr_S4[`L2_TAG_PLUS_INDEX] == pipe2_addr_S1[`L2_TAG_PLUS_INDEX]))
        ||  (pipe2_valid_S2 && (pipe2_msg_type_S2 == `MSG_TYPE_WB_REQ)
            && (addr_S4[`L2_TAG_PLUS_INDEX] == pipe2_addr_S2[`L2_TAG_PLUS_INDEX]))
        ||  (pipe2_valid_S3 && (pipe2_msg_type_S3 == `MSG_TYPE_WB_REQ)
            && (addr_S4[`L2_TAG_PLUS_INDEX] == pipe2_addr_S3[`L2_TAG_PLUS_INDEX])))));
end

always @ *
begin
    if (!rst_n)
    begin
        req_recycle_buf_S4_next = 1'b0;
    end
    else
    begin
        if (!stall_S4)
        begin
            req_recycle_buf_S4_next = 1'b0;
        end
        else if (req_recycle_cur_S4)
        begin
            req_recycle_buf_S4_next = 1'b1;
        end
        else
        begin
            req_recycle_buf_S4_next = req_recycle_buf_S4_f;
        end
    end
end


always @ (posedge clk)
begin
    req_recycle_buf_S4_f <= req_recycle_buf_S4_next;
end


always @ *
begin
    req_recycle_S4 = req_recycle_cur_S4 | req_recycle_buf_S4_f;
end



`ifndef NO_RTL_CSM
reg smc_rd_diag_en_buf_S4_next;
reg smc_rd_en_buf_S4_next;
reg smc_rd_diag_en_buf_S4_f;
reg smc_rd_en_buf_S4_f;

always @ *
begin
    if (!rst_n)
    begin
        smc_rd_diag_en_buf_S4_next = 0;
        smc_rd_en_buf_S4_next = 0;
    end
    else if (!stall_smc_buf_S4)
    begin
        smc_rd_diag_en_buf_S4_next = smc_rd_diag_en_S4;
        smc_rd_en_buf_S4_next = smc_rd_en_S4;
    end
    else
    begin
        smc_rd_diag_en_buf_S4_next = smc_rd_diag_en_buf_S4_f;
        smc_rd_en_buf_S4_next = smc_rd_en_buf_S4_f;
    end
end

always @ (posedge clk)
begin
    smc_rd_diag_en_buf_S4_f <= smc_rd_diag_en_buf_S4_next;
    smc_rd_en_buf_S4_f <= smc_rd_en_buf_S4_next;
end


always @ *
begin
    smc_rd_diag_en_buf_S4 = smc_rd_diag_en_buf_S4_f;
    smc_rd_en_buf_S4 = smc_rd_en_buf_S4_f;
end
/*
reg smc_hit_buf_S4_next;
reg smc_hit_buf_S4_f;

always @ *
begin
    if (!rst_n)
    begin
        smc_hit_buf_S4_next = 0;
    end
    else if (!stall_smc_buf_S4)
    begin
        smc_hit_buf_S4_next = smc_hit_S4;
    end
    else
    begin
        smc_hit_buf_S4_next = smc_hit_buf_S4_f;
    end
end

always @ (posedge clk)
begin
    smc_hit_buf_S4_f <= smc_hit_buf_S4_next;
end
*/
`endif


always @ *
begin
    if(valid_S4)
        begin
        if (~special_addr_type_S4_f && req_recycle_S4)
        begin
            mshr_wr_data_en_S4 = ~stall_S4;
            mshr_wr_state_en_S4 = ~stall_S4;
            mshr_inv_flag_S4 = 1'b0;
        end
        else if (load_store_mem_S4)
        begin
            mshr_wr_data_en_S4 = msg_send_valid_S4 && (msg_send_type_S4 == msg0_send_type_S4) && msg_send_ready_S4;
            mshr_wr_state_en_S4 = msg_send_valid_S4 && (msg_send_type_S4 == msg0_send_type_S4) && msg_send_ready_S4;
            mshr_inv_flag_S4 = 1'b0;
        end
        else if (msg_send_type_S4 == `MSG_TYPE_INV_FWD)
        begin
            mshr_wr_data_en_S4 = ((msg_send_valid_S4 && msg_send_ready_S4 && (dir_sharer_counter_S4 == 1)) || (~stall_S4))
                              && mshr_wr_data_en_S4_f;
            mshr_wr_state_en_S4 = ((msg_send_valid_S4 && msg_send_ready_S4 && (dir_sharer_counter_S4 == 1)) || (~stall_S4))
                               && mshr_wr_state_en_S4_f;
            mshr_inv_flag_S4 = 1'b0;
        end
        else if ((msg_type_S4 == `MSG_TYPE_WBGUARD_REQ) && l2_tag_hit_S4
              && (l2_way_state_mesi_S4 == `L2_MESI_E) && l2_way_state_subline_S4[addr_S4[`L2_DATA_SUBLINE]]
              && req_from_owner_S4)
        begin
            mshr_wr_data_en_S4 = ~stall_S4;
            mshr_wr_state_en_S4 = ~stall_S4;
            mshr_inv_flag_S4 = 1'b0;
        end
        `ifndef NO_RTL_CSM
        else if (csm_en && mshr_smc_miss_S4_f && (~mshr_wr_state_en_S4_f))
        begin
            mshr_wr_data_en_S4 = 1'b0;
            mshr_wr_state_en_S4 = ~stall_S4;
            mshr_inv_flag_S4 = 1'b1;
        end
        `endif
        else
        begin
            mshr_wr_data_en_S4 = ~stall_S4 && mshr_wr_data_en_S4_f;
            mshr_wr_state_en_S4 = ~stall_S4 && mshr_wr_state_en_S4_f;
            mshr_inv_flag_S4 = 1'b0;
        end
    end
    else
    begin
        mshr_wr_data_en_S4 = 1'b0;
        mshr_wr_state_en_S4 = 1'b0;
        mshr_inv_flag_S4 = 1'b0;
    end
end

always @ *
begin
    if (valid_S4 && (!req_recycle_S4) && (msg_send_type_S4 == `MSG_TYPE_INV_FWD)
     && (msg_send_valid_S4 && msg_send_ready_S4 && (dir_sharer_counter_S4 == 1) && stall_S4)
     && mshr_wr_data_en_S4_f)
    begin
        inv_fwd_pending_S4 = 1'b1;
    end
    else
    begin
        inv_fwd_pending_S4 = 1'b0;
    end
end

always @ *
begin
    addr_type_S4 = addr_S4[`L2_ADDR_TYPE];
    addr_op_S4 = addr_S4[`L2_ADDR_OP];
end



always @ *
begin
    if (!rst_n)
    begin
        stall_before_S4_next = 0;
    end
    else
    begin
        stall_before_S4_next = stall_S4;
    end
end

//used to switch buffered output from arrays
always @ (posedge clk)
begin
    stall_before_S4_f <= stall_before_S4_next;
end


reg [`CS_SIZE_S4-1:0] cs_S4;

always @ *
begin
    if (valid_S4)
    begin
        if (special_addr_type_S4_f)
        begin
            if (msg_type_S4_f == `MSG_TYPE_NC_STORE_REQ)
            begin
                //       msg        msg0        msg0                   msg1        msg1
                //       send_fwd   send_en     send_type              send_en     send_type
                cs_S4 = {n,         y,          `MSG_TYPE_NODATA_ACK,  n,          `MSG_TYPE_ERROR};
            end
            else
            begin
                cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,  n,          `MSG_TYPE_ERROR};
            end
        end
        else if(req_recycle_S4)
        begin
            cs_S4 = {`CS_SIZE_S4{1'b0}};
        end
        else
        begin
            if (msg_type_S4_f == `MSG_TYPE_INTERRUPT_FWD)
            begin
                cs_S4 = {n,         y,          `MSG_TYPE_INTERRUPT,    n,          `MSG_TYPE_ERROR};
            end
            else if (msg_type_S4_f == `MSG_TYPE_CAS_P2N_REQ)
            begin
                cs_S4 = {n,         n,          `MSG_TYPE_ERROR,    n,          `MSG_TYPE_ERROR};
            end
            else if (msg_type_S4_f == `MSG_TYPE_WBGUARD_REQ)
            begin
                cs_S4 = {n,         n,          `MSG_TYPE_ERROR,    n,          `MSG_TYPE_ERROR};
            end
            else if (l2_evict_S4)
            begin
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S4)
                        `L2_VD_CLEAN:
                        begin
                            if (msg_type_S4_f == `MSG_TYPE_L2_LINE_FLUSH_REQ)
                            begin
                                cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                            end
                            else if (msg_type_S4_f == `MSG_TYPE_NC_LOAD_REQ)
                            begin
                                //TODO
                                //cs_S4 = {y,          `MSG_TYPE_NC_LOAD_REQ,    n,          `MSG_TYPE_ERROR};
                                `ifdef L2_SEND_NC_REQ
                                    cs_S4 = {n,         y,          `MSG_TYPE_NC_LOAD_REQ,    n,          `MSG_TYPE_ERROR};
                                `else
                                    cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    n,          `MSG_TYPE_ERROR};
                                `endif
                            end
                            else
                            begin
                                cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    n,          `MSG_TYPE_ERROR};
                            end
                        end
                        `L2_VD_DIRTY:
                        begin
                            if (msg_type_S4_f == `MSG_TYPE_L2_LINE_FLUSH_REQ)
                            begin
                                cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    y,          `MSG_TYPE_STORE_MEM};
                            end
                            else if (msg_type_S4_f == `MSG_TYPE_NC_LOAD_REQ)
                            begin
                                //TODO
                                //cs_S4 = {y,          `MSG_TYPE_NC_LOAD_REQ,    y,          `MSG_TYPE_STORE_MEM};
                                `ifdef L2_SEND_NC_REQ
                                    cs_S4 = {n,         y,          `MSG_TYPE_NC_LOAD_REQ,    y,          `MSG_TYPE_STORE_MEM};
                                `else
                                    cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    y,          `MSG_TYPE_STORE_MEM};
                                `endif
                            end
                            else
                            begin
                                cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    y,          `MSG_TYPE_STORE_MEM};
                            end
                        end
                        default:
                        begin
                            cs_S4 = {`CS_SIZE_S4{1'bx}};
                        end
                        endcase
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
            end

            else if (!l2_tag_hit_S4)
            begin
                begin
                    if (msg_type_S4_f == `MSG_TYPE_L2_DIS_FLUSH_REQ || msg_type_S4_f == `MSG_TYPE_L2_LINE_FLUSH_REQ)
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                    end
                    else if (msg_type_S4_f == `MSG_TYPE_NC_STORE_REQ)
                    begin
                        if (msg_from_mshr_S4_f)
                        begin
                            //       msg         msg0        msg0                   msg1        msg1
                            //       send_fwd    send_en     send_type              send_en     send_type
                            cs_S4 = {n,          y,          `MSG_TYPE_NODATA_ACK,  n,          `MSG_TYPE_ERROR};
                        end
                        else
                        begin
                            cs_S4 = {n,          y,          `MSG_TYPE_NC_STORE_REQ,n,          `MSG_TYPE_ERROR};
                        end
                    end
                    else if (msg_type_S4_f == `MSG_TYPE_NC_LOAD_REQ)
                    begin
                        //TODO
                        //cs_S4 = {y,          `MSG_TYPE_NC_LOAD_REQ,    n,          `MSG_TYPE_ERROR};
                        `ifdef L2_SEND_NC_REQ
                            cs_S4 = {n,         y,          `MSG_TYPE_NC_LOAD_REQ,    n,          `MSG_TYPE_ERROR};
                        `else
                            cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    n,          `MSG_TYPE_ERROR};
                        `endif
                    end
                    else
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_LOAD_MEM,    n,          `MSG_TYPE_ERROR};
                    end
                end
            end

            else begin
            case (msg_type_S4_f)
                //TODO
                `MSG_TYPE_L2_DIS_FLUSH_REQ, `MSG_TYPE_L2_LINE_FLUSH_REQ:
                begin
                   case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S4)
                        `L2_VD_CLEAN:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        `L2_VD_DIRTY:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    y,          `MSG_TYPE_STORE_MEM};
                        end
                        default:
                        begin
                            cs_S4 = {`CS_SIZE_S4{1'bx}};
                        end
                        endcase
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,   n,          `MSG_TYPE_ERROR};
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_NC_STORE_REQ:
                begin
                   case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S4)
                        `L2_VD_CLEAN:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_NC_STORE_REQ,    n,          `MSG_TYPE_ERROR};
                        end
                        `L2_VD_DIRTY:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_STORE_MEM,    n,          `MSG_TYPE_ERROR};
                        end
                        default:
                        begin
                            cs_S4 = {`CS_SIZE_S4{1'bx}};
                        end
                        endcase
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,   n,          `MSG_TYPE_ERROR};
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end

                `MSG_TYPE_NC_LOAD_REQ:
                begin
                   case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        case (l2_way_state_vd_S4)
                        `L2_VD_CLEAN:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        `L2_VD_DIRTY:
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_STORE_MEM,    n,          `MSG_TYPE_ERROR};
                        end
                        default:
                        begin
                            cs_S4 = {`CS_SIZE_S4{1'bx}};
                        end
                        endcase
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,   n,          `MSG_TYPE_ERROR};
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_LOAD_REQ, `MSG_TYPE_LOAD_NOSHARE_REQ:
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        if (cache_type_S4_f == l2_way_state_cache_type_S4)
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        else
                        begin
                            cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                        end
                    end
                    `L2_MESI_E:
                    begin
                        if (msg_type_S4_f == `MSG_TYPE_LOAD_REQ && req_from_owner_S4 && (cache_type_S4_f == l2_way_state_cache_type_S4))
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        else if (cache_type_S4_f != l2_way_state_cache_type_S4)
                        begin
                            cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,   n,          `MSG_TYPE_ERROR};
                        end
                        else
                        begin
                            cs_S4 = {y,         y,          `MSG_TYPE_LOAD_FWD,   n,          `MSG_TYPE_ERROR};
                        end
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_LR_REQ:   // Jsut same as a store req
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_S:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        if (req_from_owner_S4 && (cache_type_S4_f == l2_way_state_cache_type_S4))
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        else
                        begin
                            cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,    n,          `MSG_TYPE_ERROR};
                        end
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_PREFETCH_REQ:
                begin
                    cs_S4 = {n,         y,          `MSG_TYPE_NODATA_ACK,    n,          `MSG_TYPE_ERROR};
                end

                `MSG_TYPE_STORE_REQ:
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        if (req_from_owner_S4 && (cache_type_S4_f == l2_way_state_cache_type_S4))
                        begin
                            cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                        end
                        else
                        begin
                            cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,    n,          `MSG_TYPE_ERROR};
                        end
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end
                `MSG_TYPE_CAS_P1_REQ, `MSG_TYPE_SWAP_P1_REQ,
                `MSG_TYPE_SWAPWB_P1_REQ,
                `MSG_TYPE_AMO_ADD_P1_REQ,
                `MSG_TYPE_AMO_AND_P1_REQ,
                `MSG_TYPE_AMO_OR_P1_REQ,
                `MSG_TYPE_AMO_XOR_P1_REQ,
                `MSG_TYPE_AMO_MAX_P1_REQ,
                `MSG_TYPE_AMO_MAXU_P1_REQ,
                `MSG_TYPE_AMO_MIN_P1_REQ,
                `MSG_TYPE_AMO_MINU_P1_REQ:
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        cs_S4 = {n,         y,          `MSG_TYPE_DATA_ACK,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end

                `MSG_TYPE_CAS_P2Y_REQ, `MSG_TYPE_SWAP_P2_REQ,
                `MSG_TYPE_SWAPWB_P2_REQ,
                `MSG_TYPE_AMO_ADD_P2_REQ,
                `MSG_TYPE_AMO_AND_P2_REQ,
                `MSG_TYPE_AMO_OR_P2_REQ,
                `MSG_TYPE_AMO_XOR_P2_REQ,
                `MSG_TYPE_AMO_MAX_P2_REQ,
                `MSG_TYPE_AMO_MAXU_P2_REQ,
                `MSG_TYPE_AMO_MIN_P2_REQ,
                `MSG_TYPE_AMO_MINU_P2_REQ:
                begin
                    case (l2_way_state_mesi_S4)
                    `L2_MESI_I:
                    begin
                        cs_S4 = {n,         n,          `MSG_TYPE_ERROR,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_S, `L2_MESI_B:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_INV_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    `L2_MESI_E:
                    begin
                        cs_S4 = {y,         y,          `MSG_TYPE_STORE_FWD,    n,          `MSG_TYPE_ERROR};
                    end
                    default:
                    begin
                        cs_S4 = {`CS_SIZE_S4{1'bx}};
                    end
                    endcase
                end

                default:
                begin
                    cs_S4 = {`CS_SIZE_S4{1'bx}};
                end
            endcase
            end
        end
    end
    else
    begin
        cs_S4 = {`CS_SIZE_S4{1'b0}};
    end
end



`ifndef NO_RTL_CSM
always @ *
begin
    msg0_send_valid_S4 = !(global_stall_S4 || stall_inv_counter_S4 || smc_stall_S4 || broadcast_stall_S4) && cs_S4[`CS_MSG0_SEND_EN_S4];
    msg0_send_type_S4 = cs_S4[`CS_MSG0_SEND_TYPE_S4];
    msg1_send_valid_S4 = !(global_stall_S4 || stall_inv_counter_S4|| smc_stall_S4 || broadcast_stall_S4) && cs_S4[`CS_MSG1_SEND_EN_S4];
    msg1_send_type_S4 = cs_S4[`CS_MSG1_SEND_TYPE_S4];
end
`else
always @ *
begin
    msg0_send_valid_S4 = !(global_stall_S4 || stall_inv_counter_S4) && cs_S4[`CS_MSG0_SEND_EN_S4];
    msg0_send_type_S4 = cs_S4[`CS_MSG0_SEND_TYPE_S4];
    msg1_send_valid_S4 = !(global_stall_S4 || stall_inv_counter_S4) && cs_S4[`CS_MSG1_SEND_EN_S4];
    msg1_send_type_S4 = cs_S4[`CS_MSG1_SEND_TYPE_S4];
end

`endif

always @ *
begin
    load_store_mem_S4 = cs_S4[`CS_MSG0_SEND_EN_S4] && cs_S4[`CS_MSG1_SEND_EN_S4] &&
                       (msg0_send_type_S4 == `MSG_TYPE_LOAD_MEM || msg0_send_type_S4 == `MSG_TYPE_NC_LOAD_REQ)
                     &&(msg1_send_type_S4 == `MSG_TYPE_STORE_MEM);
end

localparam msg_state_0 = 1'b0;
localparam msg_state_1 = 1'b1;

reg msg_state_S4_f;
reg msg_state_S4_next;


`ifndef NO_RTL_CSM
always @ *
begin
    if (!rst_n)
    begin
        msg_state_S4_next = msg_state_0;
    end
    else if (msg0_send_valid_S4 && msg1_send_valid_S4 && valid_S4
    && !(dir_data_stall_S4 || smc_stall_S4 || (msg_send_valid_S4 && !msg_send_ready_S4) || global_stall_S4 || broadcast_stall_S4))
    begin
        if (msg_state_S4_f == msg_state_0)
        begin
            msg_state_S4_next = msg_state_1;
        end
        else
        begin
            if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_3)
            begin
                msg_state_S4_next = msg_state_0;
            end
            else
            begin
                msg_state_S4_next = msg_state_1;
            end
        end
    end
    else
    begin
        msg_state_S4_next = msg_state_S4_f;
    end
end
`else
always @ *
begin
    if (!rst_n)
    begin
        msg_state_S4_next = msg_state_0;
    end
    else if (msg0_send_valid_S4 && msg1_send_valid_S4 && valid_S4
    && !(dir_data_stall_S4 || (msg_send_valid_S4 && !msg_send_ready_S4) || global_stall_S4))
    begin
        if (msg_state_S4_f == msg_state_0)
        begin
            msg_state_S4_next = msg_state_1;
        end
        else
        begin
            if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_3)
            begin
                msg_state_S4_next = msg_state_0;
            end
            else
            begin
                msg_state_S4_next = msg_state_1;
            end
        end
    end
    else
    begin
        msg_state_S4_next = msg_state_S4_f;
    end
end

`endif


always @ (posedge clk)
begin
    msg_state_S4_f <= msg_state_S4_next;
end

always @ *
begin
    if (msg_state_S4_f == msg_state_0)
    begin
        msg_send_valid_S4 = msg0_send_valid_S4;
        msg_send_type_pre_S4 = msg0_send_type_S4;
    end
    else
    begin
        msg_send_valid_S4 = msg1_send_valid_S4;
        msg_send_type_pre_S4 = msg1_send_type_S4;
    end
end

`ifndef NO_RTL_CSM
always @ *
begin
    if (smc_miss_S4)
    begin
        msg_send_type_S4 = `MSG_TYPE_NC_LOAD_REQ;
    end
    else
    begin
        msg_send_type_S4 = msg_send_type_pre_S4;
    end
end
`else
always @ *
begin
    msg_send_type_S4 = msg_send_type_pre_S4;
end

`endif

//stall signal for one cycle delay of smc array read to meet timing
/*
always @ *
begin
    if (msg_state_S4_f == msg_state_0)
    begin
        msg_send_valid_pre_S4 = msg0_send_valid_S4;
        msg_send_type_S4 = msg0_send_type_S4;
    end
    else
    begin
        msg_send_valid_pre_S4 = msg1_send_valid_S4;
        msg_send_type_S4 = msg1_send_type_S4;
    end
end
*/

`ifndef NO_RTL_CSM
localparam smc_state_0 = 1'b0;
localparam smc_state_1 = 1'b1;

reg smc_state_S4_f;
reg smc_state_S4_next;

always @ *
begin
    if (!rst_n)
    begin
        smc_state_S4_next = smc_state_0;
    end
    else if (smc_rd_en_S4 && (~stall_smc_buf_S4))
    begin
        if (smc_state_S4_f == smc_state_0)
        begin
            smc_state_S4_next = smc_state_1;
        end
        else
        begin
            smc_state_S4_next = smc_state_0;
        end
    end
    else
    begin
        smc_state_S4_next = smc_state_S4_f;
    end
end

always @ (posedge clk)
begin
    smc_state_S4_f <= smc_state_S4_next;
end

always @ *
begin
    smc_stall_S4 = smc_rd_en_S4 && (smc_state_S4_f == smc_state_0);
end
`endif
/*
always @ *
begin
    msg_send_valid_S4 = msg_send_valid_pre_S4 && (~smc_stall_S4);
end
*/

reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index_buf_S4_f;
reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index_buf_S4_next;
reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index_sel_S4;

always @ *
begin
    if (stall_before_S4_f)
    begin
        mshr_empty_index_sel_S4 = mshr_empty_index_buf_S4_f;
    end
    else
    begin
        mshr_empty_index_sel_S4 = mshr_empty_index_S4;
    end
end

always @ *
begin
    if (!rst_n)
    begin
        mshr_empty_index_buf_S4_next = {`L2_MSHR_INDEX_WIDTH{1'b0}};
    end
    else if (stall_S4 && !stall_before_S4_f)
    begin
        mshr_empty_index_buf_S4_next = mshr_empty_index_S4;
    end
    else
    begin
        mshr_empty_index_buf_S4_next = mshr_empty_index_buf_S4_f;
    end
end


always @ (posedge clk)
begin
    mshr_empty_index_buf_S4_f <= mshr_empty_index_buf_S4_next;
end



always @ *
begin
    if (msg_send_valid_S4)
    begin
        case (msg_send_type_S4)
        `MSG_TYPE_LOAD_FWD, `MSG_TYPE_STORE_FWD, `MSG_TYPE_INV_FWD:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_3H0D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
            msg_send_data_size_S4 = `MSG_DATA_SIZE_16B;
            msg_send_cache_type_S4 = l2_way_state_cache_type_S4;
            msg_send_mshrid_S4 = mshr_wr_index_in_S4;
        end
        `MSG_TYPE_NODATA_ACK:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H0D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd0;
            msg_send_data_size_S4 = `MSG_DATA_SIZE_0B;
            msg_send_cache_type_S4 = cache_type_S4_f;
            msg_send_mshrid_S4 = mshrid_S4;
        end
        `MSG_TYPE_DATA_ACK:
        begin
            // For DATA_ACK, data_size field is not used
            if (special_addr_type_S4_f)
            begin
                msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H2D;
                msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
                // msg_send_data_size_S4 = data_size_S4_f;
                msg_send_cache_type_S4 = cache_type_S4_f;
                msg_send_mshrid_S4 = mshrid_S4;
            end
`ifdef L2_SEND_NC_REQ
            else if (msg_type_S4_f == `MSG_TYPE_NC_LOAD_REQ)
            begin
                if (cache_type_S4_f == `MSG_CACHE_TYPE_INS && data_size_S4_f == `MSG_DATA_SIZE_32B)
                begin
                    // Just for Sparc non-cacheable 32B ifill
                    msg_send_length_S4 = `MSG_LENGTH_WIDTH'd4;
                    // msg_send_data_size_S4 = `MSG_DATA_SIZE_32B;
                    msg_send_cache_type_S4 = cache_type_S4_f;
                    msg_send_mshrid_S4 = mshrid_S4;
                    if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_0)
                    begin
                        msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H2D;
                    end
                    else
                    begin
                        msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H2D;
                    end
                end
                else
                begin
                    // non-cacheable data load should be within 8B, but sparc sends 16B nc-load
                    msg_send_mode_S4 = (data_size_S4_f == `MSG_DATA_SIZE_16B) ? `L2_P1_BUF_OUT_MODE_1H2D : `L2_P1_BUF_OUT_MODE_1H1D;
                    msg_send_length_S4 = (data_size_S4_f == `MSG_DATA_SIZE_16B) ? `MSG_LENGTH_WIDTH'd2 : `MSG_LENGTH_WIDTH'd1;
                    // msg_send_data_size_S4 = 1-8B;
                    msg_send_cache_type_S4 = cache_type_S4_f;
                    msg_send_mshrid_S4 = mshrid_S4;
                end
            end
`endif
            else if (msg_type_S4_f == `MSG_TYPE_LOAD_NOSHARE_REQ)
            begin
                // Allow load noshare to request 32B or 64B data.
                // For request data size equal or less than 16B,
                // we always return 16B L2 subline, without data replication
                if (data_size_S4_f==`MSG_DATA_SIZE_32B)
                begin
                    msg_send_length_S4 = `MSG_LENGTH_WIDTH'd4;
                end
                else if (data_size_S4_f==`MSG_DATA_SIZE_64B)
                begin
                    msg_send_length_S4 = `MSG_LENGTH_WIDTH'd8;
                end
                else
                begin
                    msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
                end
                // msg_send_data_size_S4 = `MSG_DATA_SIZE_32B;
                msg_send_cache_type_S4 = cache_type_S4_f;
                msg_send_mshrid_S4 = mshrid_S4;
                if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_0)
                begin
                    msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H2D;
                end
                else
                begin
                    msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H2D;
                end
            end
            else if (cache_type_S4_f == `MSG_CACHE_TYPE_DATA)
            begin
                msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H2D;
                msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
                // msg_send_data_size_S4 = `MSG_DATA_SIZE_16B;
                msg_send_cache_type_S4 = cache_type_S4_f;
                msg_send_mshrid_S4 = mshrid_S4;
            end
            else
            begin
                // ifill ack
                msg_send_length_S4 = `MSG_LENGTH_WIDTH'd4;
                // msg_send_data_size_S4 = `MSG_DATA_SIZE_32B;
                msg_send_cache_type_S4 = cache_type_S4_f;
                msg_send_mshrid_S4 = mshrid_S4;
                if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_0)
                begin
                    msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H2D;
                end
                else
                begin
                    msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H2D;
                end
            end

        end
        `MSG_TYPE_LOAD_MEM:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_3H0D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
`ifdef PITON_ASIC_RTL
            msg_send_data_size_S4 = `MSG_DATA_SIZE_64B;
`else
            msg_send_data_size_S4 = data_size_S4_f;
`endif
            msg_send_cache_type_S4 = `MSG_CACHE_TYPE_DATA;
            msg_send_mshrid_S4 = mshr_wr_index_in_S4;
        end
        `MSG_TYPE_NC_LOAD_REQ:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_3H0D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd2;
`ifdef PITON_ASIC_RTL
            msg_send_data_size_S4 = `MSG_DATA_SIZE_16B;
`else
            msg_send_data_size_S4 = data_size_S4_f;
`endif

`ifndef NO_RTL_CSM
            if (smc_miss_S4)
            begin
                msg_send_data_size_S4 = `MSG_DATA_SIZE_16B;
            end
`endif
            msg_send_cache_type_S4 = cache_type_S4_f;
            msg_send_mshrid_S4 = mshr_wr_index_in_S4;
        end

        `MSG_TYPE_NC_STORE_REQ:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_3H1D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd3;
            msg_send_data_size_S4 = data_size_S4_f;
            msg_send_cache_type_S4 = cache_type_S4_f;
            msg_send_mshrid_S4 = mshr_wr_index_in_S4;
        end
        `MSG_TYPE_INTERRUPT:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_1H1D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd1;
            msg_send_data_size_S4 = data_size_S4_f;
            msg_send_cache_type_S4 = cache_type_S4_f;
            msg_send_mshrid_S4 = mshrid_S4;
        end

        `MSG_TYPE_STORE_MEM:
        begin
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd10;
`ifdef PITON_ASIC_RTL
            msg_send_data_size_S4 = `MSG_DATA_SIZE_64B;
`else
            msg_send_data_size_S4 = data_size_S4_f;
`endif
            msg_send_cache_type_S4 = `MSG_CACHE_TYPE_DATA;
            msg_send_mshrid_S4 = mshr_wr_index_in_S4;
            if (l2_load_data_subline_S4_f == `L2_DATA_SUBLINE_0)
            begin
                msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_3H2D;
            end
            else
            begin
                msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H2D;
            end
        end
        default:
        begin
            msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H0D;
            msg_send_length_S4 = `MSG_LENGTH_WIDTH'd0;
            msg_send_data_size_S4 = `MSG_DATA_SIZE_0B;
            msg_send_cache_type_S4 = `MSG_CACHE_TYPE_DATA;
            msg_send_mshrid_S4 = mshrid_S4;
        end
        endcase
    end
    else
    begin
        msg_send_mode_S4 = `L2_P1_BUF_OUT_MODE_0H0D;
        msg_send_length_S4 = `MSG_LENGTH_WIDTH'd0;
        msg_send_data_size_S4 = `MSG_DATA_SIZE_0B;
        msg_send_cache_type_S4 = `MSG_CACHE_TYPE_DATA;
        msg_send_mshrid_S4 = mshrid_S4;
    end
end

always @ *
begin
    msg_send_l2_miss_S4 = l2_miss_S4_f;
end

always @ *
begin
    if ((msg_send_type_S4 == `MSG_TYPE_INTERRUPT)
    || special_addr_type_S4_f
    || ((msg_type_S4_f == `MSG_TYPE_NC_STORE_REQ) && !l2_tag_hit_S4))
    begin
        msg_send_subline_vector_S4 = {`L2_SUBLINE_BITS{1'b0}};
    end
    else if (msg_send_type_S4 == `MSG_TYPE_INV_FWD)
    begin
        msg_send_subline_vector_S4 = {`L2_SUBLINE_BITS{1'b1}};
    end
    else
    begin
        msg_send_subline_vector_S4 = l2_way_state_subline_S4;
    end
end


always @ *
begin
    if ((msg_type_S4_f == `MSG_TYPE_STORE_REQ || msg_type_S4_f == `MSG_TYPE_LR_REQ) && msg_send_type_S4 == `MSG_TYPE_DATA_ACK)
    begin
        msg_send_mesi_S4 = `MSG_MESI_M;
    end
    else if ((msg_send_type_S4 == `MSG_TYPE_INTERRUPT)
    || special_addr_type_S4_f
    || ((msg_type_S4_f == `MSG_TYPE_NC_STORE_REQ) && !l2_tag_hit_S4))
    begin
        msg_send_mesi_S4 = `MSG_MESI_I;
    end
    else
    begin
        if (state_mesi_S4_f == `L2_MESI_B)
        begin
            msg_send_mesi_S4 = `L2_MESI_S;
        end
        else
        begin
            msg_send_mesi_S4 = state_mesi_S4_f;
        end
    end
end

always @ *
begin
    l2_access_valid_S4 = valid_S4 && !stall_S4 && msg_send_valid_S4
                     && (msg_send_type_S4 == `MSG_TYPE_DATA_ACK || msg_send_type_S4 == `MSG_TYPE_NODATA_ACK);
end


always @ *
begin
    l2_miss_valid_S4 = l2_access_valid_S4 && msg_send_l2_miss_S4;
end


always @ *
begin
    msg_stall_S4 = msg0_send_valid_S4 && msg1_send_valid_S4
               && (msg_state_S4_f == msg_state_0);
end


reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_buf_S4_f;
reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_buf_S4_next;
reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_trans_S4;

always @ *
begin
    if (stall_before_S4_f)
    begin
        dir_data_sel_S4 = dir_data_buf_S4_f;
    end
    else
    begin
        `ifndef NO_RTL_CSM
        if(mshr_smc_miss_S4_f)
        begin
            //continue invalidation in the middle of the sharer list
            dir_data_sel_S4 = (dir_data_S4 >> mshr_miss_lsid_S4) << mshr_miss_lsid_S4;
        end
        else
        `endif
        begin
            dir_data_sel_S4 = dir_data_S4;
        end
    end
end

`ifndef NO_RTL_CSM
always @ *
begin
    if (!rst_n)
    begin
        dir_data_buf_S4_next = {`L2_DIR_ARRAY_WIDTH{1'b0}};
    end
    else if ((stall_S4 && !stall_before_S4_f) && (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD) && (l2_way_state_mesi_S4 != `L2_MESI_B))
    begin
        if (msg_stall_S4 || smc_stall_S4 || (msg_send_valid_S4 && !msg_send_ready_S4)
         || global_stall_S4 || stall_inv_counter_S4 )
        begin
            if(mshr_smc_miss_S4_f)
            begin
                dir_data_buf_S4_next = (dir_data_S4 >> mshr_miss_lsid_S4) << mshr_miss_lsid_S4;
            end
            else
            begin
                dir_data_buf_S4_next = dir_data_S4;
            end
        end
        else
        begin
            dir_data_buf_S4_next = dir_data_trans_S4;
        end
    end
    else if (!((msg_send_valid_S4 && !msg_send_ready_S4) || global_stall_S4 || smc_stall_S4 || broadcast_stall_S4
             || stall_inv_counter_S4) && dir_data_stall_S4)
    begin
        dir_data_buf_S4_next = dir_data_trans_S4;
    end
    else
    begin
        dir_data_buf_S4_next = dir_data_buf_S4_f;
    end
end
`else
always @ *
begin
    if (!rst_n)
    begin
        dir_data_buf_S4_next = {`L2_DIR_ARRAY_WIDTH{1'b0}};
    end
    else if ((stall_S4 && !stall_before_S4_f) && (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD))
    begin
        if (msg_stall_S4 || (msg_send_valid_S4 && !msg_send_ready_S4)
         || global_stall_S4 || stall_inv_counter_S4 )
        begin
            dir_data_buf_S4_next = dir_data_S4;
        end
        else
        begin
            dir_data_buf_S4_next = dir_data_trans_S4;
        end
    end
    else if (!((msg_send_valid_S4 && !msg_send_ready_S4) || global_stall_S4
             || stall_inv_counter_S4) && dir_data_stall_S4)
    begin
        dir_data_buf_S4_next = dir_data_trans_S4;
    end
    else
    begin
        dir_data_buf_S4_next = dir_data_buf_S4_f;
    end
end
`endif

always @ (posedge clk)
begin
    dir_data_buf_S4_f <= dir_data_buf_S4_next;
end

wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_sharer_mask_S4;
wire nonzero_sharer_S4;


l2_priority_encoder_2 priority_encoder_2bits( 

    .data_in        (dir_data_sel_S4),
    .data_out       (dir_sharer_S4),
    .data_out_mask  (dir_sharer_mask_S4),
    .nonzero_out    (nonzero_sharer_S4)
);

/*
always @ *
begin
    dir_sharer_mask_S4 = {`L2_DIR_ARRAY_WIDTH{1'b1}};
    dir_sharer_mask_S4[dir_sharer_S4] = 1'b0;
end
*/
//decode sharers from the sharer list with priority decoder
/*
always @ *
begin
    dir_sharer_S4 = {`L2_OWNER_BITS{1'b0}};
    dir_sharer_mask_S4 = {`L2_DIR_ARRAY_WIDTH{1'b0}};
    if (dir_data_sel_S4[0])
    begin
        dir_sharer_S4 = 2'd0;
        dir_sharer_mask_S4 = 4'b0001;
    end
    else if (dir_data_sel_S4[1])
    begin
        dir_sharer_S4 = 2'd1;
        dir_sharer_mask_S4 = 4'b0010;
    end
    else if (dir_data_sel_S4[2])
    begin
        dir_sharer_S4 = 2'd2;
        dir_sharer_mask_S4 = 4'b0100;
    end
    else if (dir_data_sel_S4[3])
    begin
        dir_sharer_S4 = 2'd3;
        dir_sharer_mask_S4 = 4'b1000;
    end

end
*/


reg [`L2_OWNER_BITS-1:0] dir_sharer_counter_S4_f;
reg [`L2_OWNER_BITS-1:0] dir_sharer_counter_S4_next;

always @ *
begin
    if (!rst_n)
    begin
        dir_sharer_counter_S4_next = 1;
    end
    else if (msg_send_valid_S4 && msg_send_ready_S4 && (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD))
    begin
        if (dir_data_stall_S4)
        begin
            dir_sharer_counter_S4_next = dir_sharer_counter_S4_f + 1;
        end
        else
        begin
            dir_sharer_counter_S4_next = 1;
        end
    end
    else
    begin
        dir_sharer_counter_S4_next = dir_sharer_counter_S4_f;
    end
end


always @ (posedge clk)
begin
    dir_sharer_counter_S4_f <= dir_sharer_counter_S4_next;
end


always @ *
begin
    dir_sharer_counter_S4 = dir_sharer_counter_S4_f;
end

always @ *
begin
    dir_data_trans_S4 = dir_data_sel_S4 & (dir_sharer_mask_S4);
end

`ifndef NO_RTL_CSM
localparam broadcast_state_0 = 1'b0;
localparam broadcast_state_1 = 1'b1;

reg broadcast_state_S4_f;
reg broadcast_state_S4_next;

always @ *
begin
    if (!rst_n)
    begin
        broadcast_state_S4_next = broadcast_state_0;
    end
    else if (valid_S4 && (~stall_S4))
    begin
        broadcast_state_S4_next = broadcast_state_0;
    end
    else if (valid_S4 && (l2_way_state_mesi_S4 == `L2_MESI_B) && (msg_send_type_S4 == `MSG_TYPE_INV_FWD)
         && (~(msg_stall_S4 || smc_stall_S4 || (msg_send_valid_S4 && !msg_send_ready_S4)
         || global_stall_S4 || stall_inv_counter_S4 || broadcast_stall_S4)))
    begin
        if (broadcast_state_S4_f == broadcast_state_0)
        begin
            broadcast_state_S4_next = broadcast_state_1;
        end
        else
        begin
            broadcast_state_S4_next = broadcast_state_S4_f;
        end
    end
    else
    begin
        broadcast_state_S4_next = broadcast_state_S4_f;
    end
end

always @ (posedge clk)
begin
    broadcast_state_S4_f <= broadcast_state_S4_next;
end


always @ *
begin
    broadcast_stall_S4 = (l2_way_state_mesi_S4 == `L2_MESI_B) && (msg_send_type_S4 == `MSG_TYPE_INV_FWD)
                      && (broadcast_state_S4_f == broadcast_state_0) && (~broadcast_counter_avail_S4)
                      && (~(msg_from_mshr_S4_f && mshr_smc_miss_S4_f));
end



always @ *
begin
    broadcast_counter_op_val_S4 = valid_S4 && (~stall_smc_buf_S4) && (~smc_stall_S4) && (l2_way_state_mesi_S4 == `L2_MESI_B)
    && (msg_send_type_S4 == `MSG_TYPE_INV_FWD) && (~((broadcast_state_S4_f == broadcast_state_1) && broadcast_counter_zero_S4));
end


always @ *
begin
    if (broadcast_counter_op_val_S4)
    begin
        broadcast_counter_op_S4 = `OP_ADD;
    end
    else
    begin
        broadcast_counter_op_S4 = `OP_CLR;
    end
end
`endif


`ifndef NO_RTL_CSM
always @ *
begin
    if (l2_way_state_mesi_S4 == `L2_MESI_B)
    begin
        dir_data_stall_S4 = (msg_send_type_S4 == `MSG_TYPE_INV_FWD) && (~broadcast_counter_max_S4);
    end
    else
    begin
        dir_data_stall_S4 = (msg_send_type_S4 == `MSG_TYPE_INV_FWD) && (| dir_data_trans_S4[`L2_DIR_ARRAY_WIDTH-1:0]);
    end
end
`else
always @ *
begin
    dir_data_stall_S4 = (msg_send_type_S4 == `MSG_TYPE_INV_FWD) && (| dir_data_trans_S4[`L2_DIR_ARRAY_WIDTH-1:0]);
end
`endif



always @ *
begin
    state_wr_en_real_S4 = valid_S4 && !dir_data_stall_S4 &&  msg_send_valid_S4 && (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD);
end

//write to the state array if either the enable signal of S3 or the one from S2 is true
always @ *
begin
    if (load_store_mem_S4)
    begin
        state_wr_en_S4 = msg_send_valid_S4 && (msg_send_type_S4 == msg0_send_type_S4) && msg_send_ready_S4 && ~(req_recycle_S4 && ~special_addr_type_S4_f);
    end
    else
    begin
        state_wr_en_S4 = !stall_S4 && (state_wr_en_real_S4 || state_wr_en_S4_f) && ~(req_recycle_S4 && ~special_addr_type_S4_f);
    end
end


`ifndef NO_RTL_CSM
always @ *
begin
    smc_rd_en_S4 = valid_S4 &&
                ((special_addr_type_S4_f
                && (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_SMC_ACCESS)
                && (msg_type_S4 == `MSG_TYPE_NC_LOAD_REQ))
                || (csm_en
//To break timing loop
//&& msg_send_valid_S4
//&& cs_S4[`CS_MSG_SEND_FWD_S4]);
                && (((msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD) && (l2_way_state_mesi_S4 != `L2_MESI_B)))));
           //     || ((msg_send_type_pre_S4 == `MSG_TYPE_LOAD_FWD || msg_send_type_pre_S4 == `MSG_TYPE_STORE_FWD)
           //        && (l2_way_state_owner_S4 != `L2_PUBLIC_SHARER))));
end

always @ *
begin
    smc_rd_diag_en_S4 =
                (special_addr_type_S4_f
                && (addr_S4[`L2_ADDR_TYPE] == `L2_ADDR_TYPE_SMC_ACCESS)
                && (msg_type_S4 == `MSG_TYPE_NC_LOAD_REQ));
end

always @ *
begin
    smc_miss_S4 = smc_rd_en_S4  && ~smc_rd_diag_en_S4 && (~smc_hit_S4);
end
`endif

always @ *
begin
    if (msg_type_S4_f == `MSG_TYPE_CAS_P1_REQ && (msg_send_valid_S4 && msg_send_type_S4 == `MSG_TYPE_DATA_ACK)
    && valid_S4 && !stall_S4)
    begin
        cas_cmp_en_S4 = y;
    end
    else
    begin
        cas_cmp_en_S4 = n;
    end
end

always @ *
begin
    if ((msg_type_S4_f == `MSG_TYPE_CAS_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_SWAP_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_SWAPWB_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_ADD_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_AND_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_OR_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_XOR_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_MAX_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_MAXU_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_MIN_P1_REQ
        || msg_type_S4_f == `MSG_TYPE_AMO_MINU_P1_REQ)
    && (msg_send_valid_S4 && msg_send_type_S4 == `MSG_TYPE_DATA_ACK)
    && valid_S4 && !stall_S4)
    begin
        atomic_read_data_en_S4 = y;
    end
    else
    begin
        atomic_read_data_en_S4 = n;
    end
end


always @ *
begin
    cas_cmp_data_size_S4 = data_size_S4_f;
end

always @ *
begin
    reg_rd_en_S4 = valid_S4  && (msg_type_S4 == `MSG_TYPE_NC_LOAD_REQ)
               && ((addr_type_S4 == `L2_ADDR_TYPE_CTRL_REG)
                || (addr_type_S4 == `L2_ADDR_TYPE_COREID_REG)
                || (addr_type_S4 == `L2_ADDR_TYPE_ERROR_STATUS_REG)
                || (addr_type_S4 == `L2_ADDR_TYPE_ACCESS_COUNTER)
                || (addr_type_S4 == `L2_ADDR_TYPE_MISS_COUNTER));
end

always @ *
begin
    reg_rd_addr_type_S4 = addr_type_S4;
end

always @ *
begin
    if (state_wr_en_real_S4)
    begin
        state_wr_sel_S4 = 1'b1;
    end
    else
    begin
        state_wr_sel_S4 = 1'b0;
    end
end

always @ *
begin
    `ifndef NO_RTL_CSM
    if (mshr_smc_miss_S4_f)
    begin
        mshr_wr_index_in_S4 = mshr_pending_index_S4_f;
    end
    else
    `endif
    begin
        mshr_wr_index_in_S4 = mshr_empty_index_sel_S4;
    end
end

always @ *
begin
    mshr_inv_counter_rd_index_in_S4 = mshr_wr_index_in_S4;
end

//wait for inv_fwdack to write to mshr in pipeline2
always @ *
begin
    stall_inv_counter_S4 = valid_S4 && ((global_stall_S1 && (pipe2_msg_type_S1 == `MSG_TYPE_INV_FWDACK))
                                     || (global_stall_S2 && (pipe2_msg_type_S2 == `MSG_TYPE_INV_FWDACK)))
                       && (msg_send_type_pre_S4 == `MSG_TYPE_INV_FWD);
                   //    && ~(dir_data_stall_S4|| msg_stall_S4 || global_stall_S4);
end


`ifndef NO_RTL_CSM
always @ *
begin
    stall_smc_buf_S4 = valid_S4 && (global_stall_S4
           || (msg_send_valid_S4 && !msg_send_ready_S4)
           || broadcast_stall_S4
           || stall_inv_counter_S4);
end


always @ *
begin
    stall_S4 = valid_S4 && (global_stall_S4 || msg_stall_S4 || dir_data_stall_S4
           || (msg_send_valid_S4 && !msg_send_ready_S4)
           || stall_inv_counter_S4
           || broadcast_stall_S4
           || smc_stall_S4);
end
`else

always @ *
begin
    stall_S4 = valid_S4 && (global_stall_S4 || msg_stall_S4 || dir_data_stall_S4
           || (msg_send_valid_S4 && !msg_send_ready_S4)
           || stall_inv_counter_S4
           );
end

`endif
endmodule
