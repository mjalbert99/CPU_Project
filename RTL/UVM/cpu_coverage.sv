class cpu_coverage extends uvm_subscriber #(cpu_item);
    `uvm_component_utils(cpu_coverage)

    uvm_analysis_imp#(cpu_item, cpu_coverage) mon_imp;

    logic resetn; 
    logic en_cpu;
    logic immd_en;
    logic[4:0] op_code;

    covergroup cg;

        operations: coverpoint op_code iff (resetn == 1) {
            bins arithmetic[] = {5'd1, 5'd3, 5'd8, 5'd9, 5'd11, 5'd16};
            bins logical[]    = {5'd2, 5'd4, 5'd5, 5'd10, 5'd12, 5'd13, 5'd17};
            bins shifts[]     = {5'd6, 5'd7, 5'd14, 5'd15};
            bins mem_str      = {5'd18};
            bins mem_lw       = {5'd19};
            bins noop         = {5'd0};
            bins branch       = {5'd20};
        }

        cp_resetn: coverpoint resetn {
            bins deactivated = {1'b0};
            bins activated   = {1'b1};
        }

        cp_en_cpu: coverpoint en_cpu {
            bins idle   = {1'b0};
            bins active = {1'b1};
        }

        cp_immd_en: coverpoint immd_en {
            bins on   = {1'b0};
            bins off = {1'b1};
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction


  function void write(cpu_item t);
        this.resetn  = t.resetn;
        this.en_cpu  = t.en_cpu;
        this.immd_en = t.immd_en;
        this.op_code = t.op_code;

        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("CPU_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction
endclass