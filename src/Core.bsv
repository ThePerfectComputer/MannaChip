package Core;

interface Core#(numeric type clkFreq);
    method Bit#(8) get_char();
    method Bit#(8) get_led();
    method Action put_char(Bit#(8) byte_in);
endinterface

module mkCore(Core#(clkFreq));
   	Wire#(Bit#(8)) uart_out <- mkWire;

    method Bit#(8) get_char();
		return uart_out;
	endmethod
    method Bit#(8) get_led();
		return uart_out;
	endmethod
    method Action put_char(Bit#(8) byte_in);
		uart_out <= byte_in;
	endmethod
endmodule

endpackage