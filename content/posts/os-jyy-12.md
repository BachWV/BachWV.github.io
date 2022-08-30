---
title: "操作系统-jyy-12"
date: 2022-08-30T16:09:19+08:00
---

# 第12讲 进程的地址空间

堆区，栈只是对平坦的内存地址空间进行的抽象。对于汇编来说，能看见的只有地址，寄存器。
比如定义一个指针，可以指向任何地方，但是你不能访问。就算你可以访问，也不一定能写它。


## pmap

report memory of a process
是通过访问procfs(/proc/)实现的

`(gdb)info inferiors`
查看进程号

```
(gdb) info inferiors
  Num  Description       Executable
* 1    process 25732     /home/charon/jyy/12/a.out
(gdb) !pmap 25732
25732:   /home/charon/jyy/12/a.out
0000000000400000      4K r---- a.out
0000000000401000      4K r-x-- a.out
00007ffff7ffa000     16K r----   [ anon ]
00007ffff7ffe000      4K r-x--   [ anon ]
00007ffffffde000    132K rw---   [ stack ]
 total              160K
```

操作系统在用execve创建进程时，就会把参数，环境变量放到stack里

pmap究竟执行了什么系统调用，可以通过`strace pmap pid`来探究一下

openat打开了一个文件 /proc/25732/maps

```
(gdb) !cat /proc/25732/maps
00400000-00401000 r--p 00000000 08:10 1591                               /home/charon/jyy/12/a.out
00401000-00402000 r-xp 00001000 08:10 1591                               /home/charon/jyy/12/a.out
7ffff7ffa000-7ffff7ffe000 r--p 00000000 00:00 0                          [vvar]
7ffff7ffe000-7ffff7fff000 r-xp 00000000 00:00 0                          [vdso]
7ffffffde000-7ffffffff000 rw-p 00000000 00:00 0                          [stack]
```

推荐宝藏手册man 5 proc

   [vdso] The virtual dynamically linked shared object.  See vdso(7).

我们可以对照 readelf中的Program Header 来验证
```
Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x00000000000000b0 0x00000000000000b0  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x000000000000004a 0x000000000000004a  R E    0x1000
```

对于动态链接来说，地址空间又复杂了一些。
这时.so动态链接库也被放入内存中，但是出现了啥都没有的地址空间映像，这是什么？
是不是bss？

这时jyy做了一个实验.
```
char big[1<<30]={0};
int main(){
}
```

看看这么大的数组究竟在哪?

```
(gdb) info inferiors
  Num  Description       Executable
* 1    process 25796     /home/charon/jyy/12/a.out
(gdb) !pmap 25796
25796:   /home/charon/jyy/12/a.out
0000555555554000      4K r---- a.out
0000555555555000      4K r-x-- a.out
0000555555556000      4K r---- a.out
0000555555557000      8K rw--- a.out
0000555555559000 1048576K rw---   [ anon ]
00007ffff7fca000     16K r----   [ anon ]
00007ffff7fce000      4K r-x--   [ anon ]
00007ffff7fcf000      4K r---- ld-2.31.so
00007ffff7fd0000    140K r-x-- ld-2.31.so
00007ffff7ff3000     32K r---- ld-2.31.so
00007ffff7ffc000      8K rw--- ld-2.31.so
00007ffff7ffe000      4K rw---   [ anon ]
00007ffffffde000    132K rw---   [ stack ]
 total          1048936K
```
确实在堆区heap

启动之后甚至吃了我1g的内存

```
$htop
PID     VIRT    Command
25805   1024M   /home/charon/jyy/12/a.out
```

## vdso

既想执行系统调用，又不想通过syscall进入内核执行

time 跳转到0x7ffff7fce730

在内存中的vdso段，
再把rip减掉-0x469，进入vvar。
而且这个内存gdb无法访问。
查看rax的值，发现就是unix时间秒数，说明这个0x7fffff7fca0a0中存的是操作系统的秒数


```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐│  >0x7ffff7fce730 <time>                   test   %rdi,%rdi                                  ││   0x7ffff7fce733 <time+3>                 mov    -0x469a(%rip),%rax        # 0x7ffff7fca0a0 ││   0x7ffff7fce73a <time+10>                je     0x7ffff7fce73f <time+15>                   ││   0x7ffff7fce73c <time+12>                mov    %rax,(%rdi)            
```

vvar是什么？由操作系统维护的一个秒数。

与其费劲心力一定要通过陷入内核的方式来读取这些数据，不如在内核与用户态之间建立一段共享内存区域，由内核定期“推送”最新的值到该共享内存区域，然后由用户态程序在调用这些glibc库函数的时候，库函数并不真正执行系统调用。

那么能不能让其他系统调用也 trap 进入内核？

疯狂的事情也许真的是能实现的 (这算是魔法吗？)
FlexSC: Flexible system call scheduling with exception-less system calls (OSDI'10).
https://www.usenix.org/conference/osdi10/flexsc-flexible-system-call-scheduling-exception-less-system-calls

使用共享内存和内核通信！

map是动态变化的。
动态链接库在开始阶段并没有加载到地址空间。

## mmap

map or unmap files or devices into memory

在状态上增改一段可访问的内存。

```

// 映射
void *mmap(void *addr, size_t length, int prot, int flags,
           int fd, off_t offset);
int munmap(void *addr, size_t length);

// 修改映射权限
int mprotect(void *addr, size_t length, int prot);
```

把文件映射到进程的地址空间

这个mmap特别有用，再此基础上实现加载器就非常容易。

elf文件会告诉你把什么段加载到哪里Program Headers

mmap会把内存标记为已分配，等到缺页的时候再说。
所以mmap申请大量内存空间几乎是瞬间完成的。

## 地址空间的隔离
每个ptr只能访问本进程的内存

剩下的40分钟都是jyy介绍上一个时代的游戏

红警、金山游侠、

如何制造外挂？

动态修改一个运行中的程序（热更新）

