package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math/bits"

Instruction :: proc(a, b, c: int)

all_instr := [16]struct{exec: Instruction, name: string, id: u16}{
        {addr, "addr",  0}, {addi, "addi",  1},
        {mulr, "mulr",  2}, {muli, "muli",  3},
        {banr, "banr",  4}, {bani, "bani",  5},
        {borr, "borr",  6}, {bori, "bori",  7},
        {setr, "setr",  8}, {seti, "seti",  9},
        {gtir, "gtir", 10}, {gtri, "gtri", 11}, {gtrr, "gtrr", 12},
        {eqir, "eqir", 13}, {eqri, "eqri", 14}, {eqrr, "eqrr", 15}
    }

registers := [4]int{0, 0, 0, 0}

// addr (add register) stores into register C the result of adding register A and register B.
addr :: proc(a, b, c: int) { registers[c] = registers[a] + registers[b] }

// addi (add immediate) stores into register C the result of adding register A and value B.
addi :: proc(a, b, c: int) { registers[c] = registers[a] + b }

// mulr (multiply register) stores into register C the result of multiplying register A and register B.
mulr :: proc(a, b, c: int) { registers[c] = registers[a] * registers[b] }

// muli (multiply immediate) stores into register C the result of multiplying register A and value B.
muli :: proc(a, b, c: int) { registers[c] = registers[a] * b }

// banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
banr :: proc(a, b, c: int) { registers[c] = registers[a] & registers[b] }

// bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
bani :: proc(a, b, c: int) { registers[c] = registers[a] & b }

// borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
borr :: proc(a, b, c: int) { registers[c] = registers[a] | registers[b] }

// bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
bori :: proc(a, b, c: int) { registers[c] = registers[a] | b}

// setr (set register) copies the contents of register A into register C. (Input B is ignored.)
setr :: proc(a, b, c: int) { registers[c] = registers[a] }

// seti (set immediate) stores value A into register C. (Input B is ignored.)
seti :: proc(a, b, c: int) { registers[c] = a }

// gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
gtir :: proc(a, b, c: int) { registers[c] = a > registers[b] ? 1 : 0 }

// gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
gtri :: proc(a, b, c: int) { registers[c] = registers[a] > b ? 1 : 0 }

// gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
gtrr :: proc(a, b, c: int) { registers[c] = registers[a] > registers[b] ? 1 : 0}

// eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
eqir :: proc(a, b, c: int) { registers[c] = a == registers[b] ? 1 : 0 }

// eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
eqri :: proc(a, b, c: int) { registers[c] = registers[a] == b ? 1 : 0 }

// eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
eqrr :: proc(a, b, c: int) { registers[c] = registers[a] == registers[b] ? 1 : 0 }

parse_register_state :: proc(line: string) -> (state: [4]int) {
    start := strings.index_rune(line, '[') + 1
    end := strings.index_rune(line, ']')
    str := strings.split(line[start:end], ", ")
    for val, idx in str {
        state[idx], _ = strconv.parse_int(val)
    }

    return state
}

parse_instruction :: proc(line: string) -> (instr: [4]int) {
    str := strings.split(line, " ")
    for val, idx in str {
        instr[idx], _ = strconv.parse_int(val)
    }

    return instr
}

execute_sample :: proc(before, instruction, after: [4]int, opcodes: ^[16]u16) -> bool {

    counter := 0
    op := instruction[0]
    mask: u16 = 0
    for instr in all_instr {
        registers = before
        instr.exec(instruction[1], instruction[2], instruction[3])
        if after == registers {
            counter += 1

            mask |= (1 << instr.id)
        }
    }

    opcodes[op] &= mask

    return counter >= 3
}

print_register_state :: proc() { fmt.printf("\tREG_0 -> %d\n\tREG_1 -> %d\n\tREG_2 -> %d\n\tREG_3 -> %d\n", registers[0], registers[1], registers[2], registers[3]) }

main :: proc() {
    input, err := os.read_entire_file("input-samples.txt", context.temp_allocator)
    if err != nil do return

    raw_samples := strings.split_lines(string(input), context.temp_allocator)

    possible_ops := [16]u16 { }
    for &op in possible_ops do op = (1 << 16) - 1

    counter := 0
    for line := 0; line < len(raw_samples); line += 4 {
        before := parse_register_state(raw_samples[line])
        instr := parse_instruction(raw_samples[line + 1])
        after := parse_register_state(raw_samples[line + 2])

        counter += execute_sample(before, instr, after, &possible_ops) ? 1 : 0
    }

    fmt.println(counter) // for part 1

    opcodes := [16]Instruction{}

    remaining := 16
    for remaining > 0 {
        for i in 0..<16 {
            if bits.count_ones(possible_ops[i]) == 1 {
                bit := bits.trailing_zeros(possible_ops[i])
                opcodes[i] = all_instr[bit].exec

                for j in 0..<16 {
                    if j != i do possible_ops[j] &= ~(u16(1) << bit)
                }

                possible_ops[i] = 0
                remaining -= 1
            }
        }
    }

    input, err = os.read_entire_file("input-prgm.txt", context.temp_allocator)
    if err != nil do return

    registers = 0
    lines := strings.split_lines(string(input))
    for line in lines {
        instruction := parse_instruction(line)
        opcodes[instruction[0]](instruction[1], instruction[2], instruction[3])
    }
    fmt.println(registers[0])
}