package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Node :: struct {
    weight: int,
    children: []string,
}

parse_line :: proc(line: string) -> (name: string, data: Node) {
    fields := strings.fields(line, context.temp_allocator)
    
    name = fields[0]
    data.weight, _ = strconv.parse_int(fields[1][1:len(fields[1]) - 1])

    if len(fields) > 2 {
        data.children = make([]string, len(fields) - 3)
        for str, i in fields[3:] do data.children[i] = strings.trim_right(str, ",")
    }

    return
}

find_root :: proc(node_map: map[string]Node) -> string {

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

tower_weight :: proc(node_map: map[string]Node, current: string) -> (weight: int) {
    node := node_map[current]
    weight += node.weight

    for cn in node.children do weight += tower_weight(node_map, cn)

    return
}

find_unbalanced_tower :: proc(node_map: map[string]Node, parent: string) -> (name: string, offset: int) {
    freq := make(map[int]struct{freq: int, name: string})
    defer delete(freq)
    for cn in node_map[parent].children {
        w := tower_weight(node_map, cn)
        freq[w] = {
            freq[w].freq + 1,
            cn
        }
    }

    val := 0
    off := 0
    for k,v in freq {
        if v.freq == 1 {
            name = v.name
            off = k
        } else {
            val = k
        }
    }
    offset = val - off

    return
}

main :: proc() {
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)

    node_map := make(map[string]Node)
    defer {
        for k,v in node_map do delete(v.children)
        delete(node_map)
    }

    // parse input
    for line in lines {
        n, d := parse_line(line)
        node_map[n] = d
    }

    // find the root; will have children but not be in another child list
    root := find_root(node_map)

    fmt.println(root)

    ubn, off := find_unbalanced_tower(node_map, root)
    prev: string
    for ubn != "" {
        prev = ubn
        ubn, _ = find_unbalanced_tower(node_map, ubn)
    }

    fmt.println(node_map[prev].weight + off)
}