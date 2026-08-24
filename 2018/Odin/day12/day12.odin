package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"

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

    d12p1 := 0
    d12p2: i64 = 0
    prev_pattern: [dynamic]int
    shift, gen := 0, 0
    for g in 1..=50000000000 {
        prev_min := min_pot
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

        pattern: [dynamic]int
        defer delete(pattern)

        for k,_ in state {
            append(&pattern, k - min_pot)
        }
        slice.sort(pattern[:])

        if slice.equal(pattern[:], prev_pattern[:]) {
            shift = min_pot - prev_min
            gen = g
            for k, _ in state do d12p2 += i64(k)
            break
        }

        delete(prev_pattern)
        prev_pattern = slice.clone_to_dynamic(pattern[:])

        if g == 20 {
            for k,_ in state do d12p1 += k
        }
    }
    delete(prev_pattern)

    fmt.printf("After 20 generations: %d\n", d12p1)

    d12p2 = d12p2 + (50000000000 - i64(gen)) * (i64(shift) * i64(len(state)))
    fmt.printf("After 50 billion generations: %d\n", d12p2)
}