// ADD LW STR BNE INTO PROGRAM
module cpu_top #(parameter ADDR_W = 16, parameter INSTR_W = 21, parameter REG_W = 4, parameter REG_N = 16, 
                 parameter MEM_N = 256, parameter OP_W = 5, parameter IMMD_W = 8, parameter DATA_W = 16)
(
    input clk, resetn, en_cpu,
    output signed[DATA_W-1:0] cpu_result,
    output valid_wb
);
    // VALID operation across stages
    wire valid_decode, valid_exe, valid_mem, br_en;

    // Fetch signals
    wire[ADDR_W-1:0] pc_index;
    wire[INSTR_W-1:0] instr, instr_decode;

    // Control signals
    wire[OP_W-1:0] op_code, op_code_exe;
    wire DAT_OUT, DAT_IN, REG_IN, EN, DAT_OUT_exe, DAT_IN_exe, REG_IN_exe, EN_exe, DAT_IN_mem, DAT_OUT_mem, REG_IN_mem, REG_IN_wb;

    // register addrs, register vals, immd, and dest register dest
    wire[REG_W-1:0] a_idx, b_idx, c_idx, a_idx_exe, b_idx_exe, c_idx_exe, dest_exe, dest_mem, dest_wb;
    wire signed[DATA_W-1:0] a_out, b_out, c_out, a_out_exe, b_out_exe, c_out_exe;
    wire signed[IMMD_W-1:0] immd, immd_exe;

    // ALU output
    wire signed[DATA_W-1:0] alu_out, alu_out_mem; 
    wire[DATA_W-1:0] str_addr, lw_addr, str_addr_mem, lw_addr_mem; 

    // MEM output
    wire signed[DATA_W-1:0] dat_out;

    // WB data
    wire signed[DATA_W-1:0] reg_data;

    // Forwarding wire for signal and outputs
    wire FORWARD;
    wire signed[DATA_W-1:0] for_a_out, for_b_out, for_c_out;


    assign cpu_result = reg_data;

    assign a_idx = instr_decode[(2*REG_W)+IMMD_W-1:REG_W+IMMD_W];  // Bits [16:13]
    assign b_idx = instr_decode[(REG_W*2)-1:REG_W];                // Bits [7:4]
    assign c_idx = instr_decode[REG_W-1:0];                        // Bits [3:0]
    assign immd =  instr_decode[REG_W+IMMD_W-1:REG_W];             // Bits [12:4]


    PC #(.ADDR_W(ADDR_W)) pc(
        .en(en_cpu),
        .clk(clk),
        .resetn(resetn),
        .branch(br_en),
        .branch_addr(alu_out),
        .index(pc_index)
    );


    INSTR_MEM #(.ADDR_W(ADDR_W), .INSTR_W(INSTR_W)) instr_mem (
        .index(pc_index),
        .instr(instr)
    ); 


    fetch_decode_pipe #(.INSTR_W(INSTR_W), .ADDR_W(ADDR_W)) ftp(
        .clk(clk),
        .en_cpu(en_cpu),
        .resetn(resetn),
        .br_en(br_en),
        .valid_fetch(en_cpu),
        .instr(instr),
        .instr_decode(instr_decode),
        .valid_decode(valid_decode)
    );


    CONTROLLER #(.INSTR_W(INSTR_W), .OP_W(OP_W)) controller(
        .instr(instr_decode),
        .DAT_OUT(DAT_OUT),
        .DAT_IN(DAT_IN),
        .REG_IN(REG_IN),
        .EN(EN),
        .op_code(op_code)
    );


    REG_FILE #(.DATA_W(DATA_W), .REG_N(REG_N), .REG_W(REG_W)) reg_file(
        .clk(clk),
        .resetn(resetn),
        .wr_en(REG_IN_wb),
        .a_idx(a_idx),
        .b_idx(b_idx),
        .c_idx(c_idx),
        .wr_idx(dest_wb),
        .data_in(reg_data),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out)
    );


    decode_exe_pipe #(.DATA_W(DATA_W), .OP_W(OP_W), .IMMD_W(IMMD_W), .REG_W(REG_W))dep(
        .clk(clk),
        .en_cpu(en_cpu),
        .resetn(resetn),
        .br_en(br_en),
        .valid_decode(valid_decode),
        .DAT_OUT(DAT_OUT),
        .DAT_IN(DAT_IN),
        .REG_IN(REG_IN),
        .EN(EN),
        .op_code(op_code),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out),
        .immd(immd),
        .a_idx(a_idx),
        .b_idx(b_idx),
        .c_idx(c_idx),
        .DAT_OUT_exe(DAT_OUT_exe),
        .DAT_IN_exe(DAT_IN_exe),
        .REG_IN_exe(REG_IN_exe),
        .EN_exe(EN_exe),
        .op_code_exe(op_code_exe),
        .valid_exe(valid_exe),
        .a_out_exe(a_out_exe),
        .b_out_exe(b_out_exe),
        .c_out_exe(c_out_exe),
        .immd_exe(immd_exe),
        .a_idx_exe(a_idx_exe),
        .b_idx_exe(b_idx_exe),
        .c_idx_exe(c_idx_exe),
        .dest_exe(dest_exe)
    );


    ALU #(.DATA_W(DATA_W), .IMMD_W(IMMD_W), .OP_W(OP_W)) alu(
        .en(EN_exe),
        .op_code(op_code_exe),
        .reg1(for_a_out),
        .reg2(for_b_out),
        .reg3(for_c_out),
        .immd(immd_exe),
        .out(alu_out),
        .str_addr(str_addr),
        .lw_addr(lw_addr),
        .br_en(br_en)
    );


    exe_mem_pipe #(.REG_W(REG_W), .DATA_W(DATA_W)) emp(
        .clk(clk),
        .en_cpu(en_cpu),
        .resetn(resetn),
        .valid_exe(valid_exe),
        .DAT_IN_exe(DAT_IN_exe),
        .DAT_OUT_exe(DAT_OUT_exe),
        .REG_IN_exe(REG_IN_exe),
        .alu_out(alu_out),
        .str_addr(str_addr),
        .lw_addr(lw_addr),
        .dest_exe(dest_exe),
        .DAT_IN_mem(DAT_IN_mem),
        .DAT_OUT_mem(DAT_OUT_mem),
        .REG_IN_mem(REG_IN_mem),
        .alu_out_mem(alu_out_mem),
        .str_addr_mem(str_addr_mem),
        .lw_addr_mem(lw_addr_mem),
        .dest_mem(dest_mem),
        .valid_mem(valid_mem)
    );


    DAT_MEM #(.DATA_W(DATA_W), .MEM_N(MEM_N)) dat_mem(
        .clk(clk),
        .wr_en(DAT_IN_mem),
        .rd_en(DAT_OUT_mem),
        .wr_addr(str_addr_mem),
        .rd_addr(lw_addr_mem),
        .data_in(alu_out_mem),
        .out(dat_out)
    );


    mem_wb_pipe #(.REG_W(REG_W), .DATA_W(DATA_W)) mwp(
        .clk(clk),
        .en_cpu(en_cpu),
        .resetn(resetn),
        .valid_mem(valid_mem),
        .REG_IN_mem(REG_IN_mem),
        .DAT_OUT_mem(DAT_OUT_mem),
        .dest_mem(dest_mem),
        .dat_out(dat_out),
        .alu_out_mem(alu_out_mem),
        .valid_wb(valid_wb),
        .REG_IN_wb(REG_IN_wb),
        .dest_wb(dest_wb),
        .reg_data(reg_data)
    );


    forwarding_unit #(.REG_W(REG_W), .DATA_W(DATA_W), .OP_W(OP_W)) forward(
        .valid_mem(valid_mem),
        .valid_wb(valid_wb),
        .REG_IN_mem(REG_IN_mem),
        .REG_IN_wb(REG_IN_wb),
        .a_idx(a_idx_exe),
        .b_idx(b_idx_exe),
        .c_idx(c_idx_exe),
        .a_out_exe(a_out_exe),
        .b_out_exe(b_out_exe),
        .c_out_exe(c_out_exe),
        .dest_mem(dest_mem),
        .dest_wb(dest_wb),
        .alu_out_mem(alu_out_mem),
        .reg_data(reg_data),
        .op_code(op_code_exe),
        .for_a_out(for_a_out),
        .for_b_out(for_b_out),
        .for_c_out(for_c_out),
        .FORWARD(FORWARD)
    );

endmodule