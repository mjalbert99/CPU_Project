class cpu_agent extends uvm_agent;
    `uvm_component_utils(cpu_agent)

    cpu_sequencer seqr;
    cpu_driver driver;
    cpu_monitor monitor;
    cpu_coverage cov;

    decode_monitor dec_monitor;
    decode_coverage dec_cov;
    
    execution_monitor exe_monitor;
    execution_coverage exe_cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            seqr = cpu_sequencer::type_id::create("seqr", this);
            driver = cpu_driver::type_id::create("driver", this);
        end
        monitor = cpu_monitor::type_id::create("monitor", this);
        cov = cpu_coverage::type_id::create("cov", this);

        dec_monitor = decode_monitor::type_id::create("dec_monitor", this);
        dec_cov = decode_coverage::type_id::create("dec_cov", this);

        exe_monitor = execution_monitor::type_id::create("exe_monitor", this);
        exe_cov = execution_coverage::type_id::create("exe_cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if(get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(seqr.seq_item_export);
        end 
        monitor.mon_port.connect(cov.mon_imp);   
        dec_monitor.mon_port.connect(dec_cov.mon_imp);
        exe_monitor.mon_port.connect(exe_cov.mon_imp);
    endfunction
endclass