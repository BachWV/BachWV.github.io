---
title: "操作系统-jyy-20"
date: 2022-09-10T22:32:41+08:00
draft: false
---

# 第20讲 处理器调度

(RR, MLFQ 和 CFS；优先级翻转；多处理器调度) 

上下文切换的策略



中断机制

- 处理器以固定的频率被中断
  - Linux Kernel可以配置：100/250/300/1000hz
- 中断/系统调用返回时可以自由选择进程/线程执行

