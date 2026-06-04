create_clock -period 10 -name clk [get_ports clk]

set_max_transition 0.4 [get_ports resetn]

set_clock_uncertainty -setup 0.3  [get_clocks clk]
set_clock_uncertainty -hold  0.05 [get_clocks clk]

set_input_delay  -clock clk -max 2.0   [get_ports [all_inputs]  -filter "name != clk && name != resetn"]
set_input_delay  -clock clk -min 0.0 [get_ports [all_inputs]  -filter "name != clk && name != resetn"]

set_output_delay -clock clk -max 2.0   [get_ports [all_outputs] -filter "name != clk && name != resetn"]
set_output_delay -clock clk -min 0.0 [get_ports [all_outputs] -filter "name != clk && name != resetn"]

set_max_transition 1.2 [current_design]

set_timing_derate -late -cell 1.03
set_timing_derate -late -net 1.03

set_timing_derate -early -cell 0.97
set_timing_derate -early -net 0.97
