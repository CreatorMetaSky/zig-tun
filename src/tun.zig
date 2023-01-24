const std = @import("std");
const os = std.os;
const sys = @cImport({
    @cInclude("sys/socket.h");
    @cInclude("sys/kern_control.h");
    @cInclude("sys/ioctl.h");
});

const SYSPROTO_CONTROL: u32 = 2;    // todo: - change this to os.proto.syscontrol
const AF_SYS_CONTROL: u32 = 2;      // todo: - change this to os.proto.syscontrol

const UTUN_CONTROL_NAME = "com.apple.net.utun_control";

const CTLIOCGINFO = (0x40000000 | 0x80000000) | ((100 & 0x1fff) << 16) | @intCast(u32, 'N')<<8 | 3;

pub const fd_t = c_int;

// todo: - error union with string or other errors
pub const DeviceServerError = error {
    InvalidOptions,
    IoCtlInfoFailed,
    ConnectFailed,
} || os.UnexpectedError;

pub const Options = struct {
    name: []const u8 = "utun8" // note: - private fields
};

pub const DeviceServer = struct {
    name: []const u8,
    sockfd: ?fd_t = null,

    pub fn init(options: Options) !DeviceServer {
        var deviceServer = DeviceServer{
            .name = options.name
        };
        deviceServer.sockfd = try startTunDevice(deviceServer.name);
        return deviceServer;
    }

    pub fn startTunDevice(name: []const u8) DeviceServerError!fd_t {
        // 1. utun name to tun id (ok) utun8 -> 8
        const utunPrefix = "utun";
        if (!std.mem.startsWith(u8, name, utunPrefix)) {
            std.debug.print("the name must has prefix utun\n", .{});
            return DeviceServerError.InvalidOptions;
        }
        std.debug.print("the name = {s}\n", .{name});

        const idStr = name[4..];
        std.debug.print("the id str = {s}\n", .{idStr});
        const tunId: u32 = std.fmt.parseInt(u32, idStr, 10) catch |err| {
            std.debug.print("parse int from string failed: {}", .{err});
            return DeviceServerError.InvalidOptions;
        }; // note: - read int from string
        std.debug.print("the tun id is : {d}\n", .{tunId});

        // 2. use socket create fd (ok)
        const fd = sys.socket(sys.AF_SYSTEM, sys.SOCK_DGRAM, SYSPROTO_CONTROL);
        std.debug.print("socket fd = {}\n", .{fd});
        // errdefer os.closeSocket(fd); // fixme: - close the sockfd

        // 3. call ioctl init ctl_info get ctl_id (ok)
        var array = [_]u8{0} ** 96;
        std.mem.copy(u8, &array, UTUN_CONTROL_NAME); // todo: - slice to array
        std.debug.print("the array = {s}\n", .{array});
        var ctlInfo: sys.ctl_info = .{
            .ctl_id = @as(u32, 0),
            .ctl_name = array,
        };
        const ioCtlRes = sys.ioctl(fd, CTLIOCGINFO, @ptrToInt(&ctlInfo)); // todo: - ptr vs ptrToInt
        if (ioCtlRes < 0) {
            std.debug.print("call iotcl failed \n res = {} \n the ctl info = {}\n", .{ioCtlRes, @sizeOf(sys.ctl_info)});
            return DeviceServerError.IoCtlInfoFailed;
        } else {
            std.debug.print("call ioctl succced, res = {}\n and info: {}\n", .{ioCtlRes, ctlInfo});
        }

        // 4. connect fd with socket address (fix)
        const len = @sizeOf(sys.sockaddr_ctl);
        const addr: sys.sockaddr_ctl = sys.sockaddr_ctl{
            .sc_id = ctlInfo.ctl_id,
            .sc_len = len,
            .sc_family = sys.AF_SYSTEM,
            .ss_sysaddr = AF_SYS_CONTROL,
            .sc_unit = tunId + 1,
            .sc_reserved = [_]u32{0} ** 5,
        };

        const sockaddrPointer = @ptrCast(*const sys.sockaddr, &addr);
        const connRes = sys.connect(fd, sockaddrPointer, len);
        if (connRes < 0) {
            std.debug.print("connect failed : {}\n", .{connRes});
            return DeviceServerError.ConnectFailed;
        } else {
            std.debug.print("connect succeed\n", .{});
        }

        return fd;
    }

    pub fn up() void {
        // fixme: execute ifconfig command
        // std.ChildProcess.exec(args: struct{allocator:mem.Allocator, argv:[]const []const u8, cwd:?[]const u8=null, cwd_dir:?fs.Dir=null, env_map:?*const EnvMap=null, max_output_bytes:usize=50*1024, expand_arg0:Arg0Expand=.no_expand, })
    }
};

