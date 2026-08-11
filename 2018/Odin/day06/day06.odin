package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

Coord :: struct {
    x: int,
    y: int,
}

calc_dist :: proc(a, b: Coord) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

d6p1 :: proc(data: string) -> int {
    coords := make(map[int]Coord)
    defer delete(coords)

    xmin := max(int)
    xmax := min(int)
    ymin := max(int)
    ymax := min(int)

    id := 0
    lines := data
    for line in strings.split_lines_iterator(&lines) {
        split, _ := strings.split(line, ", ", context.temp_allocator)

        x, _ := strconv.parse_int(split[0])
        y, _ := strconv.parse_int(split[1])

        if x < xmin do xmin = x
        if x > xmax do xmax = x
        if y < ymin do ymin = y
        if y > ymax do ymax = y

        coords[id] = Coord{x, y}
        id += 1
    }

    grid := make(map[Coord][dynamic]int)
    defer {
        for _, v in &grid do delete(v)
        delete(grid)
    }

    blacklist := make([dynamic]int)
    defer delete(blacklist)

    for y in ymin..=ymax {
        for x in xmin..=xmax {
            // calculate dist to each provided coord
            min_dist := max(int)
            list := make([dynamic]int)

            for id, coord in coords {
                dist := calc_dist(coord, Coord{x, y})

                if dist < min_dist {
                    min_dist = dist
                    list = make([dynamic]int)
                    append(&list, id)
                } else if dist == min_dist {
                    append(&list, id)
                }

                grid[{x, y}] = list
            }

            // if on border, blacklist input coord
            if x == xmin || x == xmax || y == ymin || y == ymax {
                if len(list) == 1 {
                    id := list[0]
                    if !slice.contains(blacklist[:], id) do append(&blacklist, id)
                }
            }
        }
    }

    areas := make(map[int]int)
    defer delete(areas)
    max_area := min(int)
    for _, ids in grid {
        if len(ids) == 1 && !slice.contains(blacklist[:], ids[0]) {
            areas[ids[0]] += 1

            if areas[ids[0]] > max_area do max_area = areas[ids[0]]
        }
    }

    return max_area
}

d6p2 :: proc(data: string) -> int {
    coords := make([dynamic]Coord)
    defer delete(coords)

    xmin := max(int)
    xmax := min(int)
    ymin := max(int)
    ymax := min(int)

    lines := data
    for line in strings.split_lines_iterator(&lines) {
        split, _ := strings.split(line, ", ", context.temp_allocator)

        x, _ := strconv.parse_int(split[0])
        y, _ := strconv.parse_int(split[1])

        if x < xmin do xmin = x
        if x > xmax do xmax = x
        if y < ymin do ymin = y
        if y > ymax do ymax = y

        append(&coords, Coord{x, y})
    }

    region := 0
    for y in ymin..=ymax {
        for x in xmin..=xmax {
            dist := 0
            for coord in coords {
                dist += calc_dist({x, y}, coord)
            }

            if dist < 10000 do region += 1
        }
    }

    return region
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input, context.allocator)

    data := strings.trim_space(string(input))
    fmt.printf("%d\n%d\n", d6p1(data), d6p2(data))
}