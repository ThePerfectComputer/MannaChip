package Deserializer;
export mkDeserialize;

export IDeserializer(..);

export State(..);

import ClkDivider::*;

import State::*;

interface IDeserializer#(numeric type clkFreq, numeric type baudRate);
    method Bit#(8) get();
    (* always_enabled , always_ready  *)
    method Action putBitIn(Bit#(1) bitIn);
endinterface

module mkDeserialize#(Handle fileHandle)(IDeserializer#(clkFreq, baudRate));
    Wire#(Bit#(1)) ftdiRxIn <- mkBypassWire;
    Reg#(Bit#(8)) shiftReg <- mkReg(0);
    Reg#(State) ftdiState <- mkReg(IDLE);
    
    ClkDivider#(TDiv#(clkFreq, baudRate)) clkDivider <- mkClkDivider(fileHandle);

    (* fire_when_enabled *)
    rule idle (ftdiState == IDLE && ftdiRxIn == 0);
        clkDivider.reset();
        ftdiState <= ftdiStateNext(ftdiState);
    endrule

    (* fire_when_enabled *)
    rule not_idle (ftdiState != IDLE && clkDivider.isAdvancing());
        ftdiState <= ftdiStateNext(ftdiState);
    endrule

    (* fire_when_enabled *)
    rule sampling (
          ftdiState matches (tagged DATA .n) &&& 
          clkDivider.isHalfCycle()
          );
        shiftReg <= {ftdiRxIn, shiftReg[7:1]};
    endrule

    method Bit#(8) get() if (ftdiState == STOP && clkDivider.isAdvancing());
        return shiftReg;
    endmethod

    method Action putBitIn(Bit#(1) bitIn);
        ftdiRxIn <= bitIn;
    endmethod
endmodule

endpackage