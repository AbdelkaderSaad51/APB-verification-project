package apb_coverage_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

import apb_config_pkg::*;
import master_apb_seq_item_pkg::*;

class apb_coverage extends uvm_subscriber#(master_apb_seq_item);

  `uvm_component_utils(apb_coverage)
  master_apb_seq_item mast_seq_item_cov;
  


    covergroup cov;
        mast_in_valid: coverpoint mast_seq_item_cov.i_valid {
			bins mast_in_valid_1 = {1};
        }
        mast_in_rd0_wr1: coverpoint mast_seq_item_cov.i_rd0_wr1 {
                        bins mast_in_rd0_wr1_1 = {0};
						bins mast_in_rd0_wr1_2 = {1};
        }
		mast_out_rd_valid: coverpoint mast_seq_item_cov.o_rd_valid {
                        bins mast_out_rd_valid_1 = {1};
        }
		mast_out_ready: coverpoint mast_seq_item_cov.o_ready {
                        bins mast_out_ready_1 = {1};
        }
		/////////////////////////////////////////////////////////////////////////
		mast_out_psel: coverpoint mast_seq_item_cov.o_psel {
                        bins mast_out_psel_1 = {1};
        }
		mast_out_penable: coverpoint mast_seq_item_cov.o_penable {
                        bins mast_out_penable_1 = {1};
        }
		mast_out_pwrite: coverpoint mast_seq_item_cov.o_pwrite {
			bins mast_out_pwrite_1 = {0};
			bins mast_out_pwrite_2 = {1};
        }
		
		mast_in_pready: coverpoint mast_seq_item_cov.i_pready {
			bins mast_in_pready_1 = {1};
        }

    max_address: coverpoint mast_seq_item_cov.o_paddr {
      bins max={32'hFFFFFFFF};
      bins others = default;
    }
	//////////////////////////////////////////////////////////////////////////////////////////////	
    mast_l_0: cross mast_in_rd0_wr1, mast_in_valid;
    mast_l_1: cross mast_out_ready, mast_out_rd_valid ;
	
	  mast_r_0: cross mast_out_psel, mast_out_penable;
	  mast_r_1: cross mast_out_psel, mast_out_pwrite ;
	  mast_r_2: cross mast_out_penable, mast_out_pwrite ;
	  mast_r_3: cross mast_out_pwrite, mast_in_pready ;
    endgroup

  function new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    mast_seq_item_cov = master_apb_seq_item::type_id::create("mast_seq_item_cov");
    cov = new(); // Ensure cov is instantiated here
  endfunction


  function void write(master_apb_seq_item t);
    mast_seq_item_cov.copy(t);
    cov.sample();
  endfunction


endclass
endpackage

