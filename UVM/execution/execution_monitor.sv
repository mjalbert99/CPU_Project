class execution_monitor extends uvm_monitor;
    `uvm_component_utils(execution_monitor)
    
    virtual execution_interface EXE_IF;
  	uvm_analysis_port#(execution_item) mon_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual execution_interface)::get(null, "", "EXE_IF", EXE_IF))
            `uvm_fatal("EXE_MON", "FAILED TO FETCH CPU INTERFACE")
        
        mon_port = new("mon_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        execution_item item;
        forever begin
            @(posedge EXE_IF.cg_mon);
          	item = execution_item::type_id::create("item");

            item.valid_exe    = EXE_IF.cg_mon.valid_exe;
            item.EN_exe       = EXE_IF.cg_mon.EN_exe;
            item.br_en        = EXE_IF.cg_mon.br_en;
            item.for_a_out    = EXE_IF.cg_mon.for_a_out;
            item.for_b_out    = EXE_IF.cg_mon.for_b_out;
            item.for_c_out    = EXE_IF.cg_mon.for_c_out;
            item.immd_exe     = EXE_IF.cg_mon.immd_exe;
            item.op_code_exe  = EXE_IF.cg_mon.op_code_exe;

            mon_port.write(item);

        end
    endtask
endclass