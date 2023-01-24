# Tasks

## 0.0.1

create utun device, can read packet from it (only macOS)

### basic setup

- [x] project setup
- [x] complie succeed

### use native api to create utun

- [x] write code zig call system c api
- [x] complie and run succeed
- [x] netstat -rn can see the utun device

### device with config

- [x] create Server with Options
- [x] handle the error logic in tun start
- [ ] ifconfig up the device

### test read packet from tun device

- [ ] auto config route table from config
- [ ] read packet send to tun device

## 0.0.2

### api change to zig style

- [ ] like StreamServer interface

### adapte other platform

- [ ] cross platform
- [ ] async await