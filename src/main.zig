const std = @import("std");
const net = std.net;

const tun = @import("tun.zig");

pub fn main() !void {
    const options = tun.Options{.name = "utun8"};
    const deviceServer = try tun.DeviceServer.init(options);
    std.debug.print("the utun name = {s} and fd = {?}", .{deviceServer.name, deviceServer.sockfd.?});

    deviceServer.up();

    // todo : read bytes from device
    while(true) {
        std.debug.print("", .{});
    }
}

// 11:50 continue