package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Vec3 :: [3]int

get_dist :: proc(a, b: Vec3) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
}

parse_line :: proc(line: string) -> (pos: Vec3, radius: int) {
    ps, pe := strings.index_rune(line, '<') + 1, strings.index_rune(line, '>')
    str := strings.split(line[ps:pe], ",", context.temp_allocator)
    for ss, idx in str {
        pos[idx], _ = strconv.parse_int(ss)
    }

    rs := pe + 5
    radius, _ = strconv.parse_int(line[rs:])

    return pos, radius
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input), context.temp_allocator)

    nanobots := make(map[Vec3]int, context.temp_allocator) // map pos to r
    max_r, max_pos := min(int), Vec3{}
    for line in lines {
        pos, r := parse_line(line)
        if r > max_r {
            max_r = r
            max_pos = pos
        }
        nanobots[pos] = r
    }

    sum := 0
    for pos in nanobots {
        if get_dist(pos, max_pos) <= max_r do sum += 1
    }
    fmt.println(sum)
}