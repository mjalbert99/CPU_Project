def convert(inFile, outFile1, outFile3):
    # Opened only the required machine and golden output files
    assembly_file = open(inFile, 'r')
    machine_file = open(outFile1, 'w')
    golden_file = open(outFile3, 'w')
    
    raw_lines = [line.strip() for line in assembly_file.read().split('\n')]

    register_values = {'r0': 0, 'r1': 0, 'r2': 0, 'r3': 0, 'r4': 0, 'r5': 0, 'r6': 0, 
                       'r7': 0, 'r8': 0, 'r9': 0, 'r10': 0, 'r11': 0, 'r12': 0, 'r13': 0,
                       'r14': 0, 'r15': 0}
    mem_store = [0]*256

    def to_signed_8bit_bin(int_str):
        num = int(int_str)
        if not (-128 <= num <= 127):
            raise ValueError("Number out of 8-bit signed range (-128 to 127)")
        return f"{num & 0xFF:08b}"
    
    def simulate_op(op, src_val, mid_val):
        def to_16bit_signed(val):
            val = val & 0xFFFF
            if val > 32767:
                val -= 65536
            return val

        if op == 'ADD' or op == 'ADDI':
            return to_16bit_signed(src_val + mid_val)
        elif op == 'SUB' or op == 'SUBI':
            return to_16bit_signed(src_val - mid_val)
        elif op == 'MULT' or op == 'MULTI':
            return to_16bit_signed(src_val * mid_val)
        elif op == 'AND' or op == 'ANDI':
            return to_16bit_signed(src_val & mid_val)
        elif op == 'OR' or op == 'ORI':
            return to_16bit_signed(src_val | mid_val)
        elif op == 'XOR' or op == 'XORI':
            return to_16bit_signed(src_val ^ mid_val)
        elif op == 'LS' or op == 'LSI':
            return to_16bit_signed(src_val << mid_val)
        elif op == 'RS' or op == 'RSI':
            return to_16bit_signed(src_val >> (mid_val & 0xFFFF))
        return src_val

    opcodes = {'NOOP' : '00000', 'ADD': '00001', 'AND': '00010', 'SUB' : '00011', 'OR': '00100', 'XOR': '00101',
               'LS' : '00110', 'RS': '00111', 'MULT': '01000', 'NOT': "10001", 'STR': '10010', 'LW': '10011', 'BNE': '10100'}
    
    opcodesi = {'ADDI': '01001', 'ANDI': '01010', 'SUBI' : '01011', 
                'ORI': '01100', 'XORI': '01101','LSI' : '01110', 'RSI': '01111', 'MULTI': '10000'}
    
    reg_to_bin = {'r0' : '0000', 'r1' : '0001', 'r2' : '0010', 'r3' : '0011', 'r4' : '0100', 'r5' : '0101', 'r6' : '0110', 
                  'r7' : '0111', 'r8' : '1000', 'r9' : '1001', 'r10' : '1010', 'r11' : '1011', 'r12' : '1100', 'r13' : '1101',
                  'r14' : '1110', 'r15' : '1111'}

    # Filter out empty lines to establish accurate indexing
    instructions = [line for line in raw_lines if line]

    # Pass 1: Generate machine code directly
    for line in instructions:
        res = []
        if line.startswith("NOOP"):
            res = [str(0)]*21
        elif line.startswith("NOT"):
            op, reg = line.split(" ")
            res = [opcodes[op], reg_to_bin[reg]] + [str(0)]*8 + [reg_to_bin[reg]]
        elif line.startswith("STR"):
            op, reg_addr, reg_data = line.split(" ")
            res = [opcodes[op], reg_to_bin[reg_addr], '0000', reg_to_bin[reg_data], '0000']
        elif line.startswith("LW"):
            op, reg_addr, reg_dest = line.split(" ")
            res = [opcodes[op], reg_to_bin[reg_addr], '00000000', reg_to_bin[reg_dest]]
        else:
            parts = line.split(" ")
            op, src_reg, mid, dest_reg = parts[0], parts[1], parts[2], parts[3]
            if op in opcodes:
                res.extend([opcodes[op], reg_to_bin[src_reg], '0000', reg_to_bin[mid], reg_to_bin[dest_reg]])
            else:
                res.extend([opcodesi[op], reg_to_bin[src_reg], to_signed_8bit_bin(mid), reg_to_bin[dest_reg]])
        
        machine_file.write(''.join(res) + '\n')

    pc = 0
    max_cycles = 10000
    cycles = 0

    # Pass 2: Execution simulation loop
    while pc < len(instructions) and cycles < max_cycles:
        line = instructions[pc]
        cycles += 1
        branch_taken = False

        if line.startswith("NOOP"):
            golden_file.write(str(0) + '\n')

        elif line.startswith("NOT"):
            op, reg = line.split(" ")
            val = ~register_values[reg]
            register_values[reg] = (val & 0xFFFF)
            if register_values[reg] > 32767:
                register_values[reg] -= 65536
            golden_file.write(str(register_values[reg]) + '\n')

        elif line.startswith("STR"):
            op, reg_addr, reg_data = line.split(" ")
            mem_store[register_values[reg_addr] & 0xFF] = register_values[reg_data]
            golden_file.write(str(register_values[reg_data]) + '\n')

        elif line.startswith("LW"):
            op, reg_addr, reg_dest = line.split(" ")
            register_values[reg_dest] = mem_store[register_values[reg_addr] & 0xFF]
            golden_file.write(str(register_values[reg_dest]) + '\n')

        else:
            parts = line.split(" ")
            op, src_reg, mid, dest_reg = parts[0], parts[1], parts[2], parts[3]
            src_val = register_values[src_reg]

            if op == 'BNE':
                mid_val = register_values[mid]
                reg3_val = register_values[dest_reg]
                
                if src_val != mid_val:
                    pc = reg3_val 
                    branch_taken = True
                    golden_file.write(f"{reg3_val}\n")
                else:
                    golden_file.write("0\n")

            else:
                if op in opcodes:
                    mid_val = register_values[mid]
                else:
                    mid_val = int(mid)
                    # Zero-extend logical immediate and shift operations to 8-bits
                    if op in ['ANDI', 'ORI', 'XORI', 'LSI', 'RSI']:
                        mid_val = mid_val & 0xFF

                new_val = simulate_op(op, src_val, mid_val)
                register_values[dest_reg] = new_val
                golden_file.write(f"{new_val}\n")

        if not branch_taken:
            pc += 1

    assembly_file.close()
    machine_file.close()
    golden_file.close()

convert("assembler/program.txt", "assembler/out.txt", "assembler/golden.txt")