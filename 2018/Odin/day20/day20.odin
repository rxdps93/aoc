package main

import "core:fmt"
import "core:os"
import "core:strings"

TEST_REGEX :: []string{
    "^WNE$", // 3
    "^ENWWW(NEEE|SSE(EE|N))$", // 10
    "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$", // 18
    "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$", // 23
    "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$", // 31
}

Vector :: [2]int

get_direction_vector :: proc(dir: rune) -> Vector {
    switch dir {
        case 'N': return Vector{ 0,  1 }
        case 'S': return Vector{ 0, -1 }
        case 'E': return Vector{ 1,  0 }
        case 'W': return Vector{-1,  0 }
        case: return Vector {0, 0}
    }
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    regex := strings.trim_space(string(input))

    distances := make(map[Vector]int, context.temp_allocator)
    position := Vector{0, 0}
    distances[position] = 0

    branches := make([dynamic]Vector, context.temp_allocator)

    for r in regex {
        dir := get_direction_vector(r)

        if dir == {0, 0} {
            if r == '(' { // push
                append(&branches, position)
            } else if r == ')' { // pop
                pop(&branches)
            } else if r == '|' { // try other option from head
                position = branches[len(branches) - 1]
            }
        } else {
            prev_dist := distances[position]
            position += dir
            dist, ok := distances[position]
            if ok {
                // already visited, check if new dist is lower
                distances[position] = min(dist, prev_dist + 1)
            } else {
                // new room
                distances[position] = prev_dist + 1
            }
        }
    }

    doors := min(int)
    thou := 0
    for coord, dist in distances {
        doors = max(doors, dist)
        if dist >= 1000 do thou += 1
    }
    fmt.printf("%d\n%d\n", doors, thou)
}