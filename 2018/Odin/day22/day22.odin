package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import pq "core:container/priority_queue"

Vec2 :: [2]int

State :: struct {
    coords: Vec2,
    tool: ToolType,
}

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

ToolType :: enum {
    Torch,
    Gear,
    Neither
}

OTHER_TOOL := [RegionType][ToolType]ToolType {
    .Rocky  = { .Torch = .Gear,     .Gear = .Torch,     .Neither = .Neither },
    .Wet    = { .Gear = .Neither,   .Neither = .Gear,   .Torch   = .Torch   },
    .Narrow = { .Torch = .Neither,  .Neither = .Torch,  .Gear    = .Gear    },
}

OFFSETS :: [4]Vec2{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

parse_input :: proc(filename: string) -> (depth: int, target: Vec2) {
    input, err := os.read_entire_file(filename, context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input), context.temp_allocator)

    depth, _ = strconv.parse_int(strings.trim_prefix(lines[0], "depth: "))
    
    str := strings.split(strings.trim_prefix(lines[1], "target: "), ",", context.temp_allocator)
    tx, _ := strconv.parse_int(str[0])
    ty, _ := strconv.parse_int(str[1])
    target = Vec2{tx, ty}

    return depth, target
}

to_idx :: proc(coords: Vec2, width: int) -> int {
    return coords.y * width + coords.x
}

build_cave_map :: proc(cave_map: ^[]Region, width, height, depth: int, target: Vec2) {

    for y in 0..<height {
        for x in 0..<width {
            coords := Vec2{x, y}
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

calculate_part1_risk :: proc(cave_map: []Region, width, height: int, target: Vec2) -> (risk: int) {
    for y in 0..<height {
        for x in 0..<width {
            if y > target.y || x > target.x do continue
            risk += int(cave_map[y * width + x].type)
        }
    }
    return risk
}

get_other_valid_tool :: proc(type: RegionType, equipped_tool: ToolType) -> ToolType {
    return OTHER_TOOL[type][equipped_tool]
}

check_tool_validity :: proc(type: RegionType, tool: ToolType) -> (is_valid: bool) {
    return get_other_valid_tool(type, tool) != tool
}

find_shortest_path :: proc(cave_map: []Region, width, height, depth: int, target: Vec2) -> (time: int) {
    time_map := make(map[State]int, context.temp_allocator)
    time_map[{{0, 0}, .Torch}] = 0

    TimeRecord :: struct {
        time: int,
        state: State,
    }

    q: pq.Priority_Queue(TimeRecord)
    pq.init(
        pq = &q,
        less = proc(a, b: TimeRecord) -> bool {
            return a.time < b.time
        },
        swap = pq.default_swap_proc(TimeRecord),
    )
    defer pq.destroy(&q)

    pq.push(&q, TimeRecord{0, {{0, 0}, .Torch}})
    for pq.len(q) != 0 {
        current := pq.pop(&q)

        if current.state.coords == target && current.state.tool == .Torch do return current.time

        if current.time > time_map[current.state] do continue

        other_tool := get_other_valid_tool(cave_map[to_idx(current.state.coords, width)].type, current.state.tool)

        new_state := State{current.state.coords, other_tool}
        new_time := current.time + 7

        if new_state not_in time_map || new_time < time_map[new_state] {
            time_map[new_state] = new_time
            pq.push(&q, TimeRecord{new_time, new_state})
        }

        for offset in OFFSETS {
            neighbor_at := current.state.coords + offset

            if neighbor_at.x < 0 || neighbor_at.x >= width || neighbor_at.y < 0 || neighbor_at.y >= height do continue

            neighbor := cave_map[to_idx(neighbor_at, width)]
            if check_tool_validity(neighbor.type, current.state.tool) {
                new_state = State{neighbor_at, current.state.tool}
                new_time = current.time + 1
                if new_state not_in time_map || new_time < time_map[new_state] {
                    time_map[new_state] = new_time
                    pq.push(&q, TimeRecord{new_time, new_state})
                }
            }
        }
    }
    return -1
}

main :: proc() {
    depth, target := parse_input("input.txt")

    padding :: 50
    width := target.x + 1 + padding
    height := target.y + 1 + padding
    cave_map := make([]Region, width * height)

    build_cave_map(&cave_map, width, height, depth, target)

    risk := calculate_part1_risk(cave_map, width, height, target)
    time := find_shortest_path(cave_map, width, height, depth, target)
    fmt.printf("%d\n%d\n", risk, time)

    delete(cave_map)
}