// Recommend running with -o:speed
package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Instruction :: struct{
    op: string,
    a, b, c: int
}

addr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] + registers[b] }

// addi (add immediate) stores into register C the result of adding register A and value B.
addi :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] + b }

// mulr (multiply register) stores into register C the result of multiplying register A and register B.
mulr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] * registers[b] }

// muli (multiply immediate) stores into register C the result of multiplying register A and value B.
muli :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] * b }

// banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
banr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] & registers[b] }

// bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
bani :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] & b }

// borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
borr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] | registers[b] }

// bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
bori :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] | b}

// setr (set register) copies the contents of register A into register C. (Input B is ignored.)
setr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] }

// seti (set immediate) stores value A into register C. (Input B is ignored.)
seti :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = a }

// gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
gtir :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = a > registers[b] ? 1 : 0 }

// gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
gtri :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] > b ? 1 : 0 }

// gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
gtrr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] > registers[b] ? 1 : 0}

// eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
eqir :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = a == registers[b] ? 1 : 0 }

// eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
eqri :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] == b ? 1 : 0 }

// eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
eqrr :: proc(registers: ^[6]int, a, b, c: int) { registers[c] = registers[a] == registers[b] ? 1 : 0 }

exec :: proc(registers: ^[6]int, name: string, a, b, c: int) {
    switch name {
        case "addr": addr(registers, a, b, c)
        case "addi": addi(registers, a, b, c)
        case "mulr": mulr(registers, a, b, c)
        case "muli": muli(registers, a, b, c)
        case "banr": banr(registers, a, b, c)
        case "bani": bani(registers, a, b, c)
        case "borr": borr(registers, a, b, c)
        case "bori": bori(registers, a, b, c)
        case "setr": setr(registers, a, b, c)
        case "seti": seti(registers, a, b, c)
        case "gtir": gtir(registers, a, b, c)
        case "gtri": gtri(registers, a, b, c)
        case "gtrr": gtrr(registers, a, b, c)
        case "eqir": eqir(registers, a, b, c)
        case "eqri": eqri(registers, a, b, c)
        case "eqrr": eqrr(registers, a, b, c)
    }
}

parse_instructions :: proc(prgm: []Instruction, lines: []string) {
    for line, i in lines {
        str := strings.split(line, " ")
        args: [3]int
        for val, j in str[1:] {
            args[j], _ = strconv.parse_int(val)
        }

        prgm[i] = Instruction{
            op = str[0],
            a = args[0],
            b = args[1],
            c = args[2],
        }
    }
}

fmt_reg_state :: proc(regs: [6]int) -> string {
    return fmt.tprintf("[ %d, %d, %d, %d, %d, %d ]",
        regs[0], regs[1], regs[2], regs[3], regs[4], regs[5])
}

exec_prgm :: proc(registers: ^[6]int, prgm: []Instruction, ip_reg: int) -> (p1, p2: int) {
    ip := 0
    log := make(map[int]struct{}, context.temp_allocator)
    first := true
    for ip >= 0 && ip < len(prgm) {
        registers[ip_reg] = ip
        instr := prgm[ip]
        exec(registers, instr.op, instr.a, instr.b, instr.c)
        if (instr.op == "eqrr") {
            if first {
                p1 = registers[instr.a]
                first = false
            }

            if registers[instr.a] not_in log {
                log[registers[instr.a]] = {}
                p2 = registers[instr.a]
            } else {
                break
            }
        }
        ip = registers[ip_reg] + 1
    }

    return p1, p2
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input), context.temp_allocator)
    
    ip_reg, _ := strconv.parse_int(lines[0][4:])
    lines = lines[1:]

    prgm := make([]Instruction, len(lines))
    parse_instructions(prgm[:], lines)

    registers: [6]int
    p1, p2 := exec_prgm(&registers, prgm, ip_reg)
    fmt.printf("%d\n%d\n", p1, p2)
}