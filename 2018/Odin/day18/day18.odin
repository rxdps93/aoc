package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:hash"

Vector :: [2]int

AcreType :: enum {
    Open,
    Wooded,
    Lumberyard,
}

Acre :: struct {
    currentState: AcreType,
    nextState: AcreType,
    coords: Vector,
}

tally_adjacent_acres :: proc(plot: []Acre, size: Vector, current: Vector) -> (adj_open, adj_wood, adj_lumb: int) {
    for y_offset in -1..=1 {
        for x_offset in -1..=1 {
            coords := current + {x_offset, y_offset}
            if coords == current do continue
            if coords.x < 0 || coords.x >= size.x do continue
            if coords.y < 0 || coords.y >= size.y do continue
            type := plot[coords.y * size.x + coords.x].currentState

            if type == .Open do adj_open += 1
            if type == .Wooded do adj_wood += 1
            if type == .Lumberyard do adj_lumb += 1
        }
    }

    return adj_open, adj_wood, adj_lumb
}

determine_next_state :: proc(acre: ^Acre, adj_open, adj_wood, adj_lumb: int) {
    switch acre.currentState {
        case .Open:
            if adj_wood >= 3 do acre.nextState = .Wooded
        case .Wooded:
            if adj_lumb >= 3 do acre.nextState = .Lumberyard
        case .Lumberyard:
            if adj_lumb == 0 || adj_wood == 0 do acre.nextState = .Open
    }
}

get_resource_value :: proc(plot: []Acre, size: Vector) -> int {
    wood, lumb := 0, 0
    for acre in plot {
        if acre.currentState == .Wooded do wood += 1
        if acre.currentState == .Lumberyard do lumb += 1
    }
    return wood * lumb
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    lines := strings.split_lines(string(input))
    size := Vector{len(lines[0]), len(lines)}
    plot := make([]Acre, size.x * size.y)
    for line, y in lines {
        for acre, x in line {
            type: AcreType = .Open
            if acre == '|' do type = .Wooded
            if acre == '#' do type = .Lumberyard
            plot[y * size.x + x] = { type, type, {x, y} }
        }
    }

    plot_history := make(map[u64]int, context.temp_allocator)
    scores := make([dynamic]int, context.temp_allocator)
    start, end := 0, 0
    hash_buf := make([]u8, size.x * size.y, context.temp_allocator)
    for min in 0..<1_000_000_000 {
        // figure out next state
        for &acre in plot {
            determine_next_state(&acre, tally_adjacent_acres(plot, size, acre.coords))
        }

        // apply next state and populate hash buffer
        for &acre, idx in plot {
            acre.currentState = acre.nextState
            hash_buf[idx] = u8(acre.currentState)
        }

        hash := hash.fnv64a(hash_buf[:])
        prev_min, exists := plot_history[hash]
        if exists {
            // we found our loop
            start = prev_min
            end = min
            break
        } else {
            plot_history[hash] = min
        }

        append(&scores, get_resource_value(plot, size))
    }

    target := start + ((999_999_999 - start) % (end - start))
    fmt.printf("%d\n%d\n", scores[9], scores[target])
}