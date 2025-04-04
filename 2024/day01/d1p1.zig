const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    var stream = reader.reader();

    var buffer: [1024]u8 = undefined;
    var left = std.ArrayList(i32).init(std.heap.page_allocator);
    var right = std.ArrayList(i32).init(std.heap.page_allocator);

    defer left.deinit();
    defer right.deinit();

    while (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var iter = std.mem.split(u8, line, "   ");
        while (iter.next()) |x| {
            const value = try std.fmt.parseInt(i32, x, 10);

            if (left.items.len == right.items.len) {
                try left.append(value);
            } else {
                try right.append(value);
            }
        }
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var dist: u64 = 0;
    for (left.items, right.items) |l, r| {
        dist += @abs(l - r);
    }

    std.debug.print("{d}\n", .{dist});
}
