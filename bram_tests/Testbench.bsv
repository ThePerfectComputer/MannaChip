// bsc -sim -u -g mkTestbench Testbench.bsv; bsc -sim -e mkTestbench -o simBRAM; ./simBRAM -V
import BRAM::*;
import StmtFSM::*;
import Clocks::*;

function BRAMRequest#(Bit#(8), Bit#(8)) makeRequest(Bool write, Bit#(8) addr, Bit#(8) data);
   return BRAMRequest{
                      write: write,
                      responseOnWrite:False,
                      address: addr,
                      datain: data
                      };
endfunction

(* synthesize *)
module mkTestbench();
   Reg#(UInt#(3)) count <- mkReg(0);
    BRAM_Configure cfg = defaultValue;
    cfg.allowWriteResponseBypass = False;
   //  BRAM2Port#(Bit#(8), Bit#(8)) dut0 <- mkBRAM2Server(cfg);
    cfg.loadFormat = tagged Hex "bram2.txt";
    BRAM2Port#(Bit#(8), Bit#(8)) dut1 <- mkBRAM2Server(cfg);

    rule counting;
      count <= count + 1;
    endrule

   //Define StmtFSM to run tests
   Stmt test =
      (seq
         delay(10);
         action
            $display("count = %d", count);
            dut1.portB.request.put(makeRequest(False, 0, 0));
         endaction
         action 
            $display("count = %d", count);
            $display("dut1read[0] = %x", dut1.portB.response.get);
            dut1.portB.request.put(makeRequest(False, 1, 0));
         endaction
         action 
            $display("count = %d", count);
            $display("dut1read[1] = %x", dut1.portB.response.get);
            dut1.portB.request.put(makeRequest(False, 2, 0));
         endaction
         action 
            $display("count = %d", count);
            $display("dut1read[2] = %x", dut1.portB.response.get);
         endaction
         delay(100);
         action
            $finish();
         endaction
      endseq);
      mkAutoFSM(test);
endmodule