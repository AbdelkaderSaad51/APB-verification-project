package apb_scoreboard_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import master_apb_seq_item_pkg::*;
import apb_config_pkg::*;

class apb_scoreboard extends uvm_subscriber#(master_apb_seq_item);
  `uvm_component_utils(apb_scoreboard)


  function new(string name = "apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  int write_count = 0;
  int read_count = 0;

virtual function void write(master_apb_seq_item t);
  if (t.i_rd0_wr1 == 1) begin
    write_count++;
    `uvm_info("WRITE_XACT", $sformatf("Write @ 0x%h = 0x%h", t.i_addr, t.i_wr_data), UVM_MEDIUM)
  end else begin
    read_count++;
    `uvm_info("READ_XACT", $sformatf("Read @ 0x%h → Expected data soon!", t.i_addr), UVM_MEDIUM)
  end
endfunction

virtual function void report_phase(uvm_phase phase);
  `uvm_info("REPORT", $sformatf("Writes: %0d | Reads: %0d", write_count, read_count), UVM_LOW)
endfunction

endclass

endpackage