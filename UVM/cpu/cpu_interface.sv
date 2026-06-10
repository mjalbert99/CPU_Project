interface cpu_interface(input clk);

    logic resetn, en_cpu, valid_wb, immd_en;
    logic signed[16-1:0] cpu_result;
    logic[15:0] pc_index;
    logic[4:0] op_code;

    clocking cg_drv@(posedge clk);
        default input #1ns output #1ns;
        output resetn, en_cpu;
    endclocking

    clocking cg_mon@(posedge clk);
        default input #1ns output #1ns;
        input resetn, en_cpu, valid_wb, cpu_result, pc_index, op_code, immd_en;
    endclocking

    function void write_instructions(string file);
        $readmemb(file, top.DUT.instr_mem.instructions);
    endfunction

    function void write_dat_mem(string file);
        $readmemb(file, top.DUT.dat_mem.mem_file);
    endfunction
  
  a_reset_behavior: assert property (@(posedge clk) (!resetn) |-> (en_cpu == 0))
      else `uvm_error("SVA_PROT_FAIL", "en_cpu must be low when resetn is active!")

  a_stall_propagation: assert property (@(posedge clk) disable iff (!resetn) $fell(en_cpu) |=> $stable(valid_wb)) 
    else `uvm_error("SVA_PROT_FAIL", "A stall on en_cpu failed to stablize valid_wb!")
 
  a_stall_propagation_idx: assert property (@(posedge clk) disable iff (!resetn) $fell(en_cpu) |=> $stable(pc_index)) 
    else `uvm_error("SVA_PROT_FAIL", "A stall on en_cpu failed to stablize pc_index!")

  stall_pc_index: assert property (@(posedge clk) disable iff(!resetn) (!en_cpu) |=> $stable(pc_index))
    else `uvm_error("SVA_PROT_FAIL", "pc_index is stable when the cpu is disabled!")

endinterface
