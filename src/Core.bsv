package Core;

import ClkDivider::*;
import Prelude::*;

interface Core#(numeric type clkFreq);
    method Bit#(8) get_char();
    method Bit#(8) get_led();
    method Action put_char(Bit#(8) byte_in);
endinterface

module mkCore(Core#(clkFreq));
    // Reg #  (UInt # (32)) counter     <- mkReg(0);
    Reg #  (UInt # (TLog # (clkFreq))) counter     <- mkReg(0);
    Wire # (Bool)                      tick_second <- mkDWire(False);
   	Wire # (Bit # (8))                 uart_out    <- mkWire;
   	Reg # (Bit # (8))                  led_out     <- mkReg(0);

    Integer clkFreqInt = valueOf(clkFreq);
    UInt#(TLog#(clkFreq)) clkFreqUInt = fromInteger(clkFreqInt);
    Real val = fromInteger(clkFreqInt);
    messageM("mkCore clkFreq" + realToString(val));

    rule second_counter;
        counter <= (counter == clkFreqUInt) ? 0 : counter + 1;
        tick_second <= True;
    endrule

    rule update_led(tick_second);
        led_out <= led_out + 1;
    endrule

    method Bit#(8) get_char();
		return uart_out;
	endmethod
    method Bit#(8) get_led();
		return led_out;
	endmethod
    method Action put_char(Bit#(8) byte_in);
		uart_out <= byte_in;
	endmethod
endmodule

endpackage