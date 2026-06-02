module ALU#(parameter DATA_W = 16, parameter IMMD_W = 8, parameter OP_W = 5)(
    input en,
    input[OP_W-1:0] op_code,
    input signed [DATA_W-1:0] reg1, reg2, reg3,
    input signed [IMMD_W-1:0] immd,
    output reg signed [DATA_W-1:0] out, str_addr, lw_addr,
    output reg br_en
);

    // Separate extension wires
    wire signed [DATA_W-1:0] sign_ext_immd;
    wire [DATA_W-1:0] zero_ext_immd;

    assign sign_ext_immd = {{(DATA_W-IMMD_W){immd[IMMD_W-1]}}, immd};
    assign zero_ext_immd = {{(DATA_W-IMMD_W){1'b0}}, immd};

    always@(*) begin
        str_addr = {DATA_W{1'b0}};
        lw_addr = {DATA_W{1'b0}};
        br_en = 1'b0;
        if(!en) begin
            out = {DATA_W{1'b0}};
        end
        else begin
            case(op_code)
                // Register-Register Operations
                5'd1: out = reg1 + reg2; // ADD
                5'd2: out = reg1 & reg2; // AND
                5'd3: out = reg1 - reg2; // SUB
                5'd4: out = reg1 | reg2; // OR
                5'd5: out = reg1 ^ reg2; // XOR
                5'd6: out = reg1 << reg2; // LS
                5'd7: out = reg1 >>> reg2; // ARS
                5'd8: out = reg1 * reg2; // MULT   
                
                // Immediate Operations
                5'd9:  out = reg1 + sign_ext_immd;  // ADDI (Arithmetic)
                5'd10: out = reg1 & zero_ext_immd;  // ANDI (Logical)
                5'd11: out = reg1 - sign_ext_immd;  // SUBI (Arithmetic)
                5'd12: out = reg1 | zero_ext_immd;  // ORI  (Logical)
                5'd13: out = reg1 ^ zero_ext_immd;  // XORI (Logical)
                5'd14: out = reg1 << zero_ext_immd; // LSI  (Logical)
                5'd15: out = reg1 >>> zero_ext_immd;// RSI  (Logical Shift Amount)
                5'd16: out = reg1 * sign_ext_immd;  // MULTI(Arithmetic)

                5'd17: out = ~reg1; // NOT
                
                // Memory Pass-through
                5'd18: begin
                    str_addr = reg1;
                    out = reg2; 
                end
                5'd19: begin
                    lw_addr = reg1;
                    out = reg2; 
                end

                5'd20: begin // BR
                    out = (reg1 != reg2) ? reg3 : {DATA_W{1'b0}};
                    br_en = (reg1 != reg2) ? 1'b1 : 1'b0;
                end

                default: out = {DATA_W{1'b0}};
            endcase
        end
    end

endmodule