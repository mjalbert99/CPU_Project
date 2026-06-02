class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp#(cpu_item, scoreboard) mon_imp;

    local int signed golden_queue[$];
    local int        total_golden;
    local int        pass_count;
    local int        fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        int fd;
        int signed val;
        super.start_of_simulation_phase(phase);

        fd = $fopen("golden_results.txt", "r");
        if (fd == 0)
            `uvm_fatal("SB_GOLDEN", "Could not open golden_results.txt")

        while(!$feof(fd)) begin
            if ($fscanf(fd, "%d\n", val) == 1)
                golden_queue.push_back(val);
        end

        $fclose(fd);
        total_golden = golden_queue.size();
        pass_count   = 0;
        fail_count   = 0;

        `uvm_info("SB_GOLDEN", $sformatf("Loaded %0d golden results", total_golden), UVM_LOW)
    endfunction

    function void write(cpu_item actual);

        if($isunknown(actual.resetn) || $isunknown(actual.cpu_result) || 
            actual.valid_wb === 1'b0 || golden_queue.size() == 0) return;

        begin
            int signed golden_exp_val;
            golden_exp_val = golden_queue.pop_front();

            if(actual.cpu_result === golden_exp_val) begin
                pass_count++;
                `uvm_info("SB_CPU_PASS",
                            $sformatf("[%0d/%0d] PASS  got=%0d  expected=%0d",
                            pass_count + fail_count, total_golden,
                            actual.cpu_result, golden_exp_val), UVM_LOW)
            end else begin
                fail_count++;
                `uvm_error("SB_CPU_FAIL",
                            $sformatf("[%0d/%0d] FAIL  got=%0d  expected=%0d",
                            pass_count + fail_count, total_golden,
                            actual.cpu_result, golden_exp_val))
            end
        end
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if(golden_queue.size() != 0) begin
            `uvm_error("SB_INCOMPLETE",
                        $sformatf("%0d golden result(s) were never compared — sequencer drained too early",
                        golden_queue.size()))
        end

        `uvm_info("SB_SUMMARY", $sformatf("Scoreboard done: %0d/%0d passed, %0d failed", 
                    pass_count, total_golden, fail_count), UVM_NONE)
    endfunction

endclass