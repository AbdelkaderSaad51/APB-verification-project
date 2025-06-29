package max_address_sequence_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import master_apb_seq_item_pkg::*;

class max_address_sequence extends uvm_sequence #(master_apb_seq_item);
 `uvm_object_utils(max_address_sequence)

master_apb_seq_item mast_seq_item;

function new(string name = "max_address_sequence");
super.new(name);
endfunction

task body();

repeat(10)begin
mast_seq_item = master_apb_seq_item::type_id::create("mast_seq_item");
mast_seq_item.read_c.constraint_mode(0);
start_item(mast_seq_item);
assert(mast_seq_item.randomize() with{i_addr==32'hFFFFFFFF;});
finish_item(mast_seq_item);
end

repeat(10)begin
mast_seq_item = master_apb_seq_item::type_id::create("mast_seq_item");
mast_seq_item.write_c.constraint_mode(0);
start_item(mast_seq_item);
assert(mast_seq_item.randomize() with{i_addr==32'hFFFFFFFF;});
finish_item(mast_seq_item);
end

endtask



endclass
endpackage