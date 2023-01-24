# zig-tun

A portable tun/tap network interface written in zig.

## How to use

### on macOS

```
sudo zig build run
sudo ifconfig utun8 10.1.0.10 10.1.0.20 up
```

## Tips

- todo: - the task will do it
- fixme: - small bugfix 
- note: - tech knowledge to learn

## Inspiration

- [utun-example.c](https://gist.github.com/cute/dbac4005d2f40e151fa42fac1d2d00e2)
- [water](https://github.com/songgao/water)
- [rust-tun](https://github.com/meh/rust-tun)
- [ip2socks](github.com/FlowerWrong/ip2socks)