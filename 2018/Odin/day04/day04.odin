package main

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:time"
import "core:time/datetime"
import "core:slice"
import "core:text/regex"

parse_datetime :: proc(line: string) -> datetime.DateTime {
    ts := strings.cut(line, 1, 16)
    year, _ := strconv.parse_i64(ts[0:4])
    month, _ := strconv.parse_int(ts[5:7])
    day, _ := strconv.parse_int(ts[8:10])
    hour, _ := strconv.parse_int(ts[12:14])
    minute, _ := strconv.parse_int(ts[14:16])

    return datetime.DateTime {
        year = year,
        month = i8(month),
        day = i8(day),
        hour = i8(hour),
        minute = i8(minute),
    }
}

sort_datetime :: proc(a, b: string) -> bool {
    dta := parse_datetime(a)
    dtb := parse_datetime(b)

    if dta.year < dtb.year      do return dta.year < dtb.year
    if dta.month != dtb.month   do return dta.month < dtb.month
    if dta.day != dtb.day       do return dta.day < dtb.day
    if dta.hour != dtb.hour     do return dta.hour < dtb.hour

    return dta.minute < dtb.minute
}

minute_diff :: proc(start, end: datetime.DateTime) -> int {
    ta, _ := time.components_to_time(2000, int(start.month), int(start.day), int(start.hour), int(start.minute), 0)
    tb, _ := time.components_to_time(2000, int(end.month), int(end.day), int(end.hour), int(end.minute), 0)

    return int(time.duration_minutes(time.diff(ta, tb)))
}

parse_input :: proc(data: string) -> (map[int]int, map[int][60]int) {
    lines := strings.split_lines(data, context.allocator)
    defer delete(lines)

    log := make(map[int]int)
    defer delete(log)

    freq := make(map[int][60]int)
    defer delete(freq)

    slice.sort_by(lines[:], sort_datetime)

    id_pattern := `\#(\d+)`
    reg, _ := regex.create(id_pattern)
    defer regex.destroy(reg)

    // calculate minutes asleep per guard
    active_id := -1
    sleeping := false
    start: datetime.DateTime
    for line in lines {
        c, m := regex.match(reg, line)

        if m {
            active_id, _ = strconv.parse_int(c.groups[1])
            sleeping = false
            start = {}
        } else if strings.contains(line, "asleep") {
            sleeping = true
            start = parse_datetime(line)
        } else {
            sleeping = false
        }

        if !sleeping && start != {} {
            asleep_for := minute_diff(start, parse_datetime(line))
            log[active_id] += asleep_for

            if !(active_id in freq) do freq[active_id] = [60]int{}
            ptr := &freq[active_id]

            sm := int(start.minute)
            for m in 0..<asleep_for {
                idx := sm + m

                if idx == 60 do idx = 0

                ptr[idx] += 1
            }
        }
    }
    return log, freq
}

d4p1 :: proc(data: string) -> int {
    
    log, freq := parse_input(data)

    // get sleepiest guard's id
    max := -1
    max_id := -1
    for k,v in log {
        if v > max {
            max = v
            max_id = k
        }
    }

    // get minute he slept most on
    max_minute, _ := slice.max_index((&freq[max_id])[:])

    return max_id * max_minute
}

d4p2 :: proc(data: string) -> int {
    log, freq := parse_input(data)

    max := -1
    max_id := -1
    max_times := -1
    for k,v in freq {
        arr := v
        max_minute, _ := slice.max_index(arr[:])
        if arr[max_minute] > max_times {
            max = max_minute
            max_id = k
            max_times = arr[max_minute]
        }
    }

    return max_id * max
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.allocator)
    if err != nil do return

    defer delete(input, context.allocator)

    data := string(input)
    fmt.printf("%d\n%d\n", d4p1(data), d4p2(data))
}