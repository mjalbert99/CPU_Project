class decode_monitor extends uvm_monitor;
    `uvm_component_utils(decode_monitor)
    
    virtual decode_interface DEC_IF;
  	uvm_analysis_port#(decode_item) mon_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual decode_interface)::get(null, "", "DEC_IF", DEC_IF))
            `uvm_fatal("DEC_MON", "FAILED TO FETCH CPU INTERFACE")
        
        mon_port = new("mon_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        decode_item item;
        forever begin
            @(posedge DEC_IF.cg_mon);
          	item = decode_item::type_id::create("item");

            item.valid_decode   = DEC_IF.cg_mon.valid_decode;
            item.DAT_OUT        = DEC_IF.cg_mon.DAT_OUT;
            item.DAT_IN         = DEC_IF.cg_mon.DAT_IN;
            item.REG_IN         = DEC_IF.cg_mon.REG_IN;
            item.EN             = DEC_IF.cg_mon.EN;

            item.a_idx          = DEC_IF.cg_mon.a_idx;
            item.b_idx          = DEC_IF.cg_mon.b_idx;
            item.c_idx          = DEC_IF.cg_mon.c_idx;

            mon_port.write(item);

        end
    endtask
endclass