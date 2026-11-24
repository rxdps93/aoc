package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    steps, _ := strconv.parse_int(strings.trim_space(string(input)))

    buf := make([dynamic]int, context.temp_allocator)
    append(&buf, 0)
    pos := 0
    for val in 1..=2017 {
        pos = (pos + steps) % len(buf) + 1
        inject_at(&buf, pos, val)
    }

    fmt.println(buf[(pos + 1) % len(buf)])

    pos = 0
    length := 1
    final := -1
    for val in 1..=50_000_000 {
        pos = (pos + steps) % length + 1
        length += 1

        if pos == 1 do final = val
    }

    fmt.println(final)
}