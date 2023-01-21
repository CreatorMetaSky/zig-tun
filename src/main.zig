const std = @import("std");
const utun = @import("./utun.zig");

pub fn main() !void {
    const fd = try utun.start("utun8");
    std.debug.print("return fd = {}\n", .{fd});

    // todo : read bytes from device
    while(true) {
        std.debug.print("", .{});
    }
}