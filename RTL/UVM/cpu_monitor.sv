class cpu_monitor extends uvm_monitor;
    `uvm_component_utils(cpu_monitor)
    
    virtual cpu_interface CPU_IF;
  	uvm_analysis_port#(cpu_item) mon_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual cpu_interface)::get(null, "", "CPU_IF", CPU_IF))
            `uvm_fatal("CPU_MON", "FAILED TO FETCH CPU INTERFACE")
        
        mon_port = new("mon_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        cpu_item item;
        forever begin
            @(posedge CPU_IF.cg_mon);
          
          	if (CPU_IF.cg_mon.valid_wb !== 1'b1 || CPU_IF.cg_mon.en_cpu !== 1'b1) continue;
          	item = cpu_item::type_id::create("item");

            // SCOREBOARD + COVERAGE VALUES
            item.valid_wb   = CPU_IF.cg_mon.valid_wb;
            item.cpu_result = CPU_IF.cg_mon.cpu_result;

            // COVERAGE SPECIFIC VALUES
            item.resetn     = CPU_IF.cg_mon.resetn;
            item.en_cpu     = CPU_IF.cg_mon.en_cpu;
            item.immd_en 	= CPU_IF.cg_mon.immd_en;
            item.op_code 	= CPU_IF.cg_mon.op_code;

//             `uvm_info("MON_DATA", $sformatf("CPU_RES: %d  VALID_WB:%d OP_CODE: %d", item.cpu_result, item.valid_wb, item.op_code), UVM_LOW)

            mon_port.write(item);

        end
    endtask
endclass