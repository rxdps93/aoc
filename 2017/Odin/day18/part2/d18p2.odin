package d18p2

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:reflect"
import q "core:container/queue"

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
    id: int,
    registers: [26]int,
    program_counter: int,
    queue: q.Queue(int),
    sent: int,
    partner: ^State,
    status: Status,
}

Status :: enum {
    Open,
    Blocked,
    Terminated,
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
    state.sent += 1
    q.enqueue(&state.partner.queue, get_value(state, op))
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
rcv :: proc(state: ^State, dest: Register) -> (blocked: bool) {
    if q.len(state.queue) == 0 do return true

    state.registers[dest - 'a'] = q.dequeue(&state.queue)
    return false
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

exec_instruction :: proc(state: ^State, instr: Instruction) -> (blocked: bool) {
    jumped := false
    blocked = false

    switch instr.name {
        case .snd: snd(state, instr.a)
        case .set: set(state, instr.a.(Register), instr.b)
        case .add: add(state, instr.a.(Register), instr.b)
        case .mul: mul(state, instr.a.(Register), instr.b)
        case .mod: mod(state, instr.a.(Register), instr.b)
        case .rcv: blocked = rcv(state, instr.a.(Register))
        case .jgz: jumped = jgz(state, instr.a, instr.b)
    }

    if !jumped && !blocked do state.program_counter += 1

    return
}

main :: proc() {
    input, read_err := os.read_entire_file("../input.txt", context.temp_allocator)
    if read_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    instructions := make([]Instruction, len(lines), context.temp_allocator)
    for line, i in lines {
        instructions[i] = parse_instruction(line)
    }

    programs := [2]State {
        { id = 0 },
        { id = 1 },
    }

    programs[0].partner = &programs[1]
    programs[1].partner = &programs[0]

    q.init(&programs[0].queue)
    q.init(&programs[1].queue)

    defer {
        q.destroy(&programs[0].queue)
        q.destroy(&programs[1].queue)
    }

    programs[1].registers['p' - 'a'] = 1

    for true {

        for &prgm in programs {
            if prgm.status == .Terminated do continue

            blocked := exec_instruction(&prgm, instructions[prgm.program_counter])
            prgm.status = blocked ? .Blocked : .Open

            if prgm.program_counter < 0 || prgm.program_counter >= len(instructions) {
                prgm.status = .Terminated
            }
        }

        if programs[0].status == .Terminated && programs[1].status == .Terminated do break
        if programs[0].status == .Blocked && programs[1].status == .Blocked do break
    }

    fmt.println(programs[1].sent)
}