set TOP "cpu_top"
set WORKING_DIR "../RTL/"
set SDC_FILE "${WORKING_DIR}/constraints/cpu_top.sdc"

set corners [list \
    "slow" "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ss_100C_1v60.lib" \
    "typ"  "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__tt_025C_1v80.lib" \
    "fast" "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ff_n40C_1v95.lib" \
]

foreach {corner_name lib_file} $corners {
    set out_dir "output/${corner_name}"

    puts "\n================================================================"
    puts " Corner : $corner_name"
    puts "================================================================\n"

    read_liberty $lib_file
    read_verilog  output/${corner_name}/${TOP}_${corner_name}_netlist.v
    link_design   $TOP
    read_sdc      $SDC_FILE


    report_checks \
        -path_delay max \
        -fields     {slew cap input_pins fanout} \
        -format     full_clock_expanded \
        -no_line_splits \
        > ${out_dir}/setup_timing.rpt


    report_checks \
        -path_delay min \
        -fields     {slew cap input_pins fanout} \
        -format     full_clock_expanded \
        -no_line_splits \
        > ${out_dir}/hold_timing.rpt


    report_wns -digits 4 > ${out_dir}/wns.rpt
    report_tns -digits 4 > ${out_dir}/tns.rpt


    report_check_types \
        -max_slew \
        -violators \
        > ${out_dir}/slew_drv.rpt

    report_check_types \
        -max_capacitance \
        -violators \
        > ${out_dir}/cap_drv.rpt

    report_check_types \
        -max_fanout \
        -violators \
        > ${out_dir}/fanout_drv.rpt

    puts "  Done — reports in ${out_dir}/"

}
exit