# zig-tun

A simple tun/tap network interface written in zig.

# How to use

**on macOS**

```
sudo zig build run
sudo ifconfig utun8 10.1.0.10 10.1.0.20 up
```

- https://gist.github.com/cute/dbac4005d2f40e151fa42fac1d2d00e2
- https://github.com/songgao/water
- https://github.com/meh/rust-tun
- github.com/FlowerWrong/ip2socks