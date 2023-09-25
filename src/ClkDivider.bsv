package ClkDivider;
export mkClkDivider;

export ClkDivider(..);

interface ClkDivider#(numeric type hi);
    method Action reset();
    method Bool isAdvancing();
    method Bool isHalfCycle();
endinterface

module mkClkDivider#(Handle fileHandle)(ClkDivider#(hi));
    Reg#(UInt#(TLog#(hi))) counter <- mkReg(0);
    UInt#(TLog#(hi)) hi_value = fromInteger(valueOf(hi));
    UInt#(TLog#(hi)) half_hi_value = fromInteger(valueOf(TDiv#(hi, 2)));

    Real val = fromInteger(valueOf(hi));
    let msg = "Clock Div Period : " + realToString(val) + "\n";

    hPutStr(fileHandle, msg);
    hPutStr(fileHandle, genModuleName);

    rule tick;
        // $display(counter);
        counter <= (counter == hi_value) ? 0 : counter + 1;
    endrule

	method Action reset();
		counter <= 0;
	endmethod

	method Bool isAdvancing();
		return (counter == hi_value);
	endmethod

	method Bool isHalfCycle();
		return (counter == half_hi_value);
	endmethod
endmodule

endpackage