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

//Function: This generates all of the route_request lines and the default_ready lines from
//the absolute location of the tile, the abs address of the message, and the fbits of the message
//
//State: 
//NONE
//
//Instantiates: 
//
//Note:
//

`include "network_define.v"
// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml

module io_xbar_route_request_calc(route_req_0, route_req_1, route_req_2, route_req_3, route_req_4, route_req_5, route_req_6, route_req_7, 
                                        default_ready_0, default_ready_1, default_ready_2, default_ready_3, default_ready_4, default_ready_5, default_ready_6, default_ready_7, 
                                        my_loc_x_in, my_loc_y_in, my_chip_id_in, abs_x, abs_y, abs_chip_id, final_bits, length, header_in);

// begin port declarations
output route_req_0;
output route_req_1;
output route_req_2;
output route_req_3;
output route_req_4;
output route_req_5;
output route_req_6;
output route_req_7;
output default_ready_0;
output default_ready_1;
output default_ready_2;
output default_ready_3;
output default_ready_4;
output default_ready_5;
output default_ready_6;
output default_ready_7;

input [`XY_WIDTH-1:0] my_loc_x_in;
input [`XY_WIDTH-1:0] my_loc_y_in;
input [`CHIP_ID_WIDTH-1:0] my_chip_id_in;
input [`XY_WIDTH-1:0] abs_x;
input [`XY_WIDTH-1:0] abs_y;
input [`CHIP_ID_WIDTH-1:0] abs_chip_id;

input [2:0] final_bits;
input [`PAYLOAD_LEN-1:0] length;
input header_in;

// end port declarations
`ifdef NETWORK_TOPO_XBAR
wire off_chip;
wire [`XY_WIDTH*3+3-1:0]              stub;

assign off_chip = abs_chip_id != my_chip_id_in;
assign route_req_1 = header_in & (!off_chip) & (abs_x == 8'd1);
assign route_req_2 = header_in & (!off_chip) & (abs_x == 8'd2);
assign route_req_3 = header_in & (!off_chip) & (abs_x == 8'd3);
assign route_req_4 = header_in & (!off_chip) & (abs_x == 8'd4);
assign route_req_5 = header_in & (!off_chip) & (abs_x == 8'd5);
assign route_req_6 = header_in & (!off_chip) & (abs_x == 8'd6);
assign route_req_7 = header_in & (!off_chip) & (abs_x == 8'd7);
assign route_req_0 = (header_in & (!off_chip) & (abs_x == 8'd0)) | (header_in & (off_chip)) ;

assign default_ready_0 = route_req_0;
assign default_ready_1 = route_req_1;
assign default_ready_2 = route_req_2;
assign default_ready_3 = route_req_3;
assign default_ready_4 = route_req_4;
assign default_ready_5 = route_req_5;
assign default_ready_6 = route_req_6;
assign default_ready_7 = route_req_7;

assign stub = {my_loc_x_in, my_loc_y_in, abs_y, final_bits};


`elsif NETWORK_TOPO_2D_MESH
//fbit declarations
`define FINAL_NONE	3'b000
`define FINAL_WEST	3'b010
`define FINAL_SOUTH	3'b011
`define FINAL_EAST	3'b100
`define FINAL_NORTH	3'b101

//This is the state
//NONE

//inputs to the state
//NONE

//wires
wire more_x;
wire more_y;
wire less_x;
wire less_y;
wire done_x;
wire done_y;
wire off_chip;

wire done;

wire north;
wire east;
wire south;
wire west;
wire proc;

wire north_calc;
wire south_calc;

wire [`XY_WIDTH-1:0] node_abs_x;
wire [`XY_WIDTH-1:0] node_abs_y;
wire [`XY_WIDTH-1:0] node_my_loc_x_in;
wire [`XY_WIDTH-1:0] node_my_loc_y_in;

`ifdef ROUTING_CHIP_ID
assign node_abs_x = {1'b0, abs_chip_id[`CHIP_ID_WIDTH-1: `CHIP_ID_WIDTH/2]};
assign node_abs_y = {1'b0, abs_chip_id[`CHIP_ID_WIDTH/2-1: 0]};
assign node_my_loc_x_in = {1'b0, my_chip_id_in[`CHIP_ID_WIDTH-1: `CHIP_ID_WIDTH/2]};
assign node_my_loc_y_in = {1'b0, my_chip_id_in[`CHIP_ID_WIDTH/2-1: 0]};
assign off_chip = 1'b0;
`else
assign node_abs_x = abs_x;
assign node_abs_y = abs_y;
assign node_my_loc_x_in = my_loc_x_in;
assign node_my_loc_y_in = my_loc_y_in;
assign off_chip = abs_chip_id != my_chip_id_in;
`endif
//wire regs



//assigns

assign more_x = off_chip ? `OFF_CHIP_NODE_X > node_my_loc_x_in : node_abs_x > node_my_loc_x_in;
assign more_y = off_chip ? `OFF_CHIP_NODE_Y > node_my_loc_y_in : node_abs_y > node_my_loc_y_in;

assign less_x = off_chip ? `OFF_CHIP_NODE_X < node_my_loc_x_in : node_abs_x < node_my_loc_x_in;
assign less_y = off_chip ? `OFF_CHIP_NODE_Y < node_my_loc_y_in : node_abs_y < node_my_loc_y_in;

assign done_x = off_chip ? `OFF_CHIP_NODE_X == node_my_loc_x_in : node_abs_x == node_my_loc_x_in;
assign done_y = off_chip ? `OFF_CHIP_NODE_Y == node_my_loc_y_in : node_abs_y == node_my_loc_y_in;

assign done = done_x & done_y;

assign north_calc = done_x & less_y;
assign south_calc = done_x & more_y;

assign north = north_calc | ((final_bits == `FINAL_NORTH) & done);
assign south = south_calc | ((final_bits == `FINAL_SOUTH) & done);
assign east = more_x | ((final_bits == `FINAL_EAST) & done);
assign west = less_x | ((final_bits == `FINAL_WEST) & done);
assign proc = ((final_bits == `FINAL_NONE) & done);

assign route_req_0 = header_in & north;
assign route_req_1 = header_in & east;
assign route_req_2 = header_in & south;
assign route_req_3 = header_in & west;
assign route_req_4 = header_in & proc;

assign default_ready_0 = route_req_0;
assign default_ready_1 = route_req_1;
assign default_ready_2 = route_req_2;
assign default_ready_3 = route_req_3;
assign default_ready_4 = route_req_4;

//instantiations
`elsif NETWORK_TOPO_3D_MESH
/* final bits are not used */
wire more_dim1; //north/south
wire more_dim2; //east/west
wire more_dim3; //up/down
wire less_dim1;
wire less_dim2;
wire less_dim3;
wire done_dim1;
wire done_dim2;
wire done_dim3;

wire done;

wire dir_0; //north
wire dir_1; //east
wire dir_2; //up
wire dir_3; //south
wire dir_4; //west
wire dir_5; //down
wire dir_6; //proc

wire [`XY_WIDTH-1:0] node_abs_dim1;
wire [`XY_WIDTH-1:0] node_abs_dim2;
wire [`XY_WIDTH-1:0] node_abs_dim3;
wire [`XY_WIDTH-1:0] node_my_loc_dim1_in;
wire [`XY_WIDTH-1:0] node_my_loc_dim2_in;
wire [`XY_WIDTH-1:0] node_my_loc_dim3_in;
wire [`XY_WIDTH*4+3-1:0]              stub;

// routing always based on chip id
assign node_abs_dim1 = {4'b0, abs_chip_id[`CHIP_ID_WIDTH/3*3-1: `CHIP_ID_WIDTH/3*2]};
assign node_abs_dim2 = {4'b0, abs_chip_id[`CHIP_ID_WIDTH/3*2-1: `CHIP_ID_WIDTH/3]};
assign node_abs_dim3 = {4'b0, abs_chip_id[`CHIP_ID_WIDTH/3-1: 0]};
assign node_my_loc_dim1_in = {4'b0, my_chip_id_in[`CHIP_ID_WIDTH/3*3-1: `CHIP_ID_WIDTH/3*2]};
assign node_my_loc_dim2_in = {4'b0, my_chip_id_in[`CHIP_ID_WIDTH/3*2-1: `CHIP_ID_WIDTH/3]};
assign node_my_loc_dim3_in = {4'b0, my_chip_id_in[`CHIP_ID_WIDTH/3-1: 0]};

assign more_dim1 = node_abs_dim1 > node_my_loc_dim1_in;
assign more_dim2 = node_abs_dim2 > node_my_loc_dim2_in;
assign more_dim3 = node_abs_dim3 > node_my_loc_dim3_in;

assign less_dim1 = node_abs_dim1 < node_my_loc_dim1_in;
assign less_dim2 = node_abs_dim2 < node_my_loc_dim2_in;
assign less_dim3 = node_abs_dim3 < node_my_loc_dim3_in;

assign done_dim1 = node_abs_dim1 == node_my_loc_dim1_in;
assign done_dim2 = node_abs_dim2 == node_my_loc_dim2_in;
assign done_dim3 = node_abs_dim3 == node_my_loc_dim3_in;

assign done = done_dim1 & done_dim2 & done_dim3;

assign dir_4 = less_dim1 & done_dim2 & done_dim3;
assign dir_3 = more_dim2 & done_dim3;
assign dir_2 = less_dim3;
assign dir_1 = more_dim1 & done_dim2 & done_dim3;
assign dir_0 = less_dim2 & done_dim3;
assign dir_5 = more_dim3;
assign dir_6 = done;

assign route_req_0 = header_in & dir_0;
assign route_req_1 = header_in & dir_1;
assign route_req_2 = header_in & dir_2;
assign route_req_3 = header_in & dir_3;
assign route_req_4 = header_in & dir_4;
assign route_req_5 = header_in & dir_5;
assign route_req_6 = header_in & dir_6;

assign default_ready_0 = route_req_0;
assign default_ready_1 = route_req_1;
assign default_ready_2 = route_req_2;
assign default_ready_3 = route_req_3;
assign default_ready_4 = route_req_4;
assign default_ready_5 = route_req_5;
assign default_ready_6 = route_req_6;
assign stub = {my_loc_x_in, my_loc_y_in, abs_x, abs_y, final_bits};
`endif
endmodule
   
