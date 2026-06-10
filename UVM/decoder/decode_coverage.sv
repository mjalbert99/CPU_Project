class decode_coverage extends uvm_subscriber #(decode_item);
    `uvm_component_utils(decode_coverage)

    uvm_analysis_imp#(decode_item, decode_coverage) mon_imp;

    logic DAT_OUT, DAT_IN, REG_IN, EN;
    logic[3:0] a_idx, b_idx, c_idx;

    covergroup cg;
        cp_dat_in: coverpoint DAT_IN {
            bins on   = {1'b0};
            bins off = {1'b1};
        }

        cp_dat_out: coverpoint DAT_OUT {
            bins on   = {1'b0};
            bins off = {1'b1};
        }

        cp_reg_in: coverpoint REG_IN {
            bins on   = {1'b0};
            bins off = {1'b1};
        }

        cp_en: coverpoint EN {
            bins on   = {1'b0};
            bins off = {1'b1};
        }

        cp_a_idx: coverpoint a_idx {
            bins zero = {0};
            bins mid[3] = {[1:14]};
            bins max = {15};
        }

        cp_b_idx: coverpoint b_idx {
            bins zero = {0};
            bins mid[3] = {[1:14]};
            bins max = {15};
        }

        cp_c_idx: coverpoint c_idx {
            bins zero = {0};
            bins mid[3] = {[1:14]};
            bins max = {15};
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


  function void write(decode_item t);
        this.DAT_OUT    = t.DAT_OUT;
        this.DAT_IN     = t.DAT_IN;
        this.REG_IN     = t.REG_IN;
        this.EN         = t.EN;
        this.a_idx      =  t.a_idx;
        this.b_idx      =  t.b_idx;
        this.c_idx      =  t.c_idx;

        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("DEC_COV_REPORT", $sformatf("Total Coverage: %3.2f%%", cg.get_inst_coverage()), UVM_LOW)
    endfunction
endclass