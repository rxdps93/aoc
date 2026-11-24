package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

get_position :: proc(prgms: [16]u8, prgm: u8) -> int {
    for p, i in prgms {
        if p == prgm do return i
    }
    return -1
}

swap :: proc(prgms: ^[16]u8, pos_a, pos_b: int) {
    tmp := prgms[pos_a]
    prgms[pos_a] = prgms[pos_b]
    prgms[pos_b] = tmp
}

spin :: proc(prgms: ^[16]u8, size_str: string) {
    size, _ := strconv.parse_int(size_str)
    slice.rotate_right(prgms[:], size)
}

exchange :: proc(prgms: ^[16]u8, pos_str: string) {
    pos_arr := strings.split(pos_str, "/", context.temp_allocator)
    pos_a, _ := strconv.parse_int(pos_arr[0])
    pos_b, _ := strconv.parse_int(pos_arr[1])
    swap(prgms, pos_a, pos_b)
}

partner :: proc(prgms: ^[16]u8, name_str: string) {
    pos_a := get_position(prgms^, name_str[0])
    pos_b := get_position(prgms^, name_str[2])
    swap(prgms, pos_a, pos_b)
}

perform_dance :: proc(prgms: [16]u8, instructions: []string) -> [16]u8 {
    lineup := prgms
    for instr in instructions {
        switch instr[0] {
            case 's': spin(&lineup, instr[1:])
            case 'x': exchange(&lineup, instr[1:])
            case 'p': partner(&lineup, instr[1:])
        }
    }

    return lineup
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return
    instructions := strings.split(strings.trim_space(string(input)), ",", context.temp_allocator)

    prgms: [16]u8
    for p, i in u8('a')..=u8('p') do prgms[i] = p
    
    // part 1
    lineup := perform_dance(prgms, instructions)
    fmt.println(string(lineup[:]))

    // part 2
    lineup = prgms
    iterations := 0
    for true {
        lineup = perform_dance(lineup, instructions)
        iterations += 1

        if lineup == prgms {
            break
        }
    }

    lineup = prgms
    for i in 0..<(1_000_000_000 % iterations) {
        lineup = perform_dance(lineup, instructions)
    }

    fmt.println(string(lineup[:]))
}