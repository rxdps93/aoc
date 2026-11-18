package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    data := strings.trim_space(string(input))
    score_inc := 0
    score := 0
    garbage := false
    negate := false
    garbage_chars := 0
    for c in data {
        if negate {
            negate = false
            continue
        }

        switch c {
            case '{':
                if !garbage {
                    score_inc += 1
                } else {
                    garbage_chars += 1
                }
            case '}':
                if !garbage {
                    score += score_inc
                    score_inc -= 1
                } else {
                    garbage_chars += 1
                }
            case '<':
                if !garbage {
                    garbage = true
                } else {
                    garbage_chars += 1
                }
            case '>':
                garbage = false
            case '!':
                negate = true
            case:
                if garbage do garbage_chars += 1
        }
    }

    fmt.println(score)
    fmt.println(garbage_chars)
}