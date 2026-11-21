package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Scanner :: struct {
    dir: int,
    pos: int,
}

main :: proc() {
    input, read_err := os.read_entire_file("input.txt", context.temp_allocator)
    if read_err != nil do return

    lines := strings.split_lines(strings.trim_space(string(input)), context.temp_allocator)

    layers, _ := strconv.parse_int(strings.split(lines[len(lines) - 1], ":")[0])
    layers += 1

    firewall := make([]int, layers, context.temp_allocator)
    scanners := make([]Scanner, layers, context.temp_allocator)
    for line in lines {
        layer, _ := strings.split(line, ": ", context.temp_allocator)
        depth, _ := strconv.parse_int(layer[0])
        range, _ := strconv.parse_int(layer[1])
        firewall[depth] = range
        scanners[depth] = {1, 0}
    }

    picoseconds := 0
    current_layer := 0
    severity := 0
    for current_layer < layers {
        if scanners[current_layer].pos == 0 {
            severity += (current_layer * firewall[current_layer])
        }

        for &scanner, i in scanners {
            scanner.pos += scanner.dir

            if scanner.pos == 0 || scanner.pos == firewall[i] - 1 {
                scanner.dir *= -1
            }
        }

        current_layer += 1
        picoseconds += 1
    }

    fmt.println(severity)
}