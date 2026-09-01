package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"

Vector :: [2]int

Direction :: enum {
    LEFT = 0,
    STRAIGHT = 1,
    RIGHT = 2,
}

Cart :: struct {
    coords: Vector,
    heading: Vector,
    turn: Direction,
    crashed: bool,
}

get_new_heading :: proc {
    get_new_heading_curve,
    get_new_heading_intersection,
}

symbol_to_heading :: proc(symbol: rune) -> (heading: Vector) {
    switch (symbol) {
        case '>':
            return {1, 0}
        case '<':
            return {-1, 0}
        case 'v':
            return {0, 1}
        case '^':
            return {0, -1}
    }
    return {0, 0}
}



get_new_heading_curve :: proc(current: Vector, track: rune) -> (new_heading: Vector) {
    switch (current) {
        case {1, 0}:    // going right
            return track == '/' ? {0, -1} : {0, 1}
        case {-1, 0}:   // going left
            return track == '/' ? {0, 1} : {0, -1}
        case {0, 1}:    // going down
            return track == '/' ? {-1, 0} : {1, 0}
        case {0, -1}:   // going up
            return track == '/' ? {1, 0} : {-1, 0}
    }

    return current
}

get_new_heading_intersection :: proc(current: Vector, turn: Direction) -> (new_heading: Vector) {
    if turn == .LEFT do return {current.y, -current.x}
    if turn == .RIGHT do return {-current.y, current.x}
    return current
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    track := make(map[Vector]rune, context.temp_allocator)
    carts := make([dynamic]Cart, context.temp_allocator)

    lines := strings.split_lines(string(input))
    for line, y in lines {
        for r, x in line {
            switch (r) {
                case '>', '<', '^', 'v':
                    append(&carts, Cart{{x, y}, symbol_to_heading(r), Direction.LEFT, false})
                    if r == '>' || r == '<' do track[{x, y}] = '-'
                    if r == '^' || r == 'v' do track[{x, y}] = '|'
                case '|', '-', '/', '\\', '+':
                    track[{x, y}] = r
            }
        }
    }

    active_carts := len(carts)
    first_crash := Vector{-1, -1}
    for active_carts > 1 {
        slice.sort_by(carts[:], proc(a, b: Cart) -> bool {
            if a.coords.y == b.coords.y do return a.coords.x < b.coords.x
            return a.coords.y < b.coords.y
        })

        for &cart, i in carts {
            /*
             * > check if crashed, if so continue. otherwise:
             * > add heading to coords
             * > check for crash:
             * > if crash:
             *      > mark both as crashed
             *      > continue
             * > if no crash:
             *      > if ending on a curve (/ or \):
             *          > update heading accordingly
             *      > else if ending on an intersection (+):
             *          > update heading based on turn
             *          > increment turn to next in list
             */
            if cart.crashed do continue

            cart.coords += cart.heading
            for &other, j in carts {
                if i == j || other.crashed do continue
                if cart.coords == other.coords {
                    cart.crashed = true
                    other.crashed = true
                    active_carts -= 2

                    if first_crash == {-1, -1} do first_crash = cart.coords

                    break
                }
            }

            if cart.crashed do continue

            if track[cart.coords] == '/' || track[cart.coords] == '\\' {
                cart.heading = get_new_heading(cart.heading, track[cart.coords])
            } else if track[cart.coords] == '+' {
                cart.heading = get_new_heading(cart.heading, cart.turn)
                cart.turn = cast(Direction)((cast(int)cart.turn + 1) % len(Direction))
            }
        }
    }

    fmt.printf("The first crash is at %d,%d\n", first_crash.x, first_crash.y)
}