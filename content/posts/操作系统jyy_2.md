---
title: "操作系统-jyy-2"
date: 2022-06-20T22:32:41+08:00
draft: false
---

# 第二讲

主要内容

- 程序的状态机模型（和编译器）
- 操作系统上的{最小/一般/图像}程序
  

## 1.什么是程序

程序是状态机

jyy用一个数码管的例子，来把状态机的概念更清晰地表示了

管道yyds！

c语言程序是状态机


状态栈帧的列表+全局变量

初始状态=main(argc,argv)

迁移=执行top stack frame PC++



函数调用时是什么？

栈帧oush stack frame

创建新栈帧

函数返回pop stack frame

一些小tips

分屏 Windows Terminal可以用alt shift =/- 来左右/上下分屏，jyy用的是tmux

terminal可以在explorer地址栏直接输入wt打开，记得配置要选父进程



扩展阅读：

介绍一个define的用法

```c
#define REGS_FOREACH(_)  _(X) _(Y)
#define RUN_LOGIC        X1 = !X && Y; \
                         Y1 = !X && !Y;
#define DEFINE(X)        static int X, X##1;
#define UPDATE(X)        X = X##1;
#define PRINT(X)         printf(#X " = %d; ", X);

int main() {
  REGS_FOREACH(DEFINE);
  while (1) { // clock
    RUN_LOGIC;
    REGS_FOREACH(PRINT);
    REGS_FOREACH(UPDATE);
    putchar('\n'); sleep(1);
  }
}
```

使用`gcc -E`展开

```c
int main() {
  static int X, X1; static int Y, Y1;;
  while (1) {
    X1 = !X && Y; Y1 = !X && !Y;;
    printf("X" " = %d; ", X); printf("Y" " = %d; ", Y);;
    X = X1; Y = Y1;;
    putchar('\n'); sleep(1);
  }
}
```

`#define t(func) func(x) func(y)`，遇到t(abs)展开以后变成 abs(x) abs(y)

`##`是连接操作符

什么意思呢
```c
#define Conn(x,y) x##y
#define ToChar(x) #@x
#define ToString(x) #x
```
表示x连接y

```c
int n = Conn(123,456);
     ==> int n=123456;
char* str = Conn("asdf", "adf");
     ==> char* str = "asdfadf";
```

## 2.什么是二进制程序

用gdb调试汇编代码


gdb layout asm

syscall 系统调用

改变进程状态，创建进程或销毁自己

当年在写汇编的时候，发现只去做加减，做运算是远远不够的，你不可能无限循环下去，你写出的绝妙的汇编矩阵乘法，如果没有输入输出，有什么用？
当时就有一个想法，能不能不用操作系统，直接在cpu上运行asm代码？当然可以，但有什么用？没有输入输出，你只能看到一个黑盒子里面不知道发生了什么。
所以必须要有操作系统，就比如用INT 21H 中断退出程序。


`gcc -c`只编译不链接

最小的c代码是可以运行的

```c
void main(){

}

```
链接警告,定义成_start避免警告

哈哈居然可以不以main函数为开头，见到c语言代码必须有main函数是不是可以判错了

```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# vim os_litter.c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc -c os_litter.c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ls
a.out  os.c  os_litter.c  os_litter.o
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ld os_litter.o
ld: warning: cannot find entry symbol _start; defaulting to 00000000004000b0

```
改成这个

```c
void _start(){

}

```

可以链接，运行失败
```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc -c os_litter.c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ld os_litter.o
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ./a.out
Segmentation fault (core dumped)
```


加一个while(1)就可以运行了


```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc -c os_litter.c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ld os_litter.o
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ./a.out
^C
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ll
total 16
-rwxr-xr-x 1 root root 1104 Jun 23 21:12 a.out
-rw-r--r-- 1 root root  483 Jun 23 20:01 os.c
-rw-r--r-- 1 root root   32 Jun 23 21:12 os_litter.c
-rw-r--r-- 1 root root 1232 Jun 23 21:12 os_litter.o
[root@iZwz92v9xcjopgz0rhkwh1Z c]# size a.out
   text    data     bss     dec     hex filename
     58       0       0      58      3a a.out
[root@iZwz92v9xcjopgz0rhkwh1Z c]#
```
这是一个超级小的a.out

观察此状态机的运行的工具：gdb

starti可以帮助我们从第一条指令开始执行程序

```bash

native process 1247611 In: _start            L??   PC: 0x4000b0    ┌───────────────────────────────────────────────────────────┐
  >│0x4000b0 <_start>       push   %rbp                        │ 
  │0x4000b1 <_start+1>     mov    %rsp,%rbp                   │   
  │0x4000b4 <_start+4>     jmp    0x4000b4 <_start+4>         │   
  │0x4000b6                add    %al,(%rax)                  │   
  │0x4000b8                adc    $0x0,%al                    │   
  │0x4000ba                add    %al,(%rax)                  │   
  │0x4000bc                add    %al,(%rax)                  │   
  │0x4000be                add    %al,(%rax)                  │   
  │0x4000c0                add    %edi,0x52(%rdx)             │   
  │0x4000c3                add    %al,(%rcx)                  │   
  │0x4000c5                js     0x4000d7                    │   
  │0x4000c7                add    %ebx,(%rbx)                 │   
  │0x4000c9                or     $0x7,%al                    │   
  │0x4000cb                or     %dl,0x18000001(%rax)        │   
  │0x4000d1                add    %al,(%rax)                  │   
  │0x4000d3                add    %bl,(%rax,%rax,1)           │   
  │0x4000d6                add    %al,(%rax)                  │
   └───────────────────────────────────────────────────────────┘
native process 1247611 In: _start            L??   PC: 0x4000b0
(gdb)

```



```bash
   ┌───────────────────────────────────────────────────────────┐
  >│0x4000b0 <_start>       push   %rbp                        │
   │0x4000b1 <_start+1>     mov    %rsp,%rbp                   │
   │0x4000b4 <_start+4>     nop                                │
   │0x4000b5 <_start+5>     pop    %rbp                        │
   │0x4000b6 <_start+6>     retq                               │
   │0x4000b7                add    %dl,(%rax,%rax,1)           │
   │0x4000ba                add    %al,(%rax)                  │
   │0x4000bc                add    %al,(%rax)                  │
   │0x4000be                add    %al,(%rax)                  │
   │0x4000c0                add    %edi,0x52(%rdx)             │
   │0x4000c3                add    %al,(%rcx)                  │
   │0x4000c5                js     0x4000d7                    │
   │0x4000c7                add    %ebx,(%rbx)                 │
   │0x4000c9                or     $0x7,%al                    │
   │0x4000cb                or     %dl,0x1c000001(%rax)        │
   │0x4000d1                add    %al,(%rax)                  │
   │0x4000d3                add    %bl,(%rax,%rax,1)           │   └───────────────────────────────────────────────────────────┘

   ┌───────────────────────────────────────────────────────────┐
   │0x4000b0 <_start>       push   %rbp                        │
   │0x4000b1 <_start+1>     mov    %rsp,%rbp                   │
   │0x4000b4 <_start+4>     nop                                │
   │0x4000b5 <_start+5>     pop    %rbp                        │
  >│0x4000b6 <_start+6>     retq                               │
   │0x4000b7                add    %dl,(%rax,%rax,1)           │
   │0x4000ba                add    %al,(%rax)                  │
   │0x4000bc                add    %al,(%rax)                  │
   │0x4000be                add    %al,(%rax)                  │
   │0x4000c0                add    %edi,0x52(%rdx)             │
   │0x4000c3                add    %al,(%rcx)                  │
   │0x4000c5                js     0x4000d7                    │
   │0x4000c7                add    %ebx,(%rbx)                 │
   │0x4000c9                or     $0x7,%al                    │
   │0x4000cb                or     %dl,0x1c000001(%rax)        │
   │0x4000d1                add    %al,(%rax)                  │
   │0x4000d3                add    %bl,(%rax,%rax,1)           │   └───────────────────────────────────────────────────────────┘
native process 1247751 In:                        L??   PC: 0x1
(gdb) si
0x00000000004000b4 in _start ()
(gdb) si
0x00000000004000b5 in _start ()
(gdb) si
0x00000000004000b6 in _start ()
(gdb) si
0x0000000000000001 in ?? ()
Cannot access memory at address 0x1
```
没有`while`的`void _start(){}`
错位的地方在retq
原因 返回的地址是非法的0x1?

解决方法：增加系统调用42

```
#include<sys/syscall.h>
int main(){
    syscall(SYS_exit,42);
}
```

这就没有问题了，正常返回了

```bahs
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc ex_sys.c
ex_sys.c: In function ‘main’:
ex_sys.c:3:5: warning: implicit declaration of function ‘syscall’ [-Wimplicit-function-declaration]
     syscall(SYS_exit,42);
     ^~~~~~~
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ls
a.out  ex_sys.c  os.c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ./a.out
[root@iZwz92v9xcjopgz0rhkwh1Z c]#

```
syscall的实现在libc里，不方便直接链接


```bash
   ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
  >│0x40059a <main+4>               mov    $0x2a,%esi                                              │
   │0x40059f <main+9>               mov    $0x3c,%edi                                              │
   │0x4005a4 <main+14>              mov    $0x0,%eax                                               │
   │0x4005a9 <main+19>              callq  0x4004a0 <syscall@plt>                                  │
   │0x4005ae <main+24>              mov    $0x0,%eax                                               │
   │0x4005b3 <main+29>              pop    %rbp                                                    │
   │0x4005b4 <main+30>              retq                                                           │
   │0x4005b5                        nopw   %cs:0x0(%rax,%rax,1)                                    │
   │0x4005bf                        nop                                                            │
   │0x4005c0 <__libc_csu_init>      endbr64                                                        │
   │0x4005c4 <__libc_csu_init+4>    push   %r15                                                    │
   │0x4005c6 <__libc_csu_init+6>    mov    %rdx,%r15                                               │
   │0x4005c9 <__libc_csu_init+9>    push   %r14                                                    │
   │0x4005cb <__libc_csu_init+11>   mov    %rsi,%r14                                               │
   │0x4005ce <__libc_csu_init+14>   push   %r13                                                    │
   │0x4005d0 <__libc_csu_init+16>   mov    %edi,%r13d                                              │
   │0x4005d3 <__libc_csu_init+19>   push   %r12                                                    │
   │0x4005d5 <__libc_csu_init+21>   lea    0x200824(%rip),%r12        # 0x600e00                   │
   │0x4005dc <__libc_csu_init+28>   push   %rbp                                                    │
   │0x4005dd <__libc_csu_init+29>   lea    0x200824(%rip),%rbp        # 0x600e08                   │
   │0x4005e4 <__libc_csu_init+36>   push   %rbx                                                    │
   └───────────────────────────────────────────────────────────────────────────────────────────────┘
native process 1247963 In: main                                                  L??   PC: 0x40059a
(gdb)
```
这里能看到callq

jyy为我们准备了最小的汇编代码，我哭死

```asm
#include <sys/syscall.h>

.globl _start
_start:
  movq $SYS_write, %rax   # write(
  movq $1,         %rdi   #   fd=1,
  movq $st,        %rsi   #   buf=st,
  movq $(ed - st), %rdx   #   count=ed-st
  syscall                 # );

  movq $SYS_exit,  %rax   # exit(
  movq $1,         %rdi   #   status=1
  syscall                 # );

st:
  .ascii "\033[01;31mHello, OS World\033[0m\n"
ed:

```
接下来见证奇迹

```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc minimal.S -c &&ld minimal.o
[root@iZwz92v9xcjopgz0rhkwh1Z c]# ./a.out
Hello, OS World
```

甚至也可以用gdb看执行过程

```bash
   │0x40008d <_start+21>    mov    $0x1c,%rdx                                                      │
  >│0x400094 <_start+28>    syscall                                                                │
   │0x400094 <_start+28>    syscall 0x3c,%rax                                                      │
   │0x400096 <_start+30>    mov    $0x3c,%rax                                                      │
  >│0x40009d <_start+37>    mov    $0x1,%rdi                                                       │
   │0x4000a6 <st>           sbb    0x30(%rbx),%ebx                                                 │
   │0x4000a9 <st+3>         xor    %edi,(%rbx)                                                     │
   │0x4000ab <st+5>         xor    (%rcx),%esi                                                     │
   │0x4000ad <st+7>         insl   (%dx),%es:(%rdi)                                                │
   │0x4000ae <st+8>         rex.W                                                                  │
   │0x4000af <st+9>         gs insb (%dx),%es:(%rdi)                                               │
   │0x4000b1 <st+11>        insb   (%dx),%es:(%rdi)                                                │
   │0x4000b2 <st+12>        outsl  %ds:(%rsi),(%dx)                                                │
   │0x4000b3 <st+13>        sub    $0x20,%al                                                       │
   │0x4000b5 <st+15>        rex.WRXB push %r11                                                     │
   │0x4000b7 <st+17>        and    %dl,0x6f(%rdi)                                                  │
   │0x4000ba <st+20>        jb     0x400128                                                        │
   │0x4000bc <st+22>        sbb    %fs:0x30(%rbx),%ebx                                             │
   └───────────────────────────────────────────────────────────────────────────────────────────────┘
native process 1248099 In: _start                                                L??   PC: 0x400094
(gdb) starti                                                                                      d
Program stopped.
0x0000000000400078 in _start ()
(gdb) si
0x000000000040007f in _start ()
0x0000000000400086 in _start ()
0x000000000040008d in _start ()
0x0000000000400094 in _start ()
Hello, OS World
0x0000000000400096 in _start ()
0x000000000040009d in _start ()
(gdb)


```


## 3.什么是正确的编译

除去不可优化的部分都给它优化了
inline assembly也可以参与优化

未来的编译器 

根据语义优化，把冒泡优化成快排

- semantic-based compilation

- AI-based rewriting

扩展阅读：

An executable formal semantics of C with applications (POPL'12)

ComCert C verified compiler and a paper(POPL'06,Most Influential Paper Award)

Copy-and-patch compilation (OOPSLA'21 Distinguished Paper) 

PL的领域有一种倾向：用数学化的语言定义和理解一切

背后的直觉依然是System/software

## 4.操作系统中的一般程序

和minimal.S没有本质区别：程序=计算->syscall

操作系统收编（管理）了所有的硬件/软件资源
- 只能用操作系统允许的方式访问操作系统的对象

```c
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

void try_open(const char *fname) {
  int fd = open(fname, O_RDWR);
  printf("open(\"%s\") returns %d\n", fname, fd);
  if (fd < 0) {
    perror("  FAIL");
  } else {
    printf("  SUCCESS!\n");
    close(fd);
  }
}

int main() {
  try_open("/something/not/exist");
  try_open("/dev/sda"); // hard drive
}
```


```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# gcc tryopen.c &&./a.out
open("/something/not/exist") returns -1
  FAIL: No such file or directory
open("/dev/") returns -1
  FAIL: Is a directory
```

### 常见的应用程序
#### Core Utilities

#### 系统/工具程序

bash,binutils,apt,ip,ssh,vim,tmux,python

Hello World输出的第一条指令是什么，第一条指令在libc里

main()之前发生了什么

ld-linux-x86-64.so 加载了libc

之后libc完成了自己的初始化

- RTFM: libc startup on Hurd
- main() 的开始/结束并不是整个程序的开始/结束
```c
[root@iZwz92v9xcjopgz0rhkwh1Z c]# cat hello-goodbye.c
#include <stdio.h>

__attribute__((constructor)) void hello() {
  printf("Hello, World\n");
}

// See also: atexit(3)
__attribute__((destructor)) void goodbye() {
  printf("Goodbye, Cruel OS World!\n");
}

int main() {
}
```
在main()执行前/后执行指令


为什么是ld-linux-x86-64.so而不是其他的.so

elf里写的是ld-linux-x86-64.so

strace能看到所有的系统调用

```bash
[root@iZwz92v9xcjopgz0rhkwh1Z c]# strace ./a.out
execve("./a.out", ["./a.out"], 0x7ffcbb202a30 /* 37 vars */) = 0
brk(NULL)                               = 0x12ae000
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffcb59f2750) = -1 EINVAL (Invalid argument)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0035dbc000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=24711, ...}) = 0
mmap(NULL, 24711, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f0035db5000
close(3)                                = 0
openat(AT_FDCWD, "/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2405\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=3167872, ...}) = 0
lseek(3, 808, SEEK_SET)                 = 808
read(3, "\4\0\0\0\20\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0", 32) = 32
mmap(NULL, 3950400, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f00357cd000
mprotect(0x7f0035989000, 2093056, PROT_NONE) = 0
mmap(0x7f0035b88000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1bb000) = 0x7f0035b88000
mmap(0x7f0035b8e000, 14144, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f0035b8e000
close(3)                                = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0035db3000
arch_prctl(ARCH_SET_FS, 0x7f0035dbd600) = 0
mprotect(0x7f0035b88000, 16384, PROT_READ) = 0
mprotect(0x600000, 4096, PROT_READ)     = 0
mprotect(0x7f0035dbe000, 4096, PROT_READ) = 0
munmap(0x7f0035db5000, 24711)           = 0
openat(AT_FDCWD, "/something/not/exist", O_RDWR) = -1 ENOENT (No such file or directory)
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
brk(NULL)                               = 0x12ae000
brk(0x12cf000)                          = 0x12cf000
brk(NULL)                               = 0x12cf000
write(1, "open(\"/something/not/exist\") ret"..., 40open("/something/not/exist") returns -1
) = 40
dup(2)                                  = 3
fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
fstat(3, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
write(3, "  FAIL: No such file or director"..., 34  FAIL: No such file or directory
) = 34
close(3)                                = 0
openat(AT_FDCWD, "/dev/", O_RDWR)       = -1 EISDIR (Is a directory)
write(1, "open(\"/dev/\") returns -1\n", 25open("/dev/") returns -1
) = 25
dup(2)                                  = 3
fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
fstat(3, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0
write(3, "  FAIL: Is a directory\n", 23  FAIL: Is a directory
) = 23
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
[root@iZwz92v9xcjopgz0rhkwh1Z c]#
```

本质上所有的程序和 Hello World 类似

程序 = 状态机 = 计算 → syscall → 计算 →

- 被操作系统加载

通过另一个进程执行 execve 设置为初始状态
- 状态机执行
  - 进程管理：fork, execve, exit, ...
  - 文件/设备管理：open, close, read, write, ...
  - 存储管理：mmap, brk, ...
- 直到 _exit (exit_group) 退出

(初学者对这一点会感到有一点惊讶)

说好的浏览器、游戏、杀毒软件、病毒呢？都是这些 API 吗？

这些 API 就是操作系统的全部

编译器 (gcc)，代表其他工具程序

- 主要的系统调用：execve, read, write
- strace -f gcc a.c (gcc 会启动其他进程)
  - 可以管道给编辑器 vim -
  - 编辑器里还可以 %!grep (细节/技巧)

`strace -f gcc a.c |& vim -`

图形界面程序 (xedit)，代表其他图形界面程序 (例如 vscode)

- 主要的系统调用：poll, recvmsg, writev
- strace xedit
  - 图形界面程序和 X-Window 服务器按照 X11 协议通信
  - 虚拟机中的 xedit 将 X11 命令通过 ssh (X11 forwarding) 转发到 Host
