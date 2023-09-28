package Top;
export mkTop;

export ITop(..);

// export mkSim;

import "BDPI" function Action init_terminal();
import "BDPI" function Action restore_terminal();
import "BDPI" function Bit#(8) get_char_from_terminal();
import "BDPI" function Int#(32) is_char_available();
import "BDPI" function Action write_char_to_terminal(Bit#(8) chr);

import "BDPI" function Action setup_sigint_handler();
import "BDPI" function Bool was_ctrl_c_received();

import Deserializer::*;
import Core::*;
import Serializer::*;
import BRAM::*;

typedef 25000000 FCLK;
typedef 9600 BAUD;

interface ITop;
    (* always_ready  *)
    method Bit # (1) ftdi_rxd();
    (* always_ready  *)
    method Bit # (8) led();
    (* always_enabled , always_ready  *)
    method Action ftdi_txd(Bit#(1) bitIn);
endinterface

(* synthesize *)
module mkTop(ITop);
   Handle fileHandle <- openFile("compile.log", WriteMode);
   IDeserializer # (FCLK, BAUD) deserializer  <- mkDeserialize(fileHandle);
   ISerializer   # (FCLK, BAUD)    serializer <- mkSerialize(fileHandle);
   Core          # (FCLK)               core  <- mkCore();

   Reg#(Bit#(8))  persist_led 	<- mkReg(0);

   messageM("Hallo!!" + realToString(5));

	// connect up core device
    rule core_led_o;
		persist_led <= core.get_led;
    endrule
    rule core_char_device_o;
		serializer.putBit8(core.get_char);
    endrule
    rule core_char_device_i;
		core.put_char(deserializer.get);
    endrule

	// output methods
	method Bit#(1) ftdi_rxd;
		return serializer.bitLineOut;
	endmethod

	method Action ftdi_txd(Bit#(1) bitIn);
		deserializer.putBitIn(bitIn);
	endmethod
	method Bit#(8) led;
		return persist_led;
	endmethod
endmodule

module mkSim(Empty);
	BRAM_Configure cfg = defaultValue;

    // Define a 3-bit register named count
    Reg#(UInt#(3)) count        <- mkReg(0);
	Reg#(Bool) init_C_functions <- mkReg(False);
	Core#(FCLK)           core  <- mkCore();

	rule init_c_functions_once (!init_C_functions);
		init_terminal();
		setup_sigint_handler();
		init_C_functions <= True;
	endrule

    rule core_char_device_o;
		write_char_to_terminal(core.get_char);
    endrule
    rule core_char_device_i(is_char_available() == 1);
		core.put_char(get_char_from_terminal());
    endrule

    // Rule to finish the simulation when count reaches 6
    rule end_sim (was_ctrl_c_received());
		restore_terminal();
		$display("GOT CTRL+C");
        ($finish)();
    endrule
endmodule


endpackage