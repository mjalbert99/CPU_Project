
drc off
gds readonly true
gds rescue false


gds read /root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/gds/sky130_fd_sc_hdll.gds

lef read /root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/techlef/sky130_fd_sc_hdll__max.tlef
lef read /root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lef/sky130_fd_sc_hdll.lef

def read output/cpu_top_routed.def

load cpu_top
select top cell

gds write gds/final_cpu_top.gds

drc on
drc check
set drc_errors [drc list count total]
puts "TOTAL DRC ERRORS: $drc_errors"

set drc_log [open "gds/drc_signoff.log" w]
puts $drc_log "DRC Error Count: $drc_errors"
if {$drc_errors > 0} {
    puts $drc_log [drc list count]
}
close $drc_log


extract path gds
extract do local
extract all
ext2spice lvs
ext2spice subcircuits on
ext2spice subcircuit top on

ext2spice prefix gds/
ext2spice cpu_top

exit