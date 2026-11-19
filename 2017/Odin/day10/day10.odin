package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

sparse_hash_round :: proc(list: ^[256]int, lengths: []int, pos, skip: ^int) {
    for length in lengths {
        sublist := make([]int, length, context.temp_allocator)
        for i in 0..<length do sublist[i] = list[(pos^ + i) % len(list)]
        slice.reverse(sublist)
        for i in 0..<length do list[(pos^ + i) % len(list)] = sublist[i]
        pos^ += length + skip^
        skip^ += 1
    }
}

calculate_xor_block :: proc(values: []int) -> int {
    result := 0
    for i in values do result ~= i
    return result
}

part1 :: proc(input: []byte, base_list: [256]int) {
    data := strings.split(strings.trim_space(string(input)), ",", context.temp_allocator)
    lengths := make([]int, len(data), context.temp_allocator)
    for str, i in data do lengths[i], _ = strconv.parse_int(data[i])

    list := base_list

    pos := 0
    skip := 0
    sparse_hash_round(&list, lengths, &pos, &skip)
    fmt.println(list[0] * list[1])
}

part2 :: proc(input: []byte, base_list: [256]int) {
    data := strings.trim_space(string(input))
    suffix := [5]int{17, 31, 73, 47, 23}
    lengths := make([]int, len(data) + len(suffix), context.temp_allocator)
    for c, i in data do lengths[i] = int(c)
    for i in 0..<5 do lengths[len(data) + i] = suffix[i]

    list := base_list

    // spare hash rounds
    pos := 0
    skip := 0
    for i in 0..<64 do sparse_hash_round(&list, lengths, &pos, &skip)

    // dense hash calculation
    dense_hash: [16]int
    for i in 0..<16 do dense_hash[i] = calculate_xor_block(list[i*16:(i*16)+16])

    // output as hex
    for i in dense_hash {
        fmt.printf("%02x", i)
    }
    fmt.println()
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    list: [256]int
    for i in 0..<len(list) do list[i] = i

    part1(input, list)
    part2(input, list)
}