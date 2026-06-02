create_clock -period 20 -name clk [get_ports clk]

set_clock_uncertainty -setup 0.4  [get_clocks clk]
set_clock_uncertainty -hold  0.05 [get_clocks clk]

set_input_delay  -clock clk -max 4.0   [get_ports [all_inputs]  -filter "name != clk"]
set_input_delay  -clock clk -min 0.0 [get_ports [all_inputs]  -filter "name != clk"]

set_output_delay -clock clk -max 4.0   [get_ports [all_outputs] -filter "name != clk"]
set_output_delay -clock clk -min 0.0 [get_ports [all_outputs] -filter "name != clk"]

set_load 0.05 [all_outputs]

set_max_capacitance 0.05 [all_outputs]

set_input_transition -max 0.5 [all_inputs]

set_max_transition 1.2 [current_design]

set_max_fanout 4 [current_design]


set_timing_derate -late -cell 1.03
set_timing_derate -late -net 1.03

set_timing_derate -early -cell 0.97
set_timing_derate -early -net 0.97
