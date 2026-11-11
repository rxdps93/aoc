package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

hash_array :: proc(arr: []int) -> int {
    hash := 17
    for val in arr do hash = (hash * 31) + val
    return hash
}

max_block_index :: proc(arr: []int) -> int {
    max_val := min(int)
    max_idx := 0
    for val, i in arr {
        if val > max_val {
            max_val = val
            max_idx = i
        }
    }
    return max_idx
}

redistribute_memory :: proc(arr: ^[]int) {
    idx := max_block_index(arr^)
    blocks := arr[idx]
    arr[idx] = 0
    for blocks > 0 {
        idx = (idx + 1) % len(arr)
        arr[idx] += 1
        blocks -= 1
    }
}

find_cycle :: proc(arr: ^[]int) -> int {
    mem_state := make(map[int]struct{})
    defer delete(mem_state)

    cycles := 0
    state := hash_array(arr^)
    for !(state in mem_state) {
        mem_state[state] = {}
        redistribute_memory(arr)
        cycles += 1
        state = hash_array(arr^)
    }

    return cycles
}

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    data := strings.fields(strings.trim_space(string(input)), context.temp_allocator)
    mem := make([]int, len(data))
    for str, i in data {
        val, _ := strconv.parse_int(str)
        mem[i] = val
    }

    fmt.println(find_cycle(&mem))
    fmt.println(find_cycle(&mem))
}