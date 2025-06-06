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

`include "l15.tmp.h"
`include "define.tmp.h"

// /home/gl/work/openpiton/piton/verif/env/manycore/devices_ariane.xml



module flat_id_to_xy(
    input  [(`HOME_ID_WIDTH-1):0] flat_id,
    output reg [(`NOC_X_WIDTH-1):0] x_coord,
    output reg [(`NOC_Y_WIDTH-1):0] y_coord
);

    always @*
    begin
        case (flat_id)
        
//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d0: 
`HOME_ID_WIDTH'd0: 
begin
    x_coord = `NOC_X_WIDTH'd0;
    y_coord = `NOC_Y_WIDTH'd0;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d1: 
`HOME_ID_WIDTH'd1: 
begin
    x_coord = `NOC_X_WIDTH'd1;
    y_coord = `NOC_Y_WIDTH'd0;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d2: 
`HOME_ID_WIDTH'd2: 
begin
    x_coord = `NOC_X_WIDTH'd2;
    y_coord = `NOC_Y_WIDTH'd0;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d3: 
`HOME_ID_WIDTH'd3: 
begin
    x_coord = `NOC_X_WIDTH'd3;
    y_coord = `NOC_Y_WIDTH'd0;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d4: 
`HOME_ID_WIDTH'd4: 
begin
    x_coord = `NOC_X_WIDTH'd0;
    y_coord = `NOC_Y_WIDTH'd1;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d5: 
`HOME_ID_WIDTH'd5: 
begin
    x_coord = `NOC_X_WIDTH'd1;
    y_coord = `NOC_Y_WIDTH'd1;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d6: 
`HOME_ID_WIDTH'd6: 
begin
    x_coord = `NOC_X_WIDTH'd2;
    y_coord = `NOC_Y_WIDTH'd1;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d7: 
`HOME_ID_WIDTH'd7: 
begin
    x_coord = `NOC_X_WIDTH'd3;
    y_coord = `NOC_Y_WIDTH'd1;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d8: 
`HOME_ID_WIDTH'd8: 
begin
    x_coord = `NOC_X_WIDTH'd0;
    y_coord = `NOC_Y_WIDTH'd2;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d9: 
`HOME_ID_WIDTH'd9: 
begin
    x_coord = `NOC_X_WIDTH'd1;
    y_coord = `NOC_Y_WIDTH'd2;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d10: 
`HOME_ID_WIDTH'd10: 
begin
    x_coord = `NOC_X_WIDTH'd2;
    y_coord = `NOC_Y_WIDTH'd2;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d11: 
`HOME_ID_WIDTH'd11: 
begin
    x_coord = `NOC_X_WIDTH'd3;
    y_coord = `NOC_Y_WIDTH'd2;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d12: 
`HOME_ID_WIDTH'd12: 
begin
    x_coord = `NOC_X_WIDTH'd0;
    y_coord = `NOC_Y_WIDTH'd3;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d13: 
`HOME_ID_WIDTH'd13: 
begin
    x_coord = `NOC_X_WIDTH'd1;
    y_coord = `NOC_Y_WIDTH'd3;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d14: 
`HOME_ID_WIDTH'd14: 
begin
    x_coord = `NOC_X_WIDTH'd2;
    y_coord = `NOC_Y_WIDTH'd3;
end

//(`NOC_Y_WIDTH+`NOC_X_WIDTH)'d15: 
`HOME_ID_WIDTH'd15: 
begin
    x_coord = `NOC_X_WIDTH'd3;
    y_coord = `NOC_Y_WIDTH'd3;
end

        default:
        begin
            x_coord = `NOC_X_WIDTH'dX;
            y_coord = `NOC_X_WIDTH'dX;
        end
        endcase
    end
endmodule
