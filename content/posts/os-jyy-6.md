---
title: "OS-jyy-6 并发控制基础"
date: 2022-07-05T22:52:40+08:00
draft: false
---

# 第六讲 并发控制基础

Peterson算法、模型检验和软件自动化工具

主要内容：

如何阅读理解教科书、互联网上的各种并发程序

## 如何保证互斥：一个很简单的例子Peterson算法

以及如何画出并发程序状态机的状态

如何保证一个全局变量某一刻只被一个线程写、读？

<=>如何保证一个厕所某一刻只被一个人使用？

Peterson算法

A和B争抢厕所，但是他们都很谦让。

上厕所前，需要事先举旗并贴字。具体来说

- 如果A想要上厕所，会事先举起旗子，旗子上写了A，并且将厕所门口贴上B
- 如果B想要上厕所，会事先举起旗子，旗子上写了B，并且将厕所门口贴上A

准备工作做好以后，下一步将根据旗子和厕所门口的字来决定是否进入厕所。具体来说

- 如果A想要进入厕所，会观察是否有人举起旗子，并观察厕所门口的是否为A，如果B举了旗子，且门上的贴了B，他将等待，否则A将进入厕所
- 如果B想要进入厕所，会观察是否有人举起旗子，并观察厕所门口的是否为B，如果A举了旗子，且门上的贴了A，他将等待，否则B将进入厕所

出厕所后，将放下自己的旗子。

这种奇怪的算法将保证A或B进入厕所时，厕所没人。



```c
#include "thread.h"

#define A 1
#define B 2

atomic_int nested;
atomic_long count;

void critical_section() {
  long cnt = atomic_fetch_add(&count, 1);
  assert(atomic_fetch_add(&nested, 1) == 0);
  atomic_fetch_add(&nested, -1);
}

int volatile x = 0, y = 0, turn = A;

void TA() {
    while (1) {
/* PC=1 */  x = 1;
/* PC=2 */  turn = B;
/* PC=3 */  while (y && turn == B) ;
            critical_section();
/* PC=4 */  x = 0;
    }
}

void TB() {
  while (1) {
/* PC=1 */  y = 1;
/* PC=2 */  turn = A;
/* PC=3 */  while (x && turn == A) ;
            critical_section();
/* PC=4 */  y = 0;
  }
}

int main() {
  create(TA);
  create(TB);
}

```



当然这种奇怪算法的正确性需要验证，接下来的所有内容都是围绕验证的。

一种方法是通过人脑来枚举A和B抢着上厕所以及举旗过程的所有状态。模拟多线程执行代码的顺序。

另一种方法是计算机验证，jyy的功底就体现出来了。

使用Python这种动态语言模拟验证状态机正确性。 Model checker

并利用某些库可视化状态机的所有状态。

jyy利用了Generator的一个特性来保存函数运行的上下文。这使得我们能够更方便地模拟状态机的执行过程。

关于Model Checker的Python实现和可视化展示这里就暂且不说了。



这节课告诉了我们工具的重要性，计算机辅助验证彳亍，人脑模拟计算机不彳亍！
