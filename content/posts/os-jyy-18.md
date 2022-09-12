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
如何自动生成 compile_commands.json
## bear 
A tool to generate compilation json database

使用
make qemu -> bear make qemu

为什么要配置好工具？

因为它可以让你愿意去读这个代码。
你内心里总有两股势力在斗争，一种是看代码好麻烦，我不想做了，另一个是老师说xv6代码很经典，值得学。
最终看哪一个势力取胜。

有了工具就能帮你战胜惰性。

这一点我很有感触。这一篇我整整写了4天，为什么，因为我clone 的时候一直fail，导致riscv的gcc一直没装好。就导致我的惰性取胜了。

## xv6进程发地址空间
init.c

init试图打开console，如果没有就创建它再打开。

并执行一个while(1)，shell退出了就会立即再起一个shell

神奇的页面 tarpframe和trampoline
![](https://jyywiki.cn/pages/OS/img/xv6-process-memory.png)

## 调试用户代码
initcode->ecall

gdb初始化输入那么多你能接受吗？
gdb init，在执行gdb时自动执行脚本make qemu-gdb

ecall是什么

关中断 pc->sepc 控制寄存器中会有一个flag stvec->pc

在 xv6 中

- Trampoline: $stvec = 0x3ffffff000 (只读)
- Trapframe (0x3fffffe000): 保存进程寄存器现场的内存

## Trampoline (跳板)

trampoline.S (汇编代码)

- 对 ecall 瞬间的状态做快照

  - 填充 `struct trapframe` (proc.h)

  - 利用 $sscratch (S-mode scratch) 保存所有寄存器

  - 切换到内核栈 (相当于切换到进程对应的 “内核线程”, [L2](https://jyywiki.cn/OS/2022/labs/L2))

  - 切换到内核地址空间

    - 修改 $satp (S-mode address translation and protection)
    - sfence.vma

  - 跳转到

     

    ```
    tf->kernel_trap
    ```

    - 痛苦时间解除，进入 C 代码

------

## 系统调用处理

```
struct proc *p = myproc()
```

- 我们可以在 gdb 中查看 “进程” 在操作系统内的数据结构表示

  - ```
    p/x *p
    ```

    - 可以看到 trapframe 的地址 (和地址空间中映射的完全一样)

  - `p/x *p->trapframe` (a7 = 0x7)

- 检查

   

  ```
  scause == 8
  ```

   

  (syscall)

  - $epc += 4 (更正返回地址)
  - 打开中断
  - 执行系统调用

- ```
  usertrapret()
  ```

   

  返回

  - ecall 的逆操作

