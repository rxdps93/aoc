package main

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:slice"

d3p1 :: proc(data: string) -> int {
    fabric := make(map[struct{int, int}]int)
    defer delete(fabric)

    lines := data
    for line in strings.split_lines_iterator(&lines) {
        tokens, _ := strings.fields_proc(line, proc(r: rune) -> bool {
            delims := [?]rune{' ', '#', '@', ',', ':', 'x'}
            return slice.contains(delims[:], r)
        })

        defer delete(tokens)

        id, _ := strconv.parse_int(tokens[0])
        pad_left, _ := strconv.parse_int(tokens[1])
        pad_top, _ := strconv.parse_int(tokens[2])
        width, _ := strconv.parse_int(tokens[3])
        height, _ := strconv.parse_int(tokens[4])

        for y in pad_top..<pad_top + height {
            for x in pad_left..<pad_left + width {
                fabric[{x, y}] += 1
            }
        }
    }

    overlap := 0
    for k,v in fabric {
        if v > 1 do overlap += 1
    }

    return overlap
}

d3p2 :: proc(data: string) -> int {
    fabric := make(map[struct{int, int}][dynamic]int)
    defer {
        for _, v in &fabric do delete(v)
        delete(fabric)
    }

    ids := make(map[int]struct{})
    defer delete(ids)

    lines := data
    for line in strings.split_lines_iterator(&lines) {
        tokens, _ := strings.fields_proc(line, proc(r: rune) -> bool {
            delims := [?]rune{' ', '#', '@', ',', ':', 'x'}
            return slice.contains(delims[:], r)
        })

        defer delete(tokens)

        id, _ := strconv.parse_int(tokens[0])
        pad_left, _ := strconv.parse_int(tokens[1])
        pad_top, _ := strconv.parse_int(tokens[2])
        width, _ := strconv.parse_int(tokens[3])
        height, _ := strconv.parse_int(tokens[4])

        ids[id] = {}

        for y in pad_top..<pad_top + height {
            for x in pad_left..<pad_left + width {
                ids, ok := &fabric[{x, y}]
                if ok {
                    append(ids, id)
                } else {
                    list := make([dynamic]int)
                    append(&list, id)
                    fabric[{x, y}] = list
                }
            }
        }
    }

    for k,v in fabric {
        // fmt.println(k, " -> ", v)
        // if len(v) == 1 do return v[0]
        if len(v) > 1 {
            for id in v {
                delete_key(&ids, id)
            }
        }
    }

    if len(ids) == 1 {
        for id in ids {
            return id
        }
    }

    return -1
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input, context.allocator)

    data := string(input)
    fmt.printf("%d\n%d\n", d3p1(data), d3p2(data))
}