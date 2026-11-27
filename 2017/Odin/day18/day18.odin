package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:reflect"

Register :: distinct u8
Operand :: union { int, Register }

Opcode :: enum {
    snd,
    set,
    add,
    mul,
    mod,
    rcv,
    jgz
}

Instruction :: struct {
    name: Opcode,
    a, b: Operand,
}

State :: struct {
    registers: [26]int,
    sound: Maybe(int),
    program_counter: int,
}

get_value :: proc(state: ^State, op: Operand) -> int {
    switch v in op {
        case int: return v
        case Register: return state.registers[v - 'a']
    }
    return 0
}

// snd X where X is a reg or a val
snd :: proc(state: ^State, op: Operand) {
    state.sound = get_value(state, op)
}

// set X Y where X is a reg and Y is a reg or val
set :: proc(state: ^State, dest: Register, op: Operand) {
    state.registers[dest - 'a'] = get_value(state, op)
}

// add X Y where X is a reg and Y is a reg or val
add :: proc(state: ^State, dest: Register, op: Operand) {
    state.registers[dest - 'a'] = get_value(state, dest) + get_value(state, op)
}

// mul X Y where X is a reg and Y is a reg or val
mul :: proc(state: ^State, dest: Register, op: Operand) {
    state.registers[dest - 'a'] = get_value(state, dest) * get_value(state, op)
}

// mod X Y where X is a reg and Y is a reg or val
mod :: proc(state: ^State, dest: Register, op: Operand) {
    state.registers[dest - 'a'] = get_value(state, dest) % get_value(state, op)
}

// rcv X where X is a reg or val
rcv :: proc(state: ^State, op: Operand) -> (sound: int, ok: bool) {
    if get_value(state, op) == 0 do return 0, false

    sound, ok = state.sound.?
    return
}

// jgz X Y where X and Y are either regs or vals
jgz :: proc(state: ^State, a, b: Operand) -> (jumped: bool) {
    if get_value(state, a) > 0 {
        state.program_counter += get_value(state, b)
        return true
    }

    return false
}

parse_operand :: proc(tok: string) -> Operand {
    op, is_int := strconv.parse_int(tok)
    if is_int {
        return op
    } else {
        return Register(tok[0])
    }
}

parse_instruction :: proc(line: string) -> Instruction {
    toks, _ := strings.fields(line, context.temp_allocator)
    name, _ := reflect.enum_from_name(Opcode, toks[0])

    arg1 := parse_operand(toks[1])

    if len(toks) == 2 {
        return { name, arg1, nil }
    } else {
        arg2 := parse_operand(toks[2])
        return { name, arg1, arg2 }
    }
}

exec_instruction :: proc(state: ^State, instr: Instruction) -> (result: int, has_result: bool) {
    result = 0
    has_result = false
    jumped := false

    switch instr.name {
        case .snd: snd(state, instr.a)
        case .set: set(state, instr.a.(Register), instr.b)
        case .add: add(state, instr.a.(Register), instr.b)
        case .mul: mul(state, instr.a.(Register), instr.b)
        case .mod: mod(state, instr.a.(Register), instr.b)
        case .rcv: result, has_result = rcv(state, instr.a)
        case .jgz: jumped = jgz(state, instr.a, instr.b)
    }

    if !jumped do state.program_counter += 1

    return
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    instructions := make([]Instruction, len(lines), context.temp_allocator)
    for line, i in lines {
        instructions[i] = parse_instruction(line)
    }

    state: State
    sound := 0
    snd_ok := false
    for !snd_ok && (state.program_counter >= 0 && state.program_counter < len(instructions)) {
        sound, snd_ok = exec_instruction(&state, instructions[state.program_counter])
    }

    fmt.println(sound)
}