package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Vector :: [2]int

Region :: struct {
    geo_idx: int,
    erosion: int,
    type: RegionType,
}

RegionType :: enum {
    Rocky,
    Wet,
    Narrow,
}

parse_input :: proc(filename: string) -> (depth: int, target: Vector) {
    input, err := os.read_entire_file(filename, context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input), context.temp_allocator)

    depth, _ = strconv.parse_int(strings.trim_prefix(lines[0], "depth: "))
    
    str := strings.split(strings.trim_prefix(lines[1], "target: "), ",", context.temp_allocator)
    tx, _ := strconv.parse_int(str[0])
    ty, _ := strconv.parse_int(str[1])
    target = Vector{tx, ty}

    return depth, target
}

to_idx :: proc(coords: Vector, width: int) -> int {
    return coords.y * width + coords.x
}

build_cave_map :: proc(cave_map: ^[]Region, width, height, depth: int, target: Vector) {

    for y in 0..<height {
        for x in 0..<width {
            coords := Vector{x, y}
            idx := to_idx(coords, width)

            // figure out geologic level
            if coords == target || coords == {0, 0} {
                cave_map[idx].geo_idx = 0
            } else if y == 0 {
                cave_map[idx].geo_idx = x * 16807
            } else if x == 0 {
                cave_map[idx].geo_idx = y * 48271
            } else {
                li := to_idx({x - 1, y}, width)
                ui := to_idx({x, y - 1}, width)
                cave_map[idx].geo_idx = cave_map[li].erosion * cave_map[ui].erosion
            }

            // figure out erosion level
            cave_map[idx].erosion = (cave_map[idx].geo_idx + depth) % 20183

            // determine type
            cave_map[idx].type = RegionType(cave_map[idx].erosion % 3)
        }
    }
}

main :: proc() {
    depth, target := parse_input("input.txt")

    width := target.x + 1
    height := target.y + 1
    cave_map := make([]Region, width * height)

    build_cave_map(&cave_map, width, height, depth, target)

    risk := 0
    for region in cave_map {
        risk += int(region.type)
    }
    fmt.printf("%d\n", risk)

    delete(cave_map)
}