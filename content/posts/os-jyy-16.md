---
title: "操作系统-jyy-16"
date: 2022-09-02T22:32:41+08:00
draft: false
---

# 第16讲 什么是可执行文件 (调试信息；Stack Unwinding；静态链接中的重定位)

今天的例子只有静态链接

一个重要的手册System V ABI，一切的内容都在这里面了。

如何读手册？

需要前置知识才能读懂。对我们入门的人来说怎么办？

关键的内容的部分，找到关键内容再去dfs扩散

可执行文件是最重要的操作系统对象。用来被execve系统调用使用。

状态机的状态，实际上是内存和寄存器的状态

exec执行一个非可执行文件自然会失败，为什么？操作系统不让你执行
execve=-1,ENOEXEC
这是什么？

查看手册
```
 ENOEXEC
              An executable is not in a recognized format, is for the wrong architecture, or
              has some other format error that means it cannot be executed.
```

she-bang的方法偷梁换柱
a.c
```
#!/usr/bin/python3
print("hello")
```
这也可以执行。

那么b.c，执行./b.c实际上会执行a.out
```c
#!./a.out
argv1 argv2
```
相当于execve帮你偷传参数了，相当于execve("./a.out","argv1", "argv2")

在手册中是这么写的
```
  Interpreter scripts
       An interpreter script is a text file that has execute permission  enabled  and  whose
       first line is of the form:

           #!interpreter [optional-arg]

       The interpreter must be a valid pathname for an executable file.

       If  the  pathname  argument  of execve() specifies an interpreter script, then inter‐
       preter will be invoked with the following arguments:
```
二进制工具集
binutils

数据结构查看修改工具

调试器读取运行时状态。为什么gdb知道出错的位置？

靠的是二进制文件中的info。

`gcc -g`

## 关于popcount，我好像还有一点话要说
```c
#include <stdio.h>

__attribute__((noinline))
int popcount(int x) {
  int s = 0;
  int b0 = (x >> 0) & 1;
  s += b0;
  int b1 = (x >> 1) & 1;
  s += b1;
  int b2 = (x >> 2) & 1;
  s += b2;
  int b3 = (x >> 3) & 1;
  s += b3;
  return s;
}

int main() {
  printf("%d\n", popcount(0b1101));
}
```
在某个知乎回答上我提过[bitcount]({{< relref "多少个1.md" >}})
底下就有z友评论了，不是有内建的popcount吗？😅建议不要用这种代码。内建的popcount 有些实现是汇编使用cpu机器指令，比这个快一倍轻轻松松。

当然我看到的小技巧不一定比汇编实现的快，啊对对对。


## 编译和链接 compile and link

relocation

S+A-P 太难了，没看懂



## 重新理解编译、链接流程
编译器 (gcc)

High-level semantics (C 状态机) → low-level semantics (汇编)

汇编器 (as)

Low-level semantics → Binary semantics (状态机容器)

- “一一对应” 地翻译成二进制代码

- sections, symbols, debug info
不能决定的要留下 “之后怎么办” 的信息
relocations
链接器 (ld)

合并所有容器，得到 “一个完整的状态机”
- ldscript (-Wl,--verbose); 和 C Runtime Objects (CRT) 链接
- missing/duplicate symbol 会出错

奇怪，我们完全没有讲 ELF 的细节？
ELF 就是一个 “容器数据结构”，包含了必要的信息

你完全可以试着自己定义二进制文件格式 (dump it to disk)！
```c
struct executable {
  uint32_t entry;
  struct segment *segments;
  struct reloc *relocs;
  struct symbol *symbols;
};
struct segment { uint32_t flags, size; char data[0]; }
struct reloc   { uint32_t S, A, P; char name[32]; };
struct symbol  { uint32_t off; char name[32]; };
```

当然，这有很多缺陷
- “名字” 其实应该集中存储 (const char * 而不是 char[])
- 慢慢理解了 ELF 里的各种设计 (例如 memsz 和 filesz 不一样大)