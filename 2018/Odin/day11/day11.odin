package main

import "core:fmt"

SERIAL_INPUT :: 9810
SERIAL_TEST1 :: 18
SERIAL_TEST2 :: 42

calculate_power_level :: proc(x, y, serial: int) -> int {
    return ((((((x + 10) * y) + serial) * (x + 10)) / 100) % 10) - 5
}

find_best_block :: proc(sat: [dynamic]int, size, serial: int) -> (top_left_x, top_left_y, block_power: int) {

    max_pwr, max_tlx, max_tly := min(int), -1, -1
    for tly in 0..<300 - (size - 1) {
        for tlx in 0..<300 - (size - 1) {
            tl := (tlx > 0 && tly > 0) ? sat[(tly - 1) * 300 + (tlx - 1)] : 0 // x1 - 1, y1 - 1
            br := sat[(tly + (size - 1)) * 300 + (tlx + (size - 1))] // x2, y2
            tr := tly > 0 ? sat[(tly - 1) * 300 + (tlx + (size - 1))] : 0 // x2, y1 - 1
            bl := tlx > 0 ? sat[(tly + (size - 1)) * 300 + (tlx - 1)] : 0 // x1 - 1, y2
            //tl + br - tr - bl
            pwr := tl + br - tr - bl

            if pwr > max_pwr {
                max_pwr = pwr
                max_tlx = tlx + 1
                max_tly = tly + 1
            }
        }
    }
    
    return max_tlx, max_tly, max_pwr
}

calculate_summed_area_table :: proc(sat: ^[dynamic]int, serial: int) {
    // x, y = (y * 300) + x assuming x,y in 0..299
    for y in 0..<300 {
        for x in 0..<300 {
            sat[y * 300 + x] = calculate_power_level(x + 1, y + 1, serial)
        }
    }

    for y in 0..<300 {
        for x in 0..<300 {
            a := sat[y * 300 + x]
            b := y > 0 ? sat[(y - 1) * 300 + x] : 0
            c := x > 0 ? sat[y * 300 + (x - 1)] : 0
            d := x > 0 && y > 0 ? sat[(y - 1) * 300 + (x - 1)] : 0
            sat[y * 300 + x] = a + b + c - d
        }
    }
}

main :: proc() {
    serial := SERIAL_INPUT
    sat := make([dynamic]int, 300 * 300)
    defer delete(sat)
    calculate_summed_area_table(&sat, serial)

    tlx, tly, pwr := find_best_block(sat, 3, serial)
    fmt.printf("%d,%d (power=%d)\n", tlx, tly, pwr)

    max_tlx, max_tly, max_size, max_pwr := -1, -1, 0, min(int)
    for size in 1..=300 {
        tlx, tly, pwr = find_best_block(sat, size, serial)

        if pwr > max_pwr {
            max_tlx = tlx
            max_tly = tly
            max_size = size
            max_pwr = pwr
        }
    }

    fmt.printf("%d,%d,%d (power=%d)\n", max_tlx, max_tly, max_size, max_pwr)
}