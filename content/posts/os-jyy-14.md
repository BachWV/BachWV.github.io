---
title: "操作系统-jyy-14"
date: 2022-09-01T00:09:23+08:00
---

# 第14讲 C标准库的实现

系统调用的封装，内存空间管理

不会有人想用汇编来写操作系统吧，不会有人想直接用系统调用构建吧。
不会真的有人在oj上写题，不用printf用write系统调用吧。

对系统调用进行封装，是自然而然的想法。

## 重新认识libc

一个例子

execve的pathname是绝对路径，但是你希望使用PATH下的路径可以吗?你想不按照规定来?没门。

execlp帮助你去遍历env的PATH，挨个执行execve看看能不能找到合适的pathname。高情商api，这才是人民群众喜闻乐见的api

封装纯粹的计算，比如memset。
标准库要正确，并快。兼容很多cpu

多个线程同时memset怎么办？库函数要考虑的问题比自己写的要多得多。

标准库只对“标准库内部数据”的线程安全性负责

更多标准库需要做的：排序，查找,atoi,atol,atoll

计算就更复杂了
怎样在IEEE754这个浮点数优化计算，754在-1到1之间很密，怎么利用这个特性，怎么避免-INF精度爆炸的问题。
## 封装操作系统的对象
在UNIX的世界里，实际上就是封装文件描述符

FILE * 背后是一个文件描述符
```c
#include<stdlib.h>
#include<stdio.h>

int main(){
        FILE *fp=fopen("a.txt","w");
        fprintf(fp,"Hello os");
}
```
窥探glibc的内部实现
```
openat(AT_FDCWD, "a.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
write(3, "Hello os", 8)                 = 8
```
返回了一个3 的文件描述符，并在3这里做了一个write的系统调用

我们甚至可以在gdb上`p *fp`或者`p *stdin`，会发现stdin的filenum=0
```
$1 = {_flags = -72539004, _IO_read_ptr = 0x0, _IO_read_end = 0x0, _IO_read_base = 0x0, _IO_write_base = 0x0,
  _IO_write_ptr = 0x0, _IO_write_end = 0x0, _IO_buf_base = 0x0, _IO_buf_end = 0x0, _IO_save_base = 0x0,
  _IO_backup_base = 0x0, _IO_save_end = 0x0, _markers = 0x0, _chain = 0x7ffff7fb85c0 <_IO_2_1_stderr_>,
  _fileno = 3, _flags2 = 0, _old_offset = 0, _cur_column = 0, _vtable_offset = 0 '\000', _shortbuf = "",
  _lock = 0x555555559380, _offset = -1, _codecvt = 0x0, _wide_data = 0x555555559390, _freeres_list = 0x0,
  _freeres_buf = 0x0, __pad5 = 0, _mode = 0, _unused2 = '\000' <repeats 19 times>}
(gdb)n
(gdb)p *fp
$2 = {_flags = -72536956, _IO_read_ptr = 0x555555559480 "Hello os",
  _IO_read_end = 0x555555559480 "Hello os", _IO_read_base = 0x555555559480 "Hello os",
  _IO_write_base = 0x555555559480 "Hello os", _IO_write_ptr = 0x555555559488 "",
  _IO_write_end = 0x55555555a480 "", _IO_buf_base = 0x555555559480 "Hello os",
  _IO_buf_end = 0x55555555a480 "", _IO_save_base = 0x0, _IO_backup_base = 0x0, _IO_save_end = 0x0,
  _markers = 0x0, _chain = 0x7ffff7fb85c0 <_IO_2_1_stderr_>, _fileno = 3, _flags2 = 0, _old_offset = 0,
  _cur_column = 0, _vtable_offset = 0 '\000', _shortbuf = "", _lock = 0x555555559380, _offset = -1,
  _codecvt = 0x0, _wide_data = 0x555555559390, _freeres_list = 0x0, _freeres_buf = 0x0, __pad5 = 0,
  _mode = -1, _unused2 = '\000' <repeats 19 times>}

```
怪?

**这就是UNIX**


## 封装更多的东西

err,error,perror

为什么你在很多地方都能看到No such file or directory?

我们也可以打印一个这样的error msg
```c
#include<stdlib.h>
#include<stdio.h>
#include<err.h>
int main(){
        const char *fname = "xxx.c";
        FILE *fp=fopen(fname,"r");
        if(!fp){
                warn("%s",fname);
        }
}
```

原来大家和我用的是同一个标准库
```shell
charon@DESKTOP-EIMRFTO:~/jyy/14$ gcc a.c
charon@DESKTOP-EIMRFTO:~/jyy/14$ ./a.out
a.out: xxx.c: No such file or directory
charon@DESKTOP-EIMRFTO:~/jyy/14$ cat a.c
```


下一个关于env的魔术
```c
#include <stdio.h>

int main() {
  extern char **environ;
  for (char **env = environ; *env; env++) {
    printf("%s\n", *env);
  }
}
```
链接的时候会找到这个**environ
那么状态机重置以后**environ会变成什么?

我们通过gdb一步一步看一下哪一步**environ被赋值的

静态链接结果:
```
(gdb) wa (char**)environ
Hardware watchpoint 1: (char**)environ
(gdb) c
The program is not being run.
(gdb) start
Temporary breakpoint 2 at 0x401d05: file env.c, line 3.
Starting program: /home/charon/jyy/14/a.out

Watchpoint 1: (char**)environ

Old value = (char **) 0x0
New value = (char **) 0x7fffffffe1b8
0x000000000040213a in __libc_start_main ()
(gdb)
```

是__libc_start_main()赋值的

动态链接结果：
```
(gdb) wa (char**)environ
Hardware watchpoint 1: (char**)environ
(gdb) start
Temporary breakpoint 2 at 0x1149: file env.c, line 3.
Starting program: /home/charon/jyy/14/a.out

Watchpoint 1: (char**)environ

Old value = (char **) 0x0
New value = (char **) 0x7fffffffe1b8
_init (argc=1, argv=<optimized out>, envp=<optimized out>) at init-first.c:77
77      init-first.c: No such file or directory.
```

## 封装地址空间
malloc和free

标准库的实现要考虑什么?

用户的使用场景
- 小对象的创建/分配迅速（需要考虑并发）
- 大的数组和对象拥有更长的生命周期（不太需要并发）

设置两套系统，考虑fast path和slow path
- fast path
    - 性能极好、并行度极高、覆盖大部分情况
    - 但有小概率会失败 (fall back to slow path)
- slow path
    - 不在乎那么快
    - 但把困难的事情做好
        - 计算机系统里有很多这样的例子 (比如 cache)
  
人类也是这样的系统

Daniel Kahneman. *Thinking, Fast and Slow.* Farrar, Straus and Giroux, 2011.

小内存：Segregated List


分配: Segregated List (Slab)

每个 slab 里的每个对象都一样大
每个线程拥有每个对象大小的 slab
fast path → 立即在线程本地分配完成
slow path → pgalloc()
两种实现
全局大链表 v.s. List sharding (per-page 小链表)


回收

直接归还到 slab 中
注意这可能是另一个线程持有的 slab，需要 per-slab 锁 (小心数据竞争)
大内存：一把大锁保平安
Buddy system (1963)

如果你想分配 1, 2, 3, 4, ...  个连续的页面？
例如：64 KB/页面
那就 first fit 或者 best fit 吧……
你只需要一个数据结构解决问题

区间树；线段树……

更多标准库的设计推荐阅读libc的手册
