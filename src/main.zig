const std = @import("std");
const utun = @import("./utun.zig");

pub fn main() !void {
    const fd = try utun.start("utun5");
    std.debug.print("return fd = {}\n", .{fd});
}