module exe_mem_pipe #(parameter REG_W = 4, parameter DATA_W = 16) (
    input clk, en_cpu, resetn, valid_exe,
    input DAT_IN_exe, DAT_OUT_exe, REG_IN_exe,
    input signed[DATA_W-1:0] alu_out,
    input[DATA_W-1:0] str_addr, lw_addr,
    input[REG_W-1:0] dest_exe,
    output reg DAT_IN_mem, DAT_OUT_mem, REG_IN_mem,
    output reg signed[DATA_W-1:0] alu_out_mem, 
    output reg [DATA_W-1:0] str_addr_mem, lw_addr_mem, 
    output reg[REG_W-1:0] dest_mem,
    output reg valid_mem
);

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            valid_mem <= 1'b0;
            DAT_IN_mem <= 1'b0;    
            DAT_OUT_mem <= 1'b0;    
            REG_IN_mem <= 1'b0;    
            alu_out_mem <= {DATA_W{1'b0}};
            str_addr_mem <= {DATA_W{1'b0}};
            lw_addr_mem <= {DATA_W{1'b0}};
            dest_mem <= {REG_W{1'b0}};
        end
        else if(en_cpu) begin
            valid_mem <= valid_exe;
            DAT_IN_mem <= DAT_IN_exe;    
            DAT_OUT_mem <= DAT_OUT_exe;    
            REG_IN_mem <= REG_IN_exe;    
            alu_out_mem <= alu_out;
            str_addr_mem <= str_addr;
            lw_addr_mem <= lw_addr;
            dest_mem <= dest_exe;
        end
    end

endmodule