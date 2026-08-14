package main

import "core:os"
import "core:fmt"
import "core:strings"

parse_steps :: proc(data: string) -> (map[u8][dynamic]u8, map[u8]struct{}) {
    lines := strings.split_lines(data, context.allocator)
    defer delete(lines)

    instr := make(map[u8][dynamic]u8)

    steps := make(map[u8]struct{}, context.allocator) // hashset of step ids

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

    return instr, steps
}

d7p1 :: proc(data: string) -> string {
    instr, steps := parse_steps(data)
    defer {
        for _, v in instr do delete(v)
        delete(instr)
        delete(steps)
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

d7p2 :: proc(data: string) -> int {
    instr, steps := parse_steps(data)
    defer {
        for _, v in instr do delete(v)
        delete(instr)
        delete(steps)
    }

    order := make([]u8, len(steps))
    defer delete(order)
    count := 0

    workers: [5]struct{time: int, step: u8}

    seconds := -1
    for count < len(steps) {
        seconds += 1

        // decrement time and complete tasks
        for &w in workers {
            if w.step != 0 && w.time != 0 do w.time -= 1

            if w.step != 0 && w.time == 0 {
                order[count] = w.step
                count += 1

                for s, &pr in instr {
                    idx := -1
                    for r, i in pr {
                        if r == w.step {
                            idx = i
                            break
                        }
                    }

                    if idx != -1 {
                        unordered_remove_dynamic_array(&pr, idx)
                    }
                }

                w.step = 0
                w.time = 0
            }
        }

        // assign new tasks
        for &w in workers {
            if w.step == 0 && w.time == 0 {
                task := max(u8)
                for s, pr in instr {
                    if len(pr) == 0 && s < task do task = s
                }

                if task != max(u8) {
                    w.step = task
                    w.time = int(task) - 4
                    delete_key(&instr, task)
                }
            }
        }
    }

    return seconds
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input)
    data := strings.trim_space(string(input))

    fmt.printf("%s\n%d\n", d7p1(data), d7p2(data))
}