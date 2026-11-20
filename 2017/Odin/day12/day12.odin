package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

parse_input :: proc(prgms: ^map[int][dynamic]int, input: []byte) {
    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)
    for line in lines {
        line_split := strings.split(line, " <-> ", context.temp_allocator)

        prgm, _ := strconv.parse_int(line_split[0])
        conn_str := strings.split(line_split[1], ", ", context.temp_allocator)
        conn_ids := make([]int, len(conn_str), context.temp_allocator)
        for _, i in conn_str do conn_ids[i], _ = strconv.parse_int(conn_str[i])

        if !(prgm in prgms) do prgms[prgm] = make([dynamic]int, context.allocator)

        for id in conn_ids {
            if !slice.contains(prgms[prgm][:], id) do append(&prgms[prgm], id)

            if !(id in prgms) do prgms[id] = make([dynamic]int, context.allocator)

            if !slice.contains(prgms[id][:], prgm) do append(&prgms[id], prgm)
        }
    }
}

identify_group :: proc(visited: ^map[int]struct{}, prgms: map[int][dynamic]int, pid: int) {
    visited[pid] = {}

    for cid in prgms[pid] {
        if !(cid in visited) do identify_group(visited, prgms, cid)
    }
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    prgms := make(map[int][dynamic]int, context.allocator)
    defer {
        for _, v in prgms do delete(v)
        delete(prgms)
    }

    parse_input(&prgms, input)

    group := make(map[int]struct{}, context.temp_allocator)
    identify_group(&group, prgms, 0)

    fmt.println(len(group))

    for k, _ in group do delete_key(&prgms, k)

    groups := 1
    for len(prgms) > 0 {
        clear_map(&group)
        keys, _ := slice.map_keys(prgms, context.temp_allocator)
        identify_group(&group, prgms, keys[0])
        groups += 1
        for k, _ in group do delete_key(&prgms, k)
    }

    fmt.println(groups)
}