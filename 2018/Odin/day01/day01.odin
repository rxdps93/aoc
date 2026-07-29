package main

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"

d1p1 :: proc() -> int {
    freq := 0

    data, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil {
        return 0
    }

    defer delete(data, context.allocator)

    iter := string(data)
    for line in strings.split_lines_iterator(&iter) {
        val, _ := strconv.parse_int(line[1:])

        if line[0] == '+' {
            freq += val
        } else {
            freq -= val
        }
    }
    return freq
}

d1p2 :: proc() -> int {
    freq := 0

    data, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil {
        return 0
    }

    defer delete(data, context.allocator)

    freqs := make(map[int]struct{})
    defer delete(freqs)

    freqs[freq] = {}

    iter := string(data)
    for {
        if len(iter) == 0 {
            iter = string(data)
        }

        line, ok := strings.split_lines_iterator(&iter)
        if !ok do continue

        val, _ := strconv.parse_int(line[1:])

        if line[0] == '+' {
            freq += val
        } else {
            freq -= val
        }

        if freq in freqs {
            break
        } else {
            freqs[freq] = {}
        }
    }

    return freq
}

main :: proc() {
    fmt.printf("%d\n%d\n", d1p1(), d1p2())
}