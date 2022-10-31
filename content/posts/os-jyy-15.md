---
title: "操作系统-jyy-15"
date: 2022-09-01T22:32:41+08:00
draft: false
---
# 第15讲 fork 的应用 
(文件描述符的复制；写时复制；创建平行宇宙的魔法)

既然前面都说过fork的形式语义，那你还不知道能用fork做哪些奇怪的事？

关于fork的故事：

# 一次fork引发的惨案！

[脚本之家](javascript:void(0);) *2021-11-03 17:00*

以下文章来源于编程技术宇宙 ，作者轩辕之风O

[![img](http://wx.qlogo.cn/mmhead/Q3auHgzwzM5iakZHNmMDuPl0azqlm8pPVtxhYTNqISsiat1OwT8f4I7Q/0)**编程技术宇宙**.用故事说技术，编程从未如此有趣](https://mp.weixin.qq.com/s?__biz=MjM5NTY1MjY0MQ==&mid=2650823531&idx=4&sn=620469d93fe88e41ae042bf8dcba35f8&chksm=bd01ce258a7647330015ca68c72c7e607f626a433265e7527fb0dd33b0b0fb4ac1ddda4e0e96&mpshare=1&scene=22&srcid=1103DMsYXppVVDIwrHbHytvP&sharer_sharetime=1635932496632&sharer_shareid=049dba64c0a4afe10f2b03cbfaf32231#)

![图片](https://mmbiz.qpic.cn/mmbiz_gif/iaky1Xjn7W0DiaoHmA4gHqSMxiaGJFTLQjiatEZ0wiaqbaOqN5LxYyicln5e5G8A85Tiaf0dGFhFLGxFDcKZGdXEuRwrQ/640?wx_fmt=gif&wxfrom=5&wx_lazy=1)

 关注

“脚本之家

”，与百万开发者在一起

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/LGh7bn8KbYA8qQgVrCrPUbkGptoib0GCpHya6PqRECYlSyMnvfAibktiaBjXricIfJPI4UDlY5H7FSdrj3wezNpg6Q/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

作者 | 轩辕之风O

来源 | 编程技术宇宙（ID：xuanyuancoding）

“你还有什么要说的吗？没有的话我就要动手了”，kill程序最后问道。

这一次，我没有再回答。

只见kill老哥手起刀落，我短暂的一生就这样结束了···

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/LGh7bn8KbYA8qQgVrCrPUbkGptoib0GCpWGGuiaIdw8qbJkJg3mCaVbcB1URzYkoXoEsibdibmpeL7siaekRlvDGpIw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

我是一个网络程序，一直以来都运行在Windows系统上，日子过得很舒服。可前段时间，程序员告诉我要把我移植到Linux系统下运行，需要对我大动手术，我平静的生活就这样被打破了。

来到这个叫Linux的地方运行，一切对我都很陌生，没有了熟悉的C盘、D盘和E盘，取而代之的是各种各样的目录。

```
/bin
/boot
/etc
/dev
/mnt
/opt
/proc
/home
/usr
/usr64
/var
/sys...
```

这里很有意思，一切都是文件，硬件设备是文件、管道是文件、网络套接字也是文件，搞得我很不适应。

这些都还好，我都还能接受，但直到今天···

##  

***\*- 1 -\****

## **奇怪的fork** 



今天早上，我收到了一个网络请求，需要完成一个功能，这个工作比较耗时，我准备创建一个子进程，让我的小弟去完成。

这是我第一次在Linux系统上创建进程，有点摸不着北，看了半天，只看到程序员在我的代码里写了一个fork函数：

```
pid_t pid=fork();
if ( pid > 0 ) {   ···} 
else if( pid == 0 ) {    ···} 
else {    ···}
```

我晃晃悠悠的来到fork函数的门前，四处观察。

“您是要创建进程吗？”，fork函数好像看出了我的来意。

“是的，我是第一次在这里创建进程，以前我在Windows那片儿的时候，都是调用CreateProcess，但这里好像没有叫这个名字的函数···”

fork函数听后笑了起来，说道：“别找了，我就是负责创建进程的函数”

“你？fork不是叉子的意思吗，好端端的干嘛取这么个名字？”，我一边说，一边朝fork函数走去。

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/LGh7bn8KbYA8qQgVrCrPUbkGptoib0GCpCeaq9O84TAhlU0YdBUlRcolwppLlwvAxlIoLRL5KJz3EePico3eTQGw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

fork没有理会我的问题，只是说道：“您这边稍坐一下，我要跟内核通信一下，让内核创建一个子进程”

这下我倒是明白他的意思，像创建进程这种操作，都是由操作系统内核中的系统调用来完成的，而像fork这些我们可以直接调用的函数只是应用层的接口而已，这跟以前在Windows上是一样的。

不过我突然反应过来，着急问道：“唉，我还没告诉你要创建的进程参数呢，你怎么知道要启动哪个程序？”

fork扑哧一下笑出了声，不过并没有回答我的问题。

人生地不熟的，我也没好再多问，只好耐心等待，等待期间我竟然睡着了。

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/LGh7bn8KbYB25yHFZyaPic247BbNJx3hCySaMJrGvnuwj4IiaronRrfXkcIu57lianzM9fhxNjwjSlicH3tOeybMhw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

“醒醒”，不知过了多久，fork函数叫醒了我：“创建完成了，请拿好，这是进程号pid”，说完给了我一个数字。

我摊开一看，居然写了一个大大的0！

“怎么搞的，创建失败了？”，我问到。

“没有啊，您就是刚刚创建的子进程”

“啥？你是不是搞错了，我就是专程来创建子进程的，我自己怎么会是子进程？”

fork函数又笑了，“我没有搞错，您其实已经不是原来的你了，而是一个复制品，是内核刚刚复制出来的”

“复制品？什么意思？”，我越听越懵！

“每个进程在内核中都是一个task_struct结构，刚才您睡着期间，内核在创建进程的时候，把内核中原来的你的task_struct复制了一份，还创建了一个全新的进程地址空间和堆栈，现在的你和原来的你除了极少数地方不一样，基本上差不多”

![图片](https://mmbiz.qpic.cn/mmbiz_png/1hReHaqafacOBQvONaZuqgdEofKVoBGgz3icK7lHF5MzojpQiaxaTqicVvTia8CHs89A1J1hGdvGQ6etuVeONdpzTQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

“那原来的我呢？去哪里了”

“他已经变成你的父进程了，我是一个特殊的函数，一次调用会返回两次，在父进程和子进程中都会返回。在原来的进程中，我把你的进程号给了他，而我返回给你0，就表示你现在就是子进程”

原来是这样，我大受震撼，这简直颠覆我的认知，居然还有如此奇特的函数，调用一次，就变成了两个进程，思考之间，我忽然有些明白这个函数为什么要叫fork的原因了。

##  

***\*- 2 -\****

## **写时拷贝** 



“您是刚来咱们这里吧，可能还不太熟悉，慢慢就习惯了”

“你们这效率也太高了吧，整个进程地址空间那么大，居然这么快就复制了一份！”

fork函数又笑了！难道我又说错话了？

“进程的内存地址空间可没有复制，你现在和父进程是共享的内存空间的”

“啥？共享？你刚才不是说创建了新的进程空间和堆栈吗？”

“您看到的内存地址空间是虚拟的，您的内存页面和父进程的内存页面实际上是映射的同一个物理内存页，所以实际上是共享的哟”

![图片](https://mmbiz.qpic.cn/mmbiz_png/1hReHaqafacOBQvONaZuqgdEofKVoBGgzLf1okOuwb3Fw36WSFZff84amH0icdJZt8JmpKrhUyeiavoyn5y9c1CA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

“原来是这样，可是弄成共享了，两个进程一起用，岂不是要出乱子？”

“放心，内核把这些页面都设置成了只读，如果你们只是读的话，不会有问题，但只要有一方尝试写入，就会触发异常，内核发现异常后再去分配一个新的页面让你们分开使用。哦对了，这个叫写时拷贝（COW） 机制”

![图片](https://mmbiz.qpic.cn/mmbiz_png/1hReHaqafacOBQvONaZuqgdEofKVoBGgjwbGHUjoHk3OWBzcOTXtaozq2T4bxRLvXCDSWyJ12o26G1cqx9xhqw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

“有点意思，你们倒是挺聪明的”

“没办法，尽量压缩成本，提高创建进程的效率嘛，因为进程中的很多内存页面都只会去读，如果全部无脑拷贝一份，那不是太浪费资源和时间了吗”，fork函数说到。

“有道理，有道理”，我点了点头，告别了fork函数，准备回去继续工作。

##  

**- 3 -**

## **消失的线程们** 



本以为这奇怪的进程创建方式已经让我大开眼界了，没想到可怕的事情才刚刚开始。

告别fork函数没多久，我就卡在了一个地方没法执行下去，原来，前面有一把锁被别的线程占用了，而我现在也需要占用它。

这倒也不足为奇，以往工作的时候，也经常碰到锁被别的线程锁定的情况，但这一次，我等了很久也一直不见有线程来释放。

“喂，醒醒”

不知过了多久，我竟然又睡着了。

睁开眼睛，另一个程序站出现在了我的面前。

“你是？”

“你好，我是kill”

“kill？那个专门杀进程的kill程序？你来找我干嘛”，我惊的一下睡意全无。

![图片](https://mmbiz.qpic.cn/mmbiz_png/1hReHaqafacOBQvONaZuqgdEofKVoBGgyupE3qsTxUPeLqibdic6KLfYHTsWicboDwickVlz0d4iczcYhrlxxMSmXEQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

kill程序从背后拿出了两个数字：9，1409

“你看，这是我收到的参数，1409是你的进程号PID，9表示要强制杀死你”

“啊？为什么？”，那一刻，我彻底慌了。

“可能是你卡死在这里太久了吧，人类才启动我来结束你的运行”，kill程序说到。

“是啊，不知道是哪个该死的线程占用了这把锁一直不释放，我才卡在这里”，我委屈的说到。

“哪里有别的线程，我看了一下，你这进程就只有一个线程啊！”

“你看错了吧？”，说完，我认真检查了起来，居然还真只有一个线程了！我白等了这么久！

“奇怪了，我明明是一个多线程的程序啊！”，我眉头紧锁。

“你仔细想想，刚才有没有发生什么事情？”，kill程序问到。

“我就执行了一下fork，生成了一个子进程，哦对了，我就是那个子进程”

“难怪！”，kill程序恍然大悟。

“难怪什么？

“fork那家伙创建子进程的时候，只会复制当前的线程，其他线程不会被复制！”，Kill程序说完叹了口气，仿佛已经见怪不怪了。

“what？怎么会这样？其他线程没复制，那岂不是要出乱子？”

kill程序不紧不慢地说道：“这都是历史遗留问题了，早期都是单线程的程序，一个task_struct就是一个进程，fork这样做是没有问题的，后来出现了多线程技术，一个task_struct实际上是一个线程了，多个task_struct通过共享地址空间，成为一个线程组，也就是进程，但fork仍然只复制当前的线程，就有了这个问题”

“我去，这坑爹的fork！”

“你不是第一个被坑的了！等着程序员把你重新改造下吧”

“唉···”，我长长的叹了口气。

“你还有什么要说的吗？没有的话我就要动手了”，kill程序最后问道。

这一次，我没有再回答。

只见kill老哥手起刀落，一切都消失了···

【完】




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

