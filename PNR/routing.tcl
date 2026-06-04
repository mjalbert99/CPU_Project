
global_route

detailed_route -output_drc reports/5_route_drc.rpt

repair_timing
check_antennas
repair_antennas

filler_placement -prefix FILLER_ {sky130_fd_sc_hdll__fill_1 sky130_fd_sc_hdll__fill_2 sky130_fd_sc_hdll__fill_4 sky130_fd_sc_hdll__fill_8}

write_def output/${TOP}_routed.def
puts "\[INFO\] Routing completed successfully. File generated: output/${TOP}_routed.def"