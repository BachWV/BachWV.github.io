---
title: "操作系统-jyy-7"
date: 2022-07-16T18:01:22+08:00
draft: false
toc: true
---

# 第七讲 并发控制 互斥

## 自旋锁

## 互斥锁
把锁的实现放到操作系统里
- syscall(SYSCALL_lock,&lk); 试图获得lk，如果失败，就切换到其他线程
- syscall(SYSCALL_unlock,&lk);释放lk，如果有等待锁的线程，就唤醒它