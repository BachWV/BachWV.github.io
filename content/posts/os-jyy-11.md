---
title: "操作系统-jyy-11"
date: 2022-07-26T16:09:16+08:00
---
真实世界的并发编程 

(高性能计算/数据中心/人机交互中的并发编程)
之前跳过了两节，之后补。

本节课回答的问题：什么样的任务是需要并发、并行的？它们改如何实现

本次内容：

- 高性能计算中的并发编程
- 数据中心里的并发编程
- 我们身边的并发编程

## 高性能计算中的并发编程

先河：CRAY-1 supercomputer 1976 138MFLOPS

46岁，是超算。

应用于如下领域

- 系统模拟：天气预报、分子生物学

- 人工智能

- 挖矿，hash。



### 主要挑战

#### 计算任务如何分解

比如一个dp最长子序列，就很难分解，拓扑排序。

mpi

#### 线程之间如何通信
不仅是节点、线程之间，还发生在共享内存访问

#### 例子 Mandelbrot Set

注意，这个例子会用shell执行viu，这是一个将图片用unicode打印到终端的工具（想到了命令行浏览器browsh），请先`pamac install viu`

`gcc mandelbrot.c -lpthread -lm -O2 && ./a.out 1`

`argv=1 2 4 8`线程数

还是有点炫的

截图

![image-20220716190952071](https://r2.bi-li.fun/2023/12/image-20220716190952071.png)

`convert mandelbrot.ppm a.jpg`

![a](http://charon-pic.oss-cn-hangzhou.aliyuncs.com/a.jpg)



ppm这种rgb数字构成的图片格式



## 数据中心的并行编程

与超算的区别点在于数据和存储

支撑互联网应用，导致现代人获取知识的门槛降低，效率升高；如何抗住高并发

### 主要挑战

多副本情况下的高可靠、低延迟数据访问

多副本的数据一致性 Consistency

对用户高可用，立即生效 Available

容忍机器离线 Partition tolerance



虽然本课程的主要内容是如何管理一台计算机，但这里和数据中心不矛盾

一个尽可能相应多地服务的并行请求



切换线程是有代价的

一个有趣的小实验

co_yield 函数调用

### Go

协程coroutines

- 多个执行流
- 切换代价小，协程里的切换不受操作系统调度



线程的一般执行模型 read() syscall() write()，可以多处理器并行；但是需要占有较多的资源



协程 遇到read()会阻塞线程，其他协程就无法执行



#### Go和Goroutine

多处理器并行和协程全都要

每个cpu上绑定一个线程 go work，每个线程有多个协程。

任何一个协程IO时，用不block的系统调用read_nonblock，读取时会跳到另一个协程执行。这么巧妙的设计甚至不需要切换cpu，所以可以创建百万级的goroutine。



fib.go 轮番打印字符 ，实现了一个进度条

为什么进度条在算出fib后终止了？

因为运行的协程spinner在主协程main终止后就终止了

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  go spinner(100 * time.Millisecond) //创建go ruutine 概念是线程实现是协程
  const n = 45
  fibN := fib(n) // slow
  fmt.Printf("\rFibonacci(%d) = %d\n", n, fibN)
}

func spinner(delay time.Duration) {//轮番打印字符 ，实现了一个进度条
  for {
    for _, r := range `-\|/` {
      fmt.Printf("\r%c", r)//回到行首
      time.Sleep(delay)
    }
  }
}

func fib(x int) int {
  if x < 2 { return x }
  return fib(x - 1) + fib(x - 2)
}
```

操作系统上讲的并发算法，不意味着在真正写代码时用这些并发算法，因为接近底层的锁太难写了，我们写不对。

共享内存在奇怪调度发生各种bugs，我们把握不住。

如果生产者-消费者能解决大部分问题，那操作系统提供一个API给我们调用更好。



#### channel go协程之间通信的机制

`stream <- i`把i丢进channel

`x:=<- stream` 从channel拉出

通过别人为我们提供的模型，我们能轻易写出生产者-消费者模型的代码

```go
package main

import "fmt"

var stream = make(chan int, 10)
const n = 4

func produce() {
  for i := 0; ; i++ {
    fmt.Println("produce", i)
    stream <- i
  }
}

func consume() {
  for {
    x := <- stream
    fmt.Println("consume", x)
  }
}

func main() {
  for i := 0; i < n; i++ {
    go produce()
  }
  consume()
}
```



# 我们身边的并发编程



Web交互式的年代 web2.0

- 浏览器中的并发编程 asynchronous js+xml (ajax)

- HTML(DOM Tree)+CSS

  - 通过js改变html
  - 通过js建立连接本地和服务器

  



## 扩展阅读

标准I/O函数库提供了popen函数，它启动另外一个进程去执行一个shell命令行。

这里我们称**调用popen的进程为父进程，由popen启动的进程称为子进程。**

popen函数还**创建一个管道用于父子进程间通信。**父进程要么从管道读信息，要么向管道写信息，至于是读还是写取决于父进程调用popen时传递的参数。下在给出popen、pclose的定义：

```cpp
#include <stdio.h>
/*
函数功能：popen（）会调用fork（）产生子进程，然后从子进程中调用/bin/sh -c来执行参数command的指令。
参数type可使用“r”代表读取，“w”代表写入。
依照此type值，popen（）会建立管道连到子进程的标准输出设备或标准输入设备，然后返回一个文件指针。 
随后进程便可利用此文件指针来读取子进程的输出设备或是写入到子进程的标准输入设备中
返回值：若成功则返回文件指针，否则返回NULL，错误原因存于errno中
*/
FILE * popen( const char * command,const char * type);
	/*
函数功能：pclose（）用来关闭由popen所建立的管道及文件指针。参数stream为先前由popen（）所返回的文件指针
返回值：若成功返回shell的终止状态(也即子进程的终止状态)，若出错返回-1，错误原因存于errno中
*/
int pclose(FILE * stream);
```

下面通过例子看下popen的使用：

假如我们想取得当前目录下的文件个数，在shell下我们可以使用： 

```bash
1	ls | wc -l
```

我们可以在程序中这样写：

```cpp
/*取得当前目录下的文件个数*/
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/wait.h>
 
#define MAXLINE 1024
	
int main()
{
   char result_buf[MAXLINE], command[MAXLINE];
    int rc = 0; // 用于接收命令返回值
    FILE *fp;	 
    /*将要执行的命令写入buf*/
    snprintf(command, sizeof(command), "ls ./ | wc -l");
    /*执行预先设定的命令，并读出该命令的标准输出*/
    fp = popen(command, "r");
    if(NULL == fp)  {
        perror("popen执行失败！");
        exit(1);
    }

    while(fgets(result_buf, sizeof(result_buf), fp) != NULL) {
     /*为了下面输出好看些，把命令返回的换行符去掉*/
        if('\n' == result_buf[strlen(result_buf)-1]) {
            result_buf[strlen(result_buf)-1] = '\0';
	        }
        printf("命令【%s】 输出【%s】\r\n", command, result_buf);
    }
    /*等待命令执行完毕并关闭管道及文件指针*/
    rc = pclose(fp);
    if(-1 == rc)   {
        perror("关闭文件指针失败");
        exit(1);
    } else {
        printf("命令【%s】子进程结束状态【%d】命令返回值【%d】\r\n", command, rc, WEXITSTATUS(rc));
    }
    return 0;
}
```

编译并执行：

$ gcc popen.c

$ ./a.out

命令【ls ./ | wc -l】 输出【2】

命令【ls ./ | wc -l】子进程结束状态【0】命令返回值【0】

上面popen只捕获了command的标准输出，如果command执行失败，子进程会把错误信息打印到标准错误输出，父进程就无法获取。比如，command命令为“ls nofile.txt” ，事实上我们根本没有nofile.txt这个文件，这时shell会输出“ls: nofile.txt: No such file or directory”。这个输出是在标准错误输出上的。通过上面的程序并无法获取。

注：如果你把上面程序中的command设成“ls nofile.txt”,编译执行程序你会看到如下结果：

$ gcc popen.c 

$ ./a.out

ls: nofile.txt: No such file or directory

命令【ls nofile.txt】子进程结束状态【256】命令返回值【1】

 需要注意的是第一行输出并不是父进程的输出，而是子进程的标准错误输出。

有时子进程的错误信息是很有用的，那么父进程怎么才能获取子进程的错误信息呢？

这里我们可以重定向子进程的错误输出，让错误输出重定向到标准输出（2>&1），这样父进程就可以捕获子进程的错误信息了。例如command为“ls nofile.txt 2>&1”,输出如下：

命令【ls nofile.txt 2>&1】 输出【ls: nofile.txt: No such file or directory】

命令【ls nofile.txt 2>&1】子进程结束状态【256】命令返回值【1】

附：子进程的终止状态判断涉及到的宏，设进程终止状态为status.

WIFEXITED(status)如果子进程正常结束则为非0值。

WEXITSTATUS(status)取得子进程exit()返回的结束代码，一般会先用WIFEXITED 来判断是否正常结束才能使用此宏。

WIFSIGNALED(status)如果子进程是因为信号而结束则此宏值为真。

WTERMSIG(status)取得子进程因信号而中止的信号代码，一般会先用WIFSIGNALED 来判断后才使用此宏。

WIFSTOPPED(status)如果子进程处于暂停执行情况则此宏值为真。一般只有使用WUNTRACED 时才会有此情况。

WSTOPSIG(status)取得引发子进程暂停的信号代码，一般会先用WIFSTOPPED 来判断后才使用此宏。

转自：https://www.cnblogs.com/lidabo/p/5464134.html

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

