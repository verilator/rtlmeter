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

reg [255:0]   active_thread;
reg [4:0]    thread_status[255:0];

reg [63:0]   good = '0;
reg [63:0]   done;

reg [31:0]     timeout [255:0];


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

    

    reg spc16_inst_done;
    wire [1:0]   spc16_thread_id;
    wire [63:0]      spc16_rtl_pc;
    wire sas_m16;
    reg [63:0] spc16_phy_pc_w;

    

    reg spc17_inst_done;
    wire [1:0]   spc17_thread_id;
    wire [63:0]      spc17_rtl_pc;
    wire sas_m17;
    reg [63:0] spc17_phy_pc_w;

    

    reg spc18_inst_done;
    wire [1:0]   spc18_thread_id;
    wire [63:0]      spc18_rtl_pc;
    wire sas_m18;
    reg [63:0] spc18_phy_pc_w;

    

    reg spc19_inst_done;
    wire [1:0]   spc19_thread_id;
    wire [63:0]      spc19_rtl_pc;
    wire sas_m19;
    reg [63:0] spc19_phy_pc_w;

    

    reg spc20_inst_done;
    wire [1:0]   spc20_thread_id;
    wire [63:0]      spc20_rtl_pc;
    wire sas_m20;
    reg [63:0] spc20_phy_pc_w;

    

    reg spc21_inst_done;
    wire [1:0]   spc21_thread_id;
    wire [63:0]      spc21_rtl_pc;
    wire sas_m21;
    reg [63:0] spc21_phy_pc_w;

    

    reg spc22_inst_done;
    wire [1:0]   spc22_thread_id;
    wire [63:0]      spc22_rtl_pc;
    wire sas_m22;
    reg [63:0] spc22_phy_pc_w;

    

    reg spc23_inst_done;
    wire [1:0]   spc23_thread_id;
    wire [63:0]      spc23_rtl_pc;
    wire sas_m23;
    reg [63:0] spc23_phy_pc_w;

    

    reg spc24_inst_done;
    wire [1:0]   spc24_thread_id;
    wire [63:0]      spc24_rtl_pc;
    wire sas_m24;
    reg [63:0] spc24_phy_pc_w;

    

    reg spc25_inst_done;
    wire [1:0]   spc25_thread_id;
    wire [63:0]      spc25_rtl_pc;
    wire sas_m25;
    reg [63:0] spc25_phy_pc_w;

    

    reg spc26_inst_done;
    wire [1:0]   spc26_thread_id;
    wire [63:0]      spc26_rtl_pc;
    wire sas_m26;
    reg [63:0] spc26_phy_pc_w;

    

    reg spc27_inst_done;
    wire [1:0]   spc27_thread_id;
    wire [63:0]      spc27_rtl_pc;
    wire sas_m27;
    reg [63:0] spc27_phy_pc_w;

    

    reg spc28_inst_done;
    wire [1:0]   spc28_thread_id;
    wire [63:0]      spc28_rtl_pc;
    wire sas_m28;
    reg [63:0] spc28_phy_pc_w;

    

    reg spc29_inst_done;
    wire [1:0]   spc29_thread_id;
    wire [63:0]      spc29_rtl_pc;
    wire sas_m29;
    reg [63:0] spc29_phy_pc_w;

    

    reg spc30_inst_done;
    wire [1:0]   spc30_thread_id;
    wire [63:0]      spc30_rtl_pc;
    wire sas_m30;
    reg [63:0] spc30_phy_pc_w;

    

    reg spc31_inst_done;
    wire [1:0]   spc31_thread_id;
    wire [63:0]      spc31_rtl_pc;
    wire sas_m31;
    reg [63:0] spc31_phy_pc_w;

    

    reg spc32_inst_done;
    wire [1:0]   spc32_thread_id;
    wire [63:0]      spc32_rtl_pc;
    wire sas_m32;
    reg [63:0] spc32_phy_pc_w;

    

    reg spc33_inst_done;
    wire [1:0]   spc33_thread_id;
    wire [63:0]      spc33_rtl_pc;
    wire sas_m33;
    reg [63:0] spc33_phy_pc_w;

    

    reg spc34_inst_done;
    wire [1:0]   spc34_thread_id;
    wire [63:0]      spc34_rtl_pc;
    wire sas_m34;
    reg [63:0] spc34_phy_pc_w;

    

    reg spc35_inst_done;
    wire [1:0]   spc35_thread_id;
    wire [63:0]      spc35_rtl_pc;
    wire sas_m35;
    reg [63:0] spc35_phy_pc_w;

    

    reg spc36_inst_done;
    wire [1:0]   spc36_thread_id;
    wire [63:0]      spc36_rtl_pc;
    wire sas_m36;
    reg [63:0] spc36_phy_pc_w;

    

    reg spc37_inst_done;
    wire [1:0]   spc37_thread_id;
    wire [63:0]      spc37_rtl_pc;
    wire sas_m37;
    reg [63:0] spc37_phy_pc_w;

    

    reg spc38_inst_done;
    wire [1:0]   spc38_thread_id;
    wire [63:0]      spc38_rtl_pc;
    wire sas_m38;
    reg [63:0] spc38_phy_pc_w;

    

    reg spc39_inst_done;
    wire [1:0]   spc39_thread_id;
    wire [63:0]      spc39_rtl_pc;
    wire sas_m39;
    reg [63:0] spc39_phy_pc_w;

    

    reg spc40_inst_done;
    wire [1:0]   spc40_thread_id;
    wire [63:0]      spc40_rtl_pc;
    wire sas_m40;
    reg [63:0] spc40_phy_pc_w;

    

    reg spc41_inst_done;
    wire [1:0]   spc41_thread_id;
    wire [63:0]      spc41_rtl_pc;
    wire sas_m41;
    reg [63:0] spc41_phy_pc_w;

    

    reg spc42_inst_done;
    wire [1:0]   spc42_thread_id;
    wire [63:0]      spc42_rtl_pc;
    wire sas_m42;
    reg [63:0] spc42_phy_pc_w;

    

    reg spc43_inst_done;
    wire [1:0]   spc43_thread_id;
    wire [63:0]      spc43_rtl_pc;
    wire sas_m43;
    reg [63:0] spc43_phy_pc_w;

    

    reg spc44_inst_done;
    wire [1:0]   spc44_thread_id;
    wire [63:0]      spc44_rtl_pc;
    wire sas_m44;
    reg [63:0] spc44_phy_pc_w;

    

    reg spc45_inst_done;
    wire [1:0]   spc45_thread_id;
    wire [63:0]      spc45_rtl_pc;
    wire sas_m45;
    reg [63:0] spc45_phy_pc_w;

    

    reg spc46_inst_done;
    wire [1:0]   spc46_thread_id;
    wire [63:0]      spc46_rtl_pc;
    wire sas_m46;
    reg [63:0] spc46_phy_pc_w;

    

    reg spc47_inst_done;
    wire [1:0]   spc47_thread_id;
    wire [63:0]      spc47_rtl_pc;
    wire sas_m47;
    reg [63:0] spc47_phy_pc_w;

    

    reg spc48_inst_done;
    wire [1:0]   spc48_thread_id;
    wire [63:0]      spc48_rtl_pc;
    wire sas_m48;
    reg [63:0] spc48_phy_pc_w;

    

    reg spc49_inst_done;
    wire [1:0]   spc49_thread_id;
    wire [63:0]      spc49_rtl_pc;
    wire sas_m49;
    reg [63:0] spc49_phy_pc_w;

    

    reg spc50_inst_done;
    wire [1:0]   spc50_thread_id;
    wire [63:0]      spc50_rtl_pc;
    wire sas_m50;
    reg [63:0] spc50_phy_pc_w;

    

    reg spc51_inst_done;
    wire [1:0]   spc51_thread_id;
    wire [63:0]      spc51_rtl_pc;
    wire sas_m51;
    reg [63:0] spc51_phy_pc_w;

    

    reg spc52_inst_done;
    wire [1:0]   spc52_thread_id;
    wire [63:0]      spc52_rtl_pc;
    wire sas_m52;
    reg [63:0] spc52_phy_pc_w;

    

    reg spc53_inst_done;
    wire [1:0]   spc53_thread_id;
    wire [63:0]      spc53_rtl_pc;
    wire sas_m53;
    reg [63:0] spc53_phy_pc_w;

    

    reg spc54_inst_done;
    wire [1:0]   spc54_thread_id;
    wire [63:0]      spc54_rtl_pc;
    wire sas_m54;
    reg [63:0] spc54_phy_pc_w;

    

    reg spc55_inst_done;
    wire [1:0]   spc55_thread_id;
    wire [63:0]      spc55_rtl_pc;
    wire sas_m55;
    reg [63:0] spc55_phy_pc_w;

    

    reg spc56_inst_done;
    wire [1:0]   spc56_thread_id;
    wire [63:0]      spc56_rtl_pc;
    wire sas_m56;
    reg [63:0] spc56_phy_pc_w;

    

    reg spc57_inst_done;
    wire [1:0]   spc57_thread_id;
    wire [63:0]      spc57_rtl_pc;
    wire sas_m57;
    reg [63:0] spc57_phy_pc_w;

    

    reg spc58_inst_done;
    wire [1:0]   spc58_thread_id;
    wire [63:0]      spc58_rtl_pc;
    wire sas_m58;
    reg [63:0] spc58_phy_pc_w;

    

    reg spc59_inst_done;
    wire [1:0]   spc59_thread_id;
    wire [63:0]      spc59_rtl_pc;
    wire sas_m59;
    reg [63:0] spc59_phy_pc_w;

    

    reg spc60_inst_done;
    wire [1:0]   spc60_thread_id;
    wire [63:0]      spc60_rtl_pc;
    wire sas_m60;
    reg [63:0] spc60_phy_pc_w;

    

    reg spc61_inst_done;
    wire [1:0]   spc61_thread_id;
    wire [63:0]      spc61_rtl_pc;
    wire sas_m61;
    reg [63:0] spc61_phy_pc_w;

    

    reg spc62_inst_done;
    wire [1:0]   spc62_thread_id;
    wire [63:0]      spc62_rtl_pc;
    wire sas_m62;
    reg [63:0] spc62_phy_pc_w;

    

    reg spc63_inst_done;
    wire [1:0]   spc63_thread_id;
    wire [63:0]      spc63_rtl_pc;
    wire sas_m63;
    reg [63:0] spc63_phy_pc_w;

    


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
thread_status[64] = `IFUPATH16.swl.thr0_state;
thread_status[65] = `IFUPATH16.swl.thr1_state;
thread_status[66] = `IFUPATH16.swl.thr2_state;
thread_status[67] = `IFUPATH16.swl.thr3_state;
thread_status[68] = `IFUPATH17.swl.thr0_state;
thread_status[69] = `IFUPATH17.swl.thr1_state;
thread_status[70] = `IFUPATH17.swl.thr2_state;
thread_status[71] = `IFUPATH17.swl.thr3_state;
thread_status[72] = `IFUPATH18.swl.thr0_state;
thread_status[73] = `IFUPATH18.swl.thr1_state;
thread_status[74] = `IFUPATH18.swl.thr2_state;
thread_status[75] = `IFUPATH18.swl.thr3_state;
thread_status[76] = `IFUPATH19.swl.thr0_state;
thread_status[77] = `IFUPATH19.swl.thr1_state;
thread_status[78] = `IFUPATH19.swl.thr2_state;
thread_status[79] = `IFUPATH19.swl.thr3_state;
thread_status[80] = `IFUPATH20.swl.thr0_state;
thread_status[81] = `IFUPATH20.swl.thr1_state;
thread_status[82] = `IFUPATH20.swl.thr2_state;
thread_status[83] = `IFUPATH20.swl.thr3_state;
thread_status[84] = `IFUPATH21.swl.thr0_state;
thread_status[85] = `IFUPATH21.swl.thr1_state;
thread_status[86] = `IFUPATH21.swl.thr2_state;
thread_status[87] = `IFUPATH21.swl.thr3_state;
thread_status[88] = `IFUPATH22.swl.thr0_state;
thread_status[89] = `IFUPATH22.swl.thr1_state;
thread_status[90] = `IFUPATH22.swl.thr2_state;
thread_status[91] = `IFUPATH22.swl.thr3_state;
thread_status[92] = `IFUPATH23.swl.thr0_state;
thread_status[93] = `IFUPATH23.swl.thr1_state;
thread_status[94] = `IFUPATH23.swl.thr2_state;
thread_status[95] = `IFUPATH23.swl.thr3_state;
thread_status[96] = `IFUPATH24.swl.thr0_state;
thread_status[97] = `IFUPATH24.swl.thr1_state;
thread_status[98] = `IFUPATH24.swl.thr2_state;
thread_status[99] = `IFUPATH24.swl.thr3_state;
thread_status[100] = `IFUPATH25.swl.thr0_state;
thread_status[101] = `IFUPATH25.swl.thr1_state;
thread_status[102] = `IFUPATH25.swl.thr2_state;
thread_status[103] = `IFUPATH25.swl.thr3_state;
thread_status[104] = `IFUPATH26.swl.thr0_state;
thread_status[105] = `IFUPATH26.swl.thr1_state;
thread_status[106] = `IFUPATH26.swl.thr2_state;
thread_status[107] = `IFUPATH26.swl.thr3_state;
thread_status[108] = `IFUPATH27.swl.thr0_state;
thread_status[109] = `IFUPATH27.swl.thr1_state;
thread_status[110] = `IFUPATH27.swl.thr2_state;
thread_status[111] = `IFUPATH27.swl.thr3_state;
thread_status[112] = `IFUPATH28.swl.thr0_state;
thread_status[113] = `IFUPATH28.swl.thr1_state;
thread_status[114] = `IFUPATH28.swl.thr2_state;
thread_status[115] = `IFUPATH28.swl.thr3_state;
thread_status[116] = `IFUPATH29.swl.thr0_state;
thread_status[117] = `IFUPATH29.swl.thr1_state;
thread_status[118] = `IFUPATH29.swl.thr2_state;
thread_status[119] = `IFUPATH29.swl.thr3_state;
thread_status[120] = `IFUPATH30.swl.thr0_state;
thread_status[121] = `IFUPATH30.swl.thr1_state;
thread_status[122] = `IFUPATH30.swl.thr2_state;
thread_status[123] = `IFUPATH30.swl.thr3_state;
thread_status[124] = `IFUPATH31.swl.thr0_state;
thread_status[125] = `IFUPATH31.swl.thr1_state;
thread_status[126] = `IFUPATH31.swl.thr2_state;
thread_status[127] = `IFUPATH31.swl.thr3_state;
thread_status[128] = `IFUPATH32.swl.thr0_state;
thread_status[129] = `IFUPATH32.swl.thr1_state;
thread_status[130] = `IFUPATH32.swl.thr2_state;
thread_status[131] = `IFUPATH32.swl.thr3_state;
thread_status[132] = `IFUPATH33.swl.thr0_state;
thread_status[133] = `IFUPATH33.swl.thr1_state;
thread_status[134] = `IFUPATH33.swl.thr2_state;
thread_status[135] = `IFUPATH33.swl.thr3_state;
thread_status[136] = `IFUPATH34.swl.thr0_state;
thread_status[137] = `IFUPATH34.swl.thr1_state;
thread_status[138] = `IFUPATH34.swl.thr2_state;
thread_status[139] = `IFUPATH34.swl.thr3_state;
thread_status[140] = `IFUPATH35.swl.thr0_state;
thread_status[141] = `IFUPATH35.swl.thr1_state;
thread_status[142] = `IFUPATH35.swl.thr2_state;
thread_status[143] = `IFUPATH35.swl.thr3_state;
thread_status[144] = `IFUPATH36.swl.thr0_state;
thread_status[145] = `IFUPATH36.swl.thr1_state;
thread_status[146] = `IFUPATH36.swl.thr2_state;
thread_status[147] = `IFUPATH36.swl.thr3_state;
thread_status[148] = `IFUPATH37.swl.thr0_state;
thread_status[149] = `IFUPATH37.swl.thr1_state;
thread_status[150] = `IFUPATH37.swl.thr2_state;
thread_status[151] = `IFUPATH37.swl.thr3_state;
thread_status[152] = `IFUPATH38.swl.thr0_state;
thread_status[153] = `IFUPATH38.swl.thr1_state;
thread_status[154] = `IFUPATH38.swl.thr2_state;
thread_status[155] = `IFUPATH38.swl.thr3_state;
thread_status[156] = `IFUPATH39.swl.thr0_state;
thread_status[157] = `IFUPATH39.swl.thr1_state;
thread_status[158] = `IFUPATH39.swl.thr2_state;
thread_status[159] = `IFUPATH39.swl.thr3_state;
thread_status[160] = `IFUPATH40.swl.thr0_state;
thread_status[161] = `IFUPATH40.swl.thr1_state;
thread_status[162] = `IFUPATH40.swl.thr2_state;
thread_status[163] = `IFUPATH40.swl.thr3_state;
thread_status[164] = `IFUPATH41.swl.thr0_state;
thread_status[165] = `IFUPATH41.swl.thr1_state;
thread_status[166] = `IFUPATH41.swl.thr2_state;
thread_status[167] = `IFUPATH41.swl.thr3_state;
thread_status[168] = `IFUPATH42.swl.thr0_state;
thread_status[169] = `IFUPATH42.swl.thr1_state;
thread_status[170] = `IFUPATH42.swl.thr2_state;
thread_status[171] = `IFUPATH42.swl.thr3_state;
thread_status[172] = `IFUPATH43.swl.thr0_state;
thread_status[173] = `IFUPATH43.swl.thr1_state;
thread_status[174] = `IFUPATH43.swl.thr2_state;
thread_status[175] = `IFUPATH43.swl.thr3_state;
thread_status[176] = `IFUPATH44.swl.thr0_state;
thread_status[177] = `IFUPATH44.swl.thr1_state;
thread_status[178] = `IFUPATH44.swl.thr2_state;
thread_status[179] = `IFUPATH44.swl.thr3_state;
thread_status[180] = `IFUPATH45.swl.thr0_state;
thread_status[181] = `IFUPATH45.swl.thr1_state;
thread_status[182] = `IFUPATH45.swl.thr2_state;
thread_status[183] = `IFUPATH45.swl.thr3_state;
thread_status[184] = `IFUPATH46.swl.thr0_state;
thread_status[185] = `IFUPATH46.swl.thr1_state;
thread_status[186] = `IFUPATH46.swl.thr2_state;
thread_status[187] = `IFUPATH46.swl.thr3_state;
thread_status[188] = `IFUPATH47.swl.thr0_state;
thread_status[189] = `IFUPATH47.swl.thr1_state;
thread_status[190] = `IFUPATH47.swl.thr2_state;
thread_status[191] = `IFUPATH47.swl.thr3_state;
thread_status[192] = `IFUPATH48.swl.thr0_state;
thread_status[193] = `IFUPATH48.swl.thr1_state;
thread_status[194] = `IFUPATH48.swl.thr2_state;
thread_status[195] = `IFUPATH48.swl.thr3_state;
thread_status[196] = `IFUPATH49.swl.thr0_state;
thread_status[197] = `IFUPATH49.swl.thr1_state;
thread_status[198] = `IFUPATH49.swl.thr2_state;
thread_status[199] = `IFUPATH49.swl.thr3_state;
thread_status[200] = `IFUPATH50.swl.thr0_state;
thread_status[201] = `IFUPATH50.swl.thr1_state;
thread_status[202] = `IFUPATH50.swl.thr2_state;
thread_status[203] = `IFUPATH50.swl.thr3_state;
thread_status[204] = `IFUPATH51.swl.thr0_state;
thread_status[205] = `IFUPATH51.swl.thr1_state;
thread_status[206] = `IFUPATH51.swl.thr2_state;
thread_status[207] = `IFUPATH51.swl.thr3_state;
thread_status[208] = `IFUPATH52.swl.thr0_state;
thread_status[209] = `IFUPATH52.swl.thr1_state;
thread_status[210] = `IFUPATH52.swl.thr2_state;
thread_status[211] = `IFUPATH52.swl.thr3_state;
thread_status[212] = `IFUPATH53.swl.thr0_state;
thread_status[213] = `IFUPATH53.swl.thr1_state;
thread_status[214] = `IFUPATH53.swl.thr2_state;
thread_status[215] = `IFUPATH53.swl.thr3_state;
thread_status[216] = `IFUPATH54.swl.thr0_state;
thread_status[217] = `IFUPATH54.swl.thr1_state;
thread_status[218] = `IFUPATH54.swl.thr2_state;
thread_status[219] = `IFUPATH54.swl.thr3_state;
thread_status[220] = `IFUPATH55.swl.thr0_state;
thread_status[221] = `IFUPATH55.swl.thr1_state;
thread_status[222] = `IFUPATH55.swl.thr2_state;
thread_status[223] = `IFUPATH55.swl.thr3_state;
thread_status[224] = `IFUPATH56.swl.thr0_state;
thread_status[225] = `IFUPATH56.swl.thr1_state;
thread_status[226] = `IFUPATH56.swl.thr2_state;
thread_status[227] = `IFUPATH56.swl.thr3_state;
thread_status[228] = `IFUPATH57.swl.thr0_state;
thread_status[229] = `IFUPATH57.swl.thr1_state;
thread_status[230] = `IFUPATH57.swl.thr2_state;
thread_status[231] = `IFUPATH57.swl.thr3_state;
thread_status[232] = `IFUPATH58.swl.thr0_state;
thread_status[233] = `IFUPATH58.swl.thr1_state;
thread_status[234] = `IFUPATH58.swl.thr2_state;
thread_status[235] = `IFUPATH58.swl.thr3_state;
thread_status[236] = `IFUPATH59.swl.thr0_state;
thread_status[237] = `IFUPATH59.swl.thr1_state;
thread_status[238] = `IFUPATH59.swl.thr2_state;
thread_status[239] = `IFUPATH59.swl.thr3_state;
thread_status[240] = `IFUPATH60.swl.thr0_state;
thread_status[241] = `IFUPATH60.swl.thr1_state;
thread_status[242] = `IFUPATH60.swl.thr2_state;
thread_status[243] = `IFUPATH60.swl.thr3_state;
thread_status[244] = `IFUPATH61.swl.thr0_state;
thread_status[245] = `IFUPATH61.swl.thr1_state;
thread_status[246] = `IFUPATH61.swl.thr2_state;
thread_status[247] = `IFUPATH61.swl.thr3_state;
thread_status[248] = `IFUPATH62.swl.thr0_state;
thread_status[249] = `IFUPATH62.swl.thr1_state;
thread_status[250] = `IFUPATH62.swl.thr2_state;
thread_status[251] = `IFUPATH62.swl.thr3_state;
thread_status[252] = `IFUPATH63.swl.thr0_state;
thread_status[253] = `IFUPATH63.swl.thr1_state;
thread_status[254] = `IFUPATH63.swl.thr2_state;
thread_status[255] = `IFUPATH63.swl.thr3_state;

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
    

            assign spc16_thread_id = 2'b00;
            assign spc16_rtl_pc = spc16_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(16*4)]   <= 1'b0;
                  active_thread[(16*4)+1] <= 1'b0;
                  active_thread[(16*4)+2] <= 1'b0;
                  active_thread[(16*4)+3] <= 1'b0;
                  spc16_inst_done         <= 0;
                  spc16_phy_pc_w          <= 0;
                end else begin
                  active_thread[(16*4)]   <= 1'b1;
                  active_thread[(16*4)+1] <= 1'b1;
                  active_thread[(16*4)+2] <= 1'b1;
                  active_thread[(16*4)+3] <= 1'b1;
                  spc16_inst_done         <= `TILE16.piton_pc_vld;
                  spc16_phy_pc_w          <= `TILE16.piton_pc;
                end
            end
    

            assign spc17_thread_id = 2'b00;
            assign spc17_rtl_pc = spc17_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(17*4)]   <= 1'b0;
                  active_thread[(17*4)+1] <= 1'b0;
                  active_thread[(17*4)+2] <= 1'b0;
                  active_thread[(17*4)+3] <= 1'b0;
                  spc17_inst_done         <= 0;
                  spc17_phy_pc_w          <= 0;
                end else begin
                  active_thread[(17*4)]   <= 1'b1;
                  active_thread[(17*4)+1] <= 1'b1;
                  active_thread[(17*4)+2] <= 1'b1;
                  active_thread[(17*4)+3] <= 1'b1;
                  spc17_inst_done         <= `TILE17.piton_pc_vld;
                  spc17_phy_pc_w          <= `TILE17.piton_pc;
                end
            end
    

            assign spc18_thread_id = 2'b00;
            assign spc18_rtl_pc = spc18_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(18*4)]   <= 1'b0;
                  active_thread[(18*4)+1] <= 1'b0;
                  active_thread[(18*4)+2] <= 1'b0;
                  active_thread[(18*4)+3] <= 1'b0;
                  spc18_inst_done         <= 0;
                  spc18_phy_pc_w          <= 0;
                end else begin
                  active_thread[(18*4)]   <= 1'b1;
                  active_thread[(18*4)+1] <= 1'b1;
                  active_thread[(18*4)+2] <= 1'b1;
                  active_thread[(18*4)+3] <= 1'b1;
                  spc18_inst_done         <= `TILE18.piton_pc_vld;
                  spc18_phy_pc_w          <= `TILE18.piton_pc;
                end
            end
    

            assign spc19_thread_id = 2'b00;
            assign spc19_rtl_pc = spc19_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(19*4)]   <= 1'b0;
                  active_thread[(19*4)+1] <= 1'b0;
                  active_thread[(19*4)+2] <= 1'b0;
                  active_thread[(19*4)+3] <= 1'b0;
                  spc19_inst_done         <= 0;
                  spc19_phy_pc_w          <= 0;
                end else begin
                  active_thread[(19*4)]   <= 1'b1;
                  active_thread[(19*4)+1] <= 1'b1;
                  active_thread[(19*4)+2] <= 1'b1;
                  active_thread[(19*4)+3] <= 1'b1;
                  spc19_inst_done         <= `TILE19.piton_pc_vld;
                  spc19_phy_pc_w          <= `TILE19.piton_pc;
                end
            end
    

            assign spc20_thread_id = 2'b00;
            assign spc20_rtl_pc = spc20_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(20*4)]   <= 1'b0;
                  active_thread[(20*4)+1] <= 1'b0;
                  active_thread[(20*4)+2] <= 1'b0;
                  active_thread[(20*4)+3] <= 1'b0;
                  spc20_inst_done         <= 0;
                  spc20_phy_pc_w          <= 0;
                end else begin
                  active_thread[(20*4)]   <= 1'b1;
                  active_thread[(20*4)+1] <= 1'b1;
                  active_thread[(20*4)+2] <= 1'b1;
                  active_thread[(20*4)+3] <= 1'b1;
                  spc20_inst_done         <= `TILE20.piton_pc_vld;
                  spc20_phy_pc_w          <= `TILE20.piton_pc;
                end
            end
    

            assign spc21_thread_id = 2'b00;
            assign spc21_rtl_pc = spc21_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(21*4)]   <= 1'b0;
                  active_thread[(21*4)+1] <= 1'b0;
                  active_thread[(21*4)+2] <= 1'b0;
                  active_thread[(21*4)+3] <= 1'b0;
                  spc21_inst_done         <= 0;
                  spc21_phy_pc_w          <= 0;
                end else begin
                  active_thread[(21*4)]   <= 1'b1;
                  active_thread[(21*4)+1] <= 1'b1;
                  active_thread[(21*4)+2] <= 1'b1;
                  active_thread[(21*4)+3] <= 1'b1;
                  spc21_inst_done         <= `TILE21.piton_pc_vld;
                  spc21_phy_pc_w          <= `TILE21.piton_pc;
                end
            end
    

            assign spc22_thread_id = 2'b00;
            assign spc22_rtl_pc = spc22_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(22*4)]   <= 1'b0;
                  active_thread[(22*4)+1] <= 1'b0;
                  active_thread[(22*4)+2] <= 1'b0;
                  active_thread[(22*4)+3] <= 1'b0;
                  spc22_inst_done         <= 0;
                  spc22_phy_pc_w          <= 0;
                end else begin
                  active_thread[(22*4)]   <= 1'b1;
                  active_thread[(22*4)+1] <= 1'b1;
                  active_thread[(22*4)+2] <= 1'b1;
                  active_thread[(22*4)+3] <= 1'b1;
                  spc22_inst_done         <= `TILE22.piton_pc_vld;
                  spc22_phy_pc_w          <= `TILE22.piton_pc;
                end
            end
    

            assign spc23_thread_id = 2'b00;
            assign spc23_rtl_pc = spc23_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(23*4)]   <= 1'b0;
                  active_thread[(23*4)+1] <= 1'b0;
                  active_thread[(23*4)+2] <= 1'b0;
                  active_thread[(23*4)+3] <= 1'b0;
                  spc23_inst_done         <= 0;
                  spc23_phy_pc_w          <= 0;
                end else begin
                  active_thread[(23*4)]   <= 1'b1;
                  active_thread[(23*4)+1] <= 1'b1;
                  active_thread[(23*4)+2] <= 1'b1;
                  active_thread[(23*4)+3] <= 1'b1;
                  spc23_inst_done         <= `TILE23.piton_pc_vld;
                  spc23_phy_pc_w          <= `TILE23.piton_pc;
                end
            end
    

            assign spc24_thread_id = 2'b00;
            assign spc24_rtl_pc = spc24_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(24*4)]   <= 1'b0;
                  active_thread[(24*4)+1] <= 1'b0;
                  active_thread[(24*4)+2] <= 1'b0;
                  active_thread[(24*4)+3] <= 1'b0;
                  spc24_inst_done         <= 0;
                  spc24_phy_pc_w          <= 0;
                end else begin
                  active_thread[(24*4)]   <= 1'b1;
                  active_thread[(24*4)+1] <= 1'b1;
                  active_thread[(24*4)+2] <= 1'b1;
                  active_thread[(24*4)+3] <= 1'b1;
                  spc24_inst_done         <= `TILE24.piton_pc_vld;
                  spc24_phy_pc_w          <= `TILE24.piton_pc;
                end
            end
    

            assign spc25_thread_id = 2'b00;
            assign spc25_rtl_pc = spc25_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(25*4)]   <= 1'b0;
                  active_thread[(25*4)+1] <= 1'b0;
                  active_thread[(25*4)+2] <= 1'b0;
                  active_thread[(25*4)+3] <= 1'b0;
                  spc25_inst_done         <= 0;
                  spc25_phy_pc_w          <= 0;
                end else begin
                  active_thread[(25*4)]   <= 1'b1;
                  active_thread[(25*4)+1] <= 1'b1;
                  active_thread[(25*4)+2] <= 1'b1;
                  active_thread[(25*4)+3] <= 1'b1;
                  spc25_inst_done         <= `TILE25.piton_pc_vld;
                  spc25_phy_pc_w          <= `TILE25.piton_pc;
                end
            end
    

            assign spc26_thread_id = 2'b00;
            assign spc26_rtl_pc = spc26_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(26*4)]   <= 1'b0;
                  active_thread[(26*4)+1] <= 1'b0;
                  active_thread[(26*4)+2] <= 1'b0;
                  active_thread[(26*4)+3] <= 1'b0;
                  spc26_inst_done         <= 0;
                  spc26_phy_pc_w          <= 0;
                end else begin
                  active_thread[(26*4)]   <= 1'b1;
                  active_thread[(26*4)+1] <= 1'b1;
                  active_thread[(26*4)+2] <= 1'b1;
                  active_thread[(26*4)+3] <= 1'b1;
                  spc26_inst_done         <= `TILE26.piton_pc_vld;
                  spc26_phy_pc_w          <= `TILE26.piton_pc;
                end
            end
    

            assign spc27_thread_id = 2'b00;
            assign spc27_rtl_pc = spc27_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(27*4)]   <= 1'b0;
                  active_thread[(27*4)+1] <= 1'b0;
                  active_thread[(27*4)+2] <= 1'b0;
                  active_thread[(27*4)+3] <= 1'b0;
                  spc27_inst_done         <= 0;
                  spc27_phy_pc_w          <= 0;
                end else begin
                  active_thread[(27*4)]   <= 1'b1;
                  active_thread[(27*4)+1] <= 1'b1;
                  active_thread[(27*4)+2] <= 1'b1;
                  active_thread[(27*4)+3] <= 1'b1;
                  spc27_inst_done         <= `TILE27.piton_pc_vld;
                  spc27_phy_pc_w          <= `TILE27.piton_pc;
                end
            end
    

            assign spc28_thread_id = 2'b00;
            assign spc28_rtl_pc = spc28_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(28*4)]   <= 1'b0;
                  active_thread[(28*4)+1] <= 1'b0;
                  active_thread[(28*4)+2] <= 1'b0;
                  active_thread[(28*4)+3] <= 1'b0;
                  spc28_inst_done         <= 0;
                  spc28_phy_pc_w          <= 0;
                end else begin
                  active_thread[(28*4)]   <= 1'b1;
                  active_thread[(28*4)+1] <= 1'b1;
                  active_thread[(28*4)+2] <= 1'b1;
                  active_thread[(28*4)+3] <= 1'b1;
                  spc28_inst_done         <= `TILE28.piton_pc_vld;
                  spc28_phy_pc_w          <= `TILE28.piton_pc;
                end
            end
    

            assign spc29_thread_id = 2'b00;
            assign spc29_rtl_pc = spc29_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(29*4)]   <= 1'b0;
                  active_thread[(29*4)+1] <= 1'b0;
                  active_thread[(29*4)+2] <= 1'b0;
                  active_thread[(29*4)+3] <= 1'b0;
                  spc29_inst_done         <= 0;
                  spc29_phy_pc_w          <= 0;
                end else begin
                  active_thread[(29*4)]   <= 1'b1;
                  active_thread[(29*4)+1] <= 1'b1;
                  active_thread[(29*4)+2] <= 1'b1;
                  active_thread[(29*4)+3] <= 1'b1;
                  spc29_inst_done         <= `TILE29.piton_pc_vld;
                  spc29_phy_pc_w          <= `TILE29.piton_pc;
                end
            end
    

            assign spc30_thread_id = 2'b00;
            assign spc30_rtl_pc = spc30_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(30*4)]   <= 1'b0;
                  active_thread[(30*4)+1] <= 1'b0;
                  active_thread[(30*4)+2] <= 1'b0;
                  active_thread[(30*4)+3] <= 1'b0;
                  spc30_inst_done         <= 0;
                  spc30_phy_pc_w          <= 0;
                end else begin
                  active_thread[(30*4)]   <= 1'b1;
                  active_thread[(30*4)+1] <= 1'b1;
                  active_thread[(30*4)+2] <= 1'b1;
                  active_thread[(30*4)+3] <= 1'b1;
                  spc30_inst_done         <= `TILE30.piton_pc_vld;
                  spc30_phy_pc_w          <= `TILE30.piton_pc;
                end
            end
    

            assign spc31_thread_id = 2'b00;
            assign spc31_rtl_pc = spc31_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(31*4)]   <= 1'b0;
                  active_thread[(31*4)+1] <= 1'b0;
                  active_thread[(31*4)+2] <= 1'b0;
                  active_thread[(31*4)+3] <= 1'b0;
                  spc31_inst_done         <= 0;
                  spc31_phy_pc_w          <= 0;
                end else begin
                  active_thread[(31*4)]   <= 1'b1;
                  active_thread[(31*4)+1] <= 1'b1;
                  active_thread[(31*4)+2] <= 1'b1;
                  active_thread[(31*4)+3] <= 1'b1;
                  spc31_inst_done         <= `TILE31.piton_pc_vld;
                  spc31_phy_pc_w          <= `TILE31.piton_pc;
                end
            end
    

            assign spc32_thread_id = 2'b00;
            assign spc32_rtl_pc = spc32_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(32*4)]   <= 1'b0;
                  active_thread[(32*4)+1] <= 1'b0;
                  active_thread[(32*4)+2] <= 1'b0;
                  active_thread[(32*4)+3] <= 1'b0;
                  spc32_inst_done         <= 0;
                  spc32_phy_pc_w          <= 0;
                end else begin
                  active_thread[(32*4)]   <= 1'b1;
                  active_thread[(32*4)+1] <= 1'b1;
                  active_thread[(32*4)+2] <= 1'b1;
                  active_thread[(32*4)+3] <= 1'b1;
                  spc32_inst_done         <= `TILE32.piton_pc_vld;
                  spc32_phy_pc_w          <= `TILE32.piton_pc;
                end
            end
    

            assign spc33_thread_id = 2'b00;
            assign spc33_rtl_pc = spc33_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(33*4)]   <= 1'b0;
                  active_thread[(33*4)+1] <= 1'b0;
                  active_thread[(33*4)+2] <= 1'b0;
                  active_thread[(33*4)+3] <= 1'b0;
                  spc33_inst_done         <= 0;
                  spc33_phy_pc_w          <= 0;
                end else begin
                  active_thread[(33*4)]   <= 1'b1;
                  active_thread[(33*4)+1] <= 1'b1;
                  active_thread[(33*4)+2] <= 1'b1;
                  active_thread[(33*4)+3] <= 1'b1;
                  spc33_inst_done         <= `TILE33.piton_pc_vld;
                  spc33_phy_pc_w          <= `TILE33.piton_pc;
                end
            end
    

            assign spc34_thread_id = 2'b00;
            assign spc34_rtl_pc = spc34_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(34*4)]   <= 1'b0;
                  active_thread[(34*4)+1] <= 1'b0;
                  active_thread[(34*4)+2] <= 1'b0;
                  active_thread[(34*4)+3] <= 1'b0;
                  spc34_inst_done         <= 0;
                  spc34_phy_pc_w          <= 0;
                end else begin
                  active_thread[(34*4)]   <= 1'b1;
                  active_thread[(34*4)+1] <= 1'b1;
                  active_thread[(34*4)+2] <= 1'b1;
                  active_thread[(34*4)+3] <= 1'b1;
                  spc34_inst_done         <= `TILE34.piton_pc_vld;
                  spc34_phy_pc_w          <= `TILE34.piton_pc;
                end
            end
    

            assign spc35_thread_id = 2'b00;
            assign spc35_rtl_pc = spc35_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(35*4)]   <= 1'b0;
                  active_thread[(35*4)+1] <= 1'b0;
                  active_thread[(35*4)+2] <= 1'b0;
                  active_thread[(35*4)+3] <= 1'b0;
                  spc35_inst_done         <= 0;
                  spc35_phy_pc_w          <= 0;
                end else begin
                  active_thread[(35*4)]   <= 1'b1;
                  active_thread[(35*4)+1] <= 1'b1;
                  active_thread[(35*4)+2] <= 1'b1;
                  active_thread[(35*4)+3] <= 1'b1;
                  spc35_inst_done         <= `TILE35.piton_pc_vld;
                  spc35_phy_pc_w          <= `TILE35.piton_pc;
                end
            end
    

            assign spc36_thread_id = 2'b00;
            assign spc36_rtl_pc = spc36_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(36*4)]   <= 1'b0;
                  active_thread[(36*4)+1] <= 1'b0;
                  active_thread[(36*4)+2] <= 1'b0;
                  active_thread[(36*4)+3] <= 1'b0;
                  spc36_inst_done         <= 0;
                  spc36_phy_pc_w          <= 0;
                end else begin
                  active_thread[(36*4)]   <= 1'b1;
                  active_thread[(36*4)+1] <= 1'b1;
                  active_thread[(36*4)+2] <= 1'b1;
                  active_thread[(36*4)+3] <= 1'b1;
                  spc36_inst_done         <= `TILE36.piton_pc_vld;
                  spc36_phy_pc_w          <= `TILE36.piton_pc;
                end
            end
    

            assign spc37_thread_id = 2'b00;
            assign spc37_rtl_pc = spc37_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(37*4)]   <= 1'b0;
                  active_thread[(37*4)+1] <= 1'b0;
                  active_thread[(37*4)+2] <= 1'b0;
                  active_thread[(37*4)+3] <= 1'b0;
                  spc37_inst_done         <= 0;
                  spc37_phy_pc_w          <= 0;
                end else begin
                  active_thread[(37*4)]   <= 1'b1;
                  active_thread[(37*4)+1] <= 1'b1;
                  active_thread[(37*4)+2] <= 1'b1;
                  active_thread[(37*4)+3] <= 1'b1;
                  spc37_inst_done         <= `TILE37.piton_pc_vld;
                  spc37_phy_pc_w          <= `TILE37.piton_pc;
                end
            end
    

            assign spc38_thread_id = 2'b00;
            assign spc38_rtl_pc = spc38_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(38*4)]   <= 1'b0;
                  active_thread[(38*4)+1] <= 1'b0;
                  active_thread[(38*4)+2] <= 1'b0;
                  active_thread[(38*4)+3] <= 1'b0;
                  spc38_inst_done         <= 0;
                  spc38_phy_pc_w          <= 0;
                end else begin
                  active_thread[(38*4)]   <= 1'b1;
                  active_thread[(38*4)+1] <= 1'b1;
                  active_thread[(38*4)+2] <= 1'b1;
                  active_thread[(38*4)+3] <= 1'b1;
                  spc38_inst_done         <= `TILE38.piton_pc_vld;
                  spc38_phy_pc_w          <= `TILE38.piton_pc;
                end
            end
    

            assign spc39_thread_id = 2'b00;
            assign spc39_rtl_pc = spc39_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(39*4)]   <= 1'b0;
                  active_thread[(39*4)+1] <= 1'b0;
                  active_thread[(39*4)+2] <= 1'b0;
                  active_thread[(39*4)+3] <= 1'b0;
                  spc39_inst_done         <= 0;
                  spc39_phy_pc_w          <= 0;
                end else begin
                  active_thread[(39*4)]   <= 1'b1;
                  active_thread[(39*4)+1] <= 1'b1;
                  active_thread[(39*4)+2] <= 1'b1;
                  active_thread[(39*4)+3] <= 1'b1;
                  spc39_inst_done         <= `TILE39.piton_pc_vld;
                  spc39_phy_pc_w          <= `TILE39.piton_pc;
                end
            end
    

            assign spc40_thread_id = 2'b00;
            assign spc40_rtl_pc = spc40_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(40*4)]   <= 1'b0;
                  active_thread[(40*4)+1] <= 1'b0;
                  active_thread[(40*4)+2] <= 1'b0;
                  active_thread[(40*4)+3] <= 1'b0;
                  spc40_inst_done         <= 0;
                  spc40_phy_pc_w          <= 0;
                end else begin
                  active_thread[(40*4)]   <= 1'b1;
                  active_thread[(40*4)+1] <= 1'b1;
                  active_thread[(40*4)+2] <= 1'b1;
                  active_thread[(40*4)+3] <= 1'b1;
                  spc40_inst_done         <= `TILE40.piton_pc_vld;
                  spc40_phy_pc_w          <= `TILE40.piton_pc;
                end
            end
    

            assign spc41_thread_id = 2'b00;
            assign spc41_rtl_pc = spc41_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(41*4)]   <= 1'b0;
                  active_thread[(41*4)+1] <= 1'b0;
                  active_thread[(41*4)+2] <= 1'b0;
                  active_thread[(41*4)+3] <= 1'b0;
                  spc41_inst_done         <= 0;
                  spc41_phy_pc_w          <= 0;
                end else begin
                  active_thread[(41*4)]   <= 1'b1;
                  active_thread[(41*4)+1] <= 1'b1;
                  active_thread[(41*4)+2] <= 1'b1;
                  active_thread[(41*4)+3] <= 1'b1;
                  spc41_inst_done         <= `TILE41.piton_pc_vld;
                  spc41_phy_pc_w          <= `TILE41.piton_pc;
                end
            end
    

            assign spc42_thread_id = 2'b00;
            assign spc42_rtl_pc = spc42_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(42*4)]   <= 1'b0;
                  active_thread[(42*4)+1] <= 1'b0;
                  active_thread[(42*4)+2] <= 1'b0;
                  active_thread[(42*4)+3] <= 1'b0;
                  spc42_inst_done         <= 0;
                  spc42_phy_pc_w          <= 0;
                end else begin
                  active_thread[(42*4)]   <= 1'b1;
                  active_thread[(42*4)+1] <= 1'b1;
                  active_thread[(42*4)+2] <= 1'b1;
                  active_thread[(42*4)+3] <= 1'b1;
                  spc42_inst_done         <= `TILE42.piton_pc_vld;
                  spc42_phy_pc_w          <= `TILE42.piton_pc;
                end
            end
    

            assign spc43_thread_id = 2'b00;
            assign spc43_rtl_pc = spc43_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(43*4)]   <= 1'b0;
                  active_thread[(43*4)+1] <= 1'b0;
                  active_thread[(43*4)+2] <= 1'b0;
                  active_thread[(43*4)+3] <= 1'b0;
                  spc43_inst_done         <= 0;
                  spc43_phy_pc_w          <= 0;
                end else begin
                  active_thread[(43*4)]   <= 1'b1;
                  active_thread[(43*4)+1] <= 1'b1;
                  active_thread[(43*4)+2] <= 1'b1;
                  active_thread[(43*4)+3] <= 1'b1;
                  spc43_inst_done         <= `TILE43.piton_pc_vld;
                  spc43_phy_pc_w          <= `TILE43.piton_pc;
                end
            end
    

            assign spc44_thread_id = 2'b00;
            assign spc44_rtl_pc = spc44_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(44*4)]   <= 1'b0;
                  active_thread[(44*4)+1] <= 1'b0;
                  active_thread[(44*4)+2] <= 1'b0;
                  active_thread[(44*4)+3] <= 1'b0;
                  spc44_inst_done         <= 0;
                  spc44_phy_pc_w          <= 0;
                end else begin
                  active_thread[(44*4)]   <= 1'b1;
                  active_thread[(44*4)+1] <= 1'b1;
                  active_thread[(44*4)+2] <= 1'b1;
                  active_thread[(44*4)+3] <= 1'b1;
                  spc44_inst_done         <= `TILE44.piton_pc_vld;
                  spc44_phy_pc_w          <= `TILE44.piton_pc;
                end
            end
    

            assign spc45_thread_id = 2'b00;
            assign spc45_rtl_pc = spc45_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(45*4)]   <= 1'b0;
                  active_thread[(45*4)+1] <= 1'b0;
                  active_thread[(45*4)+2] <= 1'b0;
                  active_thread[(45*4)+3] <= 1'b0;
                  spc45_inst_done         <= 0;
                  spc45_phy_pc_w          <= 0;
                end else begin
                  active_thread[(45*4)]   <= 1'b1;
                  active_thread[(45*4)+1] <= 1'b1;
                  active_thread[(45*4)+2] <= 1'b1;
                  active_thread[(45*4)+3] <= 1'b1;
                  spc45_inst_done         <= `TILE45.piton_pc_vld;
                  spc45_phy_pc_w          <= `TILE45.piton_pc;
                end
            end
    

            assign spc46_thread_id = 2'b00;
            assign spc46_rtl_pc = spc46_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(46*4)]   <= 1'b0;
                  active_thread[(46*4)+1] <= 1'b0;
                  active_thread[(46*4)+2] <= 1'b0;
                  active_thread[(46*4)+3] <= 1'b0;
                  spc46_inst_done         <= 0;
                  spc46_phy_pc_w          <= 0;
                end else begin
                  active_thread[(46*4)]   <= 1'b1;
                  active_thread[(46*4)+1] <= 1'b1;
                  active_thread[(46*4)+2] <= 1'b1;
                  active_thread[(46*4)+3] <= 1'b1;
                  spc46_inst_done         <= `TILE46.piton_pc_vld;
                  spc46_phy_pc_w          <= `TILE46.piton_pc;
                end
            end
    

            assign spc47_thread_id = 2'b00;
            assign spc47_rtl_pc = spc47_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(47*4)]   <= 1'b0;
                  active_thread[(47*4)+1] <= 1'b0;
                  active_thread[(47*4)+2] <= 1'b0;
                  active_thread[(47*4)+3] <= 1'b0;
                  spc47_inst_done         <= 0;
                  spc47_phy_pc_w          <= 0;
                end else begin
                  active_thread[(47*4)]   <= 1'b1;
                  active_thread[(47*4)+1] <= 1'b1;
                  active_thread[(47*4)+2] <= 1'b1;
                  active_thread[(47*4)+3] <= 1'b1;
                  spc47_inst_done         <= `TILE47.piton_pc_vld;
                  spc47_phy_pc_w          <= `TILE47.piton_pc;
                end
            end
    

            assign spc48_thread_id = 2'b00;
            assign spc48_rtl_pc = spc48_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(48*4)]   <= 1'b0;
                  active_thread[(48*4)+1] <= 1'b0;
                  active_thread[(48*4)+2] <= 1'b0;
                  active_thread[(48*4)+3] <= 1'b0;
                  spc48_inst_done         <= 0;
                  spc48_phy_pc_w          <= 0;
                end else begin
                  active_thread[(48*4)]   <= 1'b1;
                  active_thread[(48*4)+1] <= 1'b1;
                  active_thread[(48*4)+2] <= 1'b1;
                  active_thread[(48*4)+3] <= 1'b1;
                  spc48_inst_done         <= `TILE48.piton_pc_vld;
                  spc48_phy_pc_w          <= `TILE48.piton_pc;
                end
            end
    

            assign spc49_thread_id = 2'b00;
            assign spc49_rtl_pc = spc49_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(49*4)]   <= 1'b0;
                  active_thread[(49*4)+1] <= 1'b0;
                  active_thread[(49*4)+2] <= 1'b0;
                  active_thread[(49*4)+3] <= 1'b0;
                  spc49_inst_done         <= 0;
                  spc49_phy_pc_w          <= 0;
                end else begin
                  active_thread[(49*4)]   <= 1'b1;
                  active_thread[(49*4)+1] <= 1'b1;
                  active_thread[(49*4)+2] <= 1'b1;
                  active_thread[(49*4)+3] <= 1'b1;
                  spc49_inst_done         <= `TILE49.piton_pc_vld;
                  spc49_phy_pc_w          <= `TILE49.piton_pc;
                end
            end
    

            assign spc50_thread_id = 2'b00;
            assign spc50_rtl_pc = spc50_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(50*4)]   <= 1'b0;
                  active_thread[(50*4)+1] <= 1'b0;
                  active_thread[(50*4)+2] <= 1'b0;
                  active_thread[(50*4)+3] <= 1'b0;
                  spc50_inst_done         <= 0;
                  spc50_phy_pc_w          <= 0;
                end else begin
                  active_thread[(50*4)]   <= 1'b1;
                  active_thread[(50*4)+1] <= 1'b1;
                  active_thread[(50*4)+2] <= 1'b1;
                  active_thread[(50*4)+3] <= 1'b1;
                  spc50_inst_done         <= `TILE50.piton_pc_vld;
                  spc50_phy_pc_w          <= `TILE50.piton_pc;
                end
            end
    

            assign spc51_thread_id = 2'b00;
            assign spc51_rtl_pc = spc51_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(51*4)]   <= 1'b0;
                  active_thread[(51*4)+1] <= 1'b0;
                  active_thread[(51*4)+2] <= 1'b0;
                  active_thread[(51*4)+3] <= 1'b0;
                  spc51_inst_done         <= 0;
                  spc51_phy_pc_w          <= 0;
                end else begin
                  active_thread[(51*4)]   <= 1'b1;
                  active_thread[(51*4)+1] <= 1'b1;
                  active_thread[(51*4)+2] <= 1'b1;
                  active_thread[(51*4)+3] <= 1'b1;
                  spc51_inst_done         <= `TILE51.piton_pc_vld;
                  spc51_phy_pc_w          <= `TILE51.piton_pc;
                end
            end
    

            assign spc52_thread_id = 2'b00;
            assign spc52_rtl_pc = spc52_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(52*4)]   <= 1'b0;
                  active_thread[(52*4)+1] <= 1'b0;
                  active_thread[(52*4)+2] <= 1'b0;
                  active_thread[(52*4)+3] <= 1'b0;
                  spc52_inst_done         <= 0;
                  spc52_phy_pc_w          <= 0;
                end else begin
                  active_thread[(52*4)]   <= 1'b1;
                  active_thread[(52*4)+1] <= 1'b1;
                  active_thread[(52*4)+2] <= 1'b1;
                  active_thread[(52*4)+3] <= 1'b1;
                  spc52_inst_done         <= `TILE52.piton_pc_vld;
                  spc52_phy_pc_w          <= `TILE52.piton_pc;
                end
            end
    

            assign spc53_thread_id = 2'b00;
            assign spc53_rtl_pc = spc53_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(53*4)]   <= 1'b0;
                  active_thread[(53*4)+1] <= 1'b0;
                  active_thread[(53*4)+2] <= 1'b0;
                  active_thread[(53*4)+3] <= 1'b0;
                  spc53_inst_done         <= 0;
                  spc53_phy_pc_w          <= 0;
                end else begin
                  active_thread[(53*4)]   <= 1'b1;
                  active_thread[(53*4)+1] <= 1'b1;
                  active_thread[(53*4)+2] <= 1'b1;
                  active_thread[(53*4)+3] <= 1'b1;
                  spc53_inst_done         <= `TILE53.piton_pc_vld;
                  spc53_phy_pc_w          <= `TILE53.piton_pc;
                end
            end
    

            assign spc54_thread_id = 2'b00;
            assign spc54_rtl_pc = spc54_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(54*4)]   <= 1'b0;
                  active_thread[(54*4)+1] <= 1'b0;
                  active_thread[(54*4)+2] <= 1'b0;
                  active_thread[(54*4)+3] <= 1'b0;
                  spc54_inst_done         <= 0;
                  spc54_phy_pc_w          <= 0;
                end else begin
                  active_thread[(54*4)]   <= 1'b1;
                  active_thread[(54*4)+1] <= 1'b1;
                  active_thread[(54*4)+2] <= 1'b1;
                  active_thread[(54*4)+3] <= 1'b1;
                  spc54_inst_done         <= `TILE54.piton_pc_vld;
                  spc54_phy_pc_w          <= `TILE54.piton_pc;
                end
            end
    

            assign spc55_thread_id = 2'b00;
            assign spc55_rtl_pc = spc55_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(55*4)]   <= 1'b0;
                  active_thread[(55*4)+1] <= 1'b0;
                  active_thread[(55*4)+2] <= 1'b0;
                  active_thread[(55*4)+3] <= 1'b0;
                  spc55_inst_done         <= 0;
                  spc55_phy_pc_w          <= 0;
                end else begin
                  active_thread[(55*4)]   <= 1'b1;
                  active_thread[(55*4)+1] <= 1'b1;
                  active_thread[(55*4)+2] <= 1'b1;
                  active_thread[(55*4)+3] <= 1'b1;
                  spc55_inst_done         <= `TILE55.piton_pc_vld;
                  spc55_phy_pc_w          <= `TILE55.piton_pc;
                end
            end
    

            assign spc56_thread_id = 2'b00;
            assign spc56_rtl_pc = spc56_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(56*4)]   <= 1'b0;
                  active_thread[(56*4)+1] <= 1'b0;
                  active_thread[(56*4)+2] <= 1'b0;
                  active_thread[(56*4)+3] <= 1'b0;
                  spc56_inst_done         <= 0;
                  spc56_phy_pc_w          <= 0;
                end else begin
                  active_thread[(56*4)]   <= 1'b1;
                  active_thread[(56*4)+1] <= 1'b1;
                  active_thread[(56*4)+2] <= 1'b1;
                  active_thread[(56*4)+3] <= 1'b1;
                  spc56_inst_done         <= `TILE56.piton_pc_vld;
                  spc56_phy_pc_w          <= `TILE56.piton_pc;
                end
            end
    

            assign spc57_thread_id = 2'b00;
            assign spc57_rtl_pc = spc57_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(57*4)]   <= 1'b0;
                  active_thread[(57*4)+1] <= 1'b0;
                  active_thread[(57*4)+2] <= 1'b0;
                  active_thread[(57*4)+3] <= 1'b0;
                  spc57_inst_done         <= 0;
                  spc57_phy_pc_w          <= 0;
                end else begin
                  active_thread[(57*4)]   <= 1'b1;
                  active_thread[(57*4)+1] <= 1'b1;
                  active_thread[(57*4)+2] <= 1'b1;
                  active_thread[(57*4)+3] <= 1'b1;
                  spc57_inst_done         <= `TILE57.piton_pc_vld;
                  spc57_phy_pc_w          <= `TILE57.piton_pc;
                end
            end
    

            assign spc58_thread_id = 2'b00;
            assign spc58_rtl_pc = spc58_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(58*4)]   <= 1'b0;
                  active_thread[(58*4)+1] <= 1'b0;
                  active_thread[(58*4)+2] <= 1'b0;
                  active_thread[(58*4)+3] <= 1'b0;
                  spc58_inst_done         <= 0;
                  spc58_phy_pc_w          <= 0;
                end else begin
                  active_thread[(58*4)]   <= 1'b1;
                  active_thread[(58*4)+1] <= 1'b1;
                  active_thread[(58*4)+2] <= 1'b1;
                  active_thread[(58*4)+3] <= 1'b1;
                  spc58_inst_done         <= `TILE58.piton_pc_vld;
                  spc58_phy_pc_w          <= `TILE58.piton_pc;
                end
            end
    

            assign spc59_thread_id = 2'b00;
            assign spc59_rtl_pc = spc59_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(59*4)]   <= 1'b0;
                  active_thread[(59*4)+1] <= 1'b0;
                  active_thread[(59*4)+2] <= 1'b0;
                  active_thread[(59*4)+3] <= 1'b0;
                  spc59_inst_done         <= 0;
                  spc59_phy_pc_w          <= 0;
                end else begin
                  active_thread[(59*4)]   <= 1'b1;
                  active_thread[(59*4)+1] <= 1'b1;
                  active_thread[(59*4)+2] <= 1'b1;
                  active_thread[(59*4)+3] <= 1'b1;
                  spc59_inst_done         <= `TILE59.piton_pc_vld;
                  spc59_phy_pc_w          <= `TILE59.piton_pc;
                end
            end
    

            assign spc60_thread_id = 2'b00;
            assign spc60_rtl_pc = spc60_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(60*4)]   <= 1'b0;
                  active_thread[(60*4)+1] <= 1'b0;
                  active_thread[(60*4)+2] <= 1'b0;
                  active_thread[(60*4)+3] <= 1'b0;
                  spc60_inst_done         <= 0;
                  spc60_phy_pc_w          <= 0;
                end else begin
                  active_thread[(60*4)]   <= 1'b1;
                  active_thread[(60*4)+1] <= 1'b1;
                  active_thread[(60*4)+2] <= 1'b1;
                  active_thread[(60*4)+3] <= 1'b1;
                  spc60_inst_done         <= `TILE60.piton_pc_vld;
                  spc60_phy_pc_w          <= `TILE60.piton_pc;
                end
            end
    

            assign spc61_thread_id = 2'b00;
            assign spc61_rtl_pc = spc61_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(61*4)]   <= 1'b0;
                  active_thread[(61*4)+1] <= 1'b0;
                  active_thread[(61*4)+2] <= 1'b0;
                  active_thread[(61*4)+3] <= 1'b0;
                  spc61_inst_done         <= 0;
                  spc61_phy_pc_w          <= 0;
                end else begin
                  active_thread[(61*4)]   <= 1'b1;
                  active_thread[(61*4)+1] <= 1'b1;
                  active_thread[(61*4)+2] <= 1'b1;
                  active_thread[(61*4)+3] <= 1'b1;
                  spc61_inst_done         <= `TILE61.piton_pc_vld;
                  spc61_phy_pc_w          <= `TILE61.piton_pc;
                end
            end
    

            assign spc62_thread_id = 2'b00;
            assign spc62_rtl_pc = spc62_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(62*4)]   <= 1'b0;
                  active_thread[(62*4)+1] <= 1'b0;
                  active_thread[(62*4)+2] <= 1'b0;
                  active_thread[(62*4)+3] <= 1'b0;
                  spc62_inst_done         <= 0;
                  spc62_phy_pc_w          <= 0;
                end else begin
                  active_thread[(62*4)]   <= 1'b1;
                  active_thread[(62*4)+1] <= 1'b1;
                  active_thread[(62*4)+2] <= 1'b1;
                  active_thread[(62*4)+3] <= 1'b1;
                  spc62_inst_done         <= `TILE62.piton_pc_vld;
                  spc62_phy_pc_w          <= `TILE62.piton_pc;
                end
            end
    

            assign spc63_thread_id = 2'b00;
            assign spc63_rtl_pc = spc63_phy_pc_w;

            always @(posedge clk) begin
                if (~rst_l) begin
                  active_thread[(63*4)]   <= 1'b0;
                  active_thread[(63*4)+1] <= 1'b0;
                  active_thread[(63*4)+2] <= 1'b0;
                  active_thread[(63*4)+3] <= 1'b0;
                  spc63_inst_done         <= 0;
                  spc63_phy_pc_w          <= 0;
                end else begin
                  active_thread[(63*4)]   <= 1'b1;
                  active_thread[(63*4)+1] <= 1'b1;
                  active_thread[(63*4)+2] <= 1'b1;
                  active_thread[(63*4)+3] <= 1'b1;
                  spc63_inst_done         <= `TILE63.piton_pc_vld;
                  spc63_phy_pc_w          <= `TILE63.piton_pc;
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

    wire[31:0] long_cpuid16;
    assign long_cpuid16 = {30'd16, spc16_thread_id};

    wire[31:0] long_cpuid17;
    assign long_cpuid17 = {30'd17, spc17_thread_id};

    wire[31:0] long_cpuid18;
    assign long_cpuid18 = {30'd18, spc18_thread_id};

    wire[31:0] long_cpuid19;
    assign long_cpuid19 = {30'd19, spc19_thread_id};

    wire[31:0] long_cpuid20;
    assign long_cpuid20 = {30'd20, spc20_thread_id};

    wire[31:0] long_cpuid21;
    assign long_cpuid21 = {30'd21, spc21_thread_id};

    wire[31:0] long_cpuid22;
    assign long_cpuid22 = {30'd22, spc22_thread_id};

    wire[31:0] long_cpuid23;
    assign long_cpuid23 = {30'd23, spc23_thread_id};

    wire[31:0] long_cpuid24;
    assign long_cpuid24 = {30'd24, spc24_thread_id};

    wire[31:0] long_cpuid25;
    assign long_cpuid25 = {30'd25, spc25_thread_id};

    wire[31:0] long_cpuid26;
    assign long_cpuid26 = {30'd26, spc26_thread_id};

    wire[31:0] long_cpuid27;
    assign long_cpuid27 = {30'd27, spc27_thread_id};

    wire[31:0] long_cpuid28;
    assign long_cpuid28 = {30'd28, spc28_thread_id};

    wire[31:0] long_cpuid29;
    assign long_cpuid29 = {30'd29, spc29_thread_id};

    wire[31:0] long_cpuid30;
    assign long_cpuid30 = {30'd30, spc30_thread_id};

    wire[31:0] long_cpuid31;
    assign long_cpuid31 = {30'd31, spc31_thread_id};

    wire[31:0] long_cpuid32;
    assign long_cpuid32 = {30'd32, spc32_thread_id};

    wire[31:0] long_cpuid33;
    assign long_cpuid33 = {30'd33, spc33_thread_id};

    wire[31:0] long_cpuid34;
    assign long_cpuid34 = {30'd34, spc34_thread_id};

    wire[31:0] long_cpuid35;
    assign long_cpuid35 = {30'd35, spc35_thread_id};

    wire[31:0] long_cpuid36;
    assign long_cpuid36 = {30'd36, spc36_thread_id};

    wire[31:0] long_cpuid37;
    assign long_cpuid37 = {30'd37, spc37_thread_id};

    wire[31:0] long_cpuid38;
    assign long_cpuid38 = {30'd38, spc38_thread_id};

    wire[31:0] long_cpuid39;
    assign long_cpuid39 = {30'd39, spc39_thread_id};

    wire[31:0] long_cpuid40;
    assign long_cpuid40 = {30'd40, spc40_thread_id};

    wire[31:0] long_cpuid41;
    assign long_cpuid41 = {30'd41, spc41_thread_id};

    wire[31:0] long_cpuid42;
    assign long_cpuid42 = {30'd42, spc42_thread_id};

    wire[31:0] long_cpuid43;
    assign long_cpuid43 = {30'd43, spc43_thread_id};

    wire[31:0] long_cpuid44;
    assign long_cpuid44 = {30'd44, spc44_thread_id};

    wire[31:0] long_cpuid45;
    assign long_cpuid45 = {30'd45, spc45_thread_id};

    wire[31:0] long_cpuid46;
    assign long_cpuid46 = {30'd46, spc46_thread_id};

    wire[31:0] long_cpuid47;
    assign long_cpuid47 = {30'd47, spc47_thread_id};

    wire[31:0] long_cpuid48;
    assign long_cpuid48 = {30'd48, spc48_thread_id};

    wire[31:0] long_cpuid49;
    assign long_cpuid49 = {30'd49, spc49_thread_id};

    wire[31:0] long_cpuid50;
    assign long_cpuid50 = {30'd50, spc50_thread_id};

    wire[31:0] long_cpuid51;
    assign long_cpuid51 = {30'd51, spc51_thread_id};

    wire[31:0] long_cpuid52;
    assign long_cpuid52 = {30'd52, spc52_thread_id};

    wire[31:0] long_cpuid53;
    assign long_cpuid53 = {30'd53, spc53_thread_id};

    wire[31:0] long_cpuid54;
    assign long_cpuid54 = {30'd54, spc54_thread_id};

    wire[31:0] long_cpuid55;
    assign long_cpuid55 = {30'd55, spc55_thread_id};

    wire[31:0] long_cpuid56;
    assign long_cpuid56 = {30'd56, spc56_thread_id};

    wire[31:0] long_cpuid57;
    assign long_cpuid57 = {30'd57, spc57_thread_id};

    wire[31:0] long_cpuid58;
    assign long_cpuid58 = {30'd58, spc58_thread_id};

    wire[31:0] long_cpuid59;
    assign long_cpuid59 = {30'd59, spc59_thread_id};

    wire[31:0] long_cpuid60;
    assign long_cpuid60 = {30'd60, spc60_thread_id};

    wire[31:0] long_cpuid61;
    assign long_cpuid61 = {30'd61, spc61_thread_id};

    wire[31:0] long_cpuid62;
    assign long_cpuid62 = {30'd62, spc62_thread_id};

    wire[31:0] long_cpuid63;
    assign long_cpuid63 = {30'd63, spc63_thread_id};


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
done[16]   = spc16_inst_done;//sparc 16
done[17]   = spc17_inst_done;//sparc 17
done[18]   = spc18_inst_done;//sparc 18
done[19]   = spc19_inst_done;//sparc 19
done[20]   = spc20_inst_done;//sparc 20
done[21]   = spc21_inst_done;//sparc 21
done[22]   = spc22_inst_done;//sparc 22
done[23]   = spc23_inst_done;//sparc 23
done[24]   = spc24_inst_done;//sparc 24
done[25]   = spc25_inst_done;//sparc 25
done[26]   = spc26_inst_done;//sparc 26
done[27]   = spc27_inst_done;//sparc 27
done[28]   = spc28_inst_done;//sparc 28
done[29]   = spc29_inst_done;//sparc 29
done[30]   = spc30_inst_done;//sparc 30
done[31]   = spc31_inst_done;//sparc 31
done[32]   = spc32_inst_done;//sparc 32
done[33]   = spc33_inst_done;//sparc 33
done[34]   = spc34_inst_done;//sparc 34
done[35]   = spc35_inst_done;//sparc 35
done[36]   = spc36_inst_done;//sparc 36
done[37]   = spc37_inst_done;//sparc 37
done[38]   = spc38_inst_done;//sparc 38
done[39]   = spc39_inst_done;//sparc 39
done[40]   = spc40_inst_done;//sparc 40
done[41]   = spc41_inst_done;//sparc 41
done[42]   = spc42_inst_done;//sparc 42
done[43]   = spc43_inst_done;//sparc 43
done[44]   = spc44_inst_done;//sparc 44
done[45]   = spc45_inst_done;//sparc 45
done[46]   = spc46_inst_done;//sparc 46
done[47]   = spc47_inst_done;//sparc 47
done[48]   = spc48_inst_done;//sparc 48
done[49]   = spc49_inst_done;//sparc 49
done[50]   = spc50_inst_done;//sparc 50
done[51]   = spc51_inst_done;//sparc 51
done[52]   = spc52_inst_done;//sparc 52
done[53]   = spc53_inst_done;//sparc 53
done[54]   = spc54_inst_done;//sparc 54
done[55]   = spc55_inst_done;//sparc 55
done[56]   = spc56_inst_done;//sparc 56
done[57]   = spc57_inst_done;//sparc 57
done[58]   = spc58_inst_done;//sparc 58
done[59]   = spc59_inst_done;//sparc 59
done[60]   = spc60_inst_done;//sparc 60
done[61]   = spc61_inst_done;//sparc 61
done[62]   = spc62_inst_done;//sparc 62
done[63]   = spc63_inst_done;//sparc 63


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


string linebuf16 = "";
logic hitMadPrint16 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc16_inst_done && ((spc16_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint16 = 1;
       linebuf16 = {linebuf16, spc16_phy_pc_w[8:1]};
       if (spc16_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 16, linebuf16);
          linebuf16 = "";
       end
    end else begin
       hitMadPrint16 = 0;
    end
  end
end


string linebuf17 = "";
logic hitMadPrint17 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc17_inst_done && ((spc17_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint17 = 1;
       linebuf17 = {linebuf17, spc17_phy_pc_w[8:1]};
       if (spc17_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 17, linebuf17);
          linebuf17 = "";
       end
    end else begin
       hitMadPrint17 = 0;
    end
  end
end


string linebuf18 = "";
logic hitMadPrint18 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc18_inst_done && ((spc18_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint18 = 1;
       linebuf18 = {linebuf18, spc18_phy_pc_w[8:1]};
       if (spc18_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 18, linebuf18);
          linebuf18 = "";
       end
    end else begin
       hitMadPrint18 = 0;
    end
  end
end


string linebuf19 = "";
logic hitMadPrint19 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc19_inst_done && ((spc19_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint19 = 1;
       linebuf19 = {linebuf19, spc19_phy_pc_w[8:1]};
       if (spc19_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 19, linebuf19);
          linebuf19 = "";
       end
    end else begin
       hitMadPrint19 = 0;
    end
  end
end


string linebuf20 = "";
logic hitMadPrint20 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc20_inst_done && ((spc20_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint20 = 1;
       linebuf20 = {linebuf20, spc20_phy_pc_w[8:1]};
       if (spc20_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 20, linebuf20);
          linebuf20 = "";
       end
    end else begin
       hitMadPrint20 = 0;
    end
  end
end


string linebuf21 = "";
logic hitMadPrint21 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc21_inst_done && ((spc21_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint21 = 1;
       linebuf21 = {linebuf21, spc21_phy_pc_w[8:1]};
       if (spc21_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 21, linebuf21);
          linebuf21 = "";
       end
    end else begin
       hitMadPrint21 = 0;
    end
  end
end


string linebuf22 = "";
logic hitMadPrint22 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc22_inst_done && ((spc22_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint22 = 1;
       linebuf22 = {linebuf22, spc22_phy_pc_w[8:1]};
       if (spc22_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 22, linebuf22);
          linebuf22 = "";
       end
    end else begin
       hitMadPrint22 = 0;
    end
  end
end


string linebuf23 = "";
logic hitMadPrint23 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc23_inst_done && ((spc23_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint23 = 1;
       linebuf23 = {linebuf23, spc23_phy_pc_w[8:1]};
       if (spc23_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 23, linebuf23);
          linebuf23 = "";
       end
    end else begin
       hitMadPrint23 = 0;
    end
  end
end


string linebuf24 = "";
logic hitMadPrint24 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc24_inst_done && ((spc24_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint24 = 1;
       linebuf24 = {linebuf24, spc24_phy_pc_w[8:1]};
       if (spc24_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 24, linebuf24);
          linebuf24 = "";
       end
    end else begin
       hitMadPrint24 = 0;
    end
  end
end


string linebuf25 = "";
logic hitMadPrint25 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc25_inst_done && ((spc25_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint25 = 1;
       linebuf25 = {linebuf25, spc25_phy_pc_w[8:1]};
       if (spc25_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 25, linebuf25);
          linebuf25 = "";
       end
    end else begin
       hitMadPrint25 = 0;
    end
  end
end


string linebuf26 = "";
logic hitMadPrint26 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc26_inst_done && ((spc26_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint26 = 1;
       linebuf26 = {linebuf26, spc26_phy_pc_w[8:1]};
       if (spc26_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 26, linebuf26);
          linebuf26 = "";
       end
    end else begin
       hitMadPrint26 = 0;
    end
  end
end


string linebuf27 = "";
logic hitMadPrint27 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc27_inst_done && ((spc27_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint27 = 1;
       linebuf27 = {linebuf27, spc27_phy_pc_w[8:1]};
       if (spc27_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 27, linebuf27);
          linebuf27 = "";
       end
    end else begin
       hitMadPrint27 = 0;
    end
  end
end


string linebuf28 = "";
logic hitMadPrint28 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc28_inst_done && ((spc28_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint28 = 1;
       linebuf28 = {linebuf28, spc28_phy_pc_w[8:1]};
       if (spc28_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 28, linebuf28);
          linebuf28 = "";
       end
    end else begin
       hitMadPrint28 = 0;
    end
  end
end


string linebuf29 = "";
logic hitMadPrint29 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc29_inst_done && ((spc29_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint29 = 1;
       linebuf29 = {linebuf29, spc29_phy_pc_w[8:1]};
       if (spc29_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 29, linebuf29);
          linebuf29 = "";
       end
    end else begin
       hitMadPrint29 = 0;
    end
  end
end


string linebuf30 = "";
logic hitMadPrint30 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc30_inst_done && ((spc30_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint30 = 1;
       linebuf30 = {linebuf30, spc30_phy_pc_w[8:1]};
       if (spc30_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 30, linebuf30);
          linebuf30 = "";
       end
    end else begin
       hitMadPrint30 = 0;
    end
  end
end


string linebuf31 = "";
logic hitMadPrint31 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc31_inst_done && ((spc31_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint31 = 1;
       linebuf31 = {linebuf31, spc31_phy_pc_w[8:1]};
       if (spc31_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 31, linebuf31);
          linebuf31 = "";
       end
    end else begin
       hitMadPrint31 = 0;
    end
  end
end


string linebuf32 = "";
logic hitMadPrint32 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc32_inst_done && ((spc32_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint32 = 1;
       linebuf32 = {linebuf32, spc32_phy_pc_w[8:1]};
       if (spc32_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 32, linebuf32);
          linebuf32 = "";
       end
    end else begin
       hitMadPrint32 = 0;
    end
  end
end


string linebuf33 = "";
logic hitMadPrint33 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc33_inst_done && ((spc33_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint33 = 1;
       linebuf33 = {linebuf33, spc33_phy_pc_w[8:1]};
       if (spc33_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 33, linebuf33);
          linebuf33 = "";
       end
    end else begin
       hitMadPrint33 = 0;
    end
  end
end


string linebuf34 = "";
logic hitMadPrint34 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc34_inst_done && ((spc34_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint34 = 1;
       linebuf34 = {linebuf34, spc34_phy_pc_w[8:1]};
       if (spc34_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 34, linebuf34);
          linebuf34 = "";
       end
    end else begin
       hitMadPrint34 = 0;
    end
  end
end


string linebuf35 = "";
logic hitMadPrint35 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc35_inst_done && ((spc35_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint35 = 1;
       linebuf35 = {linebuf35, spc35_phy_pc_w[8:1]};
       if (spc35_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 35, linebuf35);
          linebuf35 = "";
       end
    end else begin
       hitMadPrint35 = 0;
    end
  end
end


string linebuf36 = "";
logic hitMadPrint36 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc36_inst_done && ((spc36_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint36 = 1;
       linebuf36 = {linebuf36, spc36_phy_pc_w[8:1]};
       if (spc36_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 36, linebuf36);
          linebuf36 = "";
       end
    end else begin
       hitMadPrint36 = 0;
    end
  end
end


string linebuf37 = "";
logic hitMadPrint37 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc37_inst_done && ((spc37_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint37 = 1;
       linebuf37 = {linebuf37, spc37_phy_pc_w[8:1]};
       if (spc37_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 37, linebuf37);
          linebuf37 = "";
       end
    end else begin
       hitMadPrint37 = 0;
    end
  end
end


string linebuf38 = "";
logic hitMadPrint38 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc38_inst_done && ((spc38_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint38 = 1;
       linebuf38 = {linebuf38, spc38_phy_pc_w[8:1]};
       if (spc38_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 38, linebuf38);
          linebuf38 = "";
       end
    end else begin
       hitMadPrint38 = 0;
    end
  end
end


string linebuf39 = "";
logic hitMadPrint39 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc39_inst_done && ((spc39_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint39 = 1;
       linebuf39 = {linebuf39, spc39_phy_pc_w[8:1]};
       if (spc39_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 39, linebuf39);
          linebuf39 = "";
       end
    end else begin
       hitMadPrint39 = 0;
    end
  end
end


string linebuf40 = "";
logic hitMadPrint40 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc40_inst_done && ((spc40_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint40 = 1;
       linebuf40 = {linebuf40, spc40_phy_pc_w[8:1]};
       if (spc40_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 40, linebuf40);
          linebuf40 = "";
       end
    end else begin
       hitMadPrint40 = 0;
    end
  end
end


string linebuf41 = "";
logic hitMadPrint41 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc41_inst_done && ((spc41_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint41 = 1;
       linebuf41 = {linebuf41, spc41_phy_pc_w[8:1]};
       if (spc41_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 41, linebuf41);
          linebuf41 = "";
       end
    end else begin
       hitMadPrint41 = 0;
    end
  end
end


string linebuf42 = "";
logic hitMadPrint42 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc42_inst_done && ((spc42_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint42 = 1;
       linebuf42 = {linebuf42, spc42_phy_pc_w[8:1]};
       if (spc42_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 42, linebuf42);
          linebuf42 = "";
       end
    end else begin
       hitMadPrint42 = 0;
    end
  end
end


string linebuf43 = "";
logic hitMadPrint43 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc43_inst_done && ((spc43_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint43 = 1;
       linebuf43 = {linebuf43, spc43_phy_pc_w[8:1]};
       if (spc43_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 43, linebuf43);
          linebuf43 = "";
       end
    end else begin
       hitMadPrint43 = 0;
    end
  end
end


string linebuf44 = "";
logic hitMadPrint44 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc44_inst_done && ((spc44_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint44 = 1;
       linebuf44 = {linebuf44, spc44_phy_pc_w[8:1]};
       if (spc44_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 44, linebuf44);
          linebuf44 = "";
       end
    end else begin
       hitMadPrint44 = 0;
    end
  end
end


string linebuf45 = "";
logic hitMadPrint45 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc45_inst_done && ((spc45_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint45 = 1;
       linebuf45 = {linebuf45, spc45_phy_pc_w[8:1]};
       if (spc45_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 45, linebuf45);
          linebuf45 = "";
       end
    end else begin
       hitMadPrint45 = 0;
    end
  end
end


string linebuf46 = "";
logic hitMadPrint46 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc46_inst_done && ((spc46_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint46 = 1;
       linebuf46 = {linebuf46, spc46_phy_pc_w[8:1]};
       if (spc46_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 46, linebuf46);
          linebuf46 = "";
       end
    end else begin
       hitMadPrint46 = 0;
    end
  end
end


string linebuf47 = "";
logic hitMadPrint47 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc47_inst_done && ((spc47_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint47 = 1;
       linebuf47 = {linebuf47, spc47_phy_pc_w[8:1]};
       if (spc47_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 47, linebuf47);
          linebuf47 = "";
       end
    end else begin
       hitMadPrint47 = 0;
    end
  end
end


string linebuf48 = "";
logic hitMadPrint48 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc48_inst_done && ((spc48_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint48 = 1;
       linebuf48 = {linebuf48, spc48_phy_pc_w[8:1]};
       if (spc48_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 48, linebuf48);
          linebuf48 = "";
       end
    end else begin
       hitMadPrint48 = 0;
    end
  end
end


string linebuf49 = "";
logic hitMadPrint49 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc49_inst_done && ((spc49_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint49 = 1;
       linebuf49 = {linebuf49, spc49_phy_pc_w[8:1]};
       if (spc49_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 49, linebuf49);
          linebuf49 = "";
       end
    end else begin
       hitMadPrint49 = 0;
    end
  end
end


string linebuf50 = "";
logic hitMadPrint50 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc50_inst_done && ((spc50_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint50 = 1;
       linebuf50 = {linebuf50, spc50_phy_pc_w[8:1]};
       if (spc50_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 50, linebuf50);
          linebuf50 = "";
       end
    end else begin
       hitMadPrint50 = 0;
    end
  end
end


string linebuf51 = "";
logic hitMadPrint51 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc51_inst_done && ((spc51_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint51 = 1;
       linebuf51 = {linebuf51, spc51_phy_pc_w[8:1]};
       if (spc51_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 51, linebuf51);
          linebuf51 = "";
       end
    end else begin
       hitMadPrint51 = 0;
    end
  end
end


string linebuf52 = "";
logic hitMadPrint52 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc52_inst_done && ((spc52_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint52 = 1;
       linebuf52 = {linebuf52, spc52_phy_pc_w[8:1]};
       if (spc52_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 52, linebuf52);
          linebuf52 = "";
       end
    end else begin
       hitMadPrint52 = 0;
    end
  end
end


string linebuf53 = "";
logic hitMadPrint53 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc53_inst_done && ((spc53_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint53 = 1;
       linebuf53 = {linebuf53, spc53_phy_pc_w[8:1]};
       if (spc53_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 53, linebuf53);
          linebuf53 = "";
       end
    end else begin
       hitMadPrint53 = 0;
    end
  end
end


string linebuf54 = "";
logic hitMadPrint54 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc54_inst_done && ((spc54_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint54 = 1;
       linebuf54 = {linebuf54, spc54_phy_pc_w[8:1]};
       if (spc54_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 54, linebuf54);
          linebuf54 = "";
       end
    end else begin
       hitMadPrint54 = 0;
    end
  end
end


string linebuf55 = "";
logic hitMadPrint55 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc55_inst_done && ((spc55_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint55 = 1;
       linebuf55 = {linebuf55, spc55_phy_pc_w[8:1]};
       if (spc55_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 55, linebuf55);
          linebuf55 = "";
       end
    end else begin
       hitMadPrint55 = 0;
    end
  end
end


string linebuf56 = "";
logic hitMadPrint56 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc56_inst_done && ((spc56_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint56 = 1;
       linebuf56 = {linebuf56, spc56_phy_pc_w[8:1]};
       if (spc56_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 56, linebuf56);
          linebuf56 = "";
       end
    end else begin
       hitMadPrint56 = 0;
    end
  end
end


string linebuf57 = "";
logic hitMadPrint57 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc57_inst_done && ((spc57_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint57 = 1;
       linebuf57 = {linebuf57, spc57_phy_pc_w[8:1]};
       if (spc57_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 57, linebuf57);
          linebuf57 = "";
       end
    end else begin
       hitMadPrint57 = 0;
    end
  end
end


string linebuf58 = "";
logic hitMadPrint58 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc58_inst_done && ((spc58_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint58 = 1;
       linebuf58 = {linebuf58, spc58_phy_pc_w[8:1]};
       if (spc58_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 58, linebuf58);
          linebuf58 = "";
       end
    end else begin
       hitMadPrint58 = 0;
    end
  end
end


string linebuf59 = "";
logic hitMadPrint59 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc59_inst_done && ((spc59_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint59 = 1;
       linebuf59 = {linebuf59, spc59_phy_pc_w[8:1]};
       if (spc59_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 59, linebuf59);
          linebuf59 = "";
       end
    end else begin
       hitMadPrint59 = 0;
    end
  end
end


string linebuf60 = "";
logic hitMadPrint60 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc60_inst_done && ((spc60_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint60 = 1;
       linebuf60 = {linebuf60, spc60_phy_pc_w[8:1]};
       if (spc60_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 60, linebuf60);
          linebuf60 = "";
       end
    end else begin
       hitMadPrint60 = 0;
    end
  end
end


string linebuf61 = "";
logic hitMadPrint61 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc61_inst_done && ((spc61_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint61 = 1;
       linebuf61 = {linebuf61, spc61_phy_pc_w[8:1]};
       if (spc61_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 61, linebuf61);
          linebuf61 = "";
       end
    end else begin
       hitMadPrint61 = 0;
    end
  end
end


string linebuf62 = "";
logic hitMadPrint62 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc62_inst_done && ((spc62_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint62 = 1;
       linebuf62 = {linebuf62, spc62_phy_pc_w[8:1]};
       if (spc62_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 62, linebuf62);
          linebuf62 = "";
       end
    end else begin
       hitMadPrint62 = 0;
    end
  end
end


string linebuf63 = "";
logic hitMadPrint63 = 0;
always @(posedge clk) begin
  if (rst_l) begin
    if (spc63_inst_done && ((spc63_phy_pc_w >> 9) == (64'h80000400 >> 9))) begin
       hitMadPrint63 = 1;
       linebuf63 = {linebuf63, spc63_phy_pc_w[8:1]};
       if (spc63_phy_pc_w[8:1] == "\n") begin
          $write("%016t hart %4d: %s", $time, 63, linebuf63);
          linebuf63 = "";
       end
    end else begin
       hitMadPrint63 = 0;
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

        if (done[16]) begin
            timeout[long_cpuid16] = 0;
            //check_bad_trap(spc16_phy_pc_w, 16, long_cpuid16);
            if(active_thread[long_cpuid16])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc16_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid16/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 16 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid16]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc16_phy_pc_w))
                begin
                    if(good[long_cpuid16/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid16 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid16/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid16])
        end // if (done[16])

        if (done[17]) begin
            timeout[long_cpuid17] = 0;
            //check_bad_trap(spc17_phy_pc_w, 17, long_cpuid17);
            if(active_thread[long_cpuid17])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc17_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid17/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 17 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid17]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc17_phy_pc_w))
                begin
                    if(good[long_cpuid17/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid17 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid17/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid17])
        end // if (done[17])

        if (done[18]) begin
            timeout[long_cpuid18] = 0;
            //check_bad_trap(spc18_phy_pc_w, 18, long_cpuid18);
            if(active_thread[long_cpuid18])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc18_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid18/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 18 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid18]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc18_phy_pc_w))
                begin
                    if(good[long_cpuid18/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid18 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid18/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid18])
        end // if (done[18])

        if (done[19]) begin
            timeout[long_cpuid19] = 0;
            //check_bad_trap(spc19_phy_pc_w, 19, long_cpuid19);
            if(active_thread[long_cpuid19])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc19_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid19/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 19 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid19]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc19_phy_pc_w))
                begin
                    if(good[long_cpuid19/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid19 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid19/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid19])
        end // if (done[19])

        if (done[20]) begin
            timeout[long_cpuid20] = 0;
            //check_bad_trap(spc20_phy_pc_w, 20, long_cpuid20);
            if(active_thread[long_cpuid20])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc20_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid20/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 20 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid20]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc20_phy_pc_w))
                begin
                    if(good[long_cpuid20/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid20 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid20/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid20])
        end // if (done[20])

        if (done[21]) begin
            timeout[long_cpuid21] = 0;
            //check_bad_trap(spc21_phy_pc_w, 21, long_cpuid21);
            if(active_thread[long_cpuid21])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc21_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid21/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 21 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid21]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc21_phy_pc_w))
                begin
                    if(good[long_cpuid21/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid21 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid21/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid21])
        end // if (done[21])

        if (done[22]) begin
            timeout[long_cpuid22] = 0;
            //check_bad_trap(spc22_phy_pc_w, 22, long_cpuid22);
            if(active_thread[long_cpuid22])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc22_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid22/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 22 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid22]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc22_phy_pc_w))
                begin
                    if(good[long_cpuid22/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid22 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid22/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid22])
        end // if (done[22])

        if (done[23]) begin
            timeout[long_cpuid23] = 0;
            //check_bad_trap(spc23_phy_pc_w, 23, long_cpuid23);
            if(active_thread[long_cpuid23])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc23_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid23/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 23 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid23]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc23_phy_pc_w))
                begin
                    if(good[long_cpuid23/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid23 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid23/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid23])
        end // if (done[23])

        if (done[24]) begin
            timeout[long_cpuid24] = 0;
            //check_bad_trap(spc24_phy_pc_w, 24, long_cpuid24);
            if(active_thread[long_cpuid24])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc24_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid24/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 24 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid24]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc24_phy_pc_w))
                begin
                    if(good[long_cpuid24/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid24 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid24/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid24])
        end // if (done[24])

        if (done[25]) begin
            timeout[long_cpuid25] = 0;
            //check_bad_trap(spc25_phy_pc_w, 25, long_cpuid25);
            if(active_thread[long_cpuid25])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc25_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid25/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 25 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid25]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc25_phy_pc_w))
                begin
                    if(good[long_cpuid25/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid25 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid25/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid25])
        end // if (done[25])

        if (done[26]) begin
            timeout[long_cpuid26] = 0;
            //check_bad_trap(spc26_phy_pc_w, 26, long_cpuid26);
            if(active_thread[long_cpuid26])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc26_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid26/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 26 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid26]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc26_phy_pc_w))
                begin
                    if(good[long_cpuid26/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid26 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid26/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid26])
        end // if (done[26])

        if (done[27]) begin
            timeout[long_cpuid27] = 0;
            //check_bad_trap(spc27_phy_pc_w, 27, long_cpuid27);
            if(active_thread[long_cpuid27])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc27_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid27/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 27 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid27]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc27_phy_pc_w))
                begin
                    if(good[long_cpuid27/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid27 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid27/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid27])
        end // if (done[27])

        if (done[28]) begin
            timeout[long_cpuid28] = 0;
            //check_bad_trap(spc28_phy_pc_w, 28, long_cpuid28);
            if(active_thread[long_cpuid28])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc28_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid28/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 28 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid28]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc28_phy_pc_w))
                begin
                    if(good[long_cpuid28/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid28 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid28/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid28])
        end // if (done[28])

        if (done[29]) begin
            timeout[long_cpuid29] = 0;
            //check_bad_trap(spc29_phy_pc_w, 29, long_cpuid29);
            if(active_thread[long_cpuid29])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc29_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid29/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 29 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid29]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc29_phy_pc_w))
                begin
                    if(good[long_cpuid29/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid29 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid29/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid29])
        end // if (done[29])

        if (done[30]) begin
            timeout[long_cpuid30] = 0;
            //check_bad_trap(spc30_phy_pc_w, 30, long_cpuid30);
            if(active_thread[long_cpuid30])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc30_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid30/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 30 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid30]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc30_phy_pc_w))
                begin
                    if(good[long_cpuid30/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid30 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid30/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid30])
        end // if (done[30])

        if (done[31]) begin
            timeout[long_cpuid31] = 0;
            //check_bad_trap(spc31_phy_pc_w, 31, long_cpuid31);
            if(active_thread[long_cpuid31])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc31_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid31/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 31 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid31]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc31_phy_pc_w))
                begin
                    if(good[long_cpuid31/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid31 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid31/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid31])
        end // if (done[31])

        if (done[32]) begin
            timeout[long_cpuid32] = 0;
            //check_bad_trap(spc32_phy_pc_w, 32, long_cpuid32);
            if(active_thread[long_cpuid32])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc32_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid32/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 32 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid32]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc32_phy_pc_w))
                begin
                    if(good[long_cpuid32/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid32 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid32/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid32])
        end // if (done[32])

        if (done[33]) begin
            timeout[long_cpuid33] = 0;
            //check_bad_trap(spc33_phy_pc_w, 33, long_cpuid33);
            if(active_thread[long_cpuid33])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc33_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid33/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 33 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid33]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc33_phy_pc_w))
                begin
                    if(good[long_cpuid33/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid33 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid33/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid33])
        end // if (done[33])

        if (done[34]) begin
            timeout[long_cpuid34] = 0;
            //check_bad_trap(spc34_phy_pc_w, 34, long_cpuid34);
            if(active_thread[long_cpuid34])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc34_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid34/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 34 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid34]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc34_phy_pc_w))
                begin
                    if(good[long_cpuid34/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid34 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid34/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid34])
        end // if (done[34])

        if (done[35]) begin
            timeout[long_cpuid35] = 0;
            //check_bad_trap(spc35_phy_pc_w, 35, long_cpuid35);
            if(active_thread[long_cpuid35])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc35_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid35/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 35 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid35]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc35_phy_pc_w))
                begin
                    if(good[long_cpuid35/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid35 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid35/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid35])
        end // if (done[35])

        if (done[36]) begin
            timeout[long_cpuid36] = 0;
            //check_bad_trap(spc36_phy_pc_w, 36, long_cpuid36);
            if(active_thread[long_cpuid36])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc36_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid36/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 36 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid36]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc36_phy_pc_w))
                begin
                    if(good[long_cpuid36/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid36 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid36/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid36])
        end // if (done[36])

        if (done[37]) begin
            timeout[long_cpuid37] = 0;
            //check_bad_trap(spc37_phy_pc_w, 37, long_cpuid37);
            if(active_thread[long_cpuid37])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc37_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid37/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 37 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid37]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc37_phy_pc_w))
                begin
                    if(good[long_cpuid37/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid37 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid37/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid37])
        end // if (done[37])

        if (done[38]) begin
            timeout[long_cpuid38] = 0;
            //check_bad_trap(spc38_phy_pc_w, 38, long_cpuid38);
            if(active_thread[long_cpuid38])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc38_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid38/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 38 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid38]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc38_phy_pc_w))
                begin
                    if(good[long_cpuid38/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid38 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid38/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid38])
        end // if (done[38])

        if (done[39]) begin
            timeout[long_cpuid39] = 0;
            //check_bad_trap(spc39_phy_pc_w, 39, long_cpuid39);
            if(active_thread[long_cpuid39])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc39_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid39/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 39 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid39]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc39_phy_pc_w))
                begin
                    if(good[long_cpuid39/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid39 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid39/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid39])
        end // if (done[39])

        if (done[40]) begin
            timeout[long_cpuid40] = 0;
            //check_bad_trap(spc40_phy_pc_w, 40, long_cpuid40);
            if(active_thread[long_cpuid40])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc40_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid40/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 40 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid40]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc40_phy_pc_w))
                begin
                    if(good[long_cpuid40/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid40 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid40/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid40])
        end // if (done[40])

        if (done[41]) begin
            timeout[long_cpuid41] = 0;
            //check_bad_trap(spc41_phy_pc_w, 41, long_cpuid41);
            if(active_thread[long_cpuid41])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc41_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid41/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 41 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid41]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc41_phy_pc_w))
                begin
                    if(good[long_cpuid41/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid41 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid41/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid41])
        end // if (done[41])

        if (done[42]) begin
            timeout[long_cpuid42] = 0;
            //check_bad_trap(spc42_phy_pc_w, 42, long_cpuid42);
            if(active_thread[long_cpuid42])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc42_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid42/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 42 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid42]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc42_phy_pc_w))
                begin
                    if(good[long_cpuid42/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid42 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid42/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid42])
        end // if (done[42])

        if (done[43]) begin
            timeout[long_cpuid43] = 0;
            //check_bad_trap(spc43_phy_pc_w, 43, long_cpuid43);
            if(active_thread[long_cpuid43])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc43_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid43/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 43 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid43]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc43_phy_pc_w))
                begin
                    if(good[long_cpuid43/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid43 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid43/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid43])
        end // if (done[43])

        if (done[44]) begin
            timeout[long_cpuid44] = 0;
            //check_bad_trap(spc44_phy_pc_w, 44, long_cpuid44);
            if(active_thread[long_cpuid44])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc44_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid44/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 44 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid44]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc44_phy_pc_w))
                begin
                    if(good[long_cpuid44/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid44 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid44/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid44])
        end // if (done[44])

        if (done[45]) begin
            timeout[long_cpuid45] = 0;
            //check_bad_trap(spc45_phy_pc_w, 45, long_cpuid45);
            if(active_thread[long_cpuid45])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc45_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid45/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 45 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid45]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc45_phy_pc_w))
                begin
                    if(good[long_cpuid45/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid45 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid45/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid45])
        end // if (done[45])

        if (done[46]) begin
            timeout[long_cpuid46] = 0;
            //check_bad_trap(spc46_phy_pc_w, 46, long_cpuid46);
            if(active_thread[long_cpuid46])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc46_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid46/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 46 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid46]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc46_phy_pc_w))
                begin
                    if(good[long_cpuid46/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid46 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid46/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid46])
        end // if (done[46])

        if (done[47]) begin
            timeout[long_cpuid47] = 0;
            //check_bad_trap(spc47_phy_pc_w, 47, long_cpuid47);
            if(active_thread[long_cpuid47])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc47_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid47/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 47 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid47]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc47_phy_pc_w))
                begin
                    if(good[long_cpuid47/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid47 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid47/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid47])
        end // if (done[47])

        if (done[48]) begin
            timeout[long_cpuid48] = 0;
            //check_bad_trap(spc48_phy_pc_w, 48, long_cpuid48);
            if(active_thread[long_cpuid48])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc48_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid48/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 48 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid48]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc48_phy_pc_w))
                begin
                    if(good[long_cpuid48/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid48 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid48/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid48])
        end // if (done[48])

        if (done[49]) begin
            timeout[long_cpuid49] = 0;
            //check_bad_trap(spc49_phy_pc_w, 49, long_cpuid49);
            if(active_thread[long_cpuid49])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc49_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid49/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 49 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid49]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc49_phy_pc_w))
                begin
                    if(good[long_cpuid49/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid49 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid49/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid49])
        end // if (done[49])

        if (done[50]) begin
            timeout[long_cpuid50] = 0;
            //check_bad_trap(spc50_phy_pc_w, 50, long_cpuid50);
            if(active_thread[long_cpuid50])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc50_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid50/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 50 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid50]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc50_phy_pc_w))
                begin
                    if(good[long_cpuid50/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid50 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid50/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid50])
        end // if (done[50])

        if (done[51]) begin
            timeout[long_cpuid51] = 0;
            //check_bad_trap(spc51_phy_pc_w, 51, long_cpuid51);
            if(active_thread[long_cpuid51])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc51_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid51/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 51 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid51]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc51_phy_pc_w))
                begin
                    if(good[long_cpuid51/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid51 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid51/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid51])
        end // if (done[51])

        if (done[52]) begin
            timeout[long_cpuid52] = 0;
            //check_bad_trap(spc52_phy_pc_w, 52, long_cpuid52);
            if(active_thread[long_cpuid52])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc52_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid52/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 52 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid52]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc52_phy_pc_w))
                begin
                    if(good[long_cpuid52/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid52 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid52/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid52])
        end // if (done[52])

        if (done[53]) begin
            timeout[long_cpuid53] = 0;
            //check_bad_trap(spc53_phy_pc_w, 53, long_cpuid53);
            if(active_thread[long_cpuid53])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc53_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid53/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 53 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid53]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc53_phy_pc_w))
                begin
                    if(good[long_cpuid53/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid53 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid53/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid53])
        end // if (done[53])

        if (done[54]) begin
            timeout[long_cpuid54] = 0;
            //check_bad_trap(spc54_phy_pc_w, 54, long_cpuid54);
            if(active_thread[long_cpuid54])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc54_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid54/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 54 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid54]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc54_phy_pc_w))
                begin
                    if(good[long_cpuid54/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid54 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid54/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid54])
        end // if (done[54])

        if (done[55]) begin
            timeout[long_cpuid55] = 0;
            //check_bad_trap(spc55_phy_pc_w, 55, long_cpuid55);
            if(active_thread[long_cpuid55])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc55_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid55/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 55 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid55]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc55_phy_pc_w))
                begin
                    if(good[long_cpuid55/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid55 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid55/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid55])
        end // if (done[55])

        if (done[56]) begin
            timeout[long_cpuid56] = 0;
            //check_bad_trap(spc56_phy_pc_w, 56, long_cpuid56);
            if(active_thread[long_cpuid56])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc56_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid56/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 56 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid56]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc56_phy_pc_w))
                begin
                    if(good[long_cpuid56/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid56 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid56/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid56])
        end // if (done[56])

        if (done[57]) begin
            timeout[long_cpuid57] = 0;
            //check_bad_trap(spc57_phy_pc_w, 57, long_cpuid57);
            if(active_thread[long_cpuid57])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc57_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid57/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 57 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid57]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc57_phy_pc_w))
                begin
                    if(good[long_cpuid57/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid57 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid57/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid57])
        end // if (done[57])

        if (done[58]) begin
            timeout[long_cpuid58] = 0;
            //check_bad_trap(spc58_phy_pc_w, 58, long_cpuid58);
            if(active_thread[long_cpuid58])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc58_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid58/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 58 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid58]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc58_phy_pc_w))
                begin
                    if(good[long_cpuid58/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid58 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid58/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid58])
        end // if (done[58])

        if (done[59]) begin
            timeout[long_cpuid59] = 0;
            //check_bad_trap(spc59_phy_pc_w, 59, long_cpuid59);
            if(active_thread[long_cpuid59])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc59_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid59/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 59 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid59]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc59_phy_pc_w))
                begin
                    if(good[long_cpuid59/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid59 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid59/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid59])
        end // if (done[59])

        if (done[60]) begin
            timeout[long_cpuid60] = 0;
            //check_bad_trap(spc60_phy_pc_w, 60, long_cpuid60);
            if(active_thread[long_cpuid60])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc60_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid60/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 60 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid60]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc60_phy_pc_w))
                begin
                    if(good[long_cpuid60/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid60 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid60/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid60])
        end // if (done[60])

        if (done[61]) begin
            timeout[long_cpuid61] = 0;
            //check_bad_trap(spc61_phy_pc_w, 61, long_cpuid61);
            if(active_thread[long_cpuid61])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc61_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid61/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 61 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid61]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc61_phy_pc_w))
                begin
                    if(good[long_cpuid61/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid61 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid61/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid61])
        end // if (done[61])

        if (done[62]) begin
            timeout[long_cpuid62] = 0;
            //check_bad_trap(spc62_phy_pc_w, 62, long_cpuid62);
            if(active_thread[long_cpuid62])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc62_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid62/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 62 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid62]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc62_phy_pc_w))
                begin
                    if(good[long_cpuid62/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid62 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid62/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid62])
        end // if (done[62])

        if (done[63]) begin
            timeout[long_cpuid63] = 0;
            //check_bad_trap(spc63_phy_pc_w, 63, long_cpuid63);
            if(active_thread[long_cpuid63])begin

                if(bad_trap_exists[0] & (bad_trap[0] == spc63_phy_pc_w))begin
                    hit_bad     <= 1'b1;
                    good[long_cpuid63/4]   <= 1;
                    local_diag_done = 1;
                    $display("%016t hart %4d: @@@ Hit Bad trap", $time, 63 / 4);
                    `MONITOR_PATH.fail("HIT BAD TRAP");
                end

            end
        if (active_thread[long_cpuid63]) begin
    
if(good_trap_exists[0] & (good_trap[0] == spc63_phy_pc_w))
                begin
                    if(good[long_cpuid63/4] == 0) begin
                        $display("%016t hart %4d: @@@ Hit Good trap %4d/%0d", $time, long_cpuid63 / 4, $countones(good), $bits(good));
                    end
                    good[long_cpuid63/4] <= 1'b1;
                end

            end // if (active_thread[long_cpuid63])
        end // if (done[63])

        
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


