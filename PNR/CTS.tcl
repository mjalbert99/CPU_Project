set cts_buffers {sky130_fd_sc_hdll__clkbuf_2 \
                 sky130_fd_sc_hdll__clkbuf_4 \
                 sky130_fd_sc_hdll__clkbuf_8}

repair_clock_inverters

clock_tree_synthesis -buf_list $cts_buffers \
                     -repair_clock_nets 
repair_clock_nets 

global_placement -routability_driven -timing_driven -incremental
repair_timing
detailed_placement -incremental

set report_file [open "output/cts_timing.rpt" "w"]

report_checks -path_delay min_max -format full_clock_expanded > $report_file

close $report_file

write_def output/${TOP}_cts.def
puts "\[INFO\] CTS completed successfully. File generated: output/${TOP}_cts.def"