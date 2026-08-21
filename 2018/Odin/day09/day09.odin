package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

print_circle :: proc(circle: [dynamic]int, current: int, player: int = -1) {
    if player == -1 {
        fmt.printf("[-] ")
    } else {
        fmt.printf("[%d] ", player)
    }

    for m, idx in circle {
        if idx == current {
            fmt.printf("(%d)", m)
        } else {
            fmt.printf(" %d ", m)
        }
    }
    fmt.println()
}

slow_marble_game :: proc(players: int, marbles: int) -> i64 {
    scores := make([]i64, players, context.temp_allocator)
    circle := make([dynamic]int, context.temp_allocator)
    append(&circle, 0)

    p_curr := 0 // whose turn it is
    m_curr := 0 // idx of the current marble
    marble := 1 // value of the marble to place
    for marble <= marbles {
        if marble%23 == 0 {
            r_idx := (m_curr - 7) % len(circle)
            if r_idx < 0 do r_idx += len(circle)
            scores[p_curr] += i64(marble + circle[r_idx])

            ordered_remove_dynamic_array(&circle, r_idx)
            m_curr = r_idx
        } else {
            n_curr := m_curr + 2
            if n_curr == len(circle) {
                append(&circle, marble)
            } else {
                if n_curr > len(circle) do n_curr -= len(circle)

                inject_at(&circle, n_curr, marble)
            }
            m_curr = n_curr
        }

        marble += 1
        p_curr = (p_curr + 1) % players
    }

    max_score, ok := slice.max(scores[:])
    return max_score
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    data := strings.fields(string(input))
    players, p_ok := strconv.parse_int(strings.trim_space(data[0]))
    marbles, m_ok := strconv.parse_int(strings.trim_space(data[6]))

    if !p_ok && !m_ok do return
    
    delete(input)
    delete(data)

    // fmt.printf("%d\n%d\n", marble_game(players, marbles), marble_game(players, marbles * 100))
    fmt.printf("%d\n", slow_marble_game(players, marbles))
}