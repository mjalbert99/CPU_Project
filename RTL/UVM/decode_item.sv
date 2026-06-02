class decode_item extends uvm_sequence_item;
    logic valid_decode;
    logic DAT_OUT, DAT_IN, REG_IN, EN;
    logic[3:0] a_idx, b_idx, c_idx;

    `uvm_object_utils_begin(decode_item)
        `uvm_field_int(valid_decode, UVM_ALL_ON)
        `uvm_field_int(DAT_OUT, UVM_ALL_ON)
        `uvm_field_int(DAT_IN, UVM_ALL_ON)
        `uvm_field_int(REG_IN, UVM_ALL_ON)
        `uvm_field_int(a_idx, UVM_ALL_ON)
        `uvm_field_int(b_idx, UVM_ALL_ON)
        `uvm_field_int(c_idx, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "cpu_item");
        super.new(name);
    endfunction
endclass