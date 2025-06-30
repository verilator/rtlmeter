`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module
    divSqrtFN#(
        parameter expWidth = 8, parameter sigWidth = 24, 
		parameter options = 0, parameter bits_per_iter_p = 1
    ) (
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input nReset,
        input clock,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input [(`floatControlWidth - 1):0] control,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output inReady,
        input inValid,
        input sqrtOp,
        input [(expWidth + sigWidth-1):0] a,
        input [(expWidth + sigWidth-1):0] b,
        input [2:0] roundingMode,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output outValid,
        output sqrtOpOut,
        output [(expWidth + sigWidth-1):0] out,
        output [4:0] exceptionFlags
    );
	
	localparam formatWidth = expWidth + sigWidth;
	
    reg [formatWidth:0] recA,recB;
	reg [formatWidth:0] recOut;
	
	fNToRecFN#(expWidth, sigWidth) fNToRecFN_a(a, recA);
    fNToRecFN#(expWidth, sigWidth) fNToRecFN_b(b, recB);
	
     divSqrtRecFN#(expWidth, sigWidth, 0, bits_per_iter_p)
        divSqrtRecFN(
            nReset,
            clock,
            control,
            inReady,
            inValid,
            sqrtOp,
            recA,
            recB,
            roundingMode,
            outValid,
            sqrtOpOut,
            recOut,
            exceptionFlags
        );
	
	recFNToFN#(expWidth, sigWidth) recToFN_out (recOut, out);

endmodule

	