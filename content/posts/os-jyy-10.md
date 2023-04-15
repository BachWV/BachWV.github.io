---
title: "操作系统-jyy-10"
date: 2022-07-26T16:09:12+08:00
---
# 同步：信号量与哲♂学家吃饭问题 (信号量的正确打开方式)

## 信号量：一种条件变量的特例
```c
void P(sem_t *sem) { // wait
  wait_until(sem->count > 0) {
    sem->count--;
  }
}

void V(sem_t *sem) { // post (signal)
  sem->count++;
}
```
正是因为条件的特殊性，信号量不需要 broadcast

- P 失败时立即睡眠等待
- 执行 V 时，唤醒任意等待的线程

# 第10讲 状态机模型的应用



## 细胞自动机

使用状态机视角理解物理世界

- 宏观物理世界近似于deterministic的状态机（经典力学

- 微观世界可能是 non-deterministic 的 (量子力学)



下面是一些畅想：

如果宇宙真的是一个状态机，随着时间切换状态。那么时间旅行能否被允许？如果回到过去，这时候的状态是否是过去的那个状态，还是过去的状态的copy，如果回到过去杀死祖父，会发生什么？（或许你不能把未来的状态带回过去，你也回不到过去）

说实话我也想过这个问题，上学期有一个cuda实验，是模拟nbody问题，当时一个很显然的结论是，不能跳着预测到未来，必须一步一步的模拟。也就是说，dp问题不能偷懒算，这是一个显然的事情，但是有没有一个世界，能支持这种运算呢？

https://www.scottaaronson.com/papers/philos.pdf

## gdb



对现代编译器来说，要保证源代码和机器码可观测行为严格一致，但内部可以做大量的优化。允许在状态机上跳跃

现在的处理器已经可以在一个周期执行超过一条指令。你会发现它超过了主频,Instruction per clock(IPC)>1

```
endwsl@LAPTOP-U1E6STIA:~/jyy/10$ gcc -O2 ilp-demo.c
endwsl@LAPTOP-U1E6STIA:~/jyy/10$ ./a.out
7.03G instructions/s
endwsl@LAPTOP-U1E6STIA:~/jyy/10$ ./a.out
8.81G instructions/s
```

观测状态机的执行

`strace -T`系统调用需要的时间

[gdb调试]({{< relref "gdb调试.md" >}})

gdb怎么回到上一个状态？

gdb隐藏功能：

`record full`

`reverse-step/reverse-stepi`回到过去

从这个小例子[rdrand](https://jyywiki.cn/pages/OS/2022/demos/rdrand.c)可以看出`rsi`的魔力

```

(gdb)record full
(gdb) si
(gdb) p val
$4 = 1919810
(gdb) si
(gdb) p val
$5 = 3129724904492477147
(gdb) p $rax
$6 = 3129724904492477147
(gdb) rsi
(gdb) p val
$7 = 1919810
```



## rr Record & Replay 

只需记录non-deterministic的指令的效果



```
endwsl@LAPTOP-U1E6STIA:~/jyy/10$ rr record ./a.out
[FATAL /build/rr-79viaC/rr-5.2.0/src/RecordSession.cc:1796:create()] rr needs /proc/sys/kernel/perf_event_paranoid <= 1, but it is 2.
Change it to 1, or use 'rr record -n' (slow).
Consider putting 'kernel.perf_event_paranoid = 1' in /etc/sysctl.conf
=== Start rr backtrace:
rr(_ZN2rr13dump_rr_stackEv+0x41)[0x562d705f7561]
rr(_ZN2rr15notifying_abortEv+0x49)[0x562d705f75f9]
rr(_ZN2rr13RecordSession6createERKSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESaIS7_EESB_RKNS_20DisableCPUIDFeaturesENS0_16SyscallBufferingENS_7BindCPUE+0xd38)[0x562d7055d618]
rr(_ZN2rr13RecordCommand3runERSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESaIS7_EE+0x6b2)[0x562d70552192]
rr(main+0x282)[0x562d704e2972]
/lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xeb)[0x7f6b4406309b]
rr(_start+0x2a)[0x562d704e2a8a]
=== End rr backtrace
Aborted
endwsl@LAPTOP-U1E6STIA:~/jyy/10$
```



所以，我们可以记录下操作系统的所有的执行过程，只需记录所有的io和中断，这样就对这个状态机的所有状态了如指掌

性能摘要，这好像是jyy实验室的方向

事实上不需要记录全部，观察状态机的执行，只需观察中断

## perf

这里jyy介绍了perf工具

然后我发现我的wsl也不支持，我们仍未知道那天运行这段代码花了多少周期

```
[root@iZwz92v9xcjopgz0rhkwh1Z c]# perf stat ./a.out
13.21G instructions/s

 Performance counter stats for './a.out':

            762.52 msec task-clock                #    0.999 CPUs utilized
                 6      context-switches          #    0.008 K/sec
                 1      cpu-migrations            #    0.001 K/sec
                52      page-faults               #    0.068 K/sec
   <not supported>      cycles
   <not supported>      instructions
   <not supported>      branches
   <not supported>      branch-misses

       0.763456230 seconds time elapsed

       0.757800000 seconds user
       0.000941000 seconds sys
```

实际中，80%的时间消耗在非常集中的几处代码。比如上次b站slb挂了，就通过火焰图发现所有时间都集中在gcd函数上了

## model checker

一些真正的 model checkers

- [TLA+](https://lamport.azurewebsites.net/tla/tla.html) by Leslie Lamport;

- [Java PathFinder (JFP)](https://ti.arc.nasa.gov/tech/rse/vandv/jpf/)

  和[SPIN](http://spinroot.com/)

  - 它们都喜欢用 Peterson 算法做 tutorial 😁

