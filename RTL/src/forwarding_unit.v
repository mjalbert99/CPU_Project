module forwarding_unit #(parameter REG_W = 4, parameter DATA_W = 16, parameter OP_W = 5
)(
    input clk, resetn, en_cpu, br_en,
    input [REG_W-1:0] a_idx, b_idx, c_idx,
    input [OP_W-1:0] op_code,
    input valid_exe, REG_IN_exe,
    input [REG_W-1:0] dest_exe,
    input valid_mem, REG_IN_mem,
    input [REG_W-1:0] dest_mem,
    input signed [DATA_W-1:0] a_out_exe, b_out_exe, c_out_exe,
    input signed [DATA_W-1:0] alu_out_mem, reg_data,
    output signed [DATA_W-1:0] for_a_out, for_b_out, for_c_out,
    output FORWARD
);

    wire a_match_exe = valid_exe && REG_IN_exe && (a_idx == dest_exe);
    wire a_match_mem = valid_mem && REG_IN_mem && (a_idx == dest_mem);
    
    wire b_match_exe = valid_exe && REG_IN_exe && (b_idx == dest_exe);
    wire b_match_mem = valid_mem && REG_IN_mem && (b_idx == dest_mem);
    
    wire is_op20 = (op_code == 5'd20);
    wire c_match_exe = is_op20 && valid_exe && REG_IN_exe && (c_idx == dest_exe);
    wire c_match_mem = is_op20 && valid_mem && REG_IN_mem && (c_idx == dest_mem);

    reg sel_a_mem, sel_a_wb;
    reg sel_b_mem, sel_b_wb;
    reg sel_c_mem, sel_c_wb;

    assign FORWARD = sel_a_mem || sel_a_wb || 
                     sel_b_mem || sel_b_wb ||
                     sel_c_mem || sel_c_wb;

    assign for_a_out = sel_a_mem ? alu_out_mem :
                       sel_a_wb  ? reg_data    : a_out_exe;

    assign for_b_out = sel_b_mem ? alu_out_mem :
                       sel_b_wb  ? reg_data    : b_out_exe;

    assign for_c_out = sel_c_mem ? alu_out_mem :
                       sel_c_wb  ? reg_data    : c_out_exe;
                       
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sel_a_mem <= 1'b0; sel_a_wb <= 1'b0;
            sel_b_mem <= 1'b0; sel_b_wb <= 1'b0;
            sel_c_mem <= 1'b0; sel_c_wb <= 1'b0;
        end   
        else if (br_en) begin
            sel_a_mem <= 1'b0; sel_a_wb <= 1'b0;
            sel_b_mem <= 1'b0; sel_b_wb <= 1'b0;
            sel_c_mem <= 1'b0; sel_c_wb <= 1'b0;
        end
        else if (en_cpu) begin
            sel_a_mem <= a_match_exe;
            sel_a_wb  <= !a_match_exe && a_match_mem;
            
            sel_b_mem <= b_match_exe;
            sel_b_wb  <= !b_match_exe && b_match_mem;
            
            sel_c_mem <= c_match_exe;
            sel_c_wb  <= !c_match_exe && c_match_mem;
        end
    end

endmodule