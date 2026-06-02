module PC #(parameter ADDR_W = 16)(
    input en, clk, resetn, branch,
    input [ADDR_W-1:0] branch_addr,
    output reg [ADDR_W-1:0] index
);

    always@(posedge clk or negedge resetn) begin
        if(!resetn)
            index <= 0;

        else if(en)
            if(!branch)
                index <= index + 1'b1;
            else
                index <= branch_addr;  
    end

endmodule