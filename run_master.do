vlib work
vlog apb_config_pkg.sv apb_master.sv master_arb_if.sv master_apb_seq_item_pkg.sv  write_sequence_pkg.sv master_apb_sequencer_pkg.sv master_apb_driver_pkg.sv master_apb_agent_pkg.sv wait_sequence.sv read_seq.sv max_address_seq.sv apb_coverage_pkg.sv apb_scoreboard_pkg.sv apb_env_pkg.sv apb_test_pkg.sv TOP.sv  +cover -covercells
vsim -voptargs=+acc work.apb_top -cover
add wave -position insertpoint sim:/apb_top/mast_inter/*
add wave -position insertpoint sim:/apb_top/dut1/*
add wave /apb_top/dut1/assert__p1 /apb_top/dut1/assert__p2 /apb_top/dut1/assert__p3 /apb_top/dut1/assert__p4  /apb_top/dut1/assert__p5 /apb_top/dut1/assert__p6  
coverage save apb.ucdb -onexit -du apb_master
run -all
vcover report apb.ucdb -details -annotate -all -output coverage_rpt.txt



