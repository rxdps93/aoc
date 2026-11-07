package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

d5p1 :: proc(jmp_arr: []int) -> int {
    jumps := slice.clone(jmp_arr)
    steps := 0
    pc := 0
    for pc >= 0 && pc < len(jumps) {
        j := jumps[pc]
        jumps[pc] += 1
        pc += j
        steps += 1
    }
    return steps
}

d5p2 :: proc(jmp_arr: []int) -> int {
    jumps := slice.clone(jmp_arr)
    steps := 0
    pc := 0
    for pc >= 0 && pc < len(jumps) {
        j := jumps[pc]
        if j >= 3 {
            jumps[pc] -= 1
        } else {
            jumps[pc] += 1
        }
        pc += j
        steps += 1
    }
    return steps
}

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    jumps := make([]int, len(lines))
    defer delete(jumps)
    for line, i in lines do jumps[i], _ = strconv.parse_int(line)
    
    fmt.printf("%d\n%d\n", d5p1(jumps), d5p2(jumps))
}