const std = @import("std");
const net = std.net;
const os = std.os;

const sys = @cImport({
    @cInclude("sys/socket.h");
    @cInclude("sys/kern_control.h");
    @cInclude("sys/ioctl.h");
});

// const impl = switch (builtin.target.os.tag) {
//     .linux => @import("./linux.zig"),
//     .macos => @import("./apple.zig"),
//     else => @compileError("OS not supported"),
// };

const SYSPROTO_CONTROL: u32 = 2; // todo: - change this to os.proto.syscontrol
const AF_SYS_CONTROL: u32 = 2; // todo: - change this to os.proto.syscontrol

const UTUN_CONTROL_NAME = "com.apple.net.utun_control";

const CTLIOCGINFO = (0x40000000 | 0x80000000) | ((100 & 0x1fff) << 16) | @intCast(u32, 'N')<<8 | 3;

pub const Stream = struct {
    handle: os.socket_t
};

pub fn start(name: []const u8) !os.socket_t {
    // 1. utun name to tun id (ok)
    const utunPrefix = "utun";
    if (!std.mem.startsWith(u8, name, utunPrefix)) {
        std.debug.print("the name must has prefix utun\n", .{});
        return -1;
    }
    std.debug.print("the name = {s}\n", .{name});

    const idStr = name[4..];
    std.debug.print("the id str = {s}\n", .{idStr});
    const tunId: u32 = try std.fmt.parseInt(u32, idStr, 10); // todo: - read int from string
    std.debug.print("the tun id is : {d}\n", .{tunId});

    // 2. use socket create fd (ok)
    const fd = sys.socket(sys.AF_SYSTEM, sys.SOCK_DGRAM, SYSPROTO_CONTROL);
    std.debug.print("socket fd = {}\n", .{fd});
    errdefer os.closeSocket(fd);

    // 3. call ioctl init ctl_info get ctl_id (ok)
    var array = [_]u8{0} ** 96;
    std.mem.copy(u8, &array, UTUN_CONTROL_NAME); // todo: - slice to array
    std.debug.print("the array = {s}\n", .{array});
    var ctlInfo: sys.ctl_info = .{
        .ctl_id = @as(u32, 0),
        .ctl_name = array,
    };
    const ioCtlRes = sys.ioctl(fd, CTLIOCGINFO, @ptrToInt(&ctlInfo));
    if (ioCtlRes < 0) {
        std.debug.print("call iotcl failed \n res = {} \n the ctl info = {}\n", .{ioCtlRes, @sizeOf(sys.ctl_info)});
    } else {
        std.debug.print("call ioctl succced, res = {}\n and info: {}\n", .{ioCtlRes, ctlInfo});
    }

    // 4. connect fd with socket address (fix)
    const addr: sys.sockaddr_ctl = sys.sockaddr_ctl{
        .sc_id = ctlInfo.ctl_id,
        .sc_len = @sizeOf(sys.sockaddr_ctl),
        .sc_family = sys.AF_SYSTEM,
        .ss_sysaddr = AF_SYS_CONTROL,
        .sc_unit = tunId,
        .sc_reserved = [_]u32{0} ** 5,
    };
    
    const cp = @ptrCast([*c]const sys.sockaddr, &addr);
    const connRes = sys.connect(fd, cp, @sizeOf(sys.sockaddr));
    if (connRes < 0) {
        std.debug.print("connect failed\n", .{});
    } else {
        std.debug.print("connect succeed\n", .{});
    }
    return fd;
}
