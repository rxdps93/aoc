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

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return
    instructions := strings.split(strings.trim_space(string(input)), ",", context.temp_allocator)

    prgms: [16]u8
    for p, i in u8('a')..=u8('p') do prgms[i] = p
    for instr in instructions {
        switch instr[0] {
            case 's': spin(&prgms, instr[1:])
            case 'x': exchange(&prgms, instr[1:])
            case 'p': partner(&prgms, instr[1:])
        }
    }

    fmt.println(string(prgms[:]))
}