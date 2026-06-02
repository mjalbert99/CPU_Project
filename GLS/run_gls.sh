# Compile
iverilog -DFUNCTIONAL -o gls_sim ../RTL/src/cpu_top_tb.v ../SYNTH/output/slow/cpu_top_slow_netlist.v \
/root/Work/vlsi/pdks/open_pdks/sky130/sky130B/libs.ref/sky130_fd_sc_hdll/verilog/primitives.v \
/root/Work/vlsi/pdks/open_pdks/sky130/sky130B/libs.ref/sky130_fd_sc_hdll/verilog/sky130_fd_sc_hdll.v &> results.txt

# Run to generate the sim.vcd file
vvp gls_sim  > results.txt

# Open in GTKWave
# gtkwave sim.vcd