package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import pq "core:container/priority_queue"

Vec3 :: [3]int

Nanobot :: struct {
    pos: Vec3,
    r: int,
}

BoundingBox :: struct {
    min_pts: Vec3,
    box_size: int,
    bot_count: int,
    dist: int,
}

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

define_bounding_box :: proc(min_pts: Vec3, box_size: int, nanobots: []Nanobot) -> BoundingBox {
    max_pts := min_pts + box_size - 1

    sum := 0
    for bot in nanobots {
        cx := clamp(bot.pos.x, min_pts.x, max_pts.x)
        cy := clamp(bot.pos.y, min_pts.y, max_pts.y)
        cz := clamp(bot.pos.z, min_pts.z, max_pts.z)

        if get_dist(bot.pos, {cx, cy, cz}) <= bot.r do sum += 1
    }

    // for origin
    ox := clamp(0, min_pts.x, max_pts.x)
    oy := clamp(0, min_pts.y, max_pts.y)
    oz := clamp(0, min_pts.z, max_pts.z)
    dist := get_dist({0, 0, 0}, {ox, oy, oz})

    return BoundingBox{
        min_pts,
        box_size,
        sum,
        dist
    }
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input), context.temp_allocator)

    nanobots := make([dynamic]Nanobot, context.temp_allocator)
    max_r, max_pos := min(int), Vec3{}
    min_pts := Vec3{max(int), max(int), max(int)}
    max_pts := Vec3{min(int), min(int), min(int)}
    for line in lines {
        pos, r := parse_line(line)
        if r > max_r {
            max_r = r
            max_pos = pos
        }
        append(&nanobots, Nanobot{pos, r})

        // calculate min bounds for total bounding box
        if pos.x - r < min_pts.x do min_pts.x = pos.x - r
        if pos.y - r < min_pts.y do min_pts.y = pos.y - r
        if pos.z - r < min_pts.z do min_pts.z = pos.z - r

        // calculate max bounds for total bounding box
        if pos.x + r > max_pts.x do max_pts.x = pos.x + r
        if pos.y + r > max_pts.y do max_pts.y = pos.y + r
        if pos.z + r > max_pts.z do max_pts.z = pos.z + r
    }

    // calculate part 1
    sum := 0
    for bot in nanobots {
        if get_dist(bot.pos, max_pos) <= max_r do sum += 1
    }
    fmt.println(sum)

    // define initial bounding box
    box_size := max(max_pts.x - min_pts.x, max_pts.y - min_pts.y, max_pts.z - min_pts.z)
    box_size = math.next_power_of_two(box_size)
    box := define_bounding_box(min_pts, box_size, nanobots[:])

    q: pq.Priority_Queue(BoundingBox)
    pq.init(
        pq = &q,
        less = proc(a, b: BoundingBox) -> bool {
            if a.bot_count != b.bot_count do return a.bot_count > b.bot_count
            if a.dist != b.dist do return a.dist < b.dist
            return a.box_size < b.box_size
        },
        swap = pq.default_swap_proc(BoundingBox)
    )
    defer pq.destroy(&q)

    pq.push(&q, box)

    for pq.len(q) > 0 {
        box = pq.pop(&q)

    if box.box_size == 1 do break
        half := box.box_size / 2
        x, y, z := box.min_pts.x, box.min_pts.y, box.min_pts.z
        child_pos := [8]Vec3{
            {x,         y,          z},
            {x + half,  y,          z},
            {x + half,  y + half,   z},
            {x + half,  y,          z + half},
            {x,         y + half,   z},
            {x,         y + half,   z + half},
            {x,         y,          z + half},
            {x + half,  y + half,   z + half},
        }

        for min in child_pos {
            child_box := define_bounding_box(min, half, nanobots[:])
            if child_box.bot_count != 0 do pq.push(&q, child_box)
        }
    }

    fmt.printf("%d\n", box.dist)
}