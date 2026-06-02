set out_dir "reports"
file mkdir ${out_dir}

# 1. Parasitic Extraction
# extract_parasitics
# write_spef ${out_dir}/${TOP}.spef
# puts "\[INFO\] SPEF file written to ${out_dir}/${TOP}.spef"

# 2. Timing Reports
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

# 3. Design Rule Violations (DRVs)
report_check_types -max_slew -violators > ${out_dir}/slew_drv.rpt
report_check_types -max_capacitance -violators > ${out_dir}/cap_drv.rpt
report_check_types -max_fanout -violators > ${out_dir}/fanout_drv.rpt

# 4. Metrics
report_design_area_metrics > ${out_dir}/area.rpt
report_power > ${out_dir}/power.rpt