module CONTROLLER#(parameter INSTR_W = 21, parameter OP_W = 5)(                
    input [INSTR_W-1:0] instr,
    output reg DAT_OUT, DAT_IN, REG_IN,
    output reg EN,
    output [OP_W-1:0] op_code
);                

    assign op_code = instr[INSTR_W-1 : INSTR_W-OP_W];                

    always@(*)begin                               
        DAT_IN = 0;                
        DAT_OUT = 0;   
        REG_IN = 1;                        
        EN = 1;                

        case(op_code)                
            5'd0 : begin // NO-OP
                EN = 0; 
                REG_IN = 0;
            end                
            
            // ADD, AND, SUB, OR, XOR, LS, RS, MULT
            5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7, 5'd8: begin
                // EN = 1;
            end                

            // ADDI, ANDI, SUBI, ORI, XORI, LSI, RSI, MULTI
            5'd9, 5'd10, 5'd11, 5'd12, 5'd13, 5'd14, 5'd15, 5'd16: begin                              
            end                

            5'd17: begin // NOT
                // Logic
            end                

            5'd18: begin // STR                
                DAT_IN = 1;   
                REG_IN = 0;          
            end                

            5'd19: begin // LW                
                DAT_OUT = 1;                
            end                

            5'd20: begin // BRANCH    
                REG_IN = 0;          
            end                

            default: begin
                EN = 0; // IF INVALID COMMAND DO NOTHING
                REG_IN = 0;
            end
        endcase                
    end                
endmodule
