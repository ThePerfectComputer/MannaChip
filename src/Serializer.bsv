package Serializer;

import ClkDivider::*;
import State::*;

export mkSerialize;
export ISerializer(..);
export State(..);

function Bit#(1) serialize(State state, Bit#(8) dataReg);
    case (state) matches
        tagged START    : return 1'b0;
        tagged DATA .n   : return dataReg[n];
        default  : return 1'b1;
    endcase
endfunction

interface ISerializer#(numeric type clkFreq, numeric type baudRate);
    (* always_enabled , always_ready  *)
    method Action putBit8(Bit#(8) bit8Val);
    (* always_ready  *)
    method Bit#(1) bitLineOut();
endinterface

module mkSerialize#(Handle fileHandle)(ISerializer#(clkFreq, baudRate));
    Wire#(Bit#(1)) ftdiTxOut <- mkBypassWire();
    Reg#(Bit#(8)) dataReg <- mkReg(0);
    Reg#(State) ftdiState <- mkReg(IDLE);

    ClkDivider#(TDiv#(clkFreq, baudRate)) clkDivider <- mkClkDivider(fileHandle);

    (* fire_when_enabled *)
    rule advanceUartState (ftdiState != IDLE && clkDivider.isAdvancing());
        ftdiState <= ftdiStateNext(ftdiState);
    endrule

    (* fire_when_enabled *)
    rule bitLine (ftdiState != IDLE);
        ftdiTxOut <= serialize(ftdiState, dataReg);
    endrule

    method Action putBit8(Bit#(8) bit8Val) if (ftdiState == IDLE);
        clkDivider.reset();
        dataReg <= bit8Val;
        ftdiState <= ftdiStateNext(ftdiState);
    endmethod

    method Bit#(1) bitLineOut;
        return ftdiTxOut;
    endmethod
endmodule

endpackage