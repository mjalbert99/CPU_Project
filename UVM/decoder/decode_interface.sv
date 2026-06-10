interface decode_interface(input clk);
    logic valid_decode;
    logic DAT_OUT, DAT_IN, REG_IN, EN;
    logic[3:0] a_idx, b_idx, c_idx;


    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input valid_decode;
        input DAT_OUT, DAT_IN, REG_IN, EN;
        input a_idx, b_idx, c_idx;
    endclocking

endinterface
