//====================================================================
// Schematics: https://docs.google.com/presentation/d/1CLZtLB3oHdmMLjzTL960ydjGzhS26V1yuOX5suPqSh4/edit?usp=sharing
//====================================================================

`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module
    divSqrtRecFN#(
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
        input [(expWidth + sigWidth):0] a,
        input [(expWidth + sigWidth):0] b,
        input [2:0] roundingMode,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output outValid,
        output sqrtOpOut,
        output [(expWidth + sigWidth):0] out,
        output [4:0] exceptionFlags
    );
	
	generate
	if(bits_per_iter_p == 2) 
		begin: divSqrtTwoBitPerIter
			     divSqrtRecFN_medium#(expWidth,sigWidth,options) 
					divSqrtRecFN_2bit(
						nReset,
						clock,
						control,
						inReady,
						inValid,
						sqrtOp,
						a,
						b,
						roundingMode,
						outValid,
						sqrtOpOut,
						out,
						exceptionFlags
					);
		end 
	else
		begin: divSqrtOneBitPerIter
				 divSqrtRecFN_small#(expWidth,sigWidth,options) 
					divSqrtRecFN_1bit(
						nReset,
						clock,
						control,
						inReady,
						inValid,
						sqrtOp,
						a,
						b,
						roundingMode,
						outValid,
						sqrtOpOut,
						out,
						exceptionFlags
					);
		end
	endgenerate
		
endmodule

module
    divSqrtRecFNToRaw #(
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
        input [(expWidth + sigWidth):0] a,
        input [(expWidth + sigWidth):0] b,
        input [2:0] roundingMode,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output outValid,
        output sqrtOpOut,
        output [2:0] roundingModeOut,
        output invalidExc,
        output infiniteExc,
        output out_isNaN,
        output out_isInf,
        output out_isZero,
        output out_sign,
        output signed [(expWidth + 1):0] out_sExp,
        output [(sigWidth + 2):0] out_sig
    );

    generate
    if(bits_per_iter_p == 2)
        begin: divSqrtTwoBitPerIter
                divSqrtRecFNToRaw_medium#(expWidth, sigWidth, options)
                    divSqrtRecFNToRaw(
                        nReset,
                        clock,
                        control,
                        inReady,
                        inValid,
                        sqrtOp,
                        a,
                        b,
                        roundingMode,
                        outValid,
                        sqrtOpOut,
                        roundingModeOut,
                        invalidExc,
                        infiniteExc,
                        out_isNaN,
                        out_isInf,
                        out_isZero,
                        out_sign,
                        out_sExp,
                        out_sig
                    );
        end
    else
        begin: divSqrtOneBitPerIter
                divSqrtRecFNToRaw_small#(expWidth, sigWidth, options)
                    divSqrtRecFNToRaw(
                        nReset,
                        clock,
                        control,
                        inReady,
                        inValid,
                        sqrtOp,
                        a,
                        b,
                        roundingMode,
                        outValid,
                        sqrtOpOut,
                        roundingModeOut,
                        invalidExc,
                        infiniteExc,
                        out_isNaN,
                        out_isInf,
                        out_isZero,
                        out_sign,
                        out_sExp,
                        out_sig
                    );
        end
    endgenerate


endmodule

