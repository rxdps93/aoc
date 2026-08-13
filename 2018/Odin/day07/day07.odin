package main

import "core:os"
import "core:fmt"
import "core:strings"

d7p1 :: proc(data: string) -> string {
    lines := strings.split_lines(data, context.allocator)
    defer delete(lines)

    instr := make(map[u8][dynamic]u8)
    defer {
        for _, v in instr do delete(v)
        delete(instr)
    }

    steps := make(map[u8]struct{}) // hashset of step ids
    defer delete(steps)

    for line in lines {
        cur_req := line[5]
        cur_step := line[36]

        steps[cur_req] = {}
        steps[cur_step] = {}

        prereqs, ok := &instr[cur_step]

        if ok {
            append(prereqs, cur_req)
        } else {
            list := make([dynamic]u8)
            append(&list, cur_req)
            instr[cur_step] = list
        }

        _, ok = &instr[cur_req]

        if !ok {
            instr[cur_req] = make([dynamic]u8)
        }
    }

    order := make([]u8, len(steps))
    defer delete(order)
    count := 0

    for count < len(steps) {
        current := max(u8)
        for s, pr in instr {
            if len(pr) == 0 && s < current do current = s
        }

        delete_key(&instr, current)

        order[count] = current
        count += 1

        for s, &pr in instr {
            idx := -1
            for r, i in pr {
                if r == current {
                    idx = i
                    break
                }
            }

            if idx != -1 {
                unordered_remove_dynamic_array(&pr, idx)
            }
        }
    }

    return strings.clone_from_bytes(order, context.temp_allocator)
}

d7p2 :: proc(data: string) -> string {
    return ""
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input)
    data := strings.trim_space(string(input))

    fmt.printf("%s\n%s\n", d7p1(data), d7p2(data))
}