
// 1. UVM Basics
import uvm_pkg::*;
`include "uvm_macros.svh"

// 2. RTL and Interface (The "Physical" Layer)
`include "fetch_decode_pipe.v"
`include "decode_exe_pipe.v"
`include "exe_mem_pipe.v"
`include "mem_wb_pipe.v"
`include "forwarding_unit.v"
`include "pc.v"
`include "instr_mem.v"
`include "controller.v"
`include "reg_file.v"
`include "alu.v"
`include "dat_mem.v"
`include "cpu_top.v"

// INTERFACES
`include "cpu_interface.sv"
`include "decode_interface.sv"
`include "execution_interface.sv"

// 3. Basic Data and Components
`include "decode_item.sv"
`include "execution_item.sv"
`include "cpu_sequencer.sv"
`include "cpu_driver.sv"
`include "cpu_monitor.sv"
`include "cpu_coverage.sv"
`include "decode_monitor.sv"
`include "decode_coverage.sv"
`include "execution_monitor.sv"
`include "execution_coverage.sv"
`include "scoreboard.sv"

// 4. Containers and Virtual Layers         
`include "cpu_agent.sv"          
`include "virtual_sequencer.sv"
`include "env.sv"            


// 5. The Test and Top
`include "test.sv"           
`include "top.sv"           