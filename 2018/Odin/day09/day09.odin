package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:container/queue"

marble_game :: proc(players: int, marbles: int) -> i64 {
    scores := make([]i64, players, context.temp_allocator)
    circle: queue.Queue(int)
    queue.init(&circle)
    defer queue.destroy(&circle)

    queue.push_back(&circle, 0)

    p_curr := 0 // whose turn it is
    marble := 1 // value of the marble to place
    for marble <= marbles {
        if marble % 23 == 0 {
            for _ in 0..<7 {
                m := queue.pop_back(&circle)
                queue.push_front(&circle, m)
            }
            scores[p_curr] += i64(marble + queue.pop_front(&circle))
        } else {
            for _ in 0..<2 {
                m := queue.pop_front(&circle)
                queue.push_back(&circle, m)
            }
            queue.push_front(&circle, marble)
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

    fmt.printf("%d\n%d\n", marble_game(players, marbles), marble_game(players, marbles * 100))
}