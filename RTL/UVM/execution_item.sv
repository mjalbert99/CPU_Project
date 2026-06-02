class execution_item extends uvm_sequence_item;
    logic valid_exe;
    logic EN_exe, br_en;
    logic signed[15:0] for_a_out, for_b_out, for_c_out;
    logic signed[7:0] immd_exe;
    logic[4:0] op_code_exe;

    `uvm_object_utils_begin(execution_item)
  		`uvm_field_int(valid_exe, UVM_ALL_ON)
        `uvm_field_int(EN_exe, UVM_ALL_ON)
        `uvm_field_int(br_en, UVM_ALL_ON)
        `uvm_field_int(for_a_out, UVM_ALL_ON)
        `uvm_field_int(for_b_out, UVM_ALL_ON)
        `uvm_field_int(for_c_out, UVM_ALL_ON)
        `uvm_field_int(immd_exe, UVM_ALL_ON)
        `uvm_field_int(op_code_exe, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "exe_item");
        super.new(name);
    endfunction
endclass