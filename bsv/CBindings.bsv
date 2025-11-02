package CBindings;

// Original function imports
import "BDPI" function Action init_terminal();
import "BDPI" function Action restore_terminal();
import "BDPI" function Bit#(8) get_char_from_terminal();
import "BDPI" function Int#(32) is_char_available();
import "BDPI" function Action write_char_to_terminal(Bit#(8) chr);
import "BDPI" function Action setup_sigint_handler();
import "BDPI" function Bool was_ctrl_c_received();

// Aliased exports
export initTerminal;
export restoreTerminal;
export getCharFromTerminal;
export isCharAvailable;
export writeCharToTerminal;
export setupSigintHandler;
export wasCtrlCReceived;

// Aliased function definitions
function Action initTerminal();
    return init_terminal();
endfunction

function Action restoreTerminal();
    return restore_terminal();
endfunction

function Bit#(8) getCharFromTerminal();
    return get_char_from_terminal();
endfunction

function Int#(32) isCharAvailable();
    return is_char_available();
endfunction

function Action writeCharToTerminal(Bit#(8) chr);
    return write_char_to_terminal(chr);
endfunction

function Action setupSigintHandler();
    return setup_sigint_handler();
endfunction

function Bool wasCtrlCReceived();
    return was_ctrl_c_received();
endfunction

endpackage
