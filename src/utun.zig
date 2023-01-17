const std = @import("std");


// @cInclude("sys/types.h>");
// @cInclude("sys/socket.h>");
// @cInclude("sys/un.h>");
// @cInclude("stdio.h>");

const socket = @cImport({
    @cInclude("sys/types.h>");
    @cInclude("sys/socket.h>");
    // @cInclude("sys/ioctl.h>");
    // @cInclude("net/if_utun.h>");
});

const unistd = @cImport({
  @cInclude("unistd.h>");
});
const stdio = @cImport({
  @cInclude("stdio.h");
});

const net = std.net;
const os = std.os;

pub const Stream = struct {
    handle: os.socket_t
};

pub fn start(name: []const u8) !os.socket_t {
    _ = name;
    // socket.socket(socket.PF_SYSTEM, c_int, c_int);
    
    

    // 1. create fd
    const sockfd = try os.socket(os.AF.SYSTEM, std.os.SOCK.DGRAM | std.os.SOCK.CLOEXEC, 0);
    std.debug.print("socket fd = {}\n", .{sockfd});
    errdefer os.closeSocket(sockfd);

    // 2. ctl_info
    // var ifr: os.ifreq = undefined;
    // std.mem.copy(u8, &ifr.ifrn.name, name);
    // ifr.ifrn.name[name.len] = 0;
    // try os.ioctl_SIOCGIFINDEX(sockfd, &ifr);

    // const index = @bitCast(u32, ifr.ifru.ivalue);
    // std.debug.print("if name to index = {}", .{index});

    // 3. create sc
    // struct sockaddr_ctl sc;
    // sc.sc_id = ctlInfo.ctl_id;
	// sc.sc_len = sizeof(sc);
	// sc.sc_family = AF_SYSTEM;
	// sc.ss_sysaddr = AF_SYS_CONTROL;
	// sc.sc_unit = 2;	/* Only have one, in this example... */

    var sockaddr = os.sockaddr.in{
        .family = os.AF.SYSTEM,
        .port = 65535,
        .addr = 0,
        .zero = [1]u8{0} ** 8,
    };

    const sc = @ptrCast(*os.sockaddr, &sockaddr);

    const len = @sizeOf(os.sockaddr.in);

    // 3. connect fd with socket address
    try os.connect(sockfd, sc, len);

    return sockfd;
}
