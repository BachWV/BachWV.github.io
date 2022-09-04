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

