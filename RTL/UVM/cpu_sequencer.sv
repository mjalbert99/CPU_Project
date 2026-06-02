class cpu_item extends uvm_sequence_item;
    // logic and randomize data
    rand logic en_cpu, resetn;
    logic signed[15:0] cpu_result;
    logic[4:0] op_code;
    logic valid_wb, immd_en;

    `uvm_object_utils_begin(cpu_item)
        `uvm_field_int(en_cpu, UVM_ALL_ON)
        `uvm_field_int(resetn, UVM_ALL_ON)
        `uvm_field_int(cpu_result, UVM_ALL_ON)
        `uvm_field_int(op_code, UVM_ALL_ON)
        `uvm_field_int(valid_wb, UVM_ALL_ON)
        `uvm_field_int(immd_en, UVM_ALL_ON)
    `uvm_object_utils_end

    // constraints
    constraint en_reset{(resetn == 0) -> (en_cpu == 0);}

    function new(string name = "cpu_item");
        super.new(name);
    endfunction
endclass


class cpu_sequence extends uvm_sequence#(cpu_item);
    `uvm_object_utils(cpu_sequence)

    virtual cpu_interface CPU_IF;

    int golden_lines;

    function new(string name = "cpu_seq");
        super.new(name);
    endfunction

    function int get_file_line_count(string file);
        int fd;
        int lines = 0;
        string dummy;

        fd = $fopen(file, "r");
        if (fd == 0)
            `uvm_fatal("CPU_SEQ", $sformatf("FAILED TO OPEN FILE: %s", file))

        while ($fgets(dummy, fd))
            lines++;

        $fclose(fd);
        return lines;
    endfunction

    task body();
        int instr_lines;
        int cycles      = 0;
        int drain       = 0;
        int max_cycles  = 10000;
        int compared;          
        localparam int PIPE_DEPTH = 5;

        if (!uvm_config_db#(virtual cpu_interface)::get(null, "", "CPU_IF", CPU_IF))
            `uvm_fatal("CPU_SEQ", "FAILED TO FETCH CPU INTERFACE")

        CPU_IF.write_instructions("out.txt");
        CPU_IF.write_dat_mem("dat_mem.txt");

        instr_lines  = get_file_line_count("out.txt");
        golden_lines = get_file_line_count("golden_results.txt");

        `uvm_info("CPU_SEQ",
            $sformatf("Instructions: %0d  Golden results: %0d",
                      instr_lines, golden_lines), UVM_LOW)

        repeat(2) begin
            req = cpu_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 0;})
                `uvm_error("CPU_SEQ", "FAILED TO CREATE RESET ITEMS")
            finish_item(req);
        end


        while (CPU_IF.pc_index < instr_lines + PIPE_DEPTH && cycles < max_cycles) begin
            req = cpu_item::type_id::create("req");
            start_item(req);
          if (!req.randomize() with {resetn == 1; en_cpu == 1;})   
                `uvm_error("CPU_SEQ", "Item failed to randomize")
            finish_item(req);
            cycles++;
        end
      
         while (drain < golden_lines * PIPE_DEPTH) begin
            if (!uvm_config_db#(int)::get(null, "", "sb_compared", compared))
                compared = 0;
 
            if (compared >= golden_lines) begin
                `uvm_info("CPU_SEQ",
                    $sformatf("All %0d golden results consumed after %0d drain cycles. Stopping.",
                              golden_lines, drain), UVM_LOW)
                break;
            end
 
            req = cpu_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {resetn == 1;})
                `uvm_error("CPU_SEQ", "Item failed to randomize")
            finish_item(req);
            drain++;
        end


    endtask

endclass


class cpu_sequencer extends uvm_sequencer#(cpu_item);
    `uvm_component_utils(cpu_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass