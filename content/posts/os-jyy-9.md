---
title: "操作系统-jyy-9"
date: 2022-07-26T16:09:07+08:00
---
# 同步：生产者-消费者与条件变量 (算法并行化；万能同步方法)
生活中的同步

并发程序的同步
- 线程同步：在某个时间点共同达到互相已知的状态

## 什么是生产者-消费者问题？

先来看看这个
```c
void Tproduce(){while(1) printf("(");}
void Tconsume(){while(1) printf(")");}
```
在printf前后增加代码，使得打印的括号序列满足
- 一定是某个合法的括号序列的前缀
- 括号嵌套的深度不超过n
如果你能解决上面这个问题，那么你就能解决生产者-消费者问题。

所以生产者-消费者问题可以这样理解：
打印左括号：生产资源(任务)、放入队列
打印右括号：从队列中取出资源（任务）执行

## 计算图
寻找并行计算的机会
- 计算任务构成有向无环图

## 生产者-消费者实现
使用互斥锁保证条件满足
- 左括号：嵌套深度不足n时才能打印
- 右括号：嵌套深度大于0时才能打印

```c
#include "thread.h"
#include "thread-sync.h"

int n, count = 0;
mutex_t lk = MUTEX_INIT();

#define CAN_PRODUCE (count < n)
#define CAN_CONSUME (count > 0)

void Tproduce() {
  while (1) {
retry:
    mutex_lock(&lk);//上锁，如果有其他线程抢这个锁，其他线程上锁失败，切换到有锁线程执行
    if (!CAN_PRODUCE) { 
      mutex_unlock(&lk);//判断条件不满足，循环，此时操作系统切换到其他等待锁的线程执行
      goto retry;
    }
    count++;
    printf("(");  // Push an element into buffer
    mutex_unlock(&lk);
  }
}

void Tconsume() {
  while (1) {
retry:
    mutex_lock(&lk);
    if (!CAN_CONSUME) {
      mutex_unlock(&lk);
      goto retry;
    }
    count--;
    printf(")");  // Pop an element from buffer
    mutex_unlock(&lk);
  }
}

int main(int argc, char *argv[]) {
  assert(argc == 2);
  n = atoi(argv[1]);
  setbuf(stdout, NULL);
  for (int i = 0; i < 8; i++) {
    create(Tproduce);
    create(Tconsume);
  }
}
```

检测输出是否正确
pc-check.py
```python
import sys

BATCH_SIZE = 100000

limit = int(sys.argv[1])
count, checked = 0, 0

while True:
    for ch in sys.stdin.read(BATCH_SIZE):
        match ch:
            case '(': count += 1
            case ')': count -= 1
            case _: assert 0
        assert 0 <= count <= limit
    checked += BATCH_SIZE
    print(f'{checked} Ok.')
```

通过管道传值`./a.out 2|python3 pc-check.py 2`
未来：ai帮我们做这些事
## 条件变量
一把互斥锁+一个条件变量+手工唤醒
- wait(cv,mutex)
  - 调用时必须保证已经获得mutex
  - wait释放mutex、进入睡眠状态、等待被唤醒
  - 被唤醒后需要重新执行lock(mutex)
- signal/notity(cv)
  - 唤醒一个等待在cv上的线程
  - 如果没有线程在cv上等待，则不做任何事情
- broadcast(notify_all)(cv)
  - 唤醒所有等待在cv上的线程
  - 如果没有线程在cv上等待，则不做任何事情
## 错误的条件变量实现
```c
#include "thread.h"
#include "thread-sync.h"

int n, count = 0;
mutex_t lk = MUTEX_INIT();
cond_t cv = COND_INIT();
 
#define CAN_PRODUCE (count < n)
#define CAN_CONSUME (count > 0)

void Tproduce() {
  while (1) {
    mutex_lock(&lk);
    while (!CAN_PRODUCE) {
      cond_wait(&cv, &lk);
    }
    printf("("); count++;
    cond_signal(&cv);
    mutex_unlock(&lk);
  }
}

void Tconsume() {
  while (1) {
    mutex_lock(&lk);
    while (!CAN_CONSUME) {
      cond_wait(&cv, &lk);
    }
    printf(")"); count--;
    cond_signal(&cv);
    mutex_unlock(&lk);
  }
}

int main(int argc, char *argv[]) {
  assert(argc == 3);
  n = atoi(argv[1]);
  int T = atoi(argv[2]); // Number of threads,add by copilot
  setbuf(stdout, NULL);
  for (int i = 0; i < T; i++) {
    create(Tproduce);
    create(Tconsume);
  }
}
```
`./a.out 1 2`
出现了错误的答案，两个线程失败了？
假设有两个consume在等待，produce打印了"("唤醒了一个consume,打印了")"，consume随机唤醒一个条件变量，唤醒了consume,打印了")"，错误的答案出现了
还是没弄懂唤醒后继续执行吗？
# 第9讲 操作系统的状态机模型

谁加载了操作系统？



不能被小学生吓倒，小学生是用有限的资料探索，大学能将已有的经验的方法重新消化，建立知识体系。

破除迷信，操作系统真的就是一个C程序，只是需要一些额外的东西。

//需要的素质：

//难调试的问题怎么办？

回到之前最小的C程序的例子：minimal.S

它不需要任何依赖库，直接用汇编

如果没有操作系统，如何直接在硬件上运行minimal.S?

硬件厂商会约定，只要按照约定来就没问题了

根据CPU手册(https://cdrdv2.intel.com/v1/dl/getContent/671190)，对intel x86来说，reset后 Real mode =0 处在16位兼容模式，

ELPAGS=0X0000002 中断关闭

![intel-IA32-doc.png](https://s2.loli.net/2022/09/06/LKtdAp13oEIF6bw.png)

CPU reset后，CPU这个状态机的初始状态是唯一确定，PC指针指向一段memory-mapped ROM,这虽然是内存地址，但是是ROM断电后仍能保存数据，PC=ffff0

用qemu-x86_64模拟一下

```
(gdb) info register
rip            0xfff0              0xfff0
eflags         0x2                 [ IOPL=0 ]
cs             0xf000              61440

(gdb) x/16xb 0xffff0
0xffff0:        0xea    0x5b    0xe0    0x00    0xf0    0x30    0x36    0x2f
0xffff8:        0x32    0x33    0x2f    0x39    0x39    0x00    0xfc    0x00
(gdb) x/10i ($cs * 16 + $rip)
   0xffff0:     (bad)
   0xffff1:     pop    %rbx
   0xffff2:     loopne 0xffff4
   0xffff4:     lock xor %dh,(%rsi)
   0xffff7:     (bad)
   0xffff8:     xor    (%rbx),%dh
   0xffffa:     (bad)
   0xffffb:     cmp    %edi,(%rcx)
   0xffffd:     add    %bh,%ah
   0xfffff:     add    %al,(%rax)
```

![os-jyy-9-2.png](https://s2.loli.net/2022/09/06/279w3yJs1SHBjfA.png)

![jyy-os-9-3.png](https://s2.loli.net/2022/09/06/sktxpvC2H5Wnm1P.png)

查看资料都说这一段是跳转到jmp f000:e05b,确实跳转到e05b（也就是BIOS区域中某个地址）



```

(gdb) si
0x000000000000e05b in ?? ()
(gdb) x/10i ($cs * 16 + $rip)
   0xfe05b:     cmpw   $0xffc8,%cs:(%rsi)
   0xfe060:     (bad)
   0xfe061:     add    %cl,(%rdi)
   0xfe063:     test   %ecx,-0x10(%rdx)
   0xfe066:     xor    %edx,%edx
   0xfe068:     mov    %edx,%ss
   0xfe06a:     mov    $0x7000,%sp
   0xfe06e:     add    %al,(%rax)
   0xfe070:     mov    $0x7c4,%dx
   0xfe074:     verw   %cx

```

以后，随后又是一段跳转，到了bios真正的地方，

```
(gdb) si
0x000000000000e062 in ?? ()
(gdb) x/10i ($cs * 16 + $rip)
   0xfe062:     jne    0xffffffffd241d0b2
   0xfe068:     mov    %edx,%ss
   0xfe06a:     mov    $0x7000,%sp
   0xfe06e:     add    %al,(%rax)
   0xfe070:     mov    $0x7c4,%dx
   0xfe074:     verw   %cx
   0xfe077:     stos   %eax,%es:(%rdi)
   0xfe078:     out    %al,(%dx)
   0xfe079:     push   %bp
   0xfe07b:     push   %di
(gdb)
```

 BIOS 把第一个可引导设备的第一个扇区加载到物理内存的 `7c00` 位置



BIOS/UEFI

#### BIOS

Legacy BIOS把第一个可引导设备的第一个扇区512B（MBR主引导扇区，最后两个字节是aa55）加载到物理内存的 7c00的位置，此时处理器还处于16-bit模式，规定CS:IP =0x7c00

同时寄存器BL里保存着当前启动的设备的设备号，这个设备号用于INT 13中断服务，如果这个扇区的最后两个字节是55AA，那么就跳转到7C00上，并转交控制权

这是firemare和操作系统的第一次也是唯一的一次握手。



翻译 https://www.usenix.org/legacy/publications/library/proceedings/usenix05/tech/freenix/full_papers/bellard/bellard.pdf

```

(gdb) x/16xb 0x7c00
0x7c00: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7c08: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
(gdb) wa *0x7c00
Hardware watchpoint 1: *0x7c00
(gdb) c
Continuing.

Hardware watchpoint 1: *0x7c00

Old value = 0
New value = 12794
0x000000000000a4c0 in ?? ()
(gdb) x/i ($cs * 16 + $rip)
   0xfa4c0:     rep insl (%dx),%es:(%edi)
(gdb) x/10i ($cs * 16 + $rip)
   0xfa4c0:     rep insl (%dx),%es:(%edi)
   0xfa4c3:     mov    0xc(%esp),%si
   0xfa4c9:     add    %si,(%esp)
   0xfa4ce:     mov    0x12(%esp),%eax
   0xfa4d3:     lea    0x2(%eax),%dx
   0xfa4d8:     in     (%dx),%al
   0xfa4d9:     mov    0x14(%esp),%ax
   0xfa4df:     callw  0xa3f7
   0xfa4e3:     (bad)
   0xfa4e4:     jmpq   *-0x7b(%rsi)
(gdb) si

Hardware watchpoint 1: *0x7c00

Old value = 12794
New value = -1900006918
0x000000000000a4c0 in ?? ()
(gdb) x/16xb 0x7c00
0x7c00: 0xfa    0x31    0xc0    0x8e    0x00    0x00    0x00    0x00
0x7c08: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
(gdb) si
0x000000000000a4c0 in ?? ()
(gdb) x/16xb 0x7c00
0x7c00: 0xfa    0x31    0xc0    0x8e    0x00    0x00    0x00    0x00
0x7c08: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
(gdb) si
0x000000000000a4c0 in ?? ()
(gdb) x/16xb 0x7c00
0x7c00: 0xfa    0x31    0xc0    0x8e    0xd8    0x8e    0x00    0x00
0x7c08: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
(gdb)
```

看到内存7c00有值了，其实就是512个字节

```
00000000: 31c0 8ed8 8ec0 8ed0 b801 4fb9 1201 bf00  1.........O.....
00000010: 40cd 10b8 024f bb12 41cd 100f 0116 5c7c  @....O..A.....\|
00000020: 0f20 c066 83c8 010f 22c0 ea30 7c08 0066  . .f...."..0|..f
00000030: b810 008e d88e c08e d0bc 00a0 0000 e8b6  ................
00000040: 0000 0000 0000 0000 0000 00ff ff00 0000  ................
00000050: 9acf 00ff ff00 0000 92cf 0017 0044 7c00  .............D|.
00000060: 0055 89e5 5756 be00 0200 0053 5389 c301  .U..WV.....SS...
00000070: d089 45f0 89c8 81e3 00fe ffff 99f7 febe  ..E.............
00000080: f701 0000 89c1 83c1 033b 5df0 7365 89f2  .........;].se..
00000090: ec83 e0c0 3c40 75f6 baf2 0100 00b0 01ee  ....<@u.........
000000a0: baf3 0100 0089 c8ee 89c8 baf4 0100 00c1  ................
000000b0: f808 ee89 c8ba f501 0000 c1f8 10ee 89c8  ................
000000c0: baf6 0100 00c1 f818 83c8 e0ee b020 89f2  ............. ..
000000d0: ee89 f2ec 83e0 c03c 4075 f6ba f001 0000  .......<@u......
000000e0: 8dbb 0002 0000 ed89 0383 c304 39fb 75f6  ............9.u.
```



#### UEFI

 

bootloader

初始化全局变量和栈；分配堆区 heap

为main函数传递参数

- 谁给操作系统传递了参数



mini操作系统 thread-os.c

可以创建并发执行的任务



后面是makefile的小技巧



如何理解make？让make跑一遍，看看到底执行了什么



vim里`%s/ /\r /g`把空格变成换行



```

 sudo apt-get install gcc-x.x-multilib
 $ sudo apt-get install g++-x.x-multilib
```

