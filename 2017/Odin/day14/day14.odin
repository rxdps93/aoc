package main

import "core:fmt"
import "core:os"
import "core:strings"

vecs :: [4][2]int {
    { 1,  0 },
    { 0,  1 },
    {-1,  0 },
    { 0, -1 },
}

build_hash_key :: proc(key_string: string, row: int) -> (hash_key: string, ok: bool) {
    if row < 0 || row > 127 do return "", false
    return fmt.tprintf("%s-%d", key_string, row), true
}

hex_to_bits :: proc(hash: [16]int) -> [128]u8 {
    bits: [128]u8
    for val, i in hash {
        for idx in 0..<8 {
            bit := (val >> u32(7 - idx)) & 1 // go most to least significant
            bits[i * 8 + idx] = u8(bit)
        }
    }

    return bits
}

fill_region :: proc(disk: ^[128][128]u8, coords: [2]int) {
    if coords.y < 0 || coords.y > 127 ||
        coords.x < 0 || coords.x > 127 {
            return
    }

    if disk[coords.y][coords.x] == 0 do return

    disk[coords.y][coords.x] = 0

    for vec in vecs {
        fill_region(disk, coords + vec)
    }
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    key_str := strings.trim_space(string(input))

    disk: [128][128]u8
    used := 0
    for row in 0..<128 {
        hash_key, _ := build_hash_key(key_str, row)
        hash := calculate_knot_hash(hash_key)
        disk[row] = hex_to_bits(hash)

        for bit in disk[row] {
            if bit == u8(1) do used += 1
        }
    }

    fmt.println(used)

    regions := 0
    for y in 0..<128 {
        for x in 0..<128 {
            if disk[y][x] == 1 {
                regions += 1
                fill_region(&disk, {x, y})
            }
        }
    }

    fmt.println(regions)
}