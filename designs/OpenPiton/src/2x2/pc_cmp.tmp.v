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

reg [15:0]   active_thread;
reg [4:0]    thread_status[15:0];

reg [3:0]   good = '0;
reg [3:0]   done;

reg [31:0]     timeout [15:0];


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


always @* begin
done[0]   = spc0_inst_done;//sparc 0
done[1]   = spc1_inst_done;//sparc 1
done[2]   = spc2_inst_done;//sparc 2
done[3]   = spc3_inst_done;//sparc 3


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


