package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return
    defer delete(input)

    lines := strings.split_lines(string(input))

    state := make(map[int]bool)
    defer delete(state)

    min_pot, max_pot := max(int), min(int)
    for c, idx in strings.trim_space(lines[0])[15:] {
        if c == '#' {
            state[idx] = true

            if idx < min_pot do min_pot = idx
            if idx > max_pot do max_pot = idx
        }
    }

    rules: [32]u8

    for line in lines[2:] {
        rule: u8 = 0
        for ch in line[0:5] {
            rule = (rule << 1) | (ch == '#' ? 1 : 0)
        }
        rules[rule] = line[9] == '#' ? 1 : 0
    }

    for _ in 1..=20 {
        next := make(map[int]bool)
        next_min, next_max := max(int), min (int)

        for i in (min_pot - 2)..=(max_pot + 2) {
            window: u8 = 0
            for offset in -2..=2 {
                window = (window << 1) | ((i + offset in state) ? 1 : 0)
            }

            if rules[window] == 1 {
                next[i] = true
                if i < next_min do next_min = i
                if i > next_max do next_max = i
            }
        }

        delete(state)
        state = next
        min_pot = next_min
        max_pot = next_max
    }

    sum := 0
    for k,v in state {
        sum += k
    }
    fmt.printf("%d\n", sum)
}