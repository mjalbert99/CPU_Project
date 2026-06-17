set TOP "cpu_top"
set SYNTH_DIR "../SYNTH"
set SDC_PATH "../RTL/constraints/cpu_top.sdc"

set PDK_ROOT "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref"
set TECH_LEF  "${PDK_ROOT}/sky130_fd_sc_hdll/techlef/sky130_fd_sc_hdll__max.tlef"
set CELL_LEF "${PDK_ROOT}/sky130_fd_sc_hdll/lef/sky130_fd_sc_hdll.lef"
set LIB_FILE_SLW  "${PDK_ROOT}/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ss_100C_1v60.lib"
set LIB_FILE_FST  "${PDK_ROOT}/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ff_n40C_1v95.lib"

# --- Read LEFs ---
read_lef $TECH_LEF
read_lef $CELL_LEF

read_liberty -min $LIB_FILE_FST
read_liberty -max $LIB_FILE_SLW

read_verilog ${SYNTH_DIR}/output/slow/${TOP}_slow_netlist.v
link_design $TOP

read_sdc $SDC_PATH

file mkdir output


initialize_floorplan -utilization 75 \
                     -aspect_ratio 1.0 \
                     -core_space 20.0 \
                     -site unithd

make_tracks

set_io_pin_constraint -pin_names cpu_result -region right:*
set_io_pin_constraint -pin_names clk -region left:*

place_pins -hor_layers met3 -ver_layers met2 \
            -min_distance 15 \
            -exclude top:* \
            -exclude bottom:* \
            -group_pins {clk resetn en_cpu} \
            -group_pins {cpu_result valid_wb} \
            -corner_avoidance 50

insert_tiecells "sky130_fd_sc_hdll__conb_1/HI" -prefix "TIE_HIGH_"
insert_tiecells "sky130_fd_sc_hdll__conb_1/LO" -prefix "TIE_LOW_"         
place_tapcells
place_endcaps

# --- PDN DOMAIN ---
add_global_connection -net VDD -pin_pattern {^VDD$} -power
add_global_connection -net VSS -pin_pattern {^VSS$} -ground

# add_global_connection -net VDD -pin_pattern {^one_$} -power

set_voltage_domain -power VDD -ground VSS

define_pdn_grid -name "Core"

# --- PDN RING ---
add_pdn_ring -grid "Core" \
             -layers {met4 met5} \
             -widths 3.0 \
             -spacings 2.0 \
             -core_offsets 5.0 \
             -add_connect

# Connects to STD rows
add_pdn_stripe -grid "Core" \
               -followpins \
               -layer met1 \
               -width 0.48 \
               -snap_to_grid

# --- PDN MESH ---

add_pdn_stripe -grid "Core" \
               -layer met4 \
               -width 1.6 \
               -pitch 112.0 \
               -spacing 54.4 \
               -offset 5.0 \
               -extend_to_core_ring


add_pdn_stripe -grid "Core" \
               -layer met5 \
               -width 1.6 \
               -pitch 112.0 \
               -spacing 54.4 \
               -offset 5.0 \
               -extend_to_core_ring

add_pdn_connect -grid "Core" -layers {met1 met4}

pdngen

write_def output/${TOP}_floorplanned.def

puts "\[INFO\] Floorplan completed successfully. File generated: output/${TOP}_floorplanned.def"