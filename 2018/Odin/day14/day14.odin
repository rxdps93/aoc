package main

import "core:fmt"
import "core:slice"

PUZZLE_INPUT :: 513401

check_sequence :: proc(sb: [dynamic]int, seq: [dynamic]int) -> int {
    if len(sb) < len(seq) do return -1

    tail := sb[len(sb) - len(seq):]
    if slice.equal(tail, seq[:]) do return len(sb) - len(seq)
    return -1
}

main :: proc() {
    scoreboard: [dynamic]int
    defer delete(scoreboard)
    append(&scoreboard, 3, 7)
    sequence := make([dynamic]int)
    defer delete(sequence)
    for d in fmt.tprintf("%d", PUZZLE_INPUT) do append(&sequence, int(d) - int('0'))

    elf_rec_a := 0
    elf_rec_b := 1
    seq_idx := -1
    for seq_idx == -1 {
        new_score := scoreboard[elf_rec_a] + scoreboard[elf_rec_b]

        if new_score < 10 {
            append(&scoreboard, new_score)

            seq_idx = check_sequence(scoreboard, sequence)
        } else {
            tens := new_score / 10
            ones := new_score % 10

            append(&scoreboard, tens)
            seq_idx = check_sequence(scoreboard, sequence)

            if seq_idx != -1 do break

            append(&scoreboard, ones)
            seq_idx = check_sequence(scoreboard, sequence)
        }

        elf_rec_a = (elf_rec_a + scoreboard[elf_rec_a] + 1) % len(scoreboard)
        elf_rec_b = (elf_rec_b + scoreboard[elf_rec_b] + 1) % len(scoreboard)
    }

    for i in 0..<10 do fmt.printf("%d", scoreboard[PUZZLE_INPUT + i])
    fmt.println()
    fmt.println(seq_idx)
}