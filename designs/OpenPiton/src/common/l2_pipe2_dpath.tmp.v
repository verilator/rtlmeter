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
//  Filename      : l2_pipe2_dpath.v
//  Created On    : 2014-04-03
//  Revision      :
//  Author        : Yaosheng Fu
//  Company       : Princeton University
//  Email         : yfu@princeton.edu
//
//  Description   : The datapath for pipeline2 in the L2 cache
//
//
//==================================================================================================


`include "l2.tmp.h"
`include "define.tmp.h"

// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml


module l2_pipe2_dpath(

    input wire clk,
    input wire rst_n,

    //Inputs to Stage 1   

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


    input wire [`PHY_ADDR_WIDTH-1:0] msg_addr_S1,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type_S1,
    input wire [`MSG_SUBLINE_ID_WIDTH-1:0] msg_subline_id_S1,
    input wire [`MSG_MSHRID_WIDTH-1:0] msg_mshrid_S1,
    input wire [`MSG_SRC_CHIPID_WIDTH-1:0] msg_src_chipid_S1,
    input wire [`MSG_SRC_X_WIDTH-1:0] msg_src_x_S1,
    input wire [`MSG_SRC_Y_WIDTH-1:0] msg_src_y_S1,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0] msg_src_fbits_S1,
    input wire [`MSG_SDID_WIDTH-1:0] msg_sdid_S1,
    input wire [`MSG_LSID_WIDTH-1:0] msg_lsid_S1,

    input wire valid_S1,
    input wire stall_S1,
    input wire msg_from_mshr_S1, 
    
    //Inputs to Stage 2   

    input wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_S2,
    input wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_S2,

    input wire [`L2_P2_DATA_BUF_IN_WIDTH-1:0] msg_data_S2,

    input wire msg_from_mshr_S2,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type_S2,
   
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2,
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
    input wire dir_clr_en_S2,
   
    input wire l2_load_64B_S2, 
    input wire l2_load_32B_S2, 
    input wire [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2,
 
    input wire valid_S2,
    input wire stall_S2,
    input wire stall_before_S2,

    //Inputs to Stage 3 
    input wire valid_S3,
    input wire stall_S3,
    
    //Outputs from Stage 1
    
    output reg [`PHY_ADDR_WIDTH-1:0] addr_S1,
    output reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_rd_index_S1,
    output reg [`L2_TAG_INDEX_WIDTH-1:0] tag_addr_S1,
    output reg [`L2_TAG_INDEX_WIDTH-1:0] state_rd_addr_S1,
    
    output reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_in_S1,
    output reg [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_mask_in_S1,
    output reg is_same_address_S1,

    //Outputs from Stage 2
   
 
    output reg [`PHY_ADDR_WIDTH-1:0] addr_S2,
    output reg l2_tag_hit_S2,
    output reg [`L2_WAYS_WIDTH-1:0] l2_way_sel_S2,
    output reg l2_wb_S2,
    output reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S2,
    output reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S2,
    output reg [`L2_VD_BITS-1:0] l2_way_state_vd_S2,
    output reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S2,
    output reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S2,
    output reg addr_l2_aligned_S2,
    output reg subline_valid_S2, 
    output reg [`MSG_LSID_WIDTH-1:0] lsid_S2,

    output reg [`L2_DIR_INDEX_WIDTH-1:0] dir_addr_S2,
    output reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_in_S2,
    output wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_mask_in_S2,

    output reg [`L2_DATA_INDEX_WIDTH-1:0] data_addr_S2,
    output reg [`L2_DATA_ARRAY_WIDTH-1:0] data_data_in_S2,
    output wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_mask_in_S2,

    `ifndef NO_RTL_CSM
    output reg [`L2_SMC_ADDR_WIDTH-1:0] smc_wr_addr_in_S2,
    output reg [`L2_SMC_DATA_IN_WIDTH-1:0] smc_data_in_S2,
    `endif

    //Outputs from Stage 3
    output reg [`PHY_ADDR_WIDTH-1:0] addr_S3,
    output reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_wr_index_S3,
    output wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_in_S3,
    output wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_mask_in_S3,
    output reg [`L2_STATE_INDEX_WIDTH-1:0] state_wr_addr_S3,
    output reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S3,
    output reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S3

);


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

always @ *
begin
    if (msg_from_mshr_S1)
    begin
`ifdef L2_SEND_NC_REQ
        addr_S1 = (msg_type_S1 == `MSG_TYPE_NC_LOAD_MEM_ACK) ? mshr_addr_S1 :
            {mshr_addr_S1[`L2_TAG], mshr_addr_S1[`L2_TAG_INDEX], msg_subline_id_S1, mshr_addr_S1[`L2_DATA_OFFSET]};
`else
        addr_S1 = {mshr_addr_S1[`L2_TAG], mshr_addr_S1[`L2_TAG_INDEX],
                         msg_subline_id_S1, mshr_addr_S1[`L2_DATA_OFFSET]};
`endif // L2_SEND_NC_REQ
        src_chipid_S1 = mshr_src_chipid_S1;
        src_x_S1 = mshr_src_x_S1;   
        src_y_S1 = mshr_src_y_S1;   
        src_fbits_S1 = mshr_src_fbits_S1;
        sdid_S1 = mshr_sdid_S1;
        lsid_S1 = mshr_lsid_S1;
    end
    else
    begin
        addr_S1 = msg_addr_S1;
        src_chipid_S1 = msg_src_chipid_S1;
        src_x_S1 = msg_src_x_S1;   
        src_y_S1 = msg_src_y_S1;   
        src_fbits_S1 = msg_src_fbits_S1;
        sdid_S1 = msg_sdid_S1;
        lsid_S1 = msg_lsid_S1;
    end
end

always @ *
begin
    is_same_address_S1 = (mshr_addr_S1 == msg_addr_S1);
end

always @ *
begin
    mshrid_S1 = msg_mshrid_S1;
end


always @ *
begin
    mshr_rd_index_S1 = msg_mshrid_S1;
end


always @ *
begin
    tag_addr_S1 = addr_S1[`L2_TAG_INDEX];
end

always @ *
begin
    state_rd_addr_S1 = addr_S1[`L2_TAG_INDEX];
end


always @ *
begin
    tag_data_in_S1 = {`L2_WAYS{addr_S1[`L2_TAG]}};
end

always @ *
begin
    tag_data_mask_in_S1 = {{(`L2_WAYS-1)*`L2_TAG_WAY_WIDTH{1'b0}},{`L2_TAG_WAY_WIDTH{1'b1}}} 
                       << (mshr_way_S1 * `L2_TAG_WAY_WIDTH);
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
reg [`L2_WAYS_WIDTH-1:0] mshr_way_S2_f;
reg [`MSG_SUBLINE_ID_WIDTH-1:0] msg_subline_id_S2_f;
reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S2_f;

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
        mshr_way_S2_f <= 0;
        msg_subline_id_S2_f <= 0;
        mshr_miss_lsid_S2_f <= 0;
    end
    else if (!stall_S2)
    begin
        addr_S2_f <= addr_S1;
        mshrid_S2_f <= mshrid_S1;
        src_chipid_S2_f <= src_chipid_S1;
        src_x_S2_f <= src_x_S1;
        src_y_S2_f <= src_y_S1;
        src_fbits_S2_f <= src_fbits_S1;
        sdid_S2_f <= sdid_S1;
        lsid_S2_f <= lsid_S1;
        mshr_way_S2_f <= mshr_way_S1;
        msg_subline_id_S2_f <= msg_subline_id_S1;
        mshr_miss_lsid_S2_f <= mshr_miss_lsid_S1;
    end
end


//============================
// Stage 2
//============================


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

reg [`L2_TAG_ARRAY_WIDTH-1:0] state_data_buf_S2_f;
reg [`L2_TAG_ARRAY_WIDTH-1:0] state_data_buf_S2_next;
reg [`L2_TAG_ARRAY_WIDTH-1:0] state_data_trans_S2;

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


reg [`L2_WAYS_WIDTH-1:0] l2_hit_way_sel_S2;
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



always @ *
begin
    if (msg_from_mshr_S2)
    begin
        l2_tag_hit_S2 = tag_hit_way_S2[mshr_way_S2_f];
    end
    else
        l2_tag_hit_S2 = tag_hit_way_S2[0] || tag_hit_way_S2[1] || tag_hit_way_S2[2] || tag_hit_way_S2[3];

end

always @ *
begin
    l2_hit_way_sel_S2 = {`L2_WAYS_WIDTH{1'bx}};
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


always @ *
begin
    if(valid_S2)
    begin
        if (msg_from_mshr_S2)
        begin
            l2_way_sel_S2 = mshr_way_S2_f;
        end
        else
        begin
            l2_way_sel_S2 = l2_hit_way_sel_S2;
        end
    end
    else
    begin
        l2_way_sel_S2 = 0;
    end
end


always @ *
begin
    if (!l2_tag_hit_S2 && (state_way_S2[l2_way_sel_S2][`L2_STATE_VD] == `L2_VD_DIRTY))
    begin
        l2_wb_S2 = 1'b1;
    end
    else
    begin
        l2_wb_S2 = 1'b0;
    end
end



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
    dir_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2}; 
end

always @ *
begin
    if (l2_load_64B_S2)
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2, l2_load_data_subline_S2};
    end
`ifdef L2_SEND_NC_REQ
    else if (l2_load_32B_S2)
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2, 
                        addr_S2_f[`L2_INS_SUBLINE], l2_load_data_subline_S2[0]};
    end
`endif
    else
    begin
        data_addr_S2 = {addr_S2_f[`L2_TAG_INDEX],l2_way_sel_S2, addr_S2_f[`L2_DATA_SUBLINE]};
    end
end



always @ *
begin
    addr_l2_aligned_S2 = (addr_S2_f[`L2_TAG_OFFSET] == {`L2_OFFSET_WIDTH{1'b0}}); 
end

/*
always @ *
begin
    dir_data_mask_in_S2 = {`L2_DIR_ARRAY_WIDTH{1'b1}}; 
end
*/
assign dir_data_mask_in_S2 = {`L2_DIR_ARRAY_WIDTH{1'b1}};

//TODO
always @ *
begin
    if (dir_clr_en_S2)
    begin
        dir_data_in_S2 = {(`L2_DIR_ARRAY_WIDTH){1'b0}}; 
    end
    else
    begin
        dir_data_in_S2 = {{(`L2_DIR_ARRAY_WIDTH-1){1'b0}},1'b1} << l2_way_state_owner_S2; 
    end
end


wire [`L2_DATA_ECC_PARITY_WIDTH-1:0] msg_data_parity1_S2;
wire [`L2_DATA_ECC_PARITY_WIDTH-1:0] msg_data_parity2_S2;

l2_data_pgen data_pgen1( 
    .din            (msg_data_S2[`L2_DATA_ECC_DATA_WIDTH-1:0]),
    .parity         (msg_data_parity1_S2)
);

l2_data_pgen data_pgen2( 
    .din            (msg_data_S2[`L2_DATA_DATA_WIDTH-1:`L2_DATA_ECC_DATA_WIDTH]),
    .parity         (msg_data_parity2_S2)
);


always @ *
begin
    data_data_in_S2 = {msg_data_parity2_S2, msg_data_S2[127:64], msg_data_parity1_S2, msg_data_S2[63:0]}; 
end

assign data_data_mask_in_S2 = {`L2_DATA_ARRAY_WIDTH{1'b1}}; 


reg [`L2_OWNER_BITS-1:0] state_owner_S2;
reg [`L2_SUBLINE_BITS-1:0] state_subline_S2;
reg [`L2_RB_BITS-1:0] state_rb_S2;
reg [`L2_LRU_BITS-1:0] state_lru_S2;


always @ *
begin
    state_owner_S2 = l2_way_state_owner_S2; 
    if (state_owner_op_S2 == `OP_LD)
    begin
        state_owner_S2 = sdid_S2_f[`L2_STATE_OWNER]; 
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
        //addr_subline_S2= {2'b11, {(`L2_SUBLINE_BITS-2){1'b0}}} >> (2*addr_S2_f[`L2_INS_SUBLINE]);
        addr_subline_S2= {{(`L2_SUBLINE_BITS-2){1'b0}},2'b11} << (2*addr_S2_f[`L2_INS_SUBLINE]);
    end
end


always @ *
begin
    if (state_subline_op_S2 == `OP_LD)
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
    subline_valid_S2 = l2_way_state_subline_S2[msg_subline_id_S2_f]; 
end



always @ *
begin
    state_data_in_S2 = {state_rb_S2, state_lru_S2, 
    {`L2_WAYS{state_mesi_S2, state_vd_S2, cache_type_S2, state_subline_S2, state_owner_S2}}};
end

reg [`L2_WAYS*`L2_STATE_WAY_WIDTH-1:0] state_way_data_mask_in_S2;


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
    state_data_mask_in_S2 = {{`L2_RB_BITS{state_rb_en_S2}}, 
                             {`L2_LRU_BITS{state_lru_en_S2}},
                              state_way_data_mask_in_S2}; 
end

`ifndef NO_RTL_CSM
always @ *
begin
    smc_wr_addr_in_S2 = {sdid_S2_f, mshr_miss_lsid_S2_f}; 
end

always @ *
begin
    smc_data_in_S2 = msg_data_S2; 
end
`endif


//============================
// Stage 2 -> Stage 3
//============================


reg [`PHY_ADDR_WIDTH-1:0] addr_S3_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_S3_f;
reg [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_S3_f;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S3_f;
reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S3_f;

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        addr_S3_f <= 0; 
        state_data_in_S3_f <= 0;
        state_data_mask_in_S3_f <= 0;
        mshrid_S3_f <= 0;
        mshr_miss_lsid_S3_f <= 0;
    end
    else if (!stall_S3)
    begin
        addr_S3_f <= addr_S2_f;
        state_data_in_S3_f <= state_data_in_S2;
        state_data_mask_in_S3_f <= state_data_mask_in_S2;
        mshrid_S3_f <= mshrid_S2_f;
        mshr_miss_lsid_S3_f <= mshr_miss_lsid_S2_f;
    end
end


//============================
// Stage 3
//============================

always @ *
begin
    state_data_in_S3 = state_data_in_S3_f;
    state_data_mask_in_S3 = state_data_mask_in_S3_f;
    addr_S3 = addr_S3_f;
end


always @ *
begin
    state_wr_addr_S3 = addr_S3_f[`L2_TAG_INDEX]; 
end

always @ *
begin
    mshr_wr_index_S3 = mshrid_S3_f; 
end

assign mshr_data_in_S3 = {`L2_MSHR_ARRAY_WIDTH{1'b0}}; 
assign mshr_data_mask_in_S3 = {1'b1, {(`L2_MSHR_ARRAY_WIDTH-1){1'b0}}}; 

/*
//============================
// Debug
//============================

`ifndef SYNTHESIS
    

always @ (posedge clk)
begin
    if (valid_S1 && !stall_S1)
    begin
        $display("-------------------------------------");
        $display($time);
        $display("P2S1 addr: 0x%h", addr_S1);
        $display("Mshr_rd_index: %b", mshr_rd_index_S1);
        $display("Tag_addr: 0x%h", tag_addr_S1,);
        $display("Tag_data_in: 0x%h", tag_data_in_S1,);
        $display("Tag_data_mask_in: 0x%h", tag_data_mask_in_S1,);
        $display("State_rd_addr: 0x%h",state_rd_addr_S1);
        $display("Msg from mshr: %b", msg_from_mshr_S1);
    end
end


always @ (posedge clk)
begin
    if (valid_S2 && !stall_S2)
    begin
        $display("-------------------------------------");
        $display($time);
        $display("P2S2 addr: 0x%h", addr_S2);
        $display("P2S2 valid: l2_way_sel: %b, l2_hit: %b, l2_wb: %b",
                  l2_way_sel_S2, l2_tag_hit_S2, l2_wb_S2);
        $display("state: mesi: %b, vd: %b, subline: %b, cache_type: %b, owner: %b",
                 l2_way_state_mesi_S2, l2_way_state_vd_S2, l2_way_state_subline_S2, l2_way_state_cache_type_S2, l2_way_state_owner_S2);
        $display("Msg from mshr: %b", msg_from_mshr_S2);
        $display("Mshr wr index: %b", mshr_wr_index_S2);
        $display("Dir addr: 0x%h", dir_addr_S2);
        $display("Dir data: 0x%h", dir_data_in_S2);
        $display("Dir data mask: 0x%h", dir_data_mask_in_S2);
        $display("Data addr: 0x%h", data_addr_S2);
        $display("Data data: 0x%h", data_data_in_S2);
        $display("Data data mask: 0x%h", data_data_mask_in_S2);
        $display("State wr addr: 0x%h", state_wr_addr_S2);
        $display("State data: 0x%h", state_data_in_S2);
        $display("State data mask: 0x%h", state_data_mask_in_S2);
    end
end





`endif
*/
endmodule
