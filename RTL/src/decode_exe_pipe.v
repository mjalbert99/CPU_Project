module decode_exe_pipe #(parameter DATA_W = 16, parameter OP_W = 5, parameter IMMD_W = 8, parameter REG_W = 4) (
    input clk, en_cpu, resetn, br_en, valid_decode,
    input DAT_OUT, DAT_IN, REG_IN, EN,
    input[OP_W-1:0] op_code,
    input signed[DATA_W-1:0] a_out, b_out, c_out,
    input signed[IMMD_W-1:0] immd,
    input[REG_W-1:0] a_idx, b_idx, c_idx,
    output reg DAT_OUT_exe, DAT_IN_exe, REG_IN_exe, EN_exe,
    output reg[OP_W-1:0] op_code_exe,
    output reg valid_exe,
    output reg signed[DATA_W-1:0] a_out_exe, b_out_exe, c_out_exe,
    output reg signed[IMMD_W-1:0] immd_exe,
    output reg[REG_W-1:0] a_idx_exe, b_idx_exe, c_idx_exe, dest_exe
);

    always@(posedge clk or negedge resetn) begin
        if(!resetn)begin
            valid_exe <= 1'b0;
            DAT_OUT_exe <= 1'b0;
            DAT_IN_exe <= 1'b0;
            REG_IN_exe <= 1'b0; 
            EN_exe <= 1'b0;
            op_code_exe <= {OP_W{1'b0}};
            a_out_exe <= {DATA_W{1'b0}};
            b_out_exe <= {DATA_W{1'b0}};
            c_out_exe <= {DATA_W{1'b0}};
            immd_exe <= {IMMD_W{1'b0}};
            a_idx_exe <= {REG_W{1'b0}};
            b_idx_exe <= {REG_W{1'b0}};
            c_idx_exe <= {REG_W{1'b0}};
            dest_exe <= {REG_W{1'b0}};
        end
        else if(br_en)begin
            valid_exe <= 1'b0;
            DAT_OUT_exe <= 1'b0;
            DAT_IN_exe <= 1'b0;
            REG_IN_exe <= 1'b0; 
            EN_exe <= 1'b0;
            op_code_exe <= {OP_W{1'b0}};
            a_out_exe <= {DATA_W{1'b0}};
            b_out_exe <= {DATA_W{1'b0}};
            c_out_exe <= {DATA_W{1'b0}};
            immd_exe <= {IMMD_W{1'b0}};
            a_idx_exe <= {REG_W{1'b0}};
            b_idx_exe <= {REG_W{1'b0}};
            c_idx_exe <= {REG_W{1'b0}};
            dest_exe <= {REG_W{1'b0}};
        end
        else if(en_cpu) begin
            valid_exe <= valid_decode;
            DAT_OUT_exe <= DAT_OUT;
            DAT_IN_exe <= DAT_IN;
            REG_IN_exe <= REG_IN; 
            EN_exe <= EN;
            op_code_exe <= op_code;
            a_out_exe <= a_out;
            b_out_exe <= b_out;
            c_out_exe <= c_out;
            immd_exe <= immd;
            a_idx_exe <= a_idx;
            b_idx_exe <= b_idx;
            c_idx_exe <= c_idx;
            dest_exe <= c_idx;
        end
    end
endmodule