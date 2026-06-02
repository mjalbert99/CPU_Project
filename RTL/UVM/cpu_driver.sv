class cpu_driver extends uvm_driver #(cpu_item);
    `uvm_component_utils(cpu_driver)
    
    virtual cpu_interface CPU_IF;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual cpu_interface)::get(null, "", "CPU_IF", CPU_IF))
            `uvm_fatal("CPU_DRV", "FAILED TO FETCH CPU INTERFACE")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(posedge CPU_IF.cg_drv);

            CPU_IF.cg_drv.resetn <= req.resetn;
            CPU_IF.cg_drv.en_cpu <= req.en_cpu;

//             `uvm_info("DRV_DATA", $sformatf("CPU_EN: %d  RESETN:%d ", req.en_cpu, req.resetn), UVM_LOW)

            seq_item_port.item_done();

        end
    endtask
endclass