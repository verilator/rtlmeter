// Modified by Princeton University on June 9th, 2015
/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: lsu.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/

// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml
`define L1D_ENTRY_COUNT 512
`define L1D_SET_IDX_HI 6
`define L1D_WAY_COUNT 4
`define L1D_WAY_WIDTH 2


// 1:0
`define L1D_WAY_MASK `L1D_WAY_WIDTH-1:0
`define L1D_WAY_ARRAY_MASK `L1D_WAY_COUNT-1:0
// 128
`define L1D_SET_COUNT (`L1D_ENTRY_COUNT/`L1D_WAY_COUNT)
// 32
`define L1D_VAL_ARRAY_HI (4*`L1D_WAY_COUNT-1)
`define L1D_VAL_SET_COUNT (`L1D_SET_COUNT/4)
// 10
`define L1D_ADDRESS_HI (`L1D_SET_IDX_HI + 4)
// 7
`define L1D_ADDRESS_WIDTH (`L1D_ADDRESS_HI - 4 + 1)
`define L1D_SET_IDX_ (`L1D_SET_IDX_HI + 4)
// 6:0
`define L1D_SET_IDX_MASK `L1D_SET_IDX_HI:0
`define L1D_SET_IDX_WIDTH (`L1D_SET_IDX_HI+1)

// 29 + 1 parity
`define L1D_TAG_PARITY_WIDTH (29+1)
`define L1D_TAG_ARRAY_WIDTH (`L1D_TAG_PARITY_WIDTH*`L1D_WAY_COUNT)
`define L1D_TAG_REAL_WIDTH 33 // physical SRAM width for tag
`define L1D_TAG_ARRAY_REAL_WIDTH (`L1D_TAG_REAL_WIDTH*`L1D_WAY_COUNT)

// 144
`define L1D_DATA_ENTRY_WIDTH 144

`define L1D_TAG_ARRAY_WAY0_MASK `L1D_TAG_PARITY_WIDTH*(0+1)-1 -: `L1D_TAG_PARITY_WIDTH
`define L1D_TAG_ARRAY_WAY0_PARITY_BIT_MASK `L1D_TAG_PARITY_WIDTH*(0+1)-1
`define L1D_TAG_REAL_ARRAY_WAY0_MASK `L1D_TAG_REAL_WIDTH*(0+1)-1 -: `L1D_TAG_REAL_WIDTH
`define L1D_DATA_ENTRY_WAY0_MASK `L1D_DATA_ENTRY_WIDTH*(0+1)-1 -: `L1D_DATA_ENTRY_WIDTH
`define L1D_TAG_ARRAY_WAY1_MASK `L1D_TAG_PARITY_WIDTH*(1+1)-1 -: `L1D_TAG_PARITY_WIDTH
`define L1D_TAG_ARRAY_WAY1_PARITY_BIT_MASK `L1D_TAG_PARITY_WIDTH*(1+1)-1
`define L1D_TAG_REAL_ARRAY_WAY1_MASK `L1D_TAG_REAL_WIDTH*(1+1)-1 -: `L1D_TAG_REAL_WIDTH
`define L1D_DATA_ENTRY_WAY1_MASK `L1D_DATA_ENTRY_WIDTH*(1+1)-1 -: `L1D_DATA_ENTRY_WIDTH
`define L1D_TAG_ARRAY_WAY2_MASK `L1D_TAG_PARITY_WIDTH*(2+1)-1 -: `L1D_TAG_PARITY_WIDTH
`define L1D_TAG_ARRAY_WAY2_PARITY_BIT_MASK `L1D_TAG_PARITY_WIDTH*(2+1)-1
`define L1D_TAG_REAL_ARRAY_WAY2_MASK `L1D_TAG_REAL_WIDTH*(2+1)-1 -: `L1D_TAG_REAL_WIDTH
`define L1D_DATA_ENTRY_WAY2_MASK `L1D_DATA_ENTRY_WIDTH*(2+1)-1 -: `L1D_DATA_ENTRY_WIDTH
`define L1D_TAG_ARRAY_WAY3_MASK `L1D_TAG_PARITY_WIDTH*(3+1)-1 -: `L1D_TAG_PARITY_WIDTH
`define L1D_TAG_ARRAY_WAY3_PARITY_BIT_MASK `L1D_TAG_PARITY_WIDTH*(3+1)-1
`define L1D_TAG_REAL_ARRAY_WAY3_MASK `L1D_TAG_REAL_WIDTH*(3+1)-1 -: `L1D_TAG_REAL_WIDTH
`define L1D_DATA_ENTRY_WAY3_MASK `L1D_DATA_ENTRY_WIDTH*(3+1)-1 -: `L1D_DATA_ENTRY_WIDTH


`define STB_PCX_WIDTH   115
`define STB_PCX_VLD     114
`define STB_PCX_RQ_HI   113
`define STB_PCX_RQ_LO   111
`define STB_PCX_NC      110
`define STB_PCX_TH_HI   109
`define STB_PCX_TH_LO   108
`define STB_PCX_FLSH   	107
//`define STB_PCX_WY_HI   107
//`define STB_PCX_WY_LO   106
`define STB_PCX_SZ_HI   105
`define STB_PCX_SZ_LO   104
`define STB_PCX_AD_HI   103
`define STB_PCX_AD_LO   64
`define STB_PCX_DA_HI   63
`define STB_PCX_DA_LO   0     
`define LMQ_WIDTH       65
`define LMQ_VLD 	64
`define LMQ_DFLUSH 	63
`define LMQ_PREF 	62
`define LMQ_FPLD 	61
`define LMQ_SIGNEXT 	60
`define LMQ_BIGEND 	59
`define LMQ_RD1_HI      58
`define LMQ_RD1_LO      54
`define LMQ_RD2_VLD 	53
`define LMQ_RD2_HI      52
`define LMQ_RD2_LO      51
`define LMQ_RQ_HI       47
`define LMQ_RQ_LO       45
`define LMQ_NC  	44
`define LMQ_WY_HI       43
`define LMQ_WY_LO       42
`define LMQ_SZ_HI       41
`define LMQ_SZ_LO       40
`define LMQ_AD_HI       39
`define LMQ_AD_LO       0
`define DATA_PA_HI      32
`define DATA_PA_LO      6
`define	STB_DFQ_WIDTH	83
`define	STB_DFQ_VLD	82
`define	STB_DFQ_ATM	81
`define	STB_DFQ_WY_HI	80
`define	STB_DFQ_WY_LO	79
`define STB_DFQ_BF_ID_HI 78
`define STB_DFQ_BF_ID_LO 76
`define	STB_DFQ_SZ_HI	75
`define	STB_DFQ_SZ_LO	74
`define	STB_DFQ_AD_HI	73
`define STB_DFQ_AD_LO	64
`define	STB_DFQ_DA_HI	63
`define	STB_DFQ_DA_LO	0

`define DFQ_WIDTH	151
`define DFQ_TH_HI	150
`define DFQ_TH_LO	149
`define DFQ_ST_CMPLT    148
`define DFQ_LD_TYPE	147
`define DFQ_INV_TYPE	146
`define DFQ_WY_HI	145
`define DFQ_WY_LO	144
`define DFQ_WY1_HI	143
`define DFQ_WY1_LO	142
`define DFQ_WY2_HI	141
`define DFQ_WY2_LO	140
`define DFQ_WY3_HI	139
`define DFQ_WY3_LO	138
`define DFQ_SI_HI	137
`define DFQ_SI_LO	132
`define DFQ_SI_DCD_HI	131
`define DFQ_SI_DCD_LO	128
`define DFQ_DA_HI	127
`define DFQ_DA_LO	0

`define DCFILL_WIDTH	183
`define DCFILL_TH_HI	182
`define DCFILL_TH_LO	181
`define DCFILL_ST	180
`define DCFILL_ST	180
`define DCFILL_LD	179
`define DCFILL_INV	178
`define DCFILL_DC_WR	177
`define DCFILL_RD_HI	176
`define DCFILL_RD_LO	172
`define DCFILL_WY_HI	171
`define DCFILL_WY_LO	170
`define DCFILL_SZ_HI	169
`define DCFILL_SZ_LO	168
`define DCFILL_AD_HI	167
`define DCFILL_AD_LO	128
`define DCFILL_DA_HI	127
`define DCFILL_DA_LO 	0

// TLB Tag and Data Format
	`define       STLB_TAG_PID_HI         58
	`define       STLB_TAG_PID_LO         56
	`define       STLB_TAG_R              55
	`define       STLB_TAG_PARITY         54
	`define       STLB_TAG_VA_47_28_HI    53
	`define       STLB_TAG_VA_47_28_LO    34
	`define       STLB_TAG_VA_27_22_HI    33
	`define       STLB_TAG_VA_27_22_LO    28
	`define       STLB_TAG_VA_27_22_V     27
	`define       STLB_TAG_V              26
	`define       STLB_TAG_L              25
	`define       STLB_TAG_U              24
	`define       STLB_TAG_VA_21_16_HI    23
	`define       STLB_TAG_VA_21_16_LO    18
	`define       STLB_TAG_VA_21_16_V     17
	`define       STLB_TAG_VA_15_13_HI    16
	`define       STLB_TAG_VA_15_13_LO    14
	`define       STLB_TAG_VA_15_13_V     13
	`define       STLB_TAG_CTXT_12_0_HI   12
	`define       STLB_TAG_CTXT_12_0_LO   0

	`define       STLB_DATA_PARITY        42
	`define       STLB_DATA_PA_39_28_HI   41 
	`define       STLB_DATA_PA_39_28_LO   30
	`define       STLB_DATA_PA_27_22_HI   29
	`define       STLB_DATA_PA_27_22_LO   24
	`define       STLB_DATA_27_22_SEL     23
	`define       STLB_DATA_PA_21_16_HI   22
	`define       STLB_DATA_PA_21_16_LO   17
	`define       STLB_DATA_21_16_SEL     16
	`define       STLB_DATA_PA_15_13_HI   15
	`define       STLB_DATA_PA_15_13_LO   13
	`define       STLB_DATA_15_13_SEL     12
	`define       STLB_DATA_V             11
	`define       STLB_DATA_NFO           10
	`define       STLB_DATA_IE            9
	`define       STLB_DATA_L             8
	`define       STLB_DATA_CP            7
	`define       STLB_DATA_CV            6
	`define       STLB_DATA_E             5
	`define       STLB_DATA_P             4
	`define       STLB_DATA_W             3
	`define       STLB_DATA_SPARE_HI      2
	`define       STLB_DATA_SPARE_LO      0

	`define CAM_VA_47_28_HI         40
	`define CAM_VA_47_28_LO         21
	`define CAM_VA_47_28_V          20
	`define CAM_VA_27_22_HI         19
	`define CAM_VA_27_22_LO         14
	`define CAM_VA_27_22_V          13
	`define CAM_VA_21_16_HI         12
	`define CAM_VA_21_16_LO         7
	`define CAM_VA_21_16_V          6
	`define CAM_VA_15_13_HI         5
	`define CAM_VA_15_13_LO         3
	`define CAM_VA_15_13_V          2
	`define CAM_CTXT_GK             1
	`define CAM_REAL_V              0


// I-TLB version - lsu_tlb only.

`define TLB_TAG_G	52
`define TLB_TAG_CTXT_HI	51
`define TLB_TAG_CTXT_LO	39
`define TLB_TAG_VA_HI	38
`define TLB_TAG_VA_LO	4
`define	TLB_TAG_L	3
`define	TLB_TAG_VA_21_19_V  2
`define	TLB_TAG_VA_18_16_V  1
`define	TLB_TAG_VA_15_13_V  0
`define TLB_DATA_PARITY 37 
`define TLB_DATA_SZ_HI	36
`define TLB_DATA_SZ_LO	35
`define TLB_DATA_NFO  	34
`define TLB_DATA_IE   	33
`define TLB_DATA_PA_HI 	32	
`define TLB_DATA_PA_LO 	6
`define TLB_DATA_CP 	5 
`define TLB_DATA_CV 	4 
`define TLB_DATA_E  	3 
`define TLB_DATA_P  	2 
`define TLB_DATA_W  	1 
`define TLB_DATA_G  	0 

// // Invalidate Format
// //addr<5:4>=00
// `define CPX_A00_C0_LO	0
// `define CPX_A00_C0_HI	3
// `define CPX_A00_C1_LO	4
// `define CPX_A00_C1_HI	7
// `define CPX_A00_C2_LO	8
// `define CPX_A00_C2_HI	11
// `define CPX_A00_C3_LO	12
// `define CPX_A00_C3_HI	15
// `define CPX_A00_C4_LO	16
// `define CPX_A00_C4_HI	19
// `define CPX_A00_C5_LO	20
// `define CPX_A00_C5_HI	23
// `define CPX_A00_C6_LO	24
// `define CPX_A00_C6_HI	27
// `define CPX_A00_C7_LO	28
// `define CPX_A00_C7_HI	31

// //addr<5:4>=01
// `define CPX_A01_C0_LO	32
// `define CPX_A01_C0_HI	34
// `define CPX_A01_C1_LO	35
// `define CPX_A01_C1_HI	37
// `define CPX_A01_C2_LO	38
// `define CPX_A01_C2_HI	40
// `define CPX_A01_C3_LO	41
// `define CPX_A01_C3_HI	43
// `define CPX_A01_C4_LO	44
// `define CPX_A01_C4_HI	46
// `define CPX_A01_C5_LO	47
// `define CPX_A01_C5_HI	49
// `define CPX_A01_C6_LO	50
// `define CPX_A01_C6_HI	52
// `define CPX_A01_C7_LO	53
// `define CPX_A01_C7_HI	55

// //addr<5:4>=10
// `define CPX_A10_C0_LO	56
// `define CPX_A10_C0_HI	59
// `define CPX_A10_C1_LO	60
// `define CPX_A10_C1_HI	63
// `define CPX_A10_C2_LO	64
// `define CPX_A10_C2_HI	67
// `define CPX_A10_C3_LO	68
// `define CPX_A10_C3_HI	71
// `define CPX_A10_C4_LO	72
// `define CPX_A10_C4_HI	75
// `define CPX_A10_C5_LO	76
// `define CPX_A10_C5_HI	79
// `define CPX_A10_C6_LO	80
// `define CPX_A10_C6_HI	83
// `define CPX_A10_C7_LO	84
// `define CPX_A10_C7_HI	87

// //addr<5:4>=11
// `define CPX_A11_C0_LO	88
// `define CPX_A11_C0_HI	90
// `define CPX_A11_C1_LO	91
// `define CPX_A11_C1_HI	93
// `define CPX_A11_C2_LO	94
// `define CPX_A11_C2_HI	96
// `define CPX_A11_C3_LO	97
// `define CPX_A11_C3_HI	99
// `define CPX_A11_C4_LO	100
// `define CPX_A11_C4_HI	102
// `define CPX_A11_C5_LO	103
// `define CPX_A11_C5_HI	105
// `define CPX_A11_C6_LO	106
// `define CPX_A11_C6_HI	108
// `define CPX_A11_C7_LO	109
// `define CPX_A11_C7_HI	111

// cpuid - 4b
`define CPX_INV_CID_LO 118
`define CPX_INV_CID_HI 120

// CPUany, addr<5:4>=00,10
// `define CPX_AX0_INV_DVLD 0
// `define CPX_AX0_INV_IVLD 1
// `define CPX_AX0_INV_WY_LO 2
// `define CPX_AX0_INV_WY_HI 3

// CPUany, addr<5:4>=01,11
// `define CPX_AX1_INV_DVLD 0
// `define CPX_AX1_INV_WY_LO 1
// `define CPX_AX1_INV_WY_HI 2

// CPUany, addr<5:4>=01,11
// `define CPX_AX1_INV_DVLD 0
// `define CPX_AX1_INV_WY_LO 1
// `define CPX_AX1_INV_WY_HI 2

// DTAG parity error Invalidate
`define CPX_PERR_DINV 123	// dcache inv
`define CPX_PERR_DINV_AD5 122	// addr bit 5
`define CPX_PERR_DINV_AD4 121	// addr bit 4

// CPX BINIT STORE
`define CPX_BINIT_STACK 125	// dcache inv
