---
title: "操作系统-jyy-15"
date: 2022-09-01T22:32:41+08:00
draft: false
---
# 第15讲 fork 的应用 
(文件描述符的复制；写时复制；创建平行宇宙的魔法)

既然前面都说过fork的形式语义，那你还不知道能用fork做哪些奇怪的事？

看看jyy是怎么把fork玩出花的。

sh-xv6.c
 - fork状态机复制包括持有的所有操作系统对象
 - execve重置状态机，但继承持有的所有操作系统对象
  
由此可以轻松实现管道。

什么是文件描述符？

一个指向操作系统内对象的指针

O_CLOEXEC 关闭execve继承的文件描述符

对于数据文件，文件描述符会记住上一次打开的位置。(offset)

一个例子
```c
$ cat a.c
#include<fcntl.h>
#include<unistd.h>
#include<assert.h>
int main(){
        int fd = open("a.txt", O_WRONLY | O_CREAT); assert(fd > 0);
        pid_t pid = fork(); assert(pid >= 0);
        if (pid == 0) {
                write(fd, "Hello",5);
        } else {
                write(fd, "World",5);
        }
}
$ cat a.txt
WorldHello
```

使用dup复制文件描述符，

两个文件描述符是共享offset的，但不共享descriptor flags

fork还需要考虑的问题

1GB内存的进程，fork以后这1GB完全复制吗?

解决办法：写时复制

进程的页面是由操作系统管理的，进程看到的页面是由一层映射关系的。

这一段 jyy讲的很细，一步一步来很舒服。

对于libc.so，复制是假的复制。整个系统只有一份libc.so的实体。

例子
[cow-test.c](https://jyywiki.cn/pages/OS/2022/demos/cow-test.c)
好吧，看来今天还是颠覆了我的一点认知的，因为共享的存在，进程的内存占用空间不可信了。

状态机并行还可以做什么？

平行宇宙！

### 1.dfs记住状态，fork的魔法。
[dfs-fork.c](https://jyywiki.cn/pages/OS/2022/demos/dfs-fork.c)
这个跑起来还是蛮震撼的，让快睡着的我顿时来了兴趣。
### 2.跳过初始化
QEMU,JVM初始化加载
### 3.备份
创建快照

容错计算
## fork带来的一些麻烦

引入信号以后如何处理

线程怎么办？

更...的解决方案 POSIX spawn

