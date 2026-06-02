// cpu_top_tb.v
module cpu_top_tb();

    parameter DATA_W = 16;
    parameter ADDR_W = 16;

    reg clk, resetn, en_cpu;
    wire signed[DATA_W-1:0] cpu_result;
    wire valid_wb; // valid pipeline track
    
    integer golden_file, status;
    reg signed [DATA_W-1:0] expected_alu_out;
    
    cpu_top DUT (
        .clk(clk),
        .resetn(resetn),
        .en_cpu(en_cpu),
        .cpu_result(cpu_result),
        .valid_wb(valid_wb)
    );
    
    initial clk = 0;
    always #7.5 clk = ~clk;

    initial begin
        resetn = 1;
        en_cpu = 0;
        @(posedge clk);
        #2;
        resetn = 0;

        golden_file = $fopen("../RTL/assembler/golden.txt", "r");
        if (golden_file == 0) begin
            $display("ERROR: Could not open golden.txt");
            $finish;
        end

        repeat(2) @(posedge clk);
        #2;
        resetn = 1;
        @(posedge clk);
        #2;
        en_cpu = 1;
        
        while (!$feof(golden_file)) begin
            @(negedge clk);
            #2;
            
            if (valid_wb) begin
                status = $fscanf(golden_file, "%d\n", expected_alu_out);
                if (status == 1) begin
                    if (cpu_result !== expected_alu_out) begin
                        $display("ALU MISMATCH | Exp: %d, Got: %d", expected_alu_out, cpu_result);
                    end else begin
                        $display("ALU PASS | Result: %d", $signed(cpu_result));
                    end
                end
            end
        end

        $display("\nSimulation Finished: Reached end of golden.txt");
        $fclose(golden_file);
        $finish;
    end

    initial begin
        $dumpfile("cpu_trace.vcd"); 
        $dumpvars(0, cpu_top_tb);    
    end

endmodule