package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    sum := 0
    for line in lines {
        line_min := max(int)
        line_max := min(int)
        values := strings.fields(line, context.temp_allocator)
        for val_str in values {
            val, _ := strconv.parse_int(val_str)
            if val < line_min do line_min = val
            if val > line_max do line_max = val
        }
        sum += line_max - line_min
    }

    fmt.println(sum)

    sum = 0
    for line in lines {
        values := strings.fields(line, context.temp_allocator)
        for i := 0; i < len(values) - 1; i += 1 {
            for j := i + 1; j < len(values); j += 1 {
                if i == j do continue
                a, _ := strconv.parse_int(values[i])
                b, _ := strconv.parse_int(values[j])
                if a % b == 0 {
                    sum += a / b
                    break
                } else if b % a == 0 {
                    sum += b / a
                    break
                }
            }
        }
    }

    fmt.println(sum)
}