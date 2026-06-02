module top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk;
    always #5 clk = ~clk;

    cpu_interface CPU_IF(clk);
    decode_interface DEC_IF(clk);
    execution_interface EXE_IF(clk);

    cpu_top DUT(clk, CPU_IF.resetn, CPU_IF.en_cpu, CPU_IF.cpu_result, CPU_IF.valid_wb);

    assign CPU_IF.pc_index = DUT.pc_index;
    assign CPU_IF.op_code = DUT.instr[20:16];
    assign CPU_IF.immd_en = (CPU_IF.op_code >= 5'd9 && CPU_IF.op_code <= 5'd16);

    assign DEC_IF.valid_decode = DUT.valid_decode;
    assign DEC_IF.DAT_OUT = DUT.DAT_OUT;
    assign DEC_IF.DAT_IN = DUT.DAT_IN;
    assign DEC_IF.REG_IN = DUT.REG_IN;
    assign DEC_IF.EN = DUT.EN;
    assign DEC_IF.a_idx = DUT.a_idx;
    assign DEC_IF.b_idx = DUT.b_idx;
    assign DEC_IF.c_idx = DUT.c_idx;

    assign EXE_IF.valid_exe   = DUT.valid_exe; 
    assign EXE_IF.EN_exe      = DUT.EN_exe;    
    assign EXE_IF.br_en       = DUT.br_en;
    assign EXE_IF.for_a_out   = DUT.for_a_out; 
    assign EXE_IF.for_b_out   = DUT.for_b_out; 
    assign EXE_IF.for_c_out   = DUT.for_c_out; 
    assign EXE_IF.immd_exe    = DUT.immd_exe; 
    assign EXE_IF.op_code_exe = DUT.op_code_exe;   

    initial begin
        clk = 0;
        uvm_config_db#(virtual cpu_interface)::set(null, "*", "CPU_IF", CPU_IF);
        uvm_config_db#(virtual decode_interface)::set(null, "*", "DEC_IF", DEC_IF);
        uvm_config_db#(virtual execution_interface)::set(null, "*", "EXE_IF", EXE_IF);
        run_test("test");
    end

endmodule