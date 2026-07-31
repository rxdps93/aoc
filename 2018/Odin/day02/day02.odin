package main

import "core:os"
import "core:strings"
import "core:unicode"
import "core:fmt"

d2p1 :: proc(data: string) -> int {
    has_two := 0
    has_three := 0

    lines := data
    for line in strings.split_lines_iterator(&lines) {
        ltr_freq := make(map[rune]int)
        is_two := false
        is_three := false

        for r in line {
            if unicode.is_alpha(r) {
                lower := unicode.to_lower(r)
                ltr_freq[lower] += 1
            }
        }

        for k, v in ltr_freq {
            if v == 2 && !is_two {
                has_two += 1
                is_two = true
            }

            if v == 3 && !is_three {
                has_three += 1
                is_three = true
            }

            if is_two && is_three do break
        }

        delete(ltr_freq)
    }

    return has_two * has_three
}

d2p2 :: proc(data: string) -> string {
    lines, _ := strings.split_lines(data, context.allocator)
    defer delete(lines, context.allocator)

    for i in 0..<len(lines) - 1 {
        for j in i + 1..<len(lines) {

            diff := -1
            diffs := 0
            for r in 0..<len(lines[i]) {
                if lines[i][r] != lines[j][r] {
                    diffs += 1
                    if diffs > 1 {
                        break;
                    }
                    diff = r
                }
            }

            if diffs == 1 {
                return strings.concatenate({lines[i][:diff], lines[i][diff + 1:]})
            }
        }
    }

    return ""
}

main :: proc() {
    data, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    iter := string(data)
    fmt.printf("%d\n%s\n", d2p1(iter), d2p2(iter))
}