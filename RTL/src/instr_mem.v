module INSTR_MEM#(parameter ADDR_W = 16, parameter INSTR_W = 21)
(
    input [ADDR_W-1:0] index, 
    output [INSTR_W-1:0] instr 
);
    parameter IDX = $clog2(255);
    reg[INSTR_W-1:0] instructions[0:255];

    initial begin
        $readmemb("assembler/out.txt", instructions);
    end

    assign instr = instructions[index[IDX-1:0]];

endmodule