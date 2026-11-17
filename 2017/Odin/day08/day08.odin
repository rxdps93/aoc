package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Instruction :: struct {
    target_reg: string,
    target_act: string,
    action_amt: int,
    cnd_reg: string,
    cnd_type: string,
    cnd_amt: int,
}

parse_line :: proc(line: string) -> Instruction {
    parts, _ := strings.split(line, "if", context.temp_allocator)

    target, _ := strings.fields(parts[0], context.temp_allocator)
    condition, _ := strings.fields(parts[1], context.temp_allocator)

    ta, _ := strconv.parse_int(target[2])
    ca, _ := strconv.parse_int(condition[2])
    instr: Instruction = {
        target_reg  = target[0],
        target_act  = target[1],
        action_amt  = ta,
        cnd_reg     = condition[0],
        cnd_type    = condition[1],
        cnd_amt     = ca,
    }

    return instr
}

exec :: proc(instr: Instruction, registers: ^map[string]int) {
    // check the conditional
    a := registers[instr.cnd_reg]
    b := instr.cnd_amt
    res: bool
    switch instr.cnd_type {
        case ">":
            res = a > b
        case "<":
            res = a < b
        case ">=":
            res = a >= b
        case "<=":
            res = a <= b
        case "==":
            res = a == b
        case "!=":
            res = a != b
    }

    if res {
        if instr.target_act == "inc" {
            registers[instr.target_reg] += instr.action_amt
        } else {
            registers[instr.target_reg] -= instr.action_amt
        }
    }
}

find_largest_value :: proc(registers: map[string]int) -> int {
    val := min(int)
    values, _ := slice.map_values(registers, context.temp_allocator)
    for v in values {
        val = max(v, val)
    }
    return val
}

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)

    registers := make(map[string]int, context.temp_allocator)
    max_value := min(int)
    for line in lines {
        instr := parse_line(line)

        if !(instr.target_reg in registers) do registers[instr.target_reg] = 0
        if !(instr.cnd_reg in registers) do registers[instr.cnd_reg] = 0

        exec(instr, &registers)

        val := find_largest_value(registers)
        max_value = max(val, max_value)
    }

    fmt.println(find_largest_value(registers))
    fmt.println(max_value)
}