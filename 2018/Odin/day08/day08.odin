package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Node :: struct {
    children: [dynamic]Node,
    metadata: [dynamic]int
}

build_tree :: proc(data: []int) -> (Node, []int) {
    ch := data[0]
    md := data[1]

    node := Node{}

    input := data[2:]
    for c in 0..<ch {
        child, rem := build_tree(input)
        append(&node.children, child)
        input = rem
    }

    for m in 0..<md {
        append(&node.metadata, input[0])
        input = input[1:]
    }

    return node, input
}

print_tree :: proc(node: ^Node, depth: int) {
    if node == nil do return

    for t in 0..<depth do fmt.print("\t")
    fmt.printf("Node with metadata: [ ")
    for md in node.metadata do fmt.printf("%d ", md)
    fmt.printf("]\n")
    for &child in node.children do print_tree(&child, depth + 1)
}

d8p1 :: proc(node: ^Node, sum: ^int) {
    if node == nil do return

    for md in node.metadata do sum^ += md

    for &child in node.children do d8p1(&child, sum)
}

d8p2 :: proc(node: ^Node, value: ^int) {
    if node == nil do return

    for md in node.metadata {
        if len(node.children) == 0 {
            value^ += md
        } else {
            if md != 0 && md <= len(node.children) {
                d8p2(&node.children[md - 1], value)
            }
        }
    }
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.allocator)
    if read_err != nil do return
    defer delete(input)

    str_data, str_err := strings.fields(strings.trim_space(string(input)))
    if str_err != nil do return

    data := make([]int, len(str_data))
    defer delete(data)

    for str, idx in str_data {
        val, ok := strconv.parse_int(str)
        if !ok do return
        data[idx] = val
    }

    defer free_all(context.temp_allocator)
    context.allocator = context.temp_allocator

    tree, _ := build_tree(data)

    p1 := 0
    d8p1(&tree, &p1)

    p2 := 0
    d8p2(&tree, &p2)
    fmt.printf("%d\n%d\n", p1, p2)
}