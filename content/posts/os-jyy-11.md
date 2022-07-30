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

复习[第九讲]({{< relref "os-jyy-9.md" >}})的内容

操作系统内核的启动： CPU Reset-> BIOS/UEFI->Boot loader->Kernel_start()

本次课回答的问题

- **Q1**: 操作系统启动后到底做了什么？
- **Q2**: 操作系统如何管理程序 (进程)？
