package Top;
export mkTop;

export ITop(..);

// export mkSim;

import Deserializer::*;

import Serializer::*;

typedef 25000000 FCLK;

typedef 9600 BAUD;

interface ITop;
    (* always_ready  *)
    method Bit#(1) ftdi_rxd();
    (* always_ready  *)
    method Bit#(8) led();
    (* always_enabled , always_ready  *)
    method Action ftdi_txd(Bit#(1) bitIn);
endinterface: ITop

(* synthesize *)
module mkTop(ITop);
   Handle fileHandle <- openFile("compile.log", WriteMode);
   IDeserializer#(FCLK, BAUD) deserializer  <- mkDeserialize(fileHandle);
   ISerializer#(FCLK, BAUD) serializer 	    <- mkSerialize(fileHandle);

   Wire#(Bit#(1)) ftdiBitIn <- mkBypassWire;
   Reg#(Bit#(8)) rxReg 	    <- mkReg(0);

   messageM("Hallo!!" + realToString(5));

    rule loopback;
		rxReg <= deserializer.get;
		serializer.putBit8(deserializer.get);
    endrule

    rule txOut;
		deserializer.putBitIn(ftdiBitIn);
    endrule

	method Bit#(1) ftdi_rxd;
		return serializer.bitLineOut;
	endmethod

	method Bit#(8) led;
		return rxReg;
	endmethod

	method Action ftdi_txd(Bit#(1) bitIn);
		ftdiBitIn <= bitIn;
	endmethod
endmodule

module mkSim(Empty);

    // Define a 3-bit register named count
    Reg#(UInt#(3)) count <- mkReg(0);

    // Rule to update and display the count
    rule tick (True);
        count <= unpack({1'b1, (pack(count))[2:1]});
        ($display)(count);
    endrule

    // Rule to finish the simulation when count reaches 6
    rule end_sim (count == 6);
        ($finish)();
    endrule

endmodule


endpackage