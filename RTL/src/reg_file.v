// reg_file.v
module REG_FILE#(parameter DATA_W = 16, parameter REG_N = 16, parameter REG_W = 4)(
    input clk, resetn, wr_en,
    input [REG_W-1:0] a_idx, b_idx, c_idx, wr_idx,
    input signed [DATA_W-1:0] data_in,
    output signed [DATA_W-1:0] a_out, b_out, c_out
);
    reg signed [DATA_W-1:0] reg_file [0:REG_N-1];
    integer i;

    // assign a_out = reg_file[a_idx];
    // assign b_out = reg_file[b_idx];
    // assign c_out = reg_file[c_idx];

    assign a_out = (wr_en && wr_idx == a_idx) ? data_in : reg_file[a_idx];
    assign b_out = (wr_en && wr_idx == b_idx) ? data_in : reg_file[b_idx];
    assign c_out = (wr_en && wr_idx == c_idx) ? data_in : reg_file[c_idx];

    always@(posedge clk or negedge resetn) begin
        if(!resetn) begin
            for(i = 0; i < REG_N; i = i + 1)begin
                reg_file[i] <= {DATA_W{1'b0}};
            end
        end
        else begin
            if(wr_en)
                reg_file[wr_idx] <= data_in;
        end
    end

endmodule