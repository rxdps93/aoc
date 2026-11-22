package main

import "core:fmt"
import "core:slice"
import "core:strings"

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

calculate_knot_hash_string :: proc(data: string, allocator := context.allocator) -> string {
    list: [256]int
    for i in 0..<len(list) do list[i] = i

    suffix := [5]int{17, 31, 73, 47, 23}
    lengths := make([]int, len(data) + len(suffix), context.temp_allocator)
    for c, i in data do lengths[i] = int(c)
    for i in 0..<5 do lengths[len(data) + i] = suffix[i]

    // spare hash rounds
    pos := 0
    skip := 0
    for i in 0..<64 do sparse_hash_round(&list, lengths, &pos, &skip)

    // dense hash calculation
    dense_hash: [16]int
    for i in 0..<16 do dense_hash[i] = calculate_xor_block(list[i*16:(i*16)+16])

    // output as hex
    out := strings.builder_make(allocator)
    for i in dense_hash do fmt.sbprintf(&out, "%02x", i)
    return strings.to_string(out)
}

calculate_knot_hash :: proc(data: string) -> [16]int {
    list: [256]int
    for i in 0..<len(list) do list[i] = i

    suffix := [5]int{17, 31, 73, 47, 23}
    lengths := make([]int, len(data) + len(suffix), context.temp_allocator)
    for c, i in data do lengths[i] = int(c)
    for i in 0..<5 do lengths[len(data) + i] = suffix[i]

    // spare hash rounds
    pos := 0
    skip := 0
    for i in 0..<64 do sparse_hash_round(&list, lengths, &pos, &skip)

    // dense hash calculation
    dense_hash: [16]int
    for i in 0..<16 do dense_hash[i] = calculate_xor_block(list[i*16:(i*16)+16])

    return dense_hash
}