package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:container/queue"

Vector :: [2]int

Battlefield :: struct {
    width: int,
    height: int,
    data: []bool,
    init_elf_count: int,
    init_gob_count: int
}

Unit :: struct {
    coords: Vector,
    isElf: bool,
    hp: int,
    ap: int,
}

get_attack_target :: proc(occupancy: []^Unit, attacker: Unit, bf: Battlefield) -> (target: ^Unit) {
    adj := make([dynamic]^Unit, context.temp_allocator)
    offsets :: [4]Vector{{0, -1}, {-1, 0}, {1, 0}, {0, 1}}

    for offset in offsets {
        pos := attacker.coords + offset
        idx := pos.y * bf.width + pos.x

        target := occupancy[idx]

        if target != nil && target.hp > 0 && target.isElf != attacker.isElf do append(&adj, target)
    }

    if len(adj) == 0 do return nil
    if len(adj) == 1 do return adj[0]

    // sort by hp and then reading order
    slice.sort_by(adj[:], proc(a, b: ^Unit) -> bool {
        if a.hp == b.hp {
            if a.coords.y == b.coords.y do return a.coords.x < b.coords.x
            return a.coords.y < b.coords.y
        }
        return a.hp < b.hp
    })

    return adj[0]
}

get_valid_destinations :: proc(destinations: ^[dynamic]Vector, occupancy: []^Unit, units: []Unit, attacker: Unit, bf: Battlefield) {
    offsets :: [4]Vector{{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
    for &enemy in units {
        if enemy.hp <= 0 || enemy.isElf == attacker.isElf do continue

        for offset in offsets {
            pos := enemy.coords + offset
            idx := pos.y * bf.width + pos.x

            if bf.data[idx] && occupancy[idx] == nil {
                append(destinations, pos)
            }
        }
    }
}

find_occupied_tiles :: proc(occupancy: []^Unit, units: []Unit, bf: Battlefield) {
    for &u in units {
        if u.hp <= 0 do continue
        idx := u.coords.y * bf.width + u.coords.x
        occupancy[idx] = &u
    }
}

get_move_target :: proc(bf: Battlefield, occupancy: []^Unit, start: Vector, end_tiles: []Vector) -> (dest: Vector) {
    Tile :: struct{first_step: Vector, coords: Vector, dist: int}
    q: queue.Queue(Tile)
    queue.init(&q, allocator = context.temp_allocator)

    visited := make(map[Vector]struct{}, context.temp_allocator)
    offsets :: [4]Vector{{0, -1}, {-1, 0}, {1, 0}, {0, 1}}

    visited[start] = {}
    queue.push_back(&q, Tile{{}, start, 0})

    shortest_tiles := make([dynamic]Tile, context.temp_allocator)

    shortest_dist := max(int)
    for queue.len(q) > 0 {
        current := queue.pop_front(&q)

        if current.dist > shortest_dist do break

        if slice.contains(end_tiles, current.coords) && current.dist <= shortest_dist {
            shortest_dist = current.dist
            append(&shortest_tiles, current)
        }

        for offset in offsets {
            next := current.coords + offset

            idx := next.y * bf.width + next.x
            if !(next in visited) && bf.data[idx] && occupancy[idx] == nil && current.dist + 1 <= shortest_dist {
                visited[next] = {}
                queue.push_back(&q, Tile{current.coords == start ? next : current.first_step, next, current.dist + 1})
            }
        }
    }

    if len(shortest_tiles) == 0 do return { -1, -1 }

    if len(shortest_tiles) > 1 {
        slice.sort_by(shortest_tiles[:], proc(a, b: Tile) -> bool {
            if a.coords.y == b.coords.y do return a.coords.x < b.coords.x
            return a.coords.y < b.coords.y
        })
    }

    return shortest_tiles[0].first_step
}

simulate_combat :: proc(bf: Battlefield, initial_units: []Unit, elf_ap: int = 3) -> (outcome: int, remaining_elves: int) {
    units := slice.clone_to_dynamic(initial_units, allocator = context.temp_allocator)
    round := 0
    elf_count := bf.init_elf_count
    gob_count := bf.init_gob_count
    main_loop: for elf_count > 0 && gob_count > 0 {
        slice.sort_by(units[:], proc(a, b: Unit) -> bool {
            if a.coords.y == b.coords.y do return a.coords.x < b.coords.x
            return a.coords.y < b.coords.y
        })

        for &unit, i in units {
            if unit.hp <= 0 do continue

            has_targets := false
            for u in units {
                if u.hp > 0 && u.isElf != unit.isElf {
                    has_targets = true
                    break
                }
            }
            if !has_targets do break main_loop

            // map out where units are
            occupancy := make([]^Unit, bf.width * bf.height, context.temp_allocator)
            find_occupied_tiles(occupancy, units[:], bf)

            target := get_attack_target(occupancy, unit, bf)

            if target == nil {

                dests := make([dynamic]Vector, context.temp_allocator)
                get_valid_destinations(&dests, occupancy, units[:], unit, bf)

                move_step := get_move_target(bf, occupancy, unit.coords, dests[:])

                // valid move found, make the change
                if move_step != { -1, -1 } {
                    unit.coords = move_step
                    slice.zero(occupancy)
                    find_occupied_tiles(occupancy, units[:], bf)
                    target = get_attack_target(occupancy, unit, bf)
                }
                
                if target == nil do continue
            }

            if unit.isElf {
                target.hp -= elf_ap
            } else {
                target.hp -= unit.ap
            }
        }

        for i := len(units) - 1; i >= 0; i -= 1 {
            if units[i].hp <= 0 {
                if units[i].isElf {
                    elf_count -= 1
                } else {
                    gob_count -= 1
                }

                unordered_remove(&units, i)
            }
        }

        round += 1
    }

    hp_sum := 0
    for unit in units do if unit.hp > 0 do hp_sum += unit.hp

    return round * hp_sum, elf_count
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return
    defer delete(input)

    lines, _ := strings.split_lines(string(input))
    defer delete(lines)

    bf := Battlefield{ len(lines[0]), len(lines), make([]bool, len(lines[0]) * len(lines)), 0, 0}
    defer delete(bf.data)

    initial_units := make([dynamic]Unit)
    defer delete(initial_units)

    elf_count := 0
    gob_count := 0
    for line, y in lines {
        for r, x in line {
            switch (r) {
                case '#', '.':
                    bf.data[y * bf.width + x] = r == '.'
                case 'E', 'G':
                    if r == 'E' do elf_count += 1
                    if r == 'G' do gob_count += 1
                    append(&initial_units, Unit{{x, y}, r == 'E', 200, 3})
                    bf.data[y * bf.width + x] = true
            }
        }
    }
    bf.init_elf_count = elf_count
    bf.init_gob_count = gob_count

    outcome, elves_remaining := simulate_combat(bf, initial_units[:])
    fmt.println(outcome)

    elf_ap := 4
    for elves_remaining < bf.init_elf_count {
        outcome, elves_remaining = simulate_combat(bf, initial_units[:], elf_ap)
        elf_ap += 1
    }
    fmt.println(outcome)
}