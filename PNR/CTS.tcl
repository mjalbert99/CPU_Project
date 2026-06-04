set cts_buffers {sky130_fd_sc_hdll__clkbuf_2 \
                 sky130_fd_sc_hdll__clkbuf_4 \
                 sky130_fd_sc_hdll__clkbuf_8 \
                 sky130_fd_sc_hdll__clkbuf_16}

repair_clock_inverters

configure_cts_characterization -max_slew 0.8 -max_cap 0.50

clock_tree_synthesis -buf_list $cts_buffers \
                     -repair_clock_nets 


repair_clock_nets 
repair_timing
repair_design

detailed_placement -incremental
repair_design -slew_margin 0.8
repair_timing

source report.tcl

write_def output/${TOP}_cts.def
puts "\[INFO\] CTS completed successfully. File generated: output/${TOP}_cts.def"