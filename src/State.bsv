package State;
export State(..);

export ftdiStateNext;

typedef union tagged {
    void IDLE;
    void START;
    UInt#(TLog#(8)) DATA;
    void PARITY;
    void STOP;
} State deriving (Bits, Eq, FShow);

function State ftdiStateNext(State state);
  return 
	case (state) matches
		tagged IDLE    : START;
		tagged START   : DATA(0);
		tagged DATA .n :
			begin
				if (n == 7)
					PARITY;
				else
					DATA(n + 1);
			end
		tagged PARITY  : STOP;
		tagged STOP    : IDLE;
	endcase
	;
endfunction

endpackage