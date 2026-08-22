package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/regex"
import "core:strconv"

Point :: struct {
    x: int,
    y: int,
    dx: int,
    dy: int,
}

area :: proc(x_min, y_min, x_max, y_max: int) -> int {
    return (y_max - y_min) * (x_max - x_min)
}

find_message :: proc(points: ^[dynamic]Point) {
    x_min, y_min, x_max, y_max: int
    seconds: int
    curr_area := max(int)
    prev_area := max(int)
    for seconds = 1; ; seconds += 1 {
        x_min, y_min, x_max, y_max = max(int), max(int), min(int), min(int)
        prev_area = curr_area
        for &p in points {
            p.x += p.dx
            p.y += p.dy
            
            if p.x < x_min do x_min = p.x
            if p.x > x_max do x_max = p.x
            if p.y < y_min do y_min = p.y
            if p.y > y_max do y_max = p.y
        }

        curr_area = area(x_min, y_min, x_max, y_max)
        
        if curr_area > prev_area do break
    }

    // revert to previous state
    x_min, y_min, x_max, y_max = max(int), max(int), min(int), min(int)
    for &p in points {
        p.x -= p.dx
        p.y -= p.dy
        
        if p.x < x_min do x_min = p.x
        if p.x > x_max do x_max = p.x
        if p.y < y_min do y_min = p.y
        if p.y > y_max do y_max = p.y
    }

    fmt.printf("Messages appears at %d second(s)\n\n", seconds - 1)
    for y in y_min..=y_max {
        for x in x_min..=x_max {
            pt := false
            for p in points {
                if p.x == x && p.y == y {
                    pt = true
                    break
                }
            }
            fmt.printf("%c", pt ? '#' : '.')
        }
        fmt.println()
    }
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    pattern := `position=<\s*(-?\d+),\s*(-?\d+)>\s*velocity=<\s*(-?\d+),\s*(-?\d+)>`
    reg, _ := regex.create(pattern)
    defer regex.destroy(reg)

    points := make([dynamic]Point, context.temp_allocator)

    lines := string(input)
    for line in strings.split_lines_iterator(&lines) {
        c, m := regex.match(reg, line)
        
        if m {
            x, _ := strconv.parse_int(c.groups[1])
            y, _ := strconv.parse_int(c.groups[2])
            dx, _ := strconv.parse_int(c.groups[3])
            dy, _ := strconv.parse_int(c.groups[4])
            append(&points, Point{x, y, dx, dy})
        } else {
            fmt.println("oops no matches")
            return
        }
    }

    find_message(&points)
}