typedef class virtual_sequencer;

class virtual_sequence extends uvm_sequence;
  	`uvm_object_utils(virtual_sequence)

    function new(string name = "virt_seq");
        super.new(name);
    endfunction

    `uvm_declare_p_sequencer(virtual_sequencer)

    cpu_sequence cpu_seq;

    task body();
		cpu_seq = cpu_sequence::type_id::create("cpu_seq");
        cpu_seq.start(p_sequencer.cpu_seqr);
    endtask
endclass

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    cpu_sequencer cpu_seqr;
endclass