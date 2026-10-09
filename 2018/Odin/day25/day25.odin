package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

Vec4 :: [4]int

Node :: struct {
    point: Vec4,
    connected: [dynamic]^Node
}

get_dist :: proc(a, b: Vec4) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z) + abs(a.w - b.w)
}

build_graph :: proc(filename: string, graph: ^[dynamic]Node) {
    data, err := os.read_entire_file(filename, context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(data))
    for line in lines {
        str, _ := strings.split(line, ",", context.temp_allocator)
        pt: Vec4
        for s, i in str do pt[i], _ = strconv.parse_int(strings.trim_space(s))
        append(graph, {pt, make([dynamic]^Node)})
    }

    for i := 0; i < len(graph) - 1; i += 1 {
        for j := i + 1; j < len(graph); j += 1 {
            if slice.contains(graph[i].connected[:], &graph[j]) do continue

            dist := get_dist(graph[i].point, graph[j].point)
            if dist <= 3 {
                append(&graph[i].connected, &graph[j])
                append(&graph[j].connected, &graph[i])
            }
        }
    }
}

dfs :: proc(current: ^Node, constellation: ^[dynamic]^Node, visited: ^map[^Node]struct{}) {
    visited[current] = {}
    append(constellation, current)

    for node in current.connected {
        if node not_in visited do dfs(node, constellation, visited)
    }
}

build_constellations :: proc(graph: [dynamic]Node, constellations: ^[dynamic][dynamic]^Node) {
    visited := make(map[^Node]struct{})

    for &node in graph {
        if &node not_in visited {
            constellation := make([dynamic]^Node)
            dfs(&node, &constellation, &visited)
            append(constellations, constellation)
        }
    }
}

main :: proc() {
    graph := make([dynamic]Node)
    build_graph("input.txt", &graph)

    constellations := make([dynamic][dynamic]^Node) // Lord have mercy on me
    build_constellations(graph, &constellations)

    fmt.println(len(constellations))

    // final clean up
    for node in graph do delete(node.connected)
    delete(graph)
    for con in constellations do delete(con)
    delete(constellations)
}