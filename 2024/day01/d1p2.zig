const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    var stream = reader.reader();

    var buffer: [1024]u8 = undefined;
    var left = std.ArrayList(u32).init(std.heap.page_allocator);
    var right = std.ArrayList(u32).init(std.heap.page_allocator);

    defer left.deinit();
    defer right.deinit();

    while (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var iter = std.mem.split(u8, line, "   ");
        while (iter.next()) |x| {
            const value = try std.fmt.parseInt(u32, x, 10);

            if (left.items.len == right.items.len) {
                try left.append(value);
            } else {
                try right.append(value);
            }
        }
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    var sim_score: u32 = 0;
    for (left.items) |l| {
        var freq: u16 = 0;
        for (right.items) |r| {
            if (r == l) {
                freq += 1;
            }
        }

        sim_score += l * freq;
    }

    std.debug.print("{d}\n", .{sim_score});
}
