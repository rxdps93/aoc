package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:container/queue"

GEN_A_FACTOR :: 16807
GEN_B_FACTOR :: 48271

generate_value :: proc(factor: int, prev_value: int) -> int {
    return (factor * prev_value) % int(max(i32))
}

judge_pair :: proc(a, b: int) -> bool {
    return i16(a) == i16(b)
}

parse_input :: proc(input: []byte) -> (a, b: int) {
    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    a, _ = strconv.parse_int(strings.fields(lines[0], context.temp_allocator)[4])
    b, _ = strconv.parse_int(strings.fields(lines[1], context.temp_allocator)[4])
    return
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return
    start_a, start_b := parse_input(input)

    matches := 0
    a := start_a
    b := start_b
    for i in 0..<40_000_000 {
        a = generate_value(GEN_A_FACTOR, a)
        b = generate_value(GEN_B_FACTOR, b)
        if judge_pair(a, b) do matches += 1
    }

    fmt.println(matches)

    matches = 0
    a = start_a
    b = start_b

    aq: queue.Queue(int)
    bq: queue.Queue(int)

    queue.init(&aq)
    queue.init(&bq)

    defer {
        queue.destroy(&aq)
        queue.destroy(&bq)
    }

    judged_pairs := 0
    for judged_pairs < 5_000_000 {
        a = generate_value(GEN_A_FACTOR, a)
        b = generate_value(GEN_B_FACTOR, b)

        if a % 4 == 0 do queue.enqueue(&aq, a)
        if b % 8 == 0 do queue.enqueue(&bq, b)

        if queue.len(aq) > 0 && queue.len(bq) > 0 {
            judged_pairs += 1
            if judge_pair(queue.dequeue(&aq), queue.dequeue(&bq)) do matches += 1
        }
    }

    fmt.println(matches)
}