---
title: "操作系统-jyy-13"
date: 2022-08-30T21:09:23+08:00
---

# 第13讲 系统调用和Shell

freestanding shell, 终端和 job control

UNIX Shell的设计和实现


## 0依赖的shell

```gcc -c -ffreestanding sh-xv6.c -g -O2
ld sh-xv6.o -o sh
```



管道实现


左子树右子树抽象|
`(echo a;echo b)|wc -l`
fork的子进程拥有pipefd[0]以及pipefd[1]，相当于父子进程共享管道
子线程执行左边，主进程执行右边，

pipe()  creates  a pipe, a unidirectional data channel that can be used for interpro‐
       cess communication.  The array pipefd is used to return two file  descriptors  refer‐
       ring  to  the  ends  of  the  pipe.   pipefd[0]  refers  to the read end of the pipe.
       pipefd[1] refers to the write end of the pipe.  Data written to the write end of  the
       pipe  is  buffered by the kernel until it is read from the read end of the pipe.  For
       further details, see pipe(7).

具体来说，对子进程，关闭编号为1的文件描述符（stdout），拷贝1到一个空闲的文件描述符。相当于把stdout指向管道的写口。
然后关闭p0和p1.执行|左边内容


之后又执行一个fork。子进程关闭编号为0的文件描述符（stdin），拷贝0到空闲文件描述符，关闭p0和p1.执行|右边内容

父进程关闭p0和p1，执行两个wait，等待父子都执行完成。

我们通过strace来探究一下./sh究竟做了什么。

小技巧`tail -f filename`
实现热更新查看文件

```
29949 read(0, ".", 1)                   = 1
29949 read(0, "/", 1)                   = 1
29949 read(0, "a", 1)                   = 1
29949 read(0, ".", 1)                   = 1
29949 read(0, "o", 1)                   = 1
29949 read(0, "u", 1)                   = 1
29949 read(0, "t", 1)                   = 1
29949 read(0, " ", 1)                   = 1
29949 read(0, "|", 1)                   = 1
29949 read(0, "/", 1)                   = 1
29949 read(0, "b", 1)                   = 1
29949 read(0, "i", 1)                   = 1
29949 read(0, "n", 1)                   = 1
29949 read(0, "/", 1)                   = 1
29949 read(0, "w", 1)                   = 1
29949 read(0, "c", 1)                   = 1
29949 read(0, " ", 1)                   = 1
29949 read(0, "-", 1)                   = 1
29949 read(0, "l", 1)                   = 1
29949 read(0, "\n", 1)                  = 1
29949 fork()                            = 30089
29949 wait4(-1,  <unfinished ...>
30089 pipe([3, 4])                      = 0
30089 fork( <unfinished ...>
30090 close(1 <unfinished ...>
30089 <... fork resumed>)               = 30090
30090 <... close resumed>)              = 0
30089 fork( <unfinished ...>
30090 dup(4)                            = 1
30091 close(0 <unfinished ...>
30090 close(3 <unfinished ...>
30091 <... close resumed>)              = 0
30089 <... fork resumed>)               = 30091
30091 dup(3 <unfinished ...>
30090 <... close resumed>)              = 0
30091 <... dup resumed>)                = 0
30089 close(3 <unfinished ...>
30091 close(3 <unfinished ...>
30090 close(4 <unfinished ...>
30091 <... close resumed>)              = 0
30089 <... close resumed>)              = 0
30091 close(4 <unfinished ...>
30090 <... close resumed>)              = 0
30091 <... close resumed>)              = 0
30089 close(4 <unfinished ...>
30091 execve("/bin/wc", ["/bin/wc", "-l"], NULL <unfinished ...>
30090 execve("./a.out", ["./a.out"], NULL <unfinished ...>
30089 <... close resumed>)              = 0
30089 wait4(-1,  <unfinished ...>
30090 <... execve resumed>)             = 0
30091 <... execve resumed>)             = 0
30090 write(1, "\33[01;31mHello, OS World\33[0m\n", 28 <unfinished ...>
30091 brk(NULL <unfinished ...>
30090 <... write resumed>)              = 28
30091 <... brk resumed>)                = 0x55b702392000
30090 exit(1 <unfinished ...>
30091 arch_prctl(0x3001 /* ARCH_??? */, 0x7ffc435e6820 <unfinished ...>
30090 <... exit resumed>)               = ?
30091 <... arch_prctl resumed>)         = -1 EINVAL (Invalid argument)
30090 +++ exited with 1 +++
30089 <... wait4 resumed>NULL, 0, NULL) = 30090
30091 access("/etc/ld.so.preload", R_OK <unfinished ...>
30089 --- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=30090, si_uid=1000, si_status=1, si_utime=0, si_stime=0} ---
30091 <... access resumed>)             = -1 ENOENT (No such file or directory)
30089 wait4(-1,  <unfinished ...>
30091 openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
30091 fstat(3, {st_mode=S_IFREG|0644, st_size=42648, ...}) = 0
30091 mmap(NULL, 42648, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f6abd690000
30091 close(3)                          = 0
30091 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
30091 read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300A\2\0\0\0\0\0"..., 832) = 832
30091 pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
30091 pread64(3, "\4\0\0\0\20\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0", 32, 848) = 32
30091 pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0\30x\346\264ur\f|Q\226\236i\253-'o"..., 68, 880) = 68
30091 fstat(3, {st_mode=S_IFREG|0755, st_size=2029592, ...}) = 0
30091 mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f6abd68e00030091 pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
30091 pread64(3, "\4\0\0\0\20\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0", 32, 848) = 32
30091 pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0\30x\346\264ur\f|Q\226\236i\253-'o"..., 68, 880) = 68
30091 mmap(NULL, 2037344, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f6abd49c000
30091 mmap(0x7f6abd4be000, 1540096, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7f6abd4be000
30091 mmap(0x7f6abd636000, 319488, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x19a000) = 0x7f6abd636000
30091 mmap(0x7f6abd684000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e7000) = 0x7f6abd684000
30091 mmap(0x7f6abd68a000, 13920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f6abd68a000
30091 close(3)                          = 0
30091 arch_prctl(ARCH_SET_FS, 0x7f6abd68f580) = 0
30091 mprotect(0x7f6abd684000, 16384, PROT_READ) = 0
30091 mprotect(0x55b702127000, 4096, PROT_READ) = 0
30091 mprotect(0x7f6abd6c8000, 4096, PROT_READ) = 0
30091 munmap(0x7f6abd690000, 42648)     = 0
30091 brk(NULL)                         = 0x55b702392000
30091 brk(0x55b7023b3000)               = 0x55b7023b3000
30091 fadvise64(0, 0, 0, POSIX_FADV_SEQUENTIAL) = -1 ESPIPE (Illegal seek)
30091 read(0, "\33[01;31mHello, OS World\33[0m\n", 16384) = 28
30091 read(0, "", 16384)                = 0
30091 fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
30091 write(1, "1\n", 2)                = 2
30091 close(0)                          = 0
30091 close(1)                          = 0
30091 close(2)                          = 0
```

### shell的一些有趣的操作

The Shell Programming Language
基于文本替换的快速工作流搭建

重定向: cmd > file < file 2> /dev/null
顺序结构: cmd1; cmd2, cmd1 && cmd2, cmd1 || cmd2
管道: cmd1 | cmd2
预处理: $(), <()
变量/环境变量、控制流……

### Shell 还有一些未解之谜


为什么 Ctrl-C 可以退出程序？

为什么有些程序又不能退出？

没有人 read 这个按键，为什么进程能退出？
Ctrl-C 到底是杀掉一个，还是杀掉全部？
如果我 fork 了一份计算任务呢？
如果我 fork-execve 了一个 shell 呢？
Hmmm……

shell 和终端的区别


这也是我一直迷惑的地方。有的时候，比如gdb在调试一个a.out此时需要另一个窗口做一些别的事情。除了!命令以外，我一般会在terminal里开另外一个窗口。

通过tty命令知道，每一个窗口其实是一个块设备。
```
$ tty
/dev/pts/0
```
甚至可以直接用重定向向另一个窗口发送信息，这太神奇了
```
$ echo hello >> /dev/pts/1
```

ctrl +c的故事

终端产生信号

通过[signal-handler.c](https://jyywiki.cn/pages/OS/2022/demos/signal-handler.c)这个例子可以改写收到信号之后的操作。

我通过另一个终端的htop向a.out发送SIGINT发现./a.out输出Received SIGIN还是挺神奇的。
