package main

import "core:os"
import "core:fmt"
import "core:strings"

hex_direction :: proc(a, b: [3]int) -> int {
    return max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    directions := strings.split(strings.trim_space(string(input)), ",", context.temp_allocator)

    /*
     * hex coordinates:
     * given 3 coordinates, x, y, z
     * NORTH:   -y;+z
     * SOUTH:   +y;-z
     * NEAST:   +x;-y
     * SEAST:   +x;-z
     * NWEST:   -x;+z
     * SWEST:   -x;+y
     *
     * distance calculation:
     * should be pretty much just a 3d manhattan function
     * max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))
     */

    vecs := make(map[string][3]int, 6, context.temp_allocator)
    vecs["n"]  = { 0, -1,  1 }
    vecs["s"]  = { 0,  1, -1 }
    vecs["ne"] = { 1, -1,  0 }
    vecs["se"] = { 1,  0, -1 }
    vecs["nw"] = {-1,  0,  1 }
    vecs["sw"] = {-1,  1,  0 }

    pos := [3]int{}
    max_dist := min(int)
    for dir in directions {
        pos += vecs[dir]
        max_dist = max(max_dist, hex_direction({0, 0, 0}, pos))
    }

    fmt.println(hex_direction({0, 0, 0}, pos))
    fmt.println(max_dist)
}