class execution_coverage extends uvm_subscriber #(execution_item);
    `uvm_component_utils(execution_coverage)

    uvm_analysis_imp#(execution_item, execution_coverage) mon_imp;

    logic valid_exe;
    logic EN_exe, br_en;
    logic signed[15:0] for_a_out, for_b_out, for_c_out;
    logic signed[7:0] immd_exe;
    logic[4:0] op_code_exe;

    covergroup cg;

        cp_en: coverpoint EN_exe{
            bins on = {1};
            bins off = {0};
        }

        cp_br: coverpoint br_en iff (op_code_exe == 5'd10) {
            bins on = {1};
            bins off = {0};
        }

      	operations: coverpoint op_code_exe {
            bins arithmetic[] = {5'd1, 5'd3, 5'd8, 5'd9, 5'd11, 5'd16}; // ADD, SUB, MULT, ADDI, SUBI, MULTI
            bins logical[]    = {5'd2, 5'd4, 5'd5, 5'd10, 5'd12, 5'd13, 5'd17}; // AND, OR, XOR, etc.
            bins shifts[]     = {5'd6, 5'd7, 5'd14, 5'd15};
          	bins mem_access[]   = {5'd18, 5'd19};
            bins noop         = {5'd0};

          	bins logic_after_arith[] = (5'd1, 5'd3, 5'd8 => 5'd2, 5'd4, 5'd5);

          	bins arith_after_logic[] = (5'd2, 5'd4, 5'd5 => 5'd1, 5'd3, 5'd8);
            
            bins stall_to_op = (5'd0 => [5'd1:5'd19]);
            
            bins double_add = (5'd1 => 5'd1);
            bins double_mul = (5'd8 => 5'd8);
          
            bins double_addi = (5'd9 => 5'd9);
            bins double_muli = (5'd16 => 5'd16);
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


  function void write(execution_item t);
        this.EN_exe         = t.EN_exe;
        this.br_en         = t.br_en;
        this.for_a_out      =  t.for_a_out;
        this.for_b_out      =  t.for_b_out;
        // this.for_c_out      =  t.for_c_out;
        this.immd_exe      =  t.immd_exe;
        this.op_code_exe      =  t.op_code_exe;

        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("EXE_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction
endclass