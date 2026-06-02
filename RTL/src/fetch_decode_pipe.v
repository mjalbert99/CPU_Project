module fetch_decode_pipe #(parameter INSTR_W = 21, parameter ADDR_W = 16) (
    input clk, en_cpu, resetn, br_en, valid_fetch,
    input[INSTR_W-1:0] instr,
    output reg[INSTR_W-1:0] instr_decode,
    output reg valid_decode
);
    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            instr_decode <= {INSTR_W{1'b0}};
            valid_decode <= 1'b0;
        end
        else if(br_en) begin
            instr_decode <= {INSTR_W{1'b0}};
            valid_decode <= 1'b0;
        end
        else if(en_cpu) begin
            instr_decode <= instr;
            valid_decode <= valid_fetch;
        end
    end

endmodule