package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

// Node :: struct {
//     name: string,
//     weight: int,
//     holding: [dynamic]Node,
// }

parse_line :: proc(line: string) -> (name: string, weight: int, children: []string) {
    fields := strings.fields(line, context.temp_allocator)
    
    name = fields[0]
    weight, _ = strconv.parse_int(fields[1])

    if len(fields) > 2 {
        children = make([]string, len(fields) - 3)
        for str, i in fields[3:] do children[i] = strings.trim_right(str, ",")
    }

    return
}

find_root :: proc(node_map: map[string]struct{weight: int, children: []string}) -> string {

    child_nodes := make([dynamic]string, context.temp_allocator)
    for k, v in node_map {
        if v.children == nil || len(v.children) == 0 do continue
        for n in v.children do append(&child_nodes, n)
    }

    for k, v in node_map {
        if v.children == nil || len(v.children) == 0 do continue
        
        if !slice.contains(child_nodes[:], k) do return k
    }

    return ""
}

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)

    node_map := make(map[string]struct{weight: int, children: []string})
    defer {
        for k,v in node_map do delete(v.children)
        delete(node_map)
    }

    // parse input
    for line in lines {
        n, w, c := parse_line(line)
        node_map[n] = {w, c}
    }

    // find the root; will have children but not be in another child list
    root := find_root(node_map)

    fmt.println(root)
}