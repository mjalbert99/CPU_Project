yosys -import
file mkdir output
set TOP cpu_top

set WORKING_DIR "../RTL/"
set END_DIR "../SYNTH/"

set ABC_FILE "constraints/constr.abc"
set ABC_SET "constraints/abc_settings"

set SLW_PDK_LIB "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ss_100C_1v60.lib"
set TYP_PDK_LIB "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__tt_025C_1v80.lib"
set FST_PDK_LIB "/root/Work/vlsi/pdks/pdk/sky130B/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__ff_n40C_1v95.lib"

cd ${WORKING_DIR}
read_verilog  src/alu.v src/controller.v src/dat_mem.v src/pc.v src/reg_file.v \
    src/instr_mem.v src/fetch_decode_pipe.v src/decode_exe_pipe.v \
    src/exe_mem_pipe.v src/mem_wb_pipe.v src/forwarding_unit.v src/cpu_top.v

# Initial structure check
hierarchy -check -top $TOP
design -save pre_synth

set corners [list "slow" $SLW_PDK_LIB "typ" $TYP_PDK_LIB "fast" $FST_PDK_LIB]

foreach {corner_name corner_lib} $corners {
    file mkdir ${END_DIR}/output/${corner_name}
    design -load pre_synth

    # Generic synthesis — flattened, no abc yet
    synth -top $TOP -flatten -noabc -booth

    memory_map
    opt -full

    # Map flip-flops to liberty cells
    dfflibmap -liberty $corner_lib

    # Force hard structural fanout buffering before ABC mapping
    splitnets
    insbuf -buf sky130_fd_sc_hdll__buf_4 A X
    clean

    abc -liberty $corner_lib -clk clk -constr ${ABC_FILE} -script ${ABC_SET}

    opt -full
    opt_clean -purge

    hilomap -hicell sky130_fd_sc_hdll__conb_1 HI LO
    splitnets
    opt_clean
    clean -purge

    write_verilog  ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_netlist.v

    read_liberty -lib -ignore_miss_dir $corner_lib
    tee -o ${END_DIR}/output/${corner_name}/${TOP}_${corner_name}_stat.txt stat -liberty $corner_lib
}

cd ${END_DIR}