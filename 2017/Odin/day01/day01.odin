package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    input_str := strings.trim_space(string(input))
    sum := 0
    for i := 0; i < len(input_str); i += 1 {
        if input_str[i] == input_str[(i + 1) % len(input_str)] do sum += int(input_str[i] - '0')
    }
    fmt.println(sum);

    sum = 0
    step := len(input_str) / 2
    for i := 0; i < len(input_str); i += 1 {
        if input_str[i] == input_str[(i + step) % len(input_str)] do sum += int(input_str[i] - '0')
    }
    fmt.println(sum);
}