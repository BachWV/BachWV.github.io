---
title: "操作系统-jyy-11"
date: 2022-07-26T16:09:16+08:00
---

# 第11讲 操作系统上的进程 

主要内容：

- 最小 Linux
-  fork
-  execve 
-  exit

本次课回答的问题

- **Q1**: 操作系统启动后到底做了什么？
- **Q2**: 操作系统如何管理程序 (进程)？

复习[第九讲]({{< relref "os-jyy-9.md" >}})的内容

操作系统内核的启动： CPU Reset-> BIOS/UEFI->Boot loader->Kernel_start()



操作系统会加载第一个程序

比如systemd/init

好像现在systemd已经是越来越多发行版的首选了，wsl2好像不是[在WSL2的Ubuntu里配置systemd](https://rainchan.win/2022/04/30/%E5%9C%A8WSL2%E7%9A%84Ubuntu%E9%87%8C%E9%85%8D%E7%BD%AEsystemd/)



最小的linux

makefile也十分简单

make run 直接进入这个 qemu

qemu 甚至没有图形界面 ctrl+a c退出sh

```
bach@LAPTOP-U1E6STIA:~/jyy/linux-minimal$ cat Makefile
.PHONY: initramfs run clean

$(shell mkdir -p build)

initramfs:
        @cd initramfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 \
          > ../build/initramfs.cpio.gz

run:
        @qemu-system-x86_64 \
          -nographic \
          -serial mon:stdio \
          -m 128 \
          -kernel vmlinuz \
          -initrd build/initramfs.cpio.gz \
          -append "console=ttyS0 quiet acpi=off"

clean:
        @rm -rf build
```



```
(qemu) info registers
RAX=ffffffffb62d5260 RBX=0000000000000000 RCX=0000000000000001 RDX=0000000000000f92
RSI=0000000000000087 RDI=0000000000000087 RBP=ffffffffb6e03e38 RSP=ffffffffb6e03e18
R8 =ffff9a834781df80 R9 =0000000000000200 R10=0000000000000000 R11=0000000000000000
R12=0000000000000000 R13=ffffffffb6e13780 R14=0000000000000000 R15=0000000000000000
RIP=ffffffffb62d564e RFL=00000246 [---Z-P-] CPL=0 II=0 A20=1 SMM=0 HLT=1
ES =0000 0000000000000000 00000000 00000000
CS =0010 0000000000000000 ffffffff 00af9b00 DPL=0 CS64 [-RA]
SS =0018 0000000000000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
DS =0000 0000000000000000 00000000 00000000
FS =0000 0000000000000000 00000000 00000000
GS =0000 ffff9a8347800000 00000000 00000000
LDT=0000 0000000000000000 00000000 00008200 DPL=0 LDT
TR =0040 fffffe0000003000 0000206f 00008900 DPL=0 TSS64-avl
GDT=     fffffe0000001000 0000007f
IDT=     fffffe0000000000 00000fff
CR0=80050033 CR2=0000000000a95c28 CR3=0000000003ca2000 CR4=000006f0
DR0=0000000000000000 DR1=0000000000000000 DR2=0000000000000000 DR3=0000000000000000
DR6=00000000ffff0ff0 DR7=0000000000000400
EFER=0000000000000d01
FCW=037f FSW=0000 [ST=0] FTW=00 MXCSR=00001f80
```



busybox是一个工具集，这么多工具居然只有2M，我哭死，加载到内核里我们就能使用了



init是一个启动脚本，它只有一行命令`/bin/busybox sh`启动sh，如果不让它启动shell会发生什么？

会kernel panic



你以为这个最小linux什么都做不了？非也！非也！





gcc -c minimal.S&&ld minimal.o



linux 内核启动后，把所有的权利都交给一个进程，这一个进程再创建成整个世界



## fork

创建状态机

创建子进程，保留进程所有上下文（内存、寄存器现场）。

新进程返回0，执行fork的进程返回子进程的进程号



理解fork的两个例子

### fork-demo.c

```
#include <unistd.h>
#include <stdio.h>

int main() {
  pid_t pid1 = fork();
  pid_t pid2 = fork();
  pid_t pid3 = fork();
  printf("Hello World from (%d, %d, %d)\n", pid1, pid2, pid3);
}
```



```
bach@LAPTOP-U1E6STIA:~/jyy/11$ gcc fork-demo.c
bach@LAPTOP-U1E6STIA:~/jyy/11$ ./a.out
Hello World from (133, 134, 136)
Hello World from (0, 135, 137)
Hello World from (133, 134, 0)
Hello World from (0, 135, 0)
Hello World from (133, 0, 138)
Hello World from (133, 0, 0)
Hello World from (0, 0, 0)
Hello World from (0, 0, 139)
```

居然和我想的一样，不行这一定得拍下来

![os-jyy-11.jpg](https://s2.loli.net/2022/09/06/KTU2bQsg1CFAikn.jpg)

### fork-printf.c

神奇的事情出现了

```
bach@LAPTOP-U1E6STIA:~/jyy/11$ ./a.out
Hello
Hello
Hello
Hello
Hello
Hello
bach@LAPTOP-U1E6STIA:~/jyy/11$ ./a.out|cat
Hello
Hello
Hello
Hello
Hello
Hello
Hello
Hello
```

这是printf的缓冲区导致的，fork会把缓冲区复制一份，等于虽然调用了printf，但是此时还没有执行系统调用。

```
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  int n = 2;
  for (int i = 0; i < n; i++) {
    fork();
    printf("Hello");
  }
  printf("\n");
  for (int i = 0; i < n; i++) {
    wait(NULL);
  }
}
gcc fork-printf.c&&a.out
HelloHello
HelloHello
HelloHello
HelloHello
```

这是一个bug吗？不是，这是我们没有充分理解fork的语义，也不知道缓冲区行为，才导致6或8个hello

stdout和pipe/file缓冲区是不一样的

- stdout line buffer
- pipe/file full buffer 写满一页才传管道

如果你想得到6个hello，即让fork不复制缓冲区

- 设置成无缓冲区：setbuf(stdout,NULL);

- 加上fflush(stdout)迅速刷新

如果你想得到8个hello，就让fork复制缓冲区就行了

机器不知道你像做什么，只是忠实执行指令

## execve

重置一个状态机，丢失所有当前状态

`int execve(const char *pathname, char *const argv[],
                  char *const envp[]);`

The argv and envp arrays must each include a null pointer at the end of the array.



gcc strace结果

gcc会在PATH下寻找as汇编器，找不到就g，我们可以指定PATH让找不到as

```
bach@LAPTOP-U1E6STIA:~/jyy/11$ PATH=bb:Dsds /bin/strace -f /bin/gcc execve-demo.c |& grep "exec"
execve("/bin/gcc", ["/bin/gcc", "execve-demo.c"], 0x7ffeb064f200 /* 27 vars */) = 0
access("execve-demo.c", F_OK)           = 0
[pid   506] execve("/usr/lib/gcc/x86_64-linux-gnu/9/cc1", ["/usr/lib/gcc/x86_64-linux-gnu/9/"..., "-quiet", "-imultiarch", "x86_64-linux-gnu", "execve-demo.c", "-quiet", "-dumpbase", "execve-demo.c", "-mtune=generic", "-march=x86-64", "-auxbase", "execve-demo", "-fasynchronous-unwind-tables", "-fstack-protector-strong", "-Wformat", "-Wformat-security", "-fstack-clash-protection", "-fcf-protection", "-o", "/tmp/ccfJr8oo.s"], 0x149cf70 /* 32 vars */ <unfinished ...>
[pid   506] <... execve resumed>)       = 0
[pid   506] stat("execve-demo.c.gch", 0x7fff6bab32d0) = -1 ENOENT (No such file or directory)
[pid   506] openat(AT_FDCWD, "execve-demo.c", O_RDONLY|O_NOCTTY) = 3
[pid   506] lstat("/home/bach/jyy/11/execve-demo.c", {st_mode=S_IFREG|0644, st_size=230, ...}) = 0
[pid   506] write(3, "\t.file\t\"execve-demo.c\"\n\t.text\n\t."..., 1237) = 1237
[pid   507] execve("bb/as", ["as", "--64", "-o", "/tmp/ccH9mHSm.o", "/tmp/ccfJr8oo.s"], 0x149cf70 /* 32 vars */) = -1 ENOENT (No such file or directory)
[pid   507] execve("Dsds/as", ["as", "--64", "-o", "/tmp/ccH9mHSm.o", "/tmp/ccfJr8oo.s"], 0x149cf70 /* 32 vars */) = -1 ENOENT (No such file or directory)
write(2, "gcc: fatal error: cannot execute"..., 77gcc: fatal error: cannot execute ‘as’: execvp: No such file or directory
```

正常是：

```
[pid   465] execve("/usr/local/sbin/as", ["as", "--64", "-o", "/tmp/ccZ9qp1b.o", "/tmp/ccYUOsnc.s"], 0x1166f70 /* 32 vars */) = -1 ENOENT (No such file or directory)
[pid   465] execve("/usr/local/bin/as", ["as", "--64", "-o", "/tmp/ccZ9qp1b.o", "/tmp/ccYUOsnc.s"], 0x1166f70 /* 32 vars */) = -1 ENOENT (No such file or directory)
[pid   465] execve("/usr/sbin/as", ["as", "--64", "-o", "/tmp/ccZ9qp1b.o", "/tmp/ccYUOsnc.s"], 0x1166f70 /* 32 vars */) = -1 ENOENT (No such file or directory)
[pid   465] execve("/usr/bin/as", ["as", "--64", "-o", "/tmp/ccZ9qp1b.o", "/tmp/ccYUOsnc.s"], 0x1166f70 /* 32 vars */ <unfinished ...>
```

 ## exit

exit的几种不同的写法：

#### exit(0) 

 stdlib.h中libc函数，会调用atexit

- All functions registered with atexit(3) and on_exit(3) are called, in the  reverse  order  of  their
         registration.
- thread safety

```bash
bach@LAPTOP-U1E6STIA:~/jyy/11$ strace ./a.out exit
execve("./a.out", ["./a.out", "exit"], 0x7ffeba56b798 /* 27 vars */) = 0
arch_prctl(0x3001 /* ARCH_??? */, 0x7fff21d63de0) = -1 EINVAL (Invalid argument)
brk(NULL)                               = 0x2282000
brk(0x22831c0)                          = 0x22831c0
arch_prctl(ARCH_SET_FS, 0x2282880)      = 0
uname({sysname="Linux", nodename="LAPTOP-U1E6STIA", ...}) = 0
readlink("/proc/self/exe", "/home/bach/jyy/11/a.out", 4096) = 23
brk(0x22a41c0)                          = 0x22a41c0
brk(0x22a5000)                          = 0x22a5000
mprotect(0x4bd000, 12288, PROT_READ)    = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
write(1, "Goodbye, Cruel OS World!\n", 25Goodbye, Cruel OS World!
) = 25
exit_group(0)                           = ?
+++ exited with 0 +++
```



#### _exit(0) 

glibc的syscall wrapper

所有的线程都会被终止

如果此时有一个还未fflush的buffer的话，将不会输出

```
$cat exit-demo.c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/syscall.h>
int main(int argc, char *argv[]) {
 // atexit(func);
 printf("unfflush buffer");
  if (argc < 2) return EXIT_FAILURE;

  if (strcmp(argv[1], "exit") == 0)
    exit(0);
  if (strcmp(argv[1], "_exit") == 0)
    _exit(0);
  if (strcmp(argv[1], "__exit") == 0)
    syscall(SYS_exit, 0);
}
$ ./a.out _exit
$ ./a.out exit
unfflush buffer
```



```
bach@LAPTOP-U1E6STIA:~/jyy/11$ strace ./a.out _exit
execve("./a.out", ["./a.out", "_exit"], 0x7ffee2ba8958 /* 27 vars */) = 0
arch_prctl(0x3001 /* ARCH_??? */, 0x7fff5f104010) = -1 EINVAL (Invalid argument)
brk(NULL)                               = 0x1407000
brk(0x14081c0)                          = 0x14081c0
arch_prctl(ARCH_SET_FS, 0x1407880)      = 0
uname({sysname="Linux", nodename="LAPTOP-U1E6STIA", ...}) = 0
readlink("/proc/self/exe", "/home/bach/jyy/11/a.out", 4096) = 23
brk(0x14291c0)                          = 0x14291c0
brk(0x142a000)                          = 0x142a000
mprotect(0x4bd000, 12288, PROT_READ)    = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

#### __syscall(SYS_exit,0)

```
bach@LAPTOP-U1E6STIA:~/jyy/11$ strace ./a.out _exit
execve("./a.out", ["./a.out", "_exit"], 0x7ffee2ba8958 /* 27 vars */) = 0
arch_prctl(0x3001 /* ARCH_??? */, 0x7fff5f104010) = -1 EINVAL (Invalid argument)
brk(NULL)                               = 0x1407000
brk(0x14081c0)                          = 0x14081c0
arch_prctl(ARCH_SET_FS, 0x1407880)      = 0
uname({sysname="Linux", nodename="LAPTOP-U1E6STIA", ...}) = 0
readlink("/proc/self/exe", "/home/bach/jyy/11/a.out", 4096) = 23
brk(0x14291c0)                          = 0x14291c0
brk(0x142a000)                          = 0x142a000
mprotect(0x4bd000, 12288, PROT_READ)    = 0
exit(0)                           = ?
+++ exited with 0 +++
```

唯一的区别是exit(0) /exit_group(0)

