# Define wire parasitics layer before timing optimization loops
set_wire_rc -layer "met3"

global_placement -timing_driven -routability_driven

buffer_ports -inputs
repair_timing
repair_design

detailed_placement -incremental 
repair_design
repair_timing

write_def output/${TOP}_placed.def
puts "\[INFO\] Placement completed successfully. File generated: output/${TOP}_placed.def"