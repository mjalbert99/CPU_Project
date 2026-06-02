# Define wire parasitics layer before timing optimization loops
set_wire_rc -layer "met3"

global_placement -routability_driven -timing_driven -incremental
repair_design
detailed_placement -incremental

write_def output/${TOP}_placed.def
puts "\[INFO\] Placement completed successfully. File generated: output/${TOP}_placed.def"