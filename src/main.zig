const std = @import("std");
const net = std.net;

const tun = @import("tun.zig");

pub fn main() !void {
    const options = tun.Options{.name = "utun8"};
    const deviceServer = try tun.DeviceServer.init(options);
    std.debug.print("the utun name = {s} and fd = {?}", .{deviceServer.name, deviceServer.sockfd.?});

    // deviceServer.up();

    const conn = net.StreamServer.Connection{
        .stream = net.Stream{ .handle = deviceServer.sockfd },
    };

    var buf: [1024]u8 = undefined;
    try conn.stream.reader().read(&buf);

    // todo : read bytes from device
    while(true) {
        std.debug.print("", .{});
    }
}

// 11:50 continue