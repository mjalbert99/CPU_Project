interface execution_interface(input clk);
    logic valid_exe;
    logic EN_exe, br_en;
    logic signed[15:0] for_a_out, for_b_out, for_c_out;
    logic signed[7:0] immd_exe;
    logic[4:0] op_code_exe;

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input valid_exe;
        input EN_exe, br_en;
        input for_a_out, for_b_out, for_c_out;
        input immd_exe;
        input op_code_exe;        
        
    endclocking

endinterface
