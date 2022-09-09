---
title: "操作系统-jyy-18"
date: 2022-09-05T22:32:41+08:00
draft: false
---

# 第17讲 Xv6 代码导读 (调试工具配置；调试系统调用执行)

经典UNIX v6的克隆

## xv6: UNIX v6 的现代 “克隆”

接近完整的 UNIX Shell 体验

- 基本工具集 (wc, echo, cat, ...)
- 命令执行、管道、重定向
  - 支持多处理器
  - Now in RISC-V!



下面是jyy狂吹xv6的code

文档也十分不错，甚至可以当作操作系统的教科书。

（你需要一个riscv-gnu-toolchain)

工具链安装也十分简单，我们只需clone仓库，https://github.com/riscv-collab/riscv-gnu-toolchain

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

./configure --prefix=/opt/riscv
make linux
```



