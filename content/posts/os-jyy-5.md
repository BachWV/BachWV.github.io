---
title: "操作系统-jyy-5 多处理器编程"
date: 2023-3-20
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