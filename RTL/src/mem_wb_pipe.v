module mem_wb_pipe #(parameter REG_W = 4, parameter DATA_W = 16) (
    input clk, en_cpu, resetn, valid_mem,
    input REG_IN_mem, DAT_OUT_mem,
    input[REG_W-1:0] dest_mem,
    input signed[DATA_W-1:0] dat_out, alu_out_mem,
    output reg valid_wb,
    output reg REG_IN_wb,
    output reg[REG_W-1:0] dest_wb,
    output reg signed[DATA_W-1:0] reg_data
);

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            valid_wb  <= 1'b0;
            REG_IN_wb <= 1'b0;
            dest_wb   <= {REG_W{1'b0}};
            reg_data  <= {DATA_W{1'b0}};
        end
        else if(en_cpu) begin
            valid_wb  <= valid_mem;          
            REG_IN_wb <= REG_IN_mem;
            dest_wb   <= dest_mem;
            reg_data  <= DAT_OUT_mem ? dat_out : alu_out_mem;
        end
    end

endmodule