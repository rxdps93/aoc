package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sort"

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    valid := 0
    word_map := make(map[string]struct{})
    defer delete(word_map)
    for line in lines {
        clear(&word_map)
        words := strings.fields(line, context.temp_allocator)
        for word in words do word_map[word] = {}

        if len(words) == len(word_map) do valid += 1
    }

    fmt.println(valid)

    valid = 0
    for line in lines {
        clear(&word_map)
        words := strings.fields(line, context.temp_allocator)
        for word in words {
            bytes := transmute([]u8)word
            sort.quick_sort(bytes)
            sorted := string(bytes)
            word_map[sorted] = {}
        }

        if len(words) == len(word_map) do valid += 1
    }

    fmt.println(valid)
}