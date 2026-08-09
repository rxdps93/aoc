package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:unicode"

reacts :: proc(p1, p2: u8) -> bool {
    r1 := rune(p1)
    r2 := rune(p2)
    
    return (unicode.to_lower(r1) == unicode.to_lower(r2)) && (r1 != r2)
}

fully_react :: proc(poly: string) -> int {
    result := make([]u8, len(poly))
    result_len := 0

    for i := 0; i < len(poly); i += 1 {
        c := u8(poly[i])
        if result_len > 0 && reacts(result[result_len - 1], c) {
            result_len -= 1
        } else {
            result[result_len] = c
            result_len += 1
        }
    }

    return result_len
}

d5p1 :: proc(data: string) -> int {
    
    return fully_react(data)
}

d5p2 :: proc(data: string) -> int {
    best := len(data)
    for ltr in 'A'..='Z' {
        upper := fmt.tprint(ltr)
        lower := fmt.tprint(unicode.to_lower(ltr))
        
        test_str, _ := strings.remove_all(data, upper, context.temp_allocator)
        test_str, _ = strings.remove_all(test_str, lower, context.temp_allocator)

        size := fully_react(test_str)

        if size < best do best = size
    }

    return best
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input, context.allocator)

    data := strings.trim_space(string(input))
    fmt.printf("%d\n%d\n", d5p1(data), d5p2(data))
}