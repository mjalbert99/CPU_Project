#!/bin/bash

python3 assembler/assembler.py

verilator --lint-only src/cpu_top.v \
                      src/decode_exe_pipe.v \
                      src/exe_mem_pipe.v \
                      src/fetch_decode_pipe.v \
                      src/mem_wb_pipe.v \
                      src/forwarding_unit.v \
                      src/pc.v \
                      src/instr_mem.v \
                      src/controller.v \
                      src/reg_file.v \
                      src/dat_mem.v \
                      src/alu.v &> lint.txt

# 1. Compile all source files and the testbench
# Listed in order of dependency
iverilog -o cpu_sim \
            src/decode_exe_pipe.v \
            src/fetch_decode_pipe.v \
            src/exe_mem_pipe.v \
            src/mem_wb_pipe.v \
            src/forwarding_unit.v \
            src/alu.v \
            src/controller.v \
            src/cpu_top.v \
            src/dat_mem.v \
            src/instr_mem.v \
            src/pc.v \
            src/reg_file.v \
            src/cpu_top_tb.v &> results.txt

# 2. Run the simulation using the vvp runtime
vvp cpu_sim > results.txt

#Automatically open the waveform if the simulation finishes
# gtkwave cpu_trace.vcd