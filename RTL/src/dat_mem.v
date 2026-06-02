module DAT_MEM#(parameter DATA_W = 16, parameter MEM_N = 256)(
    input clk, wr_en, rd_en,
    input [DATA_W-1:0] wr_addr, rd_addr, 
    input signed[DATA_W-1:0] data_in,
    output signed[DATA_W-1:0] out
);
    parameter IDX = $clog2(MEM_N);
    reg signed[DATA_W-1:0] mem_file[0:MEM_N-1];

    wire addr_match = wr_en && rd_en && (wr_addr[IDX-1:0] == rd_addr[IDX-1:0]);

    initial begin
        $readmemb("base_files/dat_mem.txt", mem_file);
    end

    assign out = (~rd_en)?{DATA_W{1'b0}}:
                 (addr_match)?data_in:
                  mem_file[rd_addr[IDX-1:0]];

    always@(posedge clk) begin
        if(wr_en)
            mem_file[wr_addr[IDX-1:0]] <= data_in;
    end

endmodule