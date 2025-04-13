const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var diffs: std.ArrayList(i8) = undefined;

    var safe: u16 = 0;
    var iter = std.mem.tokenize(u8, input, "\n");
    while (iter.next()) |token| {
        diffs = std.ArrayList(i8).init(std.heap.page_allocator);
        var line = std.mem.split(u8, token, " ");
        while (line.next()) |x| {
            const level = try std.fmt.parseInt(i8, x, 10);

            const y = line.peek();
            if (y != null) {
                const next = try std.fmt.parseInt(i8, y.?, 10);
                try diffs.append(next - level);
            }
        }

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

        if (is_safe) {
            safe += 1;
        }

        diffs.deinit();
    }
    std.debug.print("{d}\n", .{safe});
}
