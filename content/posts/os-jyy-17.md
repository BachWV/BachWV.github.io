---
title: "操作系统-jyy-17"
date: 2022-09-03T22:32:41+08:00
draft: false
---

# 第17讲 动态链接和加载 (静态 ELF 加载器实现；调试 Linux 内核；动态链接和加载) 



从这里开始了看不懂的旅程



## 若干真正的静态elf加载器

a.out:ELF header ...

loader 需要做哪些工作：解析数据结构+复制到内存+跳转

用mmap系统调用把elf描述的结构搬到内存中相应的位置[loader-static.c](https://jyywiki.cn/pages/OS/2022/demos/loader-static.c)

设置运行时状态 argv,envp

这是魔法？有没有偷偷调用其他的加载器？jyy的loader对env做了处理，过滤掉了带下划线的环境变量，以此证明在这短短的几行里确实实现了一个loader-static

定义的函数功能与execve一样，用来从第一个参数中取file，直接映射文件的4096B到内存中。

下面是抄手册的过程

## Boot Loader 

Load kernel 过程

准备，load program

下面开始编译内核



## 动态链接

自然有运行时链接的需求

jyy表示elf内容很多，由于咱们的短时记忆能力有限，一灌输就会让我们栈溢出，导致咱们跟不少老师的思路

-fPIC: 位置无关代码，编译器会把代码编译成相对地址，来自阿里面试官的拷打
`gcc -fPIC -shared -o libfoo.so foo.c`


我们需要实现什么?

- 加载动态库
- 加载外部符号
- 为动态库导出符号
- 动态符号链接

```
DL_HEAD

LOAD("libc.dl") # 加载动态库
IMPORT(putchar) # 加载外部符号
EXPORT(hello)   # 为动态库导出符号

DL_CODE

hello:
  ...
  call DSYM(putchar) # 动态链接符号
  ...

DL_END
```

让我们自己打造一套加载dl的工具链（大部分偷来的

**dlbox！**



