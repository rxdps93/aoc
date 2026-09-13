package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Tile :: enum {
    Sand,
    Clay,
    Wet,
    Water,
}

Vector :: [2]int

State :: struct {
    ground: []Tile,
    width: int,
    x_min: int,
    x_max: int,
    y_min: int,
    y_max: int,
}

simulate_water :: proc(state: ^State, loc: Vector) -> (blocking_path: bool) {
    if loc.y > state.y_max do return false

    state_idx := loc.y * state.width + (loc.x - state.x_min)
    if state.ground[state_idx] != Tile.Sand {
        return state.ground[state_idx] != Tile.Wet
    }

    state.ground[state_idx] = Tile.Wet

    blocked := false

    if loc.y < state.y_max {
        below := (loc.y + 1) * state.width + (loc.x - state.x_min)
        if state.ground[below] == Tile.Sand || state.ground[below] == Tile.Wet{
            blocked = simulate_water(state, {loc.x, loc.y + 1})
        } else {
            blocked = state.ground[below] == Tile.Clay || state.ground[below] == Tile.Water
        }
    }

    if blocked {
        for true {
            left_bounded, right_bounded := false, false
            left, right := state.x_min, state.x_max

            // check left
            for l := loc.x; l > state.x_min; l -= 1 {
                l_idx := loc.y * state.width + ((l - 1) - state.x_min)
                b_idx := (loc.y + 1) * state.width + (l - state.x_min)

                if state.ground[b_idx] == Tile.Sand || state.ground[b_idx] == Tile.Wet {
                    left = l
                    break
                }

                if state.ground[l_idx] == Tile.Clay {
                    left = l
                    left_bounded = true
                    break
                }
            } 

            // check right
            for r := loc.x; r < state.x_max; r += 1 {
                r_idx := loc.y * state.width + ((r + 1) - state.x_min)
                b_idx := (loc.y + 1) * state.width + (r - state.x_min)

                if state.ground[b_idx] == Tile.Sand || state.ground[b_idx] == Tile.Wet {
                    right = r
                    break
                }
                if state.ground[r_idx] == Tile.Clay {
                    right = r
                    right_bounded = true
                    break
                }
            }

            if left_bounded && right_bounded {
                // whole span becomes water and return true
                for wx in left..=right {
                    wi := loc.y * state.width + (wx - state.x_min)
                    state.ground[wi] = Tile.Water
                }
                return true
            }

            // whole spawn becomes wet
            // recurse down at the abyss points
            // if the downward paths become blocked reloop to mark wet
            // otherwise its infinitely spiraling into the void
            for wx in left..=right {
                wi := loc.y * state.width + (wx - state.x_min)
                state.ground[wi] = Tile.Wet
            }

            if !left_bounded do left_bounded = simulate_water(state, {left, loc.y + 1})
            if !right_bounded do right_bounded = simulate_water(state, {right, loc.y + 1})

            if left_bounded && right_bounded {
                continue
            } else {
                return false
            }
        }
    }

    return false
}

main :: proc() {
    scans, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    clay_at := make([dynamic]Vector, context.temp_allocator)

    lines := strings.split_lines(string(scans))
    y_min, y_max := max(int), min(int)
    x_min, x_max := max(int), min(int)
    for line in lines {
        data := strings.split(line, ", ")
        slice.sort_by(data, proc(a, b: string) -> bool {
            ra := len(a) > 0 ? a[0] : 0
            rb := len(b) > 0 ? b[0] : 0
            return ra < rb
        })

        // x coord
        x_start := 0
        x_end := 0
        if strings.contains(data[0], "..") {
            range := strings.split(data[0][2:], "..")
            x_start, _ = strconv.parse_int(range[0])
            x_end, _ = strconv.parse_int(range[1])
        } else {
            x_start, _ = strconv.parse_int(data[0][2:])
            x_end = x_start
        }

        // y coord
        y_start := 0
        y_end := 0
        if strings.contains(data[1], "..") {
            range := strings.split(data[1][2:], "..")
            y_start, _ = strconv.parse_int(range[0])
            y_end, _ = strconv.parse_int(range[1])
        } else {
            y_start, _ = strconv.parse_int(data[1][2:])
            y_end = y_start
        }

        x_min = min(x_min, x_start)
        x_max = max(x_max, x_end)

        y_min = min(y_min, y_start)
        y_max = max(y_max, y_end)

        for y in y_start..=y_end {
            for x in x_start..=x_end {
                append(&clay_at, Vector{x, y})
            }
        }
    }

    x_min -= 1
    x_max += 1

    width := (x_max - x_min) + 1
    height := y_max + 1

    state := State{
        make([]Tile, width * height),
        width,
        x_min,
        x_max,
        y_min,
        y_max
    }

    for vec in clay_at {
        state.ground[vec.y * width + (vec.x - x_min)] = Tile.Clay
    }

    _ = simulate_water(&state, Vector{500, 0})

    water := 0
    wet := 0
    for wy in y_min..=y_max {
        for wx in x_min..=x_max {
            idx := wy * width + (wx - x_min)
            if state.ground[idx] == Tile.Wet do wet += 1
            if state.ground[idx] == Tile.Water do water += 1
        }
    }
    fmt.println(water + wet)
    fmt.println(water)
}