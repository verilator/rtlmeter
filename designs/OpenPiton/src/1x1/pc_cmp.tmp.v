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

reg [3:0]   active_thread;
reg [4:0]    thread_status[3:0];

reg [0:0]   good = '0;
reg [0:0]   done;

reg [31:0]     timeout [3:0];


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


always @* begin
done[0]   = spc0_inst_done;//sparc 0


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


