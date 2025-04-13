const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var token_iter = std.mem.tokenize(u8, input, " \n\t");

    var left = std.ArrayList(i32).init(std.heap.page_allocator);
    var right = std.ArrayList(i32).init(std.heap.page_allocator);

    defer left.deinit();
    defer right.deinit();

    var arr: u1 = 0;
    while (token_iter.next()) |token| {
        const value = try std.fmt.parseInt(i32, token, 10);

        if (arr == 0) {
            try left.append(value);
        } else {
            try right.append(value);
        }

        arr = 1 - arr;
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var dist: u64 = 0;
    for (left.items, right.items) |l, r| {
        dist += @abs(l - r);
    }

    std.debug.print("{d}\n", .{dist});
}
