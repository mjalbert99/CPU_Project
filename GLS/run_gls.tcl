iverilog -DFUNCTIONAL -o gls_sim ../RTL/src/cpu_top_tb.v ../SYNTH/output/slow/cpu_top_slow_netlist.v /root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/verilog/primitives.v /root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/verilog/sky130_fd_sc_hdll.v &> results.txt
vvp gls_sim  &> results.txt
# gtkwave sim.vcd