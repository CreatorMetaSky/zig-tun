const std = @import("std");
const net = std.net;

const tun = @import("tun.zig");

pub fn main() !void {
    const options = tun.Options{.name = "utun8"};
    const deviceServer = try tun.DeviceServer.init(options);
    std.debug.print("the utun name = {s} and fd = {?}", .{deviceServer.name, deviceServer.sockfd});
    // deviceServer.up();

    const stream = net.Stream{ .handle = deviceServer.sockfd };

    var buf: [1024]u8 = undefined;
    // todo : read bytes from device
    while(true) {
        const size = try stream.reader().read(&buf);
        std.debug.print("the read buffer size = {}", .{size});
    }
}

// 11:50 continue