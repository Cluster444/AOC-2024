const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const galloc = gpa.allocator();

    const filename = "input.txt";
    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try galloc.alloc(u8, file_size);
    defer galloc.free(buffer);

    const NumberList = std.ArrayList(u32);
    var left_list = try NumberList.initCapacity(galloc, 1024);
    defer left_list.deinit();
    var right_list = try NumberList.initCapacity(galloc, 1024);
    defer right_list.deinit();

    _ = try file.reader().readAll(buffer);

    var cursor = buffer;
    while (cursor.len > 13) : (cursor = cursor[14..]) {
        const left = cursor[0..5];
        const right = cursor[8..13];
        const left_num = try std.fmt.parseInt(u32, left, 10);
        const right_num = try std.fmt.parseInt(u32, right, 10);
        try left_list.append(left_num);
        try right_list.append(right_num);
    }

    std.mem.sort(u32, left_list.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right_list.items, {}, std.sort.asc(u32));

    var sum: u64 = 0;
    for (left_list.items, right_list.items) |left, right| {
        if (left > right) {
            sum += left - right;
        } else {
            sum += right - left;
        }
    }

    const len = left_list.items.len;
    var last_left_number: u32 = 0;
    var right_cursor: u32 = 0;
    var sim_score: u32 = 0;
    for (left_list.items) |left| {
        if (left == last_left_number) {
            continue;
        }
        last_left_number = left;

        var count: u32 = 0;
        while (right_cursor < len and right_list.items[right_cursor] < left) : (right_cursor += 1) {}
        while (right_cursor < len and right_list.items[right_cursor] == left) : (right_cursor += 1) {
            count += 1;
        }

        sim_score += left * count;
    }

    std.debug.assert(sum == 1580061);
    std.debug.assert(sim_score == 23046913);

    try stdout.print("SUM: {}\n", .{sum});
    try stdout.print("SIM: {}\n", .{sim_score});
}
