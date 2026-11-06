package main

import "core:fmt"
import "core:os"

// if x == 2 && y > -2 we are on the right ***
// if y == 2 we are on the top side
// if x == -2 we are on the left side
// otherwise we must be on the bottom side
// by figuring out the side we can "walk" a certain number of squares
// for the right side we simply walk up the y coords from the start of the region
// for the top side we walk left the x coords up to the max dist (side)
// for the left side we walk down the y coords 2*side is an offset since the right and top are side length
// so we go down by the y coord from that point
// for the bottom we walk right, once again using side for an offset but *3 this time
// and we move by the x coord
/*
    * 17 16 15 14 13
    * 18 05 04 03 12
    * 19 06 01 02 11
    * 20 07 08 09 10
    * 21 22 23 24 25
    */
coord_to_square :: proc(x, y: int) -> int {
    region := max(abs(x), abs(y))
    if region == 0 do return 1

    prev_max := 2 * region - 1
    prev_max *= prev_max
    side := 2 * region

    // start + offset + x/y position
    // start is the max from the previous region
    // offset is how many sides past the start we are
    // e.g. right is the first side so its essentially 0 * side
    //      but bottom is the final side so 3 * side since we've walked 3 sides
    // x/y position is region +/- x or y to find where on the side we are
    if x == region && y > -region { // right
        return prev_max + (region + y)
    } else if y == region { // top
        return prev_max + side + (region - x)
    } else if x == -region { // right
        return prev_max + 2 * side + (region - y)
    } else { // bottom
        return prev_max + 3 * side + (region + x)
    }
}

square_to_coord :: proc(sq: int) -> (x, y: int) {
    if sq == 1 do return 0, 0

    // first figure out which region we are in
    // probably need prev_max again
    // we'll need side for the offset
    // and we'll need a way to represent where on the side we are
    //    (this was region +/- x or y, not sure for this one yet)

    // same pattern if left/top/right/side return based on
    // formula of start/offset/side-local-pos
    // but the formula will probably differ a bit?

    return 0, 0
}

// manhattan distance helper
dist :: proc(a, b: [2]int) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

// extra dist helper just in case
dist_sq :: proc(a, b: int) -> int {
    ax, ay := square_to_coord(a)
    bx, by := square_to_coord(b)
    return dist({ax, ay}, {bx, by})
}

main :: proc() {
    /*
     * reasoning through how to do this:
     *
     * a grid-based spiral inherently forms odd number squares around the origin:
     * 3x3, 5x5, 7x7, etc.
     * the numbers that specific layer contains seem related to the size of the square:
     * 3x3 contains 2 through 9, 3x3=9
     * 5x5 contains 10 through 25, 5x5=25
     * 7x7 presumably contains 26 through 49, 7x7=49
     * thus if I create a coordinate system where square 1 is 0,0
     * we can translate square # to coords
     * the 3x3 region goes from x=-1..1 y=-1..1
     * this becomes 3 by multiplying abs(x) or abs(y) by 2 and adding 1
     * e.g. abs(-1) * 2 = 2 + 1 = 3 then squaring it 3*3 = 9 and we know that our coords
     * is in the square that goes up to 9.
     * lets use coordinates somewhere within the 5x5 square (meaning origin out to 5x5):
     * x=2, y = -1 should be square #10, lets try and get there
     * using the y coord will miss anything outside of the 3x3 group since the x coord is bigger
     * thus we must always use the max: max(abs(x), abs(y)) = 2
     * 2 * 2 + 1 = 5 thus we are in the 5x5 region which ranges from 1 to 25
     * we now know that we are somewhere in that outer ring from 10..25
     * if we figure out which side we are on (top, bottom, left right) we can work out the square #
     * ...somehow
     */
    fmt.println(coord_to_square(-2, -1))
}