`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

/*----------------------------------------------------------------------------
| Computes a division or square root for floating-point in recoded form.
| Multiple clock cycles are needed for each division or square-root operation,
| except possibly in special cases.
*----------------------------------------------------------------------------*/

module
    divSqrtRecFNToRaw_medium#(
        parameter expWidth = 8, parameter sigWidth = 24, parameter options = 0
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
    `include "HardFloat_localFuncs.vi"

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire isNaNA_S, isInfA_S, isZeroA_S, signA_S;
    wire signed [(expWidth + 1):0] sExpA_S;
    wire [sigWidth:0] sigA_S;
    recFNToRawFN#(expWidth, sigWidth)
        recFNToRawFN_a(
            a, isNaNA_S, isInfA_S, isZeroA_S, signA_S, sExpA_S, sigA_S);
    wire isSigNaNA_S;
    isSigNaNRecFN#(expWidth, sigWidth) isSigNaN_a(a, isSigNaNA_S);
    wire isNaNB_S, isInfB_S, isZeroB_S, signB_S;
    wire signed [(expWidth + 1):0] sExpB_S;
    wire [sigWidth:0] sigB_S;
    recFNToRawFN#(expWidth, sigWidth)
        recFNToRawFN_b(
            b, isNaNB_S, isInfB_S, isZeroB_S, signB_S, sExpB_S, sigB_S);
    wire isSigNaNB_S;
    isSigNaNRecFN#(expWidth, sigWidth) isSigNaN_b(b, isSigNaNB_S);
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire notSigNaNIn_invalidExc_S_div =
        (isZeroA_S && isZeroB_S) || (isInfA_S && isInfB_S);
    wire notSigNaNIn_invalidExc_S_sqrt = !isNaNA_S && !isZeroA_S && signA_S;
    wire majorExc_S =
        sqrtOp ? isSigNaNA_S || notSigNaNIn_invalidExc_S_sqrt
            : isSigNaNA_S || isSigNaNB_S || notSigNaNIn_invalidExc_S_div
                  || (!isNaNA_S && !isInfA_S && isZeroB_S);
    wire isNaN_S =
        sqrtOp ? isNaNA_S || notSigNaNIn_invalidExc_S_sqrt
            : isNaNA_S || isNaNB_S || notSigNaNIn_invalidExc_S_div;

    wire isInf_S  = sqrtOp ? isInfA_S  : isInfA_S  || isZeroB_S;
    wire isZero_S = sqrtOp ? isZeroA_S : isZeroA_S || isInfB_S;
    wire sign_S = signA_S ^ (!sqrtOp && signB_S);
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire specialCaseA_S = isNaNA_S || isInfA_S || isZeroA_S;
    wire specialCaseB_S = isNaNB_S || isInfB_S || isZeroB_S;
    wire normalCase_S_div  = !specialCaseA_S && !specialCaseB_S;
    wire normalCase_S_sqrt = !specialCaseA_S && !signA_S;
    wire normalCase_S = sqrtOp ? normalCase_S_sqrt : normalCase_S_div;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire signed [(expWidth + 2):0] sExpQuot_S_div =
        sExpA_S + {{3{sExpB_S[expWidth]}}, ~sExpB_S[(expWidth - 1):0]};
    wire signed [(expWidth + 1):0] sSatExpQuot_S_div =
        {(7<<(expWidth - 2) <= sExpQuot_S_div) ? 4'b0110
             : sExpQuot_S_div[(expWidth + 1):(expWidth - 2)],
         sExpQuot_S_div[(expWidth - 3): 0]};
    wire evenSqrt_S = sqrtOp && !sExpA_S[0];
    wire oddSqrt_S  = sqrtOp &&  sExpA_S[0];
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    reg [(clog2(sigWidth + 3) - 1):0] cycleNum;
    reg sqrtOp_Z, majorExc_Z;
    reg isNaN_Z, isInf_Z, isZero_Z, sign_Z;
    reg signed [(expWidth + 1):0] sExp_Z;
    reg [(sigWidth - 2):0] fractB_Z;	
    reg [2:0] roundingMode_Z;
    /*------------------------------------------------------------------------
    | (The most-significant and least-significant bits of 'rem_Z' are needed
    | only for square roots.)
    *------------------------------------------------------------------------*/
    reg [(sigWidth + 1):0] rem_Z;
    reg notZeroRem_Z;
    reg [(sigWidth + 1):0] sigX_Z;
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire idle = (cycleNum == 0);
    assign inReady = (cycleNum <= 1);
    wire entering = inReady && inValid;
    wire entering_normalCase = entering && normalCase_S;
    wire skipCycle2 = (cycleNum == 4) && sigX_Z[sigWidth + 1];  
    wire step1Case = skipCycle2 || (cycleNum <= 2);

    always @(posedge clock) begin
        if (!nReset) begin
            cycleNum <= 0;
        end else begin
            if (inValid || !idle) begin
                cycleNum <=
                      (entering && !normalCase_S ? 1 : 0)
                    | (entering_normalCase
                           ? (sqrtOp ? (sExpA_S[0] ? sigWidth : sigWidth + 1)
                                     : sigWidth + 2)
                           : 0)
		    | (!idle ? (cycleNum - (step1Case ? 1 : 2)) : 0);
            end 
        end
    end
		
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
	
    always @(posedge clock) begin
      if (!nReset) begin
            sqrtOp_Z <= 1'b0;
            majorExc_Z <= 1'b0;
            isNaN_Z <= 1'b0;
            isInf_Z <= 1'b0;
            isZero_Z <= 1'b0;
            sign_Z <= 1'b0;
            sExp_Z <= '0;
            roundingMode_Z <= '0;
            fractB_Z <= '0;
      end
      else begin
        if (entering) begin
            sqrtOp_Z   <= sqrtOp;
            majorExc_Z <= majorExc_S;
            isNaN_Z    <= isNaN_S;
            isInf_Z    <= isInf_S;
            isZero_Z   <= isZero_S;
            sign_Z <= sign_S;
        end
        if (entering_normalCase) begin
            sExp_Z <= sqrtOp ? (sExpA_S>>>1) + (1<<(expWidth - 1))
                             : sSatExpQuot_S_div;
            roundingMode_Z <= roundingMode;
        end
		
        if (entering_normalCase && !sqrtOp) begin
            fractB_Z <= sigB_S[(sigWidth - 2):0];
        end
		
      end
    end
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    wire [1:0] decHiSigA_S = sigA_S[(sigWidth - 1):(sigWidth - 2)] - 1;
    wire [(sigWidth + 2):0] rem = inReady ? 
				    (oddSqrt_S ? 
					{decHiSigA_S, sigA_S[(sigWidth - 3):0], 3'b0}
					: sigA_S<<1)
				    : rem_Z<<1;
    wire [sigWidth:0] bitMask = ({{(sigWidth + 2){1'b0}}, 1'b1}<<cycleNum)>>2;
    wire [sigWidth:0] bitMaskNext = bitMask>>1;	
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
	
	wire loadDiv = inReady && !sqrtOp;
	wire loadEvenSqrt = inReady && evenSqrt_S;
	wire loadOddSqrt = inReady && oddSqrt_S;
	wire calc = !inReady;
	wire calcDiv = calc && !sqrtOp_Z;
	wire calcSqrt = calc && sqrtOp_Z;	
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
	wire [(sigWidth + 1):0] trialTerm;

	wire [4:0] [sigWidth+1:0] trialTermMuxIn = {
		{sigB_S, 1'b0},
		{1'b0, 1'b1, sigWidth ' (1'b0)},
		{3'b101, (sigWidth-1) ' (1'b0)},
		{1'b0, {1'b1, fractB_Z}, 1'b0},
		{{sigX_Z[sigWidth:0],1'b0} | bitMask}
	};

	wire [4:0] trialTermSel = {
		loadDiv,
		loadEvenSqrt,
		loadOddSqrt,
		calcDiv,
		calcSqrt
	};
   
	bsg_mux_one_hot #(.width_p(sigWidth+2),.els_p(5))
		trialTerm_mux(
			.data_i(trialTermMuxIn),
			.sel_one_hot_i(trialTermSel),
			.data_o(trialTerm)
		);
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
		
    wire signed [(sigWidth + 3):0] trialRem1 = rem - trialTerm;
	wire newBit1 = (0 <= trialRem1);
	wire [(sigWidth + 1):0] sigXNext = sigX_Z | (newBit1 ? bitMask : 0);
	wire [(sigWidth + 1):0] trialTermNext = sqrtOp_Z ? 
		                                   sigXNext<<1 | bitMaskNext
					          :trialTerm;
	wire [(sigWidth + 2):0] remNext = (newBit1 ? (trialRem1[(sigWidth + 1):0]) : (rem[(sigWidth + 1):0]))<<1;
	wire signed [(sigWidth + 3):0] trialRem2 = remNext - trialTermNext ;
	wire newBit2 = (0 <= trialRem2);	
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/

	wire [(sigWidth + 1):0] sigX_N;
	wire [3:0] [(sigWidth+1):0] sigX_NMuxIn = {
		{newBit1, (sigWidth+1) ' (1'b0)},
		{2'b01, sigWidth ' (1'b0)},
		{2'b01, newBit1, (sigWidth-1) ' (1'b0)},
		{sigXNext | (newBit2 ? bitMaskNext : (sigWidth + 1) ' (1'b0))}
	};

	wire [3:0] sigX_NSel = {
		loadDiv,
		loadEvenSqrt,
		loadOddSqrt,
		calc
	};
   
	bsg_mux_one_hot #(.width_p(sigWidth+2),.els_p(4))
		sigX_N_mux(
			.data_i(sigX_NMuxIn),
			.sel_one_hot_i(sigX_NSel),
			.data_o(sigX_N)
		);	
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
	
    always @(posedge clock) begin
      if (!nReset) begin
        rem_Z <='0;
        sigX_Z <='0;
        notZeroRem_Z <= 1'b0;
      end
      else begin
        if (entering_normalCase || (cycleNum > 2)) begin
            rem_Z <= (inReady || skipCycle2) ? (newBit1 ? trialRem1 : rem)
						:(newBit2 ? trialRem2 : remNext);
        end

        if (entering_normalCase || (!inReady && (newBit1 | newBit2))) begin
            notZeroRem_Z <= (trialRem1 != 0 && trialRem2 != 0);
	    sigX_Z       <=  sigX_N;
        end

      end
    end
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    assign outValid = (cycleNum == 1);
    assign sqrtOpOut       = sqrtOp_Z;
    assign roundingModeOut = roundingMode_Z;
    assign invalidExc  = majorExc_Z &&  isNaN_Z;
    assign infiniteExc = majorExc_Z && !isNaN_Z;
    assign out_isNaN  = isNaN_Z;
    assign out_isInf  = isInf_Z;
    assign out_isZero = isZero_Z;
    assign out_sign   = sign_Z;
    assign out_sExp   = sExp_Z;
    assign out_sig    = {sigX_Z, notZeroRem_Z};

endmodule
/*----------------------------------------------------------------------------
*----------------------------------------------------------------------------*/

module
    divSqrtRecFN_medium#(
        parameter expWidth = 8, parameter sigWidth = 24, parameter options = 0
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

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    //wire sqrtOpOut;
    wire [2:0] roundingModeOut;
    wire invalidExc, infiniteExc, out_isNaN, out_isInf, out_isZero, out_sign;
    wire signed [(expWidth + 1):0] out_sExp;
    wire [(sigWidth + 2):0] out_sig;
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
    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    roundRawFNToRecFN#(expWidth, sigWidth, 0)
        roundRawOut(
            control,
            invalidExc,
            infiniteExc,
            out_isNaN,
            out_isInf,
            out_isZero,
            out_sign,
            out_sExp,
            out_sig,
            roundingModeOut,
            out,
            exceptionFlags
        );

endmodule
