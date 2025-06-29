package master_apb_seq_item_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class master_apb_seq_item extends uvm_sequence_item;

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
///////////// left side ///////////////////////
rand bit [DATA_WIDTH-1:0] i_wr_data;
rand bit [ADDR_WIDTH-1:0] i_addr;
rand bit i_rstn_apb, i_valid, i_rd0_wr1;
bit [DATA_WIDTH-1:0] o_rd_data;
bit o_rd_valid, o_ready;

////////// right side /////////////
bit [DATA_WIDTH-1:0] o_pwdata;
bit [ADDR_WIDTH-1:0] o_paddr;
bit o_psel, o_penable, o_pwrite;
rand bit [DATA_WIDTH-1:0] i_prdata;
rand bit i_pready;
bit i_pslverr;

// UVM Utility Macros
  `uvm_object_utils_begin(master_apb_seq_item)
    `uvm_field_int(i_wr_data, UVM_DEFAULT)
    `uvm_field_int(i_addr, UVM_DEFAULT)
    `uvm_field_int(i_rstn_apb, UVM_DEFAULT)
    `uvm_field_int(i_valid, UVM_DEFAULT)
    `uvm_field_int(i_rd0_wr1, UVM_DEFAULT)

    `uvm_field_int(o_rd_data, UVM_DEFAULT)
    `uvm_field_int(o_rd_valid, UVM_DEFAULT)
    `uvm_field_int(o_ready, UVM_DEFAULT)

    `uvm_field_int(o_pwdata, UVM_DEFAULT)
    `uvm_field_int(o_paddr, UVM_DEFAULT)
    `uvm_field_int(o_psel, UVM_DEFAULT)
    `uvm_field_int(o_penable, UVM_DEFAULT)
    `uvm_field_int(o_pwrite, UVM_DEFAULT)

    `uvm_field_int(i_prdata, UVM_DEFAULT)
    `uvm_field_int(i_pslverr, UVM_DEFAULT)
    `uvm_field_int(i_pready, UVM_DEFAULT)
  `uvm_object_utils_end


function new(string name ="master_apb_seq_item");
super.new(name);
endfunction


function string convert2string(); 
return $sformatf("%s i_rstn_apb = 0b%0b,i_wr_data = 0b%0b, i_addr = 0b%0b, i_valid = 0b%0b, i_rd0_wr1 = 0b%0b, o_rd_data = 0b%0b , o_rd_valid = 0b%0b, o_ready = 0b%0b, o_pwdata = 0b%0b, o_paddr = 0b%0b, o_psel = 0b%0b, o_penable = 0b%0b, o_pwrite = 0b%0b, i_prdata = 0b%0b, i_pslverr = 0b%0b, i_pready = 0b%0b",super.convert2string, i_rstn_apb,i_wr_data, i_addr, i_valid, i_rd0_wr1, o_rd_data,o_rd_valid,o_ready,o_pwdata,o_paddr,o_psel,o_penable,o_pwrite,i_prdata,i_pslverr,i_pready);
endfunction


function string convert2string_stimulus(); 
return $sformatf("i_rstn_apb = 0b%0b,i_wr_data = 0b%0b, i_addr = 0b%0b, i_valid = 0b%0b, i_rd0_wr1 = 0b%0b, o_rd_data = 0b%0b , o_rd_valid = 0b%0b, o_ready = 0b%0b, o_pwdata = 0b%0b, o_paddr = 0b%0b, o_psel = 0b%0b, o_penable = 0b%0b, o_pwrite = 0b%0b, i_prdata = 0b%0b, i_pslverr = 0b%0b, i_pready = 0b%0b", i_rstn_apb,i_wr_data, i_addr, i_valid, i_rd0_wr1, o_rd_data,o_rd_valid,o_ready,o_pwdata,o_paddr,o_psel,o_penable,o_pwrite,i_prdata,i_pslverr,i_pready);
endfunction

////////////////////////////////


// Constraints for valid 
    constraint common_c {
        i_valid dist {0 := 10, 1 := 90};
    }

    // Separate constraints for read and write transactions
    constraint read_c {
       i_rd0_wr1 == 1'b0;
       i_pready dist {0 := 30, 1 := 70};
    }

    constraint write_c {
        i_rd0_wr1 == 1'b1;
        i_wr_data inside {[0 : (1<<DATA_WIDTH)-1]};  // Range constraint for data width
        i_pready dist {0 := 20, 1 := 80}; 
    }

    // Address constraint common to both read and write
    constraint addr_c {
        i_addr inside {[0 : (1<<ADDR_WIDTH)-1]};
    }

  
    
endclass

endpackage
