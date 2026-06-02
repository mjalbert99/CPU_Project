class test extends uvm_test;
    `uvm_component_utils(test)

    env my_env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        my_env = env::type_id::create("my_env", this);
    endfunction

    task run_phase(uvm_phase phase);
        virtual_sequence virt_seq = virtual_sequence::type_id::create("virt_seq");
        phase.raise_objection(this);
        virt_seq.start(my_env.virt_seqr);
        phase.drop_objection(this);
    endtask
endclass