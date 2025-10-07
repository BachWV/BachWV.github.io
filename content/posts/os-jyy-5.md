---
title: "操作系统-jyy-5 多处理器编程"
date: 2023-03-20
lastmod: 2025-10-07
draft: false
---

进程间是否共享内存？

- 是，怎么证明？

栈空间有多大？

- 大概8192KB

来看一个例子，基于线程库的编程

谁主导了这一切？

- 线程库

多线程比单线程多了什么？

- 放弃原子性
- 放弃执行顺序
- 放弃多处理器间内存访问的即时可见性

## 山寨支付宝多线程支付
对共享内存的修改，导致两次读到不同的x
```
       #include <pthread.h>

       int pthread_join(pthread_t thread, void **retval);

       Compile and link with -pthread.

       The pthread_join() function waits for the thread specified by
       thread to terminate.  If that thread has already terminated, then
       pthread_join() returns immediately.  The thread specified by
       thread must be joinable.

       If retval is not NULL, then pthread_join() copies the exit status
       of the target thread (i.e., the value that the target thread
       supplied to pthread_exit(3)) into the location pointed to by
       retval.  If the target thread was canceled, then PTHREAD_CANCELED
       is placed in the location pointed to by retval.

       If multiple threads simultaneously try to join with the same
       thread, the results are undefined.  If the thread calling
       pthread_join() is canceled, then the target thread will remain
       joinable (i.e., it will not be detached).
```
pthread_join()函数可以阻塞当前线程，直到指定的线程完成执行为止。它的作用是等待一个线程结束并回收它的资源，同时将线程的返回值传递给调用线程。
## 不正常的sum
```
#include "thread.h"
#define N 100000000
long sum = 0;
void Tsum() {
  for (int i = 0; i < N; i++) {
    //sum++;
    asm volatile(
        "incq %0" : "+m"(sum)
    );
  }
}
int main() {
  create(Tsum);
  create(Tsum);
  join();
  printf("sum = %ld\n", sum);
}
```
你可能得不到200000000这个答案，为什么？

哦，这该死的编译器


## 2025年jyy又升级了sum


https://jyywiki.cn/OS/2025/lect13.md

```python
def T_sum():
    for _ in range(3):
        t = heap.sum
        sys_sched()
        t = t + 1
        heap.sum = t
        sys_sched()
    heap.done += 1

def main():
    heap.sum = 0
    heap.done = 0
    sys_spawn(T_sum)
    sys_spawn(T_sum)
    sys_spawn(T_sum)
    while heap.done != 3:
        sys_sched()
    sys_write(f'sum = {heap.sum}\n')
```

这里有一个循环3次的load和store，多进程的条件下，sum最终结果的最小值是2

原因如下，可以找到这样一个极端情况。

| T1       | T2       | T3       |
|----------|----------|----------|
| Load 0   |          |          |
|          | Load 0   |          |
| Store 1  |          |          |
| Load 1   |          |          |
| Store 2  |          |          |
|          | Store 1  |          |
| Load 1   |          |          |
|          | Load 1   |          |
|          | Store 2  |          |
|          | Load 2   |          |
|          | Store 3  |          |
|          |          | Load 3   |
|          |          | Store 4  |
|          |          | Load 4   |
|          |          | Store 5  |
|          |          | Load 5   |
|          |          | Store 6  |
| Store 2  |          |          |


使用jyy的model checker 测试一下，确实会出现
```bash
time uv run  ./mosaic.py -c ../sum-model/sum.py | uv run ./collect.py 
sum = 2⏎ 
sum = 3⏎ 
sum = 4⏎ 
sum = 5⏎ 
sum = 6⏎ 
sum = 7⏎ 
sum = 8⏎ 
sum = 9⏎ 
|V| = 92565, |E| = 333826.
There are 8 distinct outputs.
real    0m28.018s
user    0m27.243s
sys     0m0.796s
```
在多处理器并行调度的情况下，找到这个解似乎也是np complete的问题。

将循环次数改为4次：验证的时间就过长了。
```bash
time uv run  ./mosaic.py -c ../sum-model/sum.py | uv run ./collect.py 
sum = 10⏎ 
sum = 11⏎ 
sum = 12⏎ 
sum = 2⏎ 
sum = 3⏎ 
sum = 4⏎ 
sum = 5⏎ 
sum = 6⏎ 
sum = 7⏎ 
sum = 8⏎ 
sum = 9⏎ 
|V| = 489052, |E| = 1814000.
There are 11 distinct outputs.
real    2m51.901s
user    2m47.937s
sys     0m3.937s
```





## 其他意想不到的问题：
- 处理器指令重排

```c

int x = 0, y = 0;

void T1() {
  x = 1;  // Store(x)
  printf("%d", y);  // Load(y)
}

void T2() {
  y = 1;  // Store(y)
  printf("%d", x); // Load(x)
}
```
理论上不会出现0 0 

实际上最多出现的就是0 0

```shell
$ ./a.out | head -n 1000000 |sort |uniq -c
 902562 0 0 
  92944 0 1 
   4461 1 0 
     33 1 1 
```
当你排除了一切不可能，不是代码，编译器的问题，只有在执行指令的时候除了问题

store(x) 和load(x)没有数据依赖，被重新排列了

卧槽，这cpu，跟我玩阴的。

当 x≠=y 时，对 x,y 的内存读写可以交换顺序

它们甚至可以在同一个周期里完成 (只要 load/store unit 支持)
如果写 x 发生 cache miss，可以让读 y 先执行满足 “尽可能执行 μop” 的原则，最大化处理器性能.

x86的内存模型是宽松内存模型
![](https://jyywiki.cn/pages/OS/img/x86-tso.png)
是你能理解的正常的内存模型

ARM/RISC-V的内存模型就很奇葩

体系结构的不同导致跨指令集翻译变得困难，Rosstta && Latx如何实现？谁也不知道


多线程那么困难，为什么还要怎么做？
**Proformance!**
**榨干性能**

所以，当我们写并发程序时，请不要相信直觉、编译器、处理器，请加锁。

>> 然而，人类本质上是物理世界 (宏观时间) 中的 “sequential creature”，因此我们在编程时，也 “只能” 习惯单线程的顺序/选择/循环结构，真实多处理器上的并发编程是非常具有挑战性的 “底层技术”，例如 Ad hoc synchronization 引发了很多系统软件中的 bugs。因此，我们需要并发控制技术 (之后的课程涉及)，使得程序能在不共享内存的时候并行执行，并且在需要共享内存时的行为能够 “容易理解”。


## 最后一部分 
如果我 munmap/mprotect 改变一段内存？
有另外一个线程在另一个 CPU 上执行
内存都没了，它还在执行？

不会“继续正常执行”——它会立即（或很快）收到异常（如 SIGSEGV），因为操作系统会通过 “TLB（Translation Lookaside Buffer） shootdown” 机制强制所有 CPU 核心同步页表变更。会向所有正在运行该进程的 CPU 核心发送 IPI（Inter-Processor Interrupt）。
收到 IPI 的 CPU 会：
刷新（invalidate）本地 TLB （每个 CPU 核心都有自己的 TLB，用于缓存虚拟地址 → 物理地址的映射。）中对应的条目；
下次再访问该虚拟地址时，会重新查页表 → 发现映射已无效 → 触发 page fault。

Linux 内核源码中 flush_tlb_page()、flush_tlb_mm() 等函数实现了 TLB shootdown；x86 上通过 invlpg 指令或写 CR3 触发局部刷新，跨核靠 IPI。 