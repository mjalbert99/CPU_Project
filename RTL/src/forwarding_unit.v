module forwarding_unit #(parameter REG_W = 4, parameter DATA_W = 16, parameter OP_W = 5)(
    input valid_mem, valid_wb,
    input REG_IN_mem, REG_IN_wb,
    input[REG_W-1:0] a_idx, b_idx, c_idx,
    input signed[DATA_W-1:0] a_out_exe, b_out_exe, c_out_exe,
    input[REG_W-1:0]  dest_mem, dest_wb,
    input signed[DATA_W-1:0] alu_out_mem, reg_data,
    input[OP_W-1:0] op_code,
    output signed[DATA_W-1:0] for_a_out, for_b_out, for_c_out,
    output FORWARD
);

    wire mem_wr = valid_mem && REG_IN_mem;
    wire wb_wr  = valid_wb  && REG_IN_wb; 

    assign FORWARD = (   (mem_wr && a_idx == dest_mem) || (wb_wr && a_idx == dest_wb) ||
                         (mem_wr && b_idx == dest_mem) || (wb_wr && b_idx == dest_wb) ||
                         (op_code == 20 && mem_wr && c_idx == dest_mem) ||
                         (op_code == 20 && wb_wr  && c_idx == dest_wb)
    );

    assign for_a_out = (mem_wr && a_idx == dest_mem) ? alu_out_mem :
                       (wb_wr  && a_idx == dest_wb)  ? reg_data    : a_out_exe;

    assign for_b_out = (mem_wr && b_idx == dest_mem) ? alu_out_mem :
                       (wb_wr  && b_idx == dest_wb)  ? reg_data    : b_out_exe;

    assign for_c_out = (op_code == 20 && mem_wr && c_idx == dest_mem) ? alu_out_mem :
                       (op_code == 20 && wb_wr  && c_idx == dest_wb)  ? reg_data    : c_out_exe;
endmodule