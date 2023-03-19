---
title: "操作系统-jyy-3"
date: 2022-06-26T18:01:41+08:00
lastmod: 2023-3-19
draft: false
---

# 第三讲
*对应2023年课程的第四讲，可以说从这一讲开始，才真正迈入操作系统的殿堂*
https://jyywiki.cn/OS/2023/build/lect4.ipynb
在多处理器时代，状态机模型会发生什么变化

jyy在2023年使用python重写了这个threads.h，几乎在50行里实现了一个解释器
因为我太菜了，所以这段代码看了我一下午才理解
```python
#os-model.py
import sys
import random
from pathlib import Path

class OperatingSystem():
    """A minimal executable operating system model."""

    SYSCALLS = ['choose', 'write', 'spawn', 'sched']
    class Thread:
        """A "freezed" thread state."""

        def __init__(self, func, *args):
            self._func = func(*args)
            self.retval = None

        def step(self):
            """Proceed with the thread until its next trap."""
            syscall, args, *_ = self._func.send(self.retval)
            self.retval = None
            return syscall, args

    def __init__(self, src):
        variables = {}
        exec(src, variables)
        self._main = variables['main']

    def run(self):
        threads = [OperatingSystem.Thread(self._main)]
        print(threads[0])
        while threads:  # Any thread lives
            try:
                match (t := threads[0]).step():
                    case 'choose', xs:  # Return a random choice
                        t.retval = random.choice(xs)
                    case 'write', xs:  # Write to debug console
                        print(xs, end='')
                    case 'spawn', (fn, args):  # Spawn a new threadL:::
                        threads += [OperatingSystem.Thread(fn, *args)]
                    case 'sched', _:  # Non-deterministic schedule
                        random.shuffle(threads)
            except StopIteration:  # A thread terminates
                threads.remove(t)
                random.shuffle(threads)  # sys_sched()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} file')
        exit(1)

    src = Path(sys.argv[1]).read_text()
    for syscall in OperatingSystem.SYSCALLS:
        src = src.replace(f'sys_{syscall}',        # sys_write(...)
                          f'yield "{syscall}", ')  #  -> yield 'write', (...)

    OperatingSystem(src).run()
```

## 前置知识yield

Generator Object 
```python
def numbers():
    i = 0
    while True:
        ret = yield f'{i:b}'
        i += ret
n=numbers()
n.send(None)
s.send(0)
```
在调用生成器函数的过程中，每次遇到 yield 时函数会暂停并保存当前所有的运行信息（保留局部变量），返回yield的值, 并在下一次执行next()方法时从当前位置继续运行，直到生成器被全部遍历完。

https://www.liaoxuefeng.com/article/895920356978720

send()的意思是，传入给ret值，让迭代器能接受外部的值，从而改变状态机的状态

```
def fab(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        print("fab:"+n+"val:"+a)
        a, b = b, a + b
        n = n + 1
```

根据thread.py的内容创建迭代器，然后选择迭代器执行下一步，就相当于选择状态机执行。在外部针对syscall做了传递


这个模型还可以更加简化，比如现在有3个迭代器，斐波那契迭代器，倍增迭代器，和倒数迭代器，每次通过random选择迭代器执行一步，然后转交控制权，等待调度执行。感谢python，让写代码变得这么容易。

```python
import random
def fab(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        print(f"fab:{n} val:{b}")
        a, b = b, a + b
        n = n + 1

def declin(max):
    n, a= 0, 0
    while n < max:
        yield a
        print(f"dec:{n} val:{a}")
        a = a - 1
        n = n + 1

def doubl(max):
    n, a= 0, 1
    while n < max:
        yield a
        print(f"dou:{n} val:{a}")
        a *= 2
        n = n + 1

threads = [fab(10),doubl(10),declin(10)]


while threads:
    try:
        random.shuffle(threads)
        next(threads[0])
    except StopIteration:  # A thread terminates
            threads.remove(threads[0])
            random.shuffle(threads) 
```

这里有一个巧妙的地方，把threads.py替换成下面代码，通过exec运行
```python
count = 0
def Tprint(name):
    global count
    for i in range(3):
        count += 1
        yield "write", (f'#{count:02} Hello from {name}{i+1}\n')
        yield "sched", ()
def main():   
    n = yield "choose", ([3, 4, 5])
    yield "write", (f'#Thread = {n}\n')
    for name in 'ABCDE'[:n]:
        yield "spawn", (Tprint, name)
        yield "sched", ()
```


当你熟悉了python构建的状态机，来试试c吧
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

static pthread_t threads[64];
static int nthreads = 0;

static inline void
sys_write(const char *s) {
  printf("%s", s);
  fflush(stdout);
}

static inline void
sys_sched() {
  usleep(rand() % 10000);
}

static inline void
sys_spawn(void *(*fn)(void *), void *args) {
    pthread_create(&threads[nthreads++], NULL, fn, args);
}

static inline int
sys_choose(int x) {
  return rand() % x;
}

// Constructor called before main()
static inline void __attribute__((constructor))
srand_init() {
  srand(time(0));
}

// Destructor called after main()
static inline void __attribute__((destructor))
thread_join() {
  for (int i = 0; i < nthreads; i++) {
    pthread_join(threads[i], NULL);  // Wait for thread terminations
  }
}
```

```c
#include "os-real.h"

int count = 0;

void *Tprint(void *s) {
  char buf[64];
  for (int i = 0; i < 3; i++) {
    sprintf(buf, "#%02d Hello from %c%d\n", ++count, *(const char *)s, i);
    sys_write(buf);
    sys_sched();
  }
  return NULL;
}

int main() {
  int n = sys_choose(3) + 3;
  char buf[64];
  sprintf(buf, "#Thread = %d\n", n);
  sys_write(buf);
  for (int i = 0; i < n; i++) {
    sys_spawn(Tprint, &"ABCDE"[i]);
  }
}
```

将上面的调度改写成c的
```c
void *fab(int max){
  int n=0, a=0, b=1;
  char buf[64];
  while(n < max){
    sys_sched();
    sprintf(buf,"fab: %d val:%d\n",n,b);
    sys_write(buf);
    int tmp=a;
    a=b;
    b=tmp + b;
    n++;
  }
  return NULL;
}
void *declin(int max){
  int n=0,a=0;
  char buf[64];
  while (n<max){
    sys_sched();
    sprintf(buf,"dec: %d val:%d\n",n,a);
    sys_write(buf);
    a--;
    n++;
  }
  return NULL;
}
void *doubl(int max){
  int n=0,a=1;
  char buf[64];
  while (n<max){
    sys_sched();
    sprintf(buf,"dou: %d val:%d\n",n,a);
    sys_write(buf);
    a*=2;
    n++;
  }
  return NULL;
}
int main() {
  sys_spawn(doubl,10);
  sys_spawn(fab,10);
  sys_spawn(declin,10);
}
```