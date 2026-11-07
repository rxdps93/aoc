package main

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"
import "core:strconv"

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

    // to figure out region we'll need to see if it lies between
    // the min and max values of the region e.g. 10 and 25 for 5x5
    // since the max value is size squared we will want to sqrt it
    // to get the "width" of the region the square # is in
    // since prev_max is (2*region+1)^2 we'll be reversing that and
    // since we already have sqrt we need to subtract 1 and divide by 2
    // giving us (sqrt(sq) - 1) / 2
    // thus region = (sqrt(sq) - 1) / 2
    // this causes everything to be 1 too low except the squares (e.g. 9 and 25)
    // which are fine so lets start by adding 1 to the result
    // now hte max values are 1 too high but everything else is good.
    // will experiment with subtracting 1 from sq
    // that seemed to work
    region := int((math.sqrt(f32(sq - 1)) - 1) / 2) + 1

    prev_max := 2 * region - 1
    prev_max *= prev_max
    side_pos := sq - prev_max
    side := 2 * region

    // same pattern if left/top/right/side return based on
    // formula of start/offset/side-local-pos
    // but the formula will probably differ a bit?
    // determine which side we're on with the same offset logic of something*side
    // each return will have either x or y be region or -region
    // and then the other coord will be based on our position along the side
    // and the sign will be based on which direction the spiral goes along that side
    if side_pos <= side { // right going up
        return region, -region + side_pos
    } else if side_pos <= 2 * side { // top going left
        return region - (side_pos - side), region
    } else if side_pos <= 3 * side { // left going down
        return -region, region - (side_pos - 2 * side)
    } else { // bottom going right
        return -region + (side_pos - 3 * side), -region
    }
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
    input, parse_err := os.read_entire_file("input.txt", context.temp_allocator)
    if parse_err != nil do return

    target_square, _ := strconv.parse_int(strings.trim_space(string(input)))

    fmt.println(dist_sq(1, target_square))

    sum := 0
    sq := 2
    mem := make(map[int]int, context.temp_allocator)
    mem[1] = 1
    vecs := [8][2]int{
        { 0,  1},   // up
        { 0, -1},   // down
        {-1,  0},   // left
        { 1,  0},   // right
        { 1,  1},   // up+right
        { 1, -1},   // up+left
        {-1,  1},   // down+right
        {-1, -1},   // down+left
    }
    for sum <= target_square {
        sum = 0
        x, y := square_to_coord(sq)
        for vec in vecs {
            s := coord_to_square(x + vec.x, y + vec.y)
            if s not_in mem do continue
            sum += mem[s]
        }
        mem[sq] = sum
        sq += 1
    }

    fmt.println(sum)
}

/*
 * as i figured this out i left my thought process in comments so i could refer
 * back to it as I usually only have short bursts of time in the evenings to work
 * on aoc. i will leave my thoughts in the file for the time being.
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