const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var token_iter = std.mem.tokenize(u8, input, " \n\t");

    var left = std.ArrayList(u32).init(std.heap.page_allocator);
    var right = std.ArrayList(u32).init(std.heap.page_allocator);

    defer left.deinit();
    defer right.deinit();

    var arr: u1 = 0;
    while (token_iter.next()) |token| {
        const value = try std.fmt.parseInt(u32, token, 10);

        if (arr == 0) {
            try left.append(value);
        } else {
            try right.append(value);
        }

        arr = 1 - arr;
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
