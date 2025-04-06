const std = @import("std");

fn line_ctoi(line: []u8) ![]i8 {
    var iline = std.ArrayList(i8).init(std.heap.page_allocator);

    var iter = std.mem.split(u8, line, " ");
    while (iter.next()) |x| {
        const val = try std.fmt.parseInt(i8, x, 10);
        try iline.append(val);
    }

    return iline.toOwnedSlice();
}

fn calculate_diffs(list: *std.ArrayList(i8), line: []i8) !void {
    for (0..line.len) |i| {
        if (i < line.len - 1) {
            try list.append(line[i + 1] - line[i]);
        }
    }
}

fn check_record_safety(line: []i8) !bool {
    var diffs: std.ArrayList(i8) = std.ArrayList(i8).init(std.heap.page_allocator);

    try calculate_diffs(&diffs, line);

    var dir: i8 = 0;
    var is_safe = true;
    for (diffs.items) |d| {
        if (@abs(d) < 1 or @abs(d) > 3) {
            is_safe = false;
            break;
        }

        if (d < 0) {
            dir -= 1;
        } else if (d > 0) {
            dir += 1;
        }
    }

    is_safe = (@abs(dir) == diffs.items.len);
    diffs.deinit();

    return is_safe;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    var stream = reader.reader();

    var buffer: [1024]u8 = undefined;
    var safe: u16 = 0;
    while (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const iline = try line_ctoi(line);

        if (try check_record_safety(iline)) {
            safe += 1;
        } else {
            var new_line: std.ArrayList(i8) = undefined;
            for (0..iline.len) |i| {
                new_line = std.ArrayList(i8).init(std.heap.page_allocator);
                try new_line.appendSlice(iline);
                _ = new_line.orderedRemove(i);

                if (try check_record_safety(new_line.items)) {
                    safe += 1;
                    break;
                }
            }
            new_line.deinit();
        }
    }

    std.debug.print("{d}\n", .{safe});
}
