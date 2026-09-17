// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: pc_cmp.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
//
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// The above named program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
//
// ========== Copyright Header End ============================================

`include "define.tmp.h"
`include "ifu.tmp.h"

// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml
`define GOOD_TRAP_COUNTER 1


 module pc_cmp(/*AUTOARG*/
     // Inputs
     clk,
     rst_l
 );
input clk;
input rst_l;

// trap register

reg [63:0]   active_thread;
reg [4:0]    thread_status[63:0];

reg [15:0]   good = '0;
reg [15:0]   done;

reg [31:0]     timeout [63:0];


reg [63:0]    good_trap[`GOOD_TRAP_COUNTER-1:0];
reg [63:0]    bad_trap [`GOOD_TRAP_COUNTER-1:0];

reg [`GOOD_TRAP_COUNTER-1:0] good_trap_exists;
reg [`GOOD_TRAP_COUNTER-1:0] bad_trap_exists;

reg           dum;
reg           hit_bad = 0;

integer       time_tmp, trap_count;


    reg spc0_inst_done;
    wire [1:0]   spc0_thread_id;
    wire [63:0]      spc0_rtl_pc;
    wire sas_m0;
    reg [63:0] spc0_phy_pc_w;

    

    reg spc1_inst_done;
    wire [1:0]   spc1_thread_id;
    wire [63:0]      spc1_rtl_pc;
    wire sas_m1;
    reg [63:0] spc1_phy_pc_w;

    

    reg spc2_inst_done;
    wire [1:0]   spc2_thread_id;
    wire [63:0]      spc2_rtl_pc;
    wire sas_m2;
    reg [63:0] spc2_phy_pc_w;

    

    reg spc3_inst_done;
    wire [1:0]   spc3_thread_id;
    wire [63:0]      spc3_rtl_pc;
    wire sas_m3;
    reg [63:0] spc3_phy_pc_w;

    

    reg spc4_inst_done;
    wire [1:0]   spc4_thread_id;
    wire [63:0]      spc4_rtl_pc;
    wire sas_m4;
    reg [63:0] spc4_phy_pc_w;

    

    reg spc5_inst_done;
    wire [1:0]   spc5_thread_id;
    wire [63:0]      spc5_rtl_pc;
    wire sas_m5;
    reg [63:0] spc5_phy_pc_w;

    

    reg spc6_inst_done;
    wire [1:0]   spc6_thread_id;
    wire [63:0]      spc6_rtl_pc;
    wire sas_m6;
    reg [63:0] spc6_phy_pc_w;

    

    reg spc7_inst_done;
    wire [1:0]   spc7_thread_id;
    wire [63:0]      spc7_rtl_pc;
    wire sas_m7;
    reg [63:0] spc7_phy_pc_w;

    

    reg spc8_inst_done;
    wire [1:0]   spc8_thread_id;
    wire [63:0]      spc8_rtl_pc;
    wire sas_m8;
    reg [63:0] spc8_phy_pc_w;

    

    reg spc9_inst_done;
    wire [1:0]   spc9_thread_id;
    wire [63:0]      spc9_rtl_pc;
    wire sas_m9;
    reg [63:0] spc9_phy_pc_w;

    

    reg spc10_inst_done;
    wire [1:0]   spc10_thread_id;
    wire [63:0]      spc10_rtl_pc;
    wire sas_m10;
    reg [63:0] spc10_phy_pc_w;

    

    reg spc11_inst_done;
    wire [1:0]   spc11_thread_id;
    wire [63:0]      spc11_rtl_pc;
    wire sas_m11;
    reg [63:0] spc11_phy_pc_w;

    

    reg spc12_inst_done;
    wire [1:0]   spc12_thread_id;
    wire [63:0]      spc12_rtl_pc;
    wire sas_m12;
    reg [63:0] spc12_phy_pc_w;

    

    reg spc13_inst_done;
    wire [1:0]   spc13_thread_id;
    wire [63:0]      spc13_rtl_pc;
    wire sas_m13;
    reg [63:0] spc13_phy_pc_w;

    

    reg spc14_inst_done;
    wire [1:0]   spc14_thread_id;
    wire [63:0]      spc14_rtl_pc;
    wire sas_m14;
    reg [63:0] spc14_phy_pc_w;

    

    reg spc15_inst_done;
    wire [1:0]   spc15_thread_id;
    wire [63:0]      spc15_rtl_pc;
    wire sas_m15;
    reg [63:0] spc15_phy_pc_w;

    


integer      good_trap_count;
integer      bad_trap_count;
reg         local_diag_done;

//use this for the second reset.
initial begin
    local_diag_done = 0;

    good_trap_exists = {`GOOD_TRAP_COUNTER{1'b0}};
    bad_trap_exists = {`GOOD_TRAP_COUNTER{1'b0}};
end
//-----------------------------------------------------------

`ifdef INCLUDE_SAS_TASKS
task get_thread_status;
    begin
    thread_status[0] = `IFUPATH0.swl.thr0_state;
thread_status[1] = `IFUPATH0.swl.thr1_state;
thread_status[2] = `IFUPATH0.swl.thr2_state;
thread_status[3] = `IFUPATH0.swl.thr3_state;
thread_status[4] = `IFUPATH1.swl.thr0_state;
thread_status[5] = `IFUPATH1.swl.thr1_state;
thread_status[6] = `IFUPATH1.swl.thr2_state;
thread_status[7] = `IFUPATH1.swl.thr3_state;
thread_status[8] = `IFUPATH2.swl.thr0_state;
thread_status[9] = `IFUPATH2.swl.thr1_state;
thread_status[10] = `IFUPATH2.swl.thr2_state;
thread_status[11] = `IFUPATH2.swl.thr3_state;
thread_status[12] = `IFUPATH3.swl.thr0_state;
thread_status[13] = `IFUPATH3.swl.thr1_state;
thread_status[14] = `IFUPATH3.swl.thr2_state;
thread_status[15] = `IFUPATH3.swl.thr3_state;
thread_status[16] = `IFUPATH4.swl.thr0_state;
thread_status[17] = `IFUPATH4.swl.thr1_state;
thread_status[18] = `IFUPATH4.swl.thr2_state;
thread_status[19] = `IFUPATH4.swl.thr3_state;
thread_status[20] = `IFUPATH5.swl.thr0_state;
thread_status[21] = `IFUPATH5.swl.thr1_state;
thread_status[22] = `IFUPATH5.swl.thr2_state;
thread_status[23] = `IFUPATH5.swl.thr3_state;
thread_status[24] = `IFUPATH6.swl.thr0_state;
thread_status[25] = `IFUPATH6.swl.thr1_state;
thread_status[26] = `IFUPATH6.swl.thr2_state;
thread_status[27] = `IFUPATH6.swl.thr3_state;
thread_status[28] = `IFUPATH7.swl.thr0_state;
thread_status[29] = `IFUPATH7.swl.thr1_state;
thread_status[30] = `IFUPATH7.swl.thr2_state;
thread_status[31] = `IFUPATH7.swl.thr3_state;
thread_status[32] = `IFUPATH8.swl.thr0_state;
thread_status[33] = `IFUPATH8.swl.thr1_state;
thread_status[34] = `IFUPATH8.swl.thr2_state;
thread_status[35] = `IFUPATH8.swl.thr3_state;
thread_status[36] = `IFUPATH9.swl.thr0_state;
thread_status[37] = `IFUPATH9.swl.thr1_state;
thread_status[38] = `IFUPATH9.swl.thr2_state;
thread_status[39] = `IFUPATH9.swl.thr3_state;
thread_status[40] = `IFUPATH10.swl.thr0_state;
thread_status[41] = `IFUPATH10.swl.thr1_state;
thread_status[42] = `IFUPATH10.swl.thr2_state;
thread_status[43] = `IFUPATH10.swl.thr3_state;
thread_status[44] = `IFUPATH11.swl.thr0_state;
thread_status[45] = `IFUPATH11.swl.thr1_state;
thread_status[46] = `IFUPATH11.swl.thr2_state;
thread_status[47] = `IFUPATH11.swl.thr3_state;
thread_status[48] = `IFUPATH12.swl.thr0_state;
thread_status[49] = `IFUPATH12.swl.thr1_state;
thread_status[50] = `IFUPATH12.swl.thr2_state;
thread_status[51] = `IFUPATH12.swl.thr3_state;
thread_status[52] = `IFUPATH13.swl.thr0_state;
thread_status[53] = `IFUPATH13.swl.thr1_state;
thread_status[54] = `IFUPATH13.swl.thr2_state;
thread_status[55] = `IFUPATH13.swl.thr3_state;
thread_status[56] = `IFUPATH14.swl.thr0_state;
thread_status[57] = `IFUPATH14.swl.thr1_state;
thread_status[58] = `IFUPATH14.swl.thr2_state;
thread_status[59] = `IFUPATH14.swl.thr3_state;
thread_status[60] = `IFUPATH15.swl.thr0_state;
thread_status[61] = `IFUPATH15.swl.thr1_state;
thread_status[62] = `IFUPATH15.swl.thr2_state;
thread_status[63] = `IFUPATH15.swl.thr3_state;

    end
endtask // get_thread_status
`endif


            assign spc0_thread_id = 2'b00;
            assign spc0_rtl_pc = spc0_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(0*4)]   <= 1'b0;
                  active_thread[(0*4)+1] <= 1'b0;
                  active_thread[(0*4)+2] <= 1'b0;
                  active_thread[(0*4)+3] <= 1'b0;
                  spc0_inst_done         <= 0;
                  spc0_phy_pc_w          <= 0;
                end else begin
                  active_thread[(0*4)]   <= 1'b1;
                  active_thread[(0*4)+1] <= 1'b1;
                  active_thread[(0*4)+2] <= 1'b1;
                  active_thread[(0*4)+3] <= 1'b1;
                  spc0_inst_done         <= `TILE0.piton_pc_vld;
                  spc0_phy_pc_w          <= `TILE0.piton_pc;
                end
            end
    

            assign spc1_thread_id = 2'b00;
            assign spc1_rtl_pc = spc1_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(1*4)]   <= 1'b0;
                  active_thread[(1*4)+1] <= 1'b0;
                  active_thread[(1*4)+2] <= 1'b0;
                  active_thread[(1*4)+3] <= 1'b0;
                  spc1_inst_done         <= 0;
                  spc1_phy_pc_w          <= 0;
                end else begin
                  active_thread[(1*4)]   <= 1'b1;
                  active_thread[(1*4)+1] <= 1'b1;
                  active_thread[(1*4)+2] <= 1'b1;
                  active_thread[(1*4)+3] <= 1'b1;
                  spc1_inst_done         <= `TILE1.piton_pc_vld;
                  spc1_phy_pc_w          <= `TILE1.piton_pc;
                end
            end
    

            assign spc2_thread_id = 2'b00;
            assign spc2_rtl_pc = spc2_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(2*4)]   <= 1'b0;
                  active_thread[(2*4)+1] <= 1'b0;
                  active_thread[(2*4)+2] <= 1'b0;
                  active_thread[(2*4)+3] <= 1'b0;
                  spc2_inst_done         <= 0;
                  spc2_phy_pc_w          <= 0;
                end else begin
                  active_thread[(2*4)]   <= 1'b1;
                  active_thread[(2*4)+1] <= 1'b1;
                  active_thread[(2*4)+2] <= 1'b1;
                  active_thread[(2*4)+3] <= 1'b1;
                  spc2_inst_done         <= `TILE2.piton_pc_vld;
                  spc2_phy_pc_w          <= `TILE2.piton_pc;
                end
            end
    

            assign spc3_thread_id = 2'b00;
            assign spc3_rtl_pc = spc3_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(3*4)]   <= 1'b0;
                  active_thread[(3*4)+1] <= 1'b0;
                  active_thread[(3*4)+2] <= 1'b0;
                  active_thread[(3*4)+3] <= 1'b0;
                  spc3_inst_done         <= 0;
                  spc3_phy_pc_w          <= 0;
                end else begin
                  active_thread[(3*4)]   <= 1'b1;
                  active_thread[(3*4)+1] <= 1'b1;
                  active_thread[(3*4)+2] <= 1'b1;
                  active_thread[(3*4)+3] <= 1'b1;
                  spc3_inst_done         <= `TILE3.piton_pc_vld;
                  spc3_phy_pc_w          <= `TILE3.piton_pc;
                end
            end
    

            assign spc4_thread_id = 2'b00;
            assign spc4_rtl_pc = spc4_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(4*4)]   <= 1'b0;
                  active_thread[(4*4)+1] <= 1'b0;
                  active_thread[(4*4)+2] <= 1'b0;
                  active_thread[(4*4)+3] <= 1'b0;
                  spc4_inst_done         <= 0;
                  spc4_phy_pc_w          <= 0;
                end else begin
                  active_thread[(4*4)]   <= 1'b1;
                  active_thread[(4*4)+1] <= 1'b1;
                  active_thread[(4*4)+2] <= 1'b1;
                  active_thread[(4*4)+3] <= 1'b1;
                  spc4_inst_done         <= `TILE4.piton_pc_vld;
                  spc4_phy_pc_w          <= `TILE4.piton_pc;
                end
            end
    

            assign spc5_thread_id = 2'b00;
            assign spc5_rtl_pc = spc5_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(5*4)]   <= 1'b0;
                  active_thread[(5*4)+1] <= 1'b0;
                  active_thread[(5*4)+2] <= 1'b0;
                  active_thread[(5*4)+3] <= 1'b0;
                  spc5_inst_done         <= 0;
                  spc5_phy_pc_w          <= 0;
                end else begin
                  active_thread[(5*4)]   <= 1'b1;
                  active_thread[(5*4)+1] <= 1'b1;
                  active_thread[(5*4)+2] <= 1'b1;
                  active_thread[(5*4)+3] <= 1'b1;
                  spc5_inst_done         <= `TILE5.piton_pc_vld;
                  spc5_phy_pc_w          <= `TILE5.piton_pc;
                end
            end
    

            assign spc6_thread_id = 2'b00;
            assign spc6_rtl_pc = spc6_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(6*4)]   <= 1'b0;
                  active_thread[(6*4)+1] <= 1'b0;
                  active_thread[(6*4)+2] <= 1'b0;
                  active_thread[(6*4)+3] <= 1'b0;
                  spc6_inst_done         <= 0;
                  spc6_phy_pc_w          <= 0;
                end else begin
                  active_thread[(6*4)]   <= 1'b1;
                  active_thread[(6*4)+1] <= 1'b1;
                  active_thread[(6*4)+2] <= 1'b1;
                  active_thread[(6*4)+3] <= 1'b1;
                  spc6_inst_done         <= `TILE6.piton_pc_vld;
                  spc6_phy_pc_w          <= `TILE6.piton_pc;
                end
            end
    

            assign spc7_thread_id = 2'b00;
            assign spc7_rtl_pc = spc7_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(7*4)]   <= 1'b0;
                  active_thread[(7*4)+1] <= 1'b0;
                  active_thread[(7*4)+2] <= 1'b0;
                  active_thread[(7*4)+3] <= 1'b0;
                  spc7_inst_done         <= 0;
                  spc7_phy_pc_w          <= 0;
                end else begin
                  active_thread[(7*4)]   <= 1'b1;
                  active_thread[(7*4)+1] <= 1'b1;
                  active_thread[(7*4)+2] <= 1'b1;
                  active_thread[(7*4)+3] <= 1'b1;
                  spc7_inst_done         <= `TILE7.piton_pc_vld;
                  spc7_phy_pc_w          <= `TILE7.piton_pc;
                end
            end
    

            assign spc8_thread_id = 2'b00;
            assign spc8_rtl_pc = spc8_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(8*4)]   <= 1'b0;
                  active_thread[(8*4)+1] <= 1'b0;
                  active_thread[(8*4)+2] <= 1'b0;
                  active_thread[(8*4)+3] <= 1'b0;
                  spc8_inst_done         <= 0;
                  spc8_phy_pc_w          <= 0;
                end else begin
                  active_thread[(8*4)]   <= 1'b1;
                  active_thread[(8*4)+1] <= 1'b1;
                  active_thread[(8*4)+2] <= 1'b1;
                  active_thread[(8*4)+3] <= 1'b1;
                  spc8_inst_done         <= `TILE8.piton_pc_vld;
                  spc8_phy_pc_w          <= `TILE8.piton_pc;
                end
            end
    

            assign spc9_thread_id = 2'b00;
            assign spc9_rtl_pc = spc9_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(9*4)]   <= 1'b0;
                  active_thread[(9*4)+1] <= 1'b0;
                  active_thread[(9*4)+2] <= 1'b0;
                  active_thread[(9*4)+3] <= 1'b0;
                  spc9_inst_done         <= 0;
                  spc9_phy_pc_w          <= 0;
                end else begin
                  active_thread[(9*4)]   <= 1'b1;
                  active_thread[(9*4)+1] <= 1'b1;
                  active_thread[(9*4)+2] <= 1'b1;
                  active_thread[(9*4)+3] <= 1'b1;
                  spc9_inst_done         <= `TILE9.piton_pc_vld;
                  spc9_phy_pc_w          <= `TILE9.piton_pc;
                end
            end
    

            assign spc10_thread_id = 2'b00;
            assign spc10_rtl_pc = spc10_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(10*4)]   <= 1'b0;
                  active_thread[(10*4)+1] <= 1'b0;
                  active_thread[(10*4)+2] <= 1'b0;
                  active_thread[(10*4)+3] <= 1'b0;
                  spc10_inst_done         <= 0;
                  spc10_phy_pc_w          <= 0;
                end else begin
                  active_thread[(10*4)]   <= 1'b1;
                  active_thread[(10*4)+1] <= 1'b1;
                  active_thread[(10*4)+2] <= 1'b1;
                  active_thread[(10*4)+3] <= 1'b1;
                  spc10_inst_done         <= `TILE10.piton_pc_vld;
                  spc10_phy_pc_w          <= `TILE10.piton_pc;
                end
            end
    

            assign spc11_thread_id = 2'b00;
            assign spc11_rtl_pc = spc11_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(11*4)]   <= 1'b0;
                  active_thread[(11*4)+1] <= 1'b0;
                  active_thread[(11*4)+2] <= 1'b0;
                  active_thread[(11*4)+3] <= 1'b0;
                  spc11_inst_done         <= 0;
                  spc11_phy_pc_w          <= 0;
                end else begin
                  active_thread[(11*4)]   <= 1'b1;
                  active_thread[(11*4)+1] <= 1'b1;
                  active_thread[(11*4)+2] <= 1'b1;
                  active_thread[(11*4)+3] <= 1'b1;
                  spc11_inst_done         <= `TILE11.piton_pc_vld;
                  spc11_phy_pc_w          <= `TILE11.piton_pc;
                end
            end
    

            assign spc12_thread_id = 2'b00;
            assign spc12_rtl_pc = spc12_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(12*4)]   <= 1'b0;
                  active_thread[(12*4)+1] <= 1'b0;
                  active_thread[(12*4)+2] <= 1'b0;
                  active_thread[(12*4)+3] <= 1'b0;
                  spc12_inst_done         <= 0;
                  spc12_phy_pc_w          <= 0;
                end else begin
                  active_thread[(12*4)]   <= 1'b1;
                  active_thread[(12*4)+1] <= 1'b1;
                  active_thread[(12*4)+2] <= 1'b1;
                  active_thread[(12*4)+3] <= 1'b1;
                  spc12_inst_done         <= `TILE12.piton_pc_vld;
                  spc12_phy_pc_w          <= `TILE12.piton_pc;
                end
            end
    

            assign spc13_thread_id = 2'b00;
            assign spc13_rtl_pc = spc13_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(13*4)]   <= 1'b0;
                  active_thread[(13*4)+1] <= 1'b0;
                  active_thread[(13*4)+2] <= 1'b0;
                  active_thread[(13*4)+3] <= 1'b0;
                  spc13_inst_done         <= 0;
                  spc13_phy_pc_w          <= 0;
                end else begin
                  active_thread[(13*4)]   <= 1'b1;
                  active_thread[(13*4)+1] <= 1'b1;
                  active_thread[(13*4)+2] <= 1'b1;
                  active_thread[(13*4)+3] <= 1'b1;
                  spc13_inst_done         <= `TILE13.piton_pc_vld;
                  spc13_phy_pc_w          <= `TILE13.piton_pc;
                end
            end
    

            assign spc14_thread_id = 2'b00;
            assign spc14_rtl_pc = spc14_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(14*4)]   <= 1'b0;
                  active_thread[(14*4)+1] <= 1'b0;
                  active_thread[(14*4)+2] <= 1'b0;
                  active_thread[(14*4)+3] <= 1'b0;
                  spc14_inst_done         <= 0;
                  spc14_phy_pc_w          <= 0;
                end else begin
                  active_thread[(14*4)]   <= 1'b1;
                  active_thread[(14*4)+1] <= 1'b1;
                  active_thread[(14*4)+2] <= 1'b1;
                  active_thread[(14*4)+3] <= 1'b1;
                  spc14_inst_done         <= `TILE14.piton_pc_vld;
                  spc14_phy_pc_w          <= `TILE14.piton_pc;
                end
            end
    

            assign spc15_thread_id = 2'b00;
            assign spc15_rtl_pc = spc15_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(15*4)]   <= 1'b0;
                  active_thread[(15*4)+1] <= 1'b0;
                  active_thread[(15*4)+2] <= 1'b0;
                  active_thread[(15*4)+3] <= 1'b0;
                  spc15_inst_done         <= 0;
                  spc15_phy_pc_w          <= 0;
                end else begin
                  active_thread[(15*4)]   <= 1'b1;
                  active_thread[(15*4)+1] <= 1'b1;
                  active_thread[(15*4)+2] <= 1'b1;
                  active_thread[(15*4)+3] <= 1'b1;
                  spc15_inst_done         <= `TILE15.piton_pc_vld;
                  spc15_phy_pc_w          <= `TILE15.piton_pc;
                end
            end
    




reg           dummy;

task trap_extract;
    reg [2048:0] pc_str;
    reg [63:0]  tmp_val;
    integer     i;
    begin
        bad_trap_count = 0;

            if($value$plusargs("good_trap0=%h", tmp_val)) begin
                good_trap[0] = tmp_val;
                good_trap_exists[0] = 1'b1;
                //$display ("%t: good_trap %h", $time, good_trap[0]);
            end



            if($value$plusargs("bad_trap0=%h", tmp_val)) begin
                bad_trap[0] = tmp_val;
                bad_trap_exists[0] = 1'b1;
                //$display ("%t: bad_trap %h", $time, bad_trap[0]);
            end

        trap_count = good_trap_count > bad_trap_count ? good_trap_count :  bad_trap_count;

    end
endtask // trap_extract
// deceide pass or fail
integer       ind;
//post-silicon request
reg [63:0]    last_hit [31:0];
//indicate the 2nd time hit.
reg [31:0]    hitted;
initial hitted = 0;

reg first_rst;
initial begin
    //#20//need to wait for socket initializing.
     trap_extract;
    done    = 0;
    first_rst = 1;
    for(ind = 0;ind < `PITON_NUM_TILES; ind = ind + 1)timeout[ind] = 0;
end // initial begin
always @(posedge rst_l)begin
    if(first_rst)begin
        active_thread = 0;
        first_rst     = 0;
        done          = 0;
    end
end

task set_diag_done;
    input local_diag_done;

    begin
        if (local_diag_done) begin
            `TOP_MOD.diag_done = 1;
        end
    end
endtask


    wire[31:0] long_cpuid0;
    assign long_cpuid0 = {30'd0, spc0_thread_id};

    wire[31:0] long_cpuid1;
    assign long_cpuid1 = {30'd1, spc1_thread_id};

    wire[31:0] long_cpuid2;
    assign long_cpuid2 = {30'd2, spc2_thread_id};

    wire[31:0] long_cpuid3;
    assign long_cpuid3 = {30'd3, spc3_thread_id};

    wire[31:0] long_cpuid4;
    assign long_cpuid4 = {30'd4, spc4_thread_id};

    wire[31:0] long_cpuid5;
    assign long_cpuid5 = {30'd5, spc5_thread_id};

    wire[31:0] long_cpuid6;
    assign long_cpuid6 = {30'd6, spc6_thread_id};

    wire[31:0] long_cpuid7;
    assign long_cpuid7 = {30'd7, spc7_thread_id};

    wire[31:0] long_cpuid8;
    assign long_cpuid8 = {30'd8, spc8_thread_id};

    wire[31:0] long_cpuid9;
    assign long_cpuid9 = {30'd9, spc9_thread_id};

    wire[31:0] long_cpuid10;
    assign long_cpuid10 = {30'd10, spc10_thread_id};

    wire[31:0] long_cpuid11;
    assign long_cpuid11 = {30'd11, spc11_thread_id};

    wire[31:0] long_cpuid12;
    assign long_cpuid12 = {30'd12, spc12_thread_id};

    wire[31:0] long_cpuid13;
    assign long_cpuid13 = {30'd13, spc13_thread_id};

    wire[31:0] long_cpuid14;
    assign long_cpuid14 = {30'd14, spc14_thread_id};

    wire[31:0] long_cpuid15;
    assign long_cpuid15 = {30'd15, spc15_thread_id};


always @* begin
done[0]   = spc0_inst_done;//sparc 0
done[1]   = spc1_inst_done;//sparc 1
done[2]   = spc2_inst_done;//sparc 2
done[3]   = spc3_inst_done;//sparc 3
done[4]   = spc4_inst_done;//sparc 4
done[5]   = spc5_inst_done;//sparc 5
done[6]   = spc6_inst_done;//sparc 6
done[7]   = spc7_inst_done;//sparc 7
done[8]   = spc8_inst_done;//sparc 8
done[9]   = spc9_inst_done;//sparc 9
done[10]   = spc10_inst_done;//sparc 10
done[11]   = spc11_inst_done;//sparc 11
done[12]   = spc12_inst_done;//sparc 12
done[13]   = spc13_inst_done;//sparc 13
done[14]   = spc14_inst_done;//sparc 14
done[15]   = spc15_inst_done;//sparc 15


end



string linebuf0 = "";
logic hitMadPrint0 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc0_inst_done && ((spc0_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint0 = 1;
       linebuf0 = {linebuf0, spc0_phy_pc_w[8:1]};
       if (spc0_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 0, linebuf0);
          linebuf0 = "";
       end
    end else begin
       hitMadPrint0 = 0;
    end
  end
end


string linebuf1 = "";
logic hitMadPrint1 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc1_inst_done && ((spc1_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint1 = 1;
       linebuf1 = {linebuf1, spc1_phy_pc_w[8:1]};
       if (spc1_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 1, linebuf1);
          linebuf1 = "";
       end
    end else begin
       hitMadPrint1 = 0;
    end
  end
end


string linebuf2 = "";
logic hitMadPrint2 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc2_inst_done && ((spc2_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint2 = 1;
       linebuf2 = {linebuf2, spc2_phy_pc_w[8:1]};
       if (spc2_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 2, linebuf2);
          linebuf2 = "";
       end
    end else begin
       hitMadPrint2 = 0;
    end
  end
end


string linebuf3 = "";
logic hitMadPrint3 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc3_inst_done && ((spc3_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint3 = 1;
       linebuf3 = {linebuf3, spc3_phy_pc_w[8:1]};
       if (spc3_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 3, linebuf3);
          linebuf3 = "";
       end
    end else begin
       hitMadPrint3 = 0;
    end
  end
end


string linebuf4 = "";
logic hitMadPrint4 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc4_inst_done && ((spc4_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint4 = 1;
       linebuf4 = {linebuf4, spc4_phy_pc_w[8:1]};
       if (spc4_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 4, linebuf4);
          linebuf4 = "";
       end
    end else begin
       hitMadPrint4 = 0;
    end
  end
end


string linebuf5 = "";
logic hitMadPrint5 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc5_inst_done && ((spc5_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint5 = 1;
       linebuf5 = {linebuf5, spc5_phy_pc_w[8:1]};
       if (spc5_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 5, linebuf5);
          linebuf5 = "";
       end
    end else begin
       hitMadPrint5 = 0;
    end
  end
end


string linebuf6 = "";
logic hitMadPrint6 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc6_inst_done && ((spc6_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint6 = 1;
       linebuf6 = {linebuf6, spc6_phy_pc_w[8:1]};
       if (spc6_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 6, linebuf6);
          linebuf6 = "";
       end
    end else begin
       hitMadPrint6 = 0;
    end
  end
end


string linebuf7 = "";
logic hitMadPrint7 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc7_inst_done && ((spc7_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint7 = 1;
       linebuf7 = {linebuf7, spc7_phy_pc_w[8:1]};
       if (spc7_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 7, linebuf7);
          linebuf7 = "";
       end
    end else begin
       hitMadPrint7 = 0;
    end
  end
end


string linebuf8 = "";
logic hitMadPrint8 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc8_inst_done && ((spc8_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint8 = 1;
       linebuf8 = {linebuf8, spc8_phy_pc_w[8:1]};
       if (spc8_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 8, linebuf8);
          linebuf8 = "";
       end
    end else begin
       hitMadPrint8 = 0;
    end
  end
end


string linebuf9 = "";
logic hitMadPrint9 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc9_inst_done && ((spc9_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint9 = 1;
       linebuf9 = {linebuf9, spc9_phy_pc_w[8:1]};
       if (spc9_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 9, linebuf9);
          linebuf9 = "";
       end
    end else begin
       hitMadPrint9 = 0;
    end
  end
end


string linebuf10 = "";
logic hitMadPrint10 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc10_inst_done && ((spc10_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint10 = 1;
       linebuf10 = {linebuf10, spc10_phy_pc_w[8:1]};
       if (spc10_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 10, linebuf10);
          linebuf10 = "";
       end
    end else begin
       hitMadPrint10 = 0;
    end
  end
end


string linebuf11 = "";
logic hitMadPrint11 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc11_inst_done && ((spc11_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint11 = 1;
       linebuf11 = {linebuf11, spc11_phy_pc_w[8:1]};
       if (spc11_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 11, linebuf11);
          linebuf11 = "";
       end
    end else begin
       hitMadPrint11 = 0;
    end
  end
end


string linebuf12 = "";
logic hitMadPrint12 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc12_inst_done && ((spc12_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint12 = 1;
       linebuf12 = {linebuf12, spc12_phy_pc_w[8:1]};
       if (spc12_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 12, linebuf12);
          linebuf12 = "";
       end
    end else begin
       hitMadPrint12 = 0;
    end
  end
end


string linebuf13 = "";
logic hitMadPrint13 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc13_inst_done && ((spc13_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint13 = 1;
       linebuf13 = {linebuf13, spc13_phy_pc_w[8:1]};
       if (spc13_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 13, linebuf13);
          linebuf13 = "";
       end
    end else begin
       hitMadPrint13 = 0;
    end
  end
end


string linebuf14 = "";
logic hitMadPrint14 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc14_inst_done && ((spc14_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint14 = 1;
       linebuf14 = {linebuf14, spc14_phy_pc_w[8:1]};
       if (spc14_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 14, linebuf14);
          linebuf14 = "";
       end
    end else begin
       hitMadPrint14 = 0;
    end
  end
end


string linebuf15 = "";
logic hitMadPrint15 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc15_inst_done && ((spc15_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint15 = 1;
       linebuf15 = {linebuf15, spc15_phy_pc_w[8:1]};
       if (spc15_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 15, linebuf15);
          linebuf15 = "";
       end
    end else begin
       hitMadPrint15 = 0;
    end
  end
end




//main routine of pc cmp to finish the simulation.
always @(posedge clk)begin
    if(rst_l)begin
        if(|done[`PITON_NUM_TILES-1:0]) begin

        if (done[0]) begin
            timeout[long_cpuid0] = 0;
            //check_bad_trap(spc0_phy_pc_w, 0, long_cpuid0);
            if(active_thread[long_cpuid0])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc0_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid0/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 0 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid0]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc0_phy_pc_w))
                begin
                    if(good[long_cpuid0/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid0 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid0/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid0])
        end // if (done[0])

        if (done[1]) begin
            timeout[long_cpuid1] = 0;
            //check_bad_trap(spc1_phy_pc_w, 1, long_cpuid1);
            if(active_thread[long_cpuid1])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc1_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid1/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 1 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid1]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc1_phy_pc_w))
                begin
                    if(good[long_cpuid1/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid1 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid1/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid1])
        end // if (done[1])

        if (done[2]) begin
            timeout[long_cpuid2] = 0;
            //check_bad_trap(spc2_phy_pc_w, 2, long_cpuid2);
            if(active_thread[long_cpuid2])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc2_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid2/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 2 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid2]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc2_phy_pc_w))
                begin
                    if(good[long_cpuid2/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid2 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid2/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid2])
        end // if (done[2])

        if (done[3]) begin
            timeout[long_cpuid3] = 0;
            //check_bad_trap(spc3_phy_pc_w, 3, long_cpuid3);
            if(active_thread[long_cpuid3])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc3_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid3/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 3 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid3]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc3_phy_pc_w))
                begin
                    if(good[long_cpuid3/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid3 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid3/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid3])
        end // if (done[3])

        if (done[4]) begin
            timeout[long_cpuid4] = 0;
            //check_bad_trap(spc4_phy_pc_w, 4, long_cpuid4);
            if(active_thread[long_cpuid4])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc4_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid4/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 4 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid4]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc4_phy_pc_w))
                begin
                    if(good[long_cpuid4/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid4 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid4/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid4])
        end // if (done[4])

        if (done[5]) begin
            timeout[long_cpuid5] = 0;
            //check_bad_trap(spc5_phy_pc_w, 5, long_cpuid5);
            if(active_thread[long_cpuid5])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc5_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid5/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 5 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid5]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc5_phy_pc_w))
                begin
                    if(good[long_cpuid5/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid5 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid5/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid5])
        end // if (done[5])

        if (done[6]) begin
            timeout[long_cpuid6] = 0;
            //check_bad_trap(spc6_phy_pc_w, 6, long_cpuid6);
            if(active_thread[long_cpuid6])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc6_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid6/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 6 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid6]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc6_phy_pc_w))
                begin
                    if(good[long_cpuid6/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid6 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid6/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid6])
        end // if (done[6])

        if (done[7]) begin
            timeout[long_cpuid7] = 0;
            //check_bad_trap(spc7_phy_pc_w, 7, long_cpuid7);
            if(active_thread[long_cpuid7])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc7_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid7/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 7 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid7]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc7_phy_pc_w))
                begin
                    if(good[long_cpuid7/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid7 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid7/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid7])
        end // if (done[7])

        if (done[8]) begin
            timeout[long_cpuid8] = 0;
            //check_bad_trap(spc8_phy_pc_w, 8, long_cpuid8);
            if(active_thread[long_cpuid8])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc8_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid8/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 8 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid8]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc8_phy_pc_w))
                begin
                    if(good[long_cpuid8/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid8 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid8/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid8])
        end // if (done[8])

        if (done[9]) begin
            timeout[long_cpuid9] = 0;
            //check_bad_trap(spc9_phy_pc_w, 9, long_cpuid9);
            if(active_thread[long_cpuid9])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc9_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid9/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 9 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid9]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc9_phy_pc_w))
                begin
                    if(good[long_cpuid9/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid9 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid9/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid9])
        end // if (done[9])

        if (done[10]) begin
            timeout[long_cpuid10] = 0;
            //check_bad_trap(spc10_phy_pc_w, 10, long_cpuid10);
            if(active_thread[long_cpuid10])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc10_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid10/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 10 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid10]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc10_phy_pc_w))
                begin
                    if(good[long_cpuid10/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid10 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid10/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid10])
        end // if (done[10])

        if (done[11]) begin
            timeout[long_cpuid11] = 0;
            //check_bad_trap(spc11_phy_pc_w, 11, long_cpuid11);
            if(active_thread[long_cpuid11])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc11_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid11/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 11 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid11]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc11_phy_pc_w))
                begin
                    if(good[long_cpuid11/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid11 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid11/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid11])
        end // if (done[11])

        if (done[12]) begin
            timeout[long_cpuid12] = 0;
            //check_bad_trap(spc12_phy_pc_w, 12, long_cpuid12);
            if(active_thread[long_cpuid12])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc12_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid12/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 12 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid12]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc12_phy_pc_w))
                begin
                    if(good[long_cpuid12/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid12 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid12/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid12])
        end // if (done[12])

        if (done[13]) begin
            timeout[long_cpuid13] = 0;
            //check_bad_trap(spc13_phy_pc_w, 13, long_cpuid13);
            if(active_thread[long_cpuid13])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc13_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid13/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 13 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid13]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc13_phy_pc_w))
                begin
                    if(good[long_cpuid13/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid13 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid13/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid13])
        end // if (done[13])

        if (done[14]) begin
            timeout[long_cpuid14] = 0;
            //check_bad_trap(spc14_phy_pc_w, 14, long_cpuid14);
            if(active_thread[long_cpuid14])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc14_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid14/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 14 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid14]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc14_phy_pc_w))
                begin
                    if(good[long_cpuid14/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid14 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid14/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid14])
        end // if (done[14])

        if (done[15]) begin
            timeout[long_cpuid15] = 0;
            //check_bad_trap(spc15_phy_pc_w, 15, long_cpuid15);
            if(active_thread[long_cpuid15])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc15_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid15/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 15 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid15]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc15_phy_pc_w))
                begin
                    if(good[long_cpuid15/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid15 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid15/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid15])
        end // if (done[15])

        
        end
`ifdef INCLUDE_SAS_TASKS
        get_thread_status;
`endif
        set_diag_done(local_diag_done);
    end // if (rst_l)
end // always @ (posedge clk)

always @(posedge clk) begin
  if (!rst_l) begin
    good <= '0;
    hit_bad <= 1'b0;
  end else begin
    if (&good) begin
      $display("All threads hit good trap - PASS");
      $finish;
    end
    if (hit_bad) begin
      $display("A thread hit bad trap - FAIL");
      $error;
      $finish;
    end
  end
end

endmodule


