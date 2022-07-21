---
title: "Unix读书笔记"
date: 2021-06-17T13:50:16+08:00
draft: false
toc: true
---

# UNIX 读书笔记





# 第2章：UNIX 发展历史以及系统架构

发展历史：

1965年    MULTICS  ( Multiplexed Information and Computing Service) 的开发
1970年    Ken Thompson 和 Dennis Ritchie 在PDP7上用汇编语言开发出UNICS
1971年    在PDP-11上用汇编开发出UNIX  v.1
1972年    增加管道功能后开发出UNIX v.2
1973年    Dennis Ritchie 在B language基础上发明了C language 并用C重写UNIX, 形成v.5 ---- 当时第一个高级语言OS

1975年    发表UNIX v.6  并广泛扩散到大学和科研单位, 为后期发展奠定了良好的基础
1978年    优化后发布UNIX v.7 ---- UNIX的第一个商业版本 ---- 我国开始研究应用的最早版本
1981年    AT&T发布UNIX System III,  完全转向为社会提供的商品软件
1983年    AT&T发布UNIX System V,  系统功能已趋于稳定和完善. 此后System V又有一系列的公布号:1.0/2.0/2.3/3.5/4.0/4.2 等, 现在最后版本为 System V  Release  4  (SVR4)

有代表性的版本：

AIX          IBM公司
XENIX/OpenServer
                       Microsoft、SCO公司
HP-UX    HP公司
BSD          加州大学伯克利分校 
Solaris     SUN公司
IRIX         SGI公司
Ultrix       DEC公司
Linux       开放源代码

## 系统结构：

![image-20210612144726435](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210612144726435.png)



内核：负责管理所有与硬件相关的功能，这些功能由UNIX内核中的各个模块实现。内核包括直接控制硬件的各个模块，这样能够极大程度上保护这些硬件，以避免应用程序直接操作而导致混乱。用户不能直接访问内核。

>注意：系统工具和UNIX命令不是内核组件。
>
>用户应用程序得到保护，避免被其他用户的无意写操作破坏。
>
>

常驻模块层：提供执行用户请求服务的例程，包括IO控制服务，文件/磁盘访问服务，以及进程创建和终止服务。

工具层：是UNIX的用户接口，通常成为shell在后面会详细讲到shell

虚拟计算机：UNIX操作系统向系统中的**每个用户指定一个执行环境**，这个环境成为虚拟计算机，包括一个**用户终端**和共享的其他的计算机资源。而UNIX上可以存在多个用户，所以每一个用户都有自己的专用虚拟计算机。不同的用户的虚拟计算机共享CPU和其他计算机资源，所以虚拟计算机比真实的计算机要慢。

**进程**：一个重要的概念。一般面试时都会问进程和线程 的区别。UNIX系统通过进程向用户和程序分配资源（这句话不怎么懂）。每个进程都有一个进程号pid和一组与之相关的资源。进程在虚拟计算机环境下运行，就好像在一个专用CPU上执行一样。

# 第3章 UNIX入门



## 3.1登录与退出

1.登录

输入用户名，密码

2.修改密码：passwd和一般的修改要验证旧密码并两次重新输入新密码，具体操作不再赘述

![image-20210612151234131](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210612151234131.png)

3.退出系统：[ctrl+d] 或是exit，即可退出

## 3.2 简单的UNIX命令

命令行格式：```[命令] [选项] [参数]```

字段间要用一个或多个空格隔开。选项的前面一般会有连字符```-```，一个命令同时也可以有多个，例如下列著名的命令：



![image-2021061215201111](https://raw.githubusercontents.com/bachwv/picgo/master/image-2021061215201111.jpg)

```rm```表示删除，```-rf```表示两个选项：r和f，```/*```表示的磁盘路径就是参数，告诉系统在哪里要删除什么文件



下面介绍一些简单的命令：

1.date：显示日期和时间

![image-20210612152830573](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210612152830573.png)

2.who：列出登录系统的所有用户的用户名，终端号，和登录时间。这里wsl没有这个命令，原因如下

>who程序跟Linux内核无关，只是读取Unix里约定俗成的utmp,wtmp登录文件。你第一次打开wsl2的终端，或者通过其他方式运行wsl2的这个系统，就是第一次登录。但是wsl2子系统不会用utmp/wtmp记录这些，没有任何意义
>
>但在wsl里/init does not create /var/run/utmp
>
>解决方案： Use 'touch /var/run/utmp' in some "system startup script"
>
>来源：https://github.com/Microsoft/WSL/issues/573

who还有一些的选项：-q -H -b。



3.显示日历：cal

![image-20220616104917751](https://raw.githubusercontents.com/bachwv/picgo/master/image-20220616104917751.png)

## 3.3 获取帮助信息



learn和help，使用时需要安装

![image-20220616104948628](https://raw.githubusercontents.com/bachwv/picgo/master/image-20220616104948628.png)



比如我不知道exit的用法

![image-20220616105333358](https://raw.githubusercontents.com/bachwv/picgo/master/image-20220616105333358.png)

### 3.3.3 man手册：

学习新命令时使用，可以得到该man(manual)命令的详细说明，当然

在简洁的wsl中也是没有man的，需要先```sudo apt install man-db manpages manpages-dev```,之后才能愉快地使用man



## 3.4 更正键盘输入错误

中断程序的执行，在大多数系统中，del或者ctrl-c就是中断键，比如不小心按了``rm -rf /*``，这是就要猛敲[ctrl-c]



## 3.5 使用shell

命令的处理是位于用户和操作系统的其他部分之间的shell完成的，每输入一个命令以后，命令被传到shell，先进行分析，然后执行。

bulitin命令：包含的是一些比较简单的linux系统命令，这些命令由shell程序识别并在shell程序内部完成运行，通常在linux系统加载运行时shell就被加载并驻留在系统内存中。内部命令是写在bashy源码里面的，其执行速度比外部命令快，因为解析内部命令shell不需要创建子进程。比如：exit，history，cd，echo等。

外部命令是linux系统中的实用程序部分，因为实用程序的功能通常都比较强大，所以其包含的程序量也会很大，在系统加载时并不随系统一起被加载到内存中，而是在需要时才将其调用内存。通常外部命令的实体并不包含在shell中，但是其命令执行过程是由shell程序控制的。shell程序管理外部命令执行的路径查找、加载存放，并控制命令的执行。外部命令是在bash之外额外安装的，通常放在/bin，/usr/bin，/sbin，/usr/sbin......等等。可通过“echo $PATH”命令查看外部命令的存储路径，比如：ls、vi等。

用type命令可以分辨内部命令与外部命令





关于内部命令和外部命令执行顺序的问题：

>
>
>pwd命令用于显示当前工作目录，是Linux系统下最常用的命令之一。在不太能确定当前位置时，可以使用pwd命令来判断目录在文件系统内的确切位置。而涉及pwd指令，就不得不提及三个环境变量：PATH、OLDPWD、PWD。
>
>PATH：执行文件路径的变量；"echo \$PATH"（PATH前面加$表示后面接的是变量）
>
>OLDPWD：表示前一次的工作目录；
>
>PWD：表示当前的工作目录。
>
>问题缘由：当输入“man pwd”时可以查看pwd的帮助文档，而输入“pwd --help”就提示有错误bash: pwd: --: invalid option；若输入“ /bin/pwd --help”就能正常显示pwd的帮助文档。
>
>从网上查找原因并经过整合可知，这主要是由于内部命令和外部命令的区别，pwd是内部命令，而/bin/pwd就是外部命令。在显示当前目录时，/bin/pwd能显示当前工作目录的完整文件路径，能更准确些。在多人共享同一台Linux机器时，经常会发现当前目录被别人删除后，pwd命令仍然会显示那个目录。
>
>后续试验：切换至root权限下，将/bin目录下的执行文件ls移动到非正规目录中去，mv /bin/ls /root（#mv为移动，可将文件在不同的目录间进行移动操作），然后不管在哪个目录底下输入任何与ls相关的指令，都不能顺利执行ls了（因为/root这个目录并不在PATH指定的目录中，外部命令ls是没法通过PATH路径找到执行文件ls），除非用/root/ls 才行。
>
>如果想要让root在任何目录下均可执行/root底下的ls，那么可以将/root加入到PATH当中，该命令PATH="$PATH":/root即可。若有两个ls指令在不同的目录中，例如/usr/local/bin/ls 和/bin/ls ，那么当我下达 ls命令时，是根据PATH里面哪个目录先被查询到，则那个目录下的指令就先被执行。
>
>而即使采用相同的方法移动/bin目录下的执行文件pwd，仍可以输入pwd命令执行，因为这时仍是调用内部命令pwd指令。
>
>故shell命令解释器在执行命令时，是应先执行内部指令，若要执行的指令不是内部指令，则应是调用的外部指令。
>————————————————
>版权声明：本文为CSDN博主「JustDo-IT」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
>原文链接：https://blog.csdn.net/taohuaxinmu123/article/details/10845001

### 3.5.2 更改用户shell

可以在 /etc/passwd里查看用户登录的shell

例如第一行：`root:x:0:0:root:/root:/bin/bash`
 　用户名：密码：UID：GID：描述性信息：用户主目录：Shell　

具体shell的内容将在第9章中详细说明

# 第4章 vi 编辑器入门

`vi 文件名`启动vi 编辑器，进入的是shell的命令模式,如果你要输入文本，可以按i进入文本输入模式，退出vi：先esc，再输入`:wq`，即可保存或退出。

以上就是最最基础的用法。下面介绍高级用法：

## 4.1模式：

![image-20210612165940750](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210612165940750.png)





从命令模式进入文本输入模式：

| 文本输入模式 |      |                          |      |
| ------------ | ---- | ------------------------ | ---- |
| i            |      | 在光标左侧加入文本       |      |
| I            |      | 在光标所在行首插入文本   |      |
| a            |      | 在光标右侧加入文本       |      |
| A            |      | 在光标所在行尾加入文本   |      |
| o            |      | 在光标所在行下面新加一行 |      |
| O            |      | 在光标所在行上面新加一行 |      |
| ESC          |      | 退出文本输入模式         |      |

## 4.2 命令模式：

光标移动：

| 光标移动  |      |              |      |
| --------- | ---- | ------------ | ---- |
| h j k l   |      | 左下上右移动 |      |
| ^         |      | 行首         |      |
| $         |      | 行尾         |      |
| +         |      | 下一行的行首 |      |
| _         |      | 上一行的行首 |      |
| Space     |      | 右移         |      |
| Backspace |      | 左移         |      |
| w         |      | 下一个字     |      |
| b         |      | 前一个字     |      |
| e         |      | 当前字的末尾 |      |

文本修改：

| 文本修改 |      |                                           |
| -------- | ---- | ----------------------------------------- |
| x        |      | 删除光标所在字符                          |
| dw       |      | 删除光标所在词的从光标开始到该**词**结尾  |
| D        |      | 删除从光标到行尾                          |
| dd       |      | 删除光标所在行                            |
| u        |      | 撤销上一次修改                            |
| r        |      | 把当前光标所在字符替换为紧跟在r后的一个字 |

x,dw,dd前都可加上数字，表示同时删除多个单位

.可以重复最近一次对文本的修改操作



搜索文本

| 搜索 |                                      |
| ---- | ------------------------------------ |
| /    | 输入搜索词并回车，向尾部查找下一个词 |
| ?    | 与/相同，查找方向相反                |

## 4.3 退出

在命令模式时，

| 退出    |                                |
| ------- | ------------------------------ |
| :wq     | 保存文本，退出vi，返回shell    |
| :w      | 保存文本，不退出               |
| :w file | 把文本保存到文件file中，不退出 |
| :q      | 退出vi，返回shell              |
| ZZ      | 快速保存文件并退出             |

## 4.4 存储缓冲区

vi编辑器为用户所要创建或修改的文件建立了一个临时工作区，用户编辑的过程中只作用于工作区的文件副本而不是源文件。如果用户需要保存，必须用命令将修改的文件替换原文件。

## 4.5 高级操作

希望能在vim中完成大多数工作，而不是频繁的退出vim
首先`:tabnew`创建一个标签
然后`:e 文件名`打开一个文件
`:tabnext`在窗口上打开下一个tab
`:tabprevious`在窗口上打开前一个tab
`:q`或者`:tabclose`关闭tab
更多的高级用法将在第6章讲到

# 第5章 UNIX 文件系统介绍

## 5.1 磁盘组织

UNIX允许用户将硬盘分为很多单元（称为目录）和子单元（子目录），这样可以在目录里嵌套子目录。UNIX提供命令，可以在磁盘上创建、组织、和查找目录和文件。

文件系统原理

Unix有三大抽象

- 进程、线程对执行过程
- 文件对io
- 地址空间对内存

Unix有四种io：文件系统、块设备、字符设备、socket

- 块设备和字符设备出现在文件系统的名字空间
- Socket仅表现为文件

考虑到磁盘的空间组织，主要有边长的堆、定长的记录、索引

Unix文件系统选择：堆 + 索引



## 5.2 UNIX中的文件类型

普通文件：包含字节序列，如程序代码、数据、文本。

目录文件：目录文件和其他文件一样，用户可以像命名其他文件一样来命名目录文件。区别在于不是标准的ascii文本文件，包含的是关于其他文件的信息。

特殊文件：包含与外部设备，如打印机、磁盘等相联系的的特定信息。unix的一大抽象就是将io设备视同文件对待，系统中的每个设备都分别对应一个文件。

## 5.3 目录详述

目录结构以层次形式组织，称为层次结构（其实可以理解为树）。最高层目录为根目录。

### 5.3.1 重要的目录：

/usr 用户主目录，当用户在系统中登录时，会自动进入用户主目录，它在/usr/[username]下。


/bin 可执行文件

/dev设备文件，代表物理设备的抽象，如终端是/dev/tty文件。/dev/null是一个特殊设备，即空设备，所有发给空设备的信息都被删除。

/sbin 存放系统文件，在3.5章讲到：

>外部命令是在bash之外额外安装的，通常放在/bin，/usr/bin，/sbin，/usr/sbin......等等

/etc 存放unix配置文件，通常是文本，只要特权用户才有权限编辑。

### 5.3.2 路径

绝对路径名：从根目录到该文件的路径，以/开始

相对路径名：从当前路径到目的文件，开头没有/

## 5.4 目录命令

1.打印工作目录 `pwd`(print working directory)

2.改变工作目录 `cd `

| cd命令   |                        |
| -------- | ---------------------- |
| cd       | 返回用户主目录，缺省值 |
| cd $HOME | 返回用户主目录         |
| cd ..    | 返回上一级目录         |

3.创建目录 `mkdir`

选项有-p

`mkdir -p xx/yy/zz` 创建xx目录，在xx下创建yy目录，在yy下创建zz目录

4.删除目录 `rmdir` 

注意只能删除空目录，即除了本目录（.）和父目录（..）外，该目录不包含其他任何子目录和文件。

5.目录列表 `ls`

显示指定目录的信息，如果没有指定目录，则列出当前目录。

| UNIX选项 | linux选项                              | 功能                                                 |
| -------- | -------------------------------------- | ---------------------------------------------------- |
| -a       | --all                                  | 列出所有文件，包括隐藏文件                           |
| -C       | --format=vertical  --format=horizontal | 用多列方式列出文件，按列排列                         |
| -F       | --classify                             | 将子目录与普通文件类型分开，子目录加/，可执行文件加* |
| -l       | --format=single-column                 | 详细列出文件的属性，每行一个文件                     |
| -m       | --format=commas                        | 按页宽列出文件，用逗号隔开                           |
| -p       |                                        | 在目录文件名后加斜杠 /                               |
| -r       | --reverse                              | 以反字母顺序列出文件                                 |
| -R       | --recursive                            | 递归列出子目录的内容                                 |
| -s       | --size                                 | 以block为单位列出文件大小                            |
| -x       | --format=horizontal  --format=across   | 以多列方式列出文件，按行排列                         |
|          | --help                                 | 显示帮助信息                                         |

例如：

![image-20210615181145639](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210615181145639.png)



`drwxr-xr-x` 为属性字段

![img](https://www.runoob.com/wp-content/uploads/2014/08/file-permissions-rwx.jpg)

文件属性字段总共有10个字母组成；第一个字符代表**文件的类型**。

字母**“-”**表示该文件是一个普通文件

字母**“d”**表示该文件是一个目录，字母"d"，是dirtectory(目录)的缩写

**注意：**目录或者是特殊文件，这个特殊文件存放其他文件或目录的相关信息

字母**“l”**表示该文件是一个链接文件。字母"l"是link(链接)的缩写，类似于windows下的快捷方式

字母**“b”**的表示块设备文件(block)，一般置于/dev目录下，设备文件是普通文件和程序访问硬件设备的入口，是很特殊的文件。没有文件大小，只有一个主设备号和一个辅设备号。一次传输数据为一整块的被称为块设备，如硬盘、光盘等。最小数据传输单位为一个数据块(通常一个数据块的大小为512字节)

字母**“c”**表示该文件是一个字符设备文件(character)，一般置于/dev目录下，一次传输一个字节的设备被称为字符设备，如键盘、字符终端等，传输数据的最小单位为一个字节。

字母**“p”**表示该文件为命令管道文件。与shell编程有关的文件。

字母**“s”**表示该文件为sock文件。与shell编程有关的文件。

后面的是文件访问模式：rwx分别为read，write，执行的权限。分为3组，第一组`rwx`是文件所有者，第二组`r-x`是同组用户权限，第三组`r-x`是其他用户权限。

第2列是链接数，第3列是文件所有者，第4列是文件组，第5列是文件大小，第6列是上次修改的日期和时间，第7列是文件名。

6.隐藏文件

文件名以点开始的文件，不可见。

#### chmod命令

chmod命令可以使用八进制数来指定权限。文件或目录的权限位是由9个权限位来控制，每三位为一组，它们分别是文件所有者（User）的读、写、执行，用户组（Group）的读、写、执行以及其它用户（Other）的读、写、执行。历史上，文件权限被放在一个比特掩码中，掩码中指定的比特位设为1，用来说明一个类具有相应的优先级。

| #    | 权限           | rwx  | 二进制 |
| :--- | :------------- | :--- | :----- |
| 7    | 读 + 写 + 执行 | rwx  | 111    |
| 6    | 读 + 写        | rw-  | 110    |
| 5    | 读 + 执行      | r-x  | 101    |
| 4    | 只读           | r--  | 100    |
| 3    | 写 + 执行      | -wx  | 011    |
| 2    | 只写           | -w-  | 010    |
| 1    | 只执行         | --x  | 001    |
| 0    | 无             | ---  | 000    |

.和. .目录项 

本目录（.）和父目录（..）mkdir命令自动将两项放到创建的每个目录中。分别代表当前目录和上一级目录。



## 5.5 显示文件

`cat` concatenate命令 可以显示一个、多个、创建文件、连接文件。 

## 5.6 打印文件内容

`lp` 将文件发送给打印机

Linux中的打印请求 `lpr`命令

取消打印命令`cancel`

获取打印机状态`lpstat`

## 5.7 删除文件

`rm`可以删除指定的文件

| 选项 | 功能                                     |
| ---- | ---------------------------------------- |
| -i   | 删除文件前，给出确认信息                 |
| -r   | 删除指定的目录及目录下的所有文件和子目录 |
| -rf  | 无提示地强制递归删除文件                 |



如果想无提示删除所有文件，可以作死尝试`sudo rm -rf /*`



# 第6章 vi编辑器的高级用法

## 6.1 更多vi知识

### 6.1.1 启动vi编辑器

以不依靠文件的方式启动vi，可以最后用`:w filename`保存（如果有同名文件会提示）

启动选项：

`-R` 只读，如果希望保存的话，必须用`!`强制执行写选项

`view filename`同样可以以只读模式打开

### 6.1.2 编辑多个文件

`:n` 启动下一个编辑文件，此时用下一个文件替换工作缓冲区的内容（源文件要保存）。我觉得唯一作用就是可以省略退出的操作。

`:e`编辑另一个文件，感觉这种方法和`:n`一样啊

`:r`读另一个文件，将指定文件的副本放到缓冲区中光标位置之后，指定文件成为当前文件的一部分。保存到源文件。

`:w`将正在编辑的文件写入另一个文件中，就相当于6.1.1中最后的保存操作

## 6.2 重排文本

vi提供了删除，复制，剪贴操作。就是命令有点复杂。

书中讲了几个例子：

1.剪贴行（使用删除和put操作符）

在某一行按dd，会发现这一行消失了，但并没有完全消失，只是保存到临时缓冲区中，在合适的地方按p，这时刚才被删除的行就被放在当前行下。

2.复制行（使用复制和put操作符）

在某一行按yy，这一行保存到临时缓冲区中，在合适的地方按p，粘贴。

当然先要精细化粘贴怎么办呢？

## 6.3 操作符的域

命令=操作符+域

确定操作域后，可以使用户更好地控制编辑任务。

|  键  |            功能说明            |
| :--: | :----------------------------: |
|  $   | 标识域为从光标位置后到当前行尾 |
|  0   | 标识域为从光标位置前到当前行首 |
| e/w  | 标识域为从光标位置后到当前字尾 |
|  b   | 标识域为从光标位置前到当前字首 |

比如要复制从光标到行尾的所有，可以按`d$`，这就实现了复制，再按p粘贴。

删除2行，`d2d`

## 6.4 使用缓冲区

### 6.4.1 数字编号缓冲区

编号1-9，每次删除或复制的文本就会放在这些地方。使用`"1p`就可以把1号缓冲区粘贴到下一行。

### 6.4.2 字母编号缓冲区

编号a-z，用户可以保存指定文本到某字母编号缓冲区。

比如`"wdd`将当前行删除，删除的副本保存在w号缓冲区

`"z7yy`，复制7行内容到z缓冲区

## 6.5  光标定位键



|    键    |                 功能说明                 |
| :------: | :--------------------------------------: |
| `Ctrl-d` | 将光标向下移动到文件尾，通常每次移动12行 |
| `Ctrl-u` | 将光标向下移动到文件头，通常每次移动12行 |
| `Ctrl-f` | 将光标向下移动到文件尾，通常每次移动24行 |
| `Ctrl-b` | 将光标向下移动到文件头，通常每次移动24行 |



## 6.6 定制vi

用户可以调整vi编辑器的设置

![image-20210615203331825](https://raw.githubusercontents.com/BachWV/PicGo/master/image-20210615203331825.png)

可以看到有众多选项可以自定义。

下面介绍一些常用选项：

|    选项    | 缩写 |                    功能                    |
| :--------: | :--: | :----------------------------------------: |
| autoindent |  ai  |          将新行与前一行的行首对齐          |
| ignorecase |  ic  |           在搜索选项中忽略大小写           |
|   magic    |      |          允许在搜索时使用特殊字符          |
|   number   |  nu  |                  显示行号                  |
|   report   |      |        通知用户上一个命令影响的行号        |
|   scroll   |      |         设定`Ctrl-d`命令翻动的行数         |
| shiftwidth |  sw  | 设置缩进的空格数，与autoindent选项一起使用 |
|  showmode  | smd  |       在屏幕的右角显示vi编辑器的模式       |
|   terse    |      |                缩短错误信息                |
| wrapmargin |  wm  |       设置距屏幕右边界为指定的字符数       |

### 6.6.4 缩写`ab`

在命令模式输入`:ab hos harmony OS`，进入文本模式，在任何地方输入` hos `，注意前后要有空格，vi就会把hos替换为harmony OS。

`:ab [return]`可以查看所有的缩写

宏操作符`map`：可以指定单个键代表键序列。例如：想要用`q`代替删除5行`5dd`，可以在命令模式输入`:map q 5dd`

以上取消可以按`:unab hos`和`:unmap q`

### 6.6.5 .exrc文件

用户的设置都是临时的，如果想要永久保存对vi的设置，可以在.exrc文件保存设置

## 6.7 其他命令

当你想在vi编辑时运行shell命令，为了在vi中编辑文件不被打断，可以`:! `执行shell命令





# 第7章 正则表达式 Regular Expressions



RE分为BRE和ERE	

Basic RE：

| **字    符** | **BRE/ERE** | **含义**                                                     |
| ------------ | ----------- | ------------------------------------------------------------ |
| \            | Both        | 转义                                                         |
| .            | Both        | 匹配单个字符                                                 |
| *            | Both        | 匹配任意次，可以是0次。a*表示匹配任意多次a，.*表示任意字符串 |
| ^            | Both        | 锚定匹配位置，从一行的行首开始                               |
| $            | Both        | 锚定匹配位置，到一行的行尾                                   |
| […]          | Both        | 匹配中括号内的某个字符。x-y表示一个范围；[^…]表示不匹配中括号中的任意字符。[开括号后跟-或]，-]转义为普通字符 |
| \\{n,m\\}    | BRE         | 匹配次数为[n,m]，\{n\}匹配n次，\{n,\}最小匹配次数为n         |
| \ \(\  \)    | BRE         | 定义一个匹配位置，在后部可以引用该位置。例如，\\(ab\\).*\1表示ab字符串包夹了一个任意字符串。 |
| \n           | BRE         | 引用已经定义的位置，可以从\1到\9                             |



下面是一些例子：

a*g$ 匹配到行尾

^a*g 匹配到行首（\*表示0-任意次）

a[a-z]g可以匹配aag，abg，...,azg都可以

a[\^0-9]g不匹配a9g

> []中也可以加`[[:alnum:]]`表示字符+数字
>
> [[:alpha:]]表示字符
>
> [[:digit:]]表示数字
>
> [[:lower:]]表示小写字符
>
> [[:upper:]]大写字符
>
> [[:space:]]空字符：空格、tab

a{3}匹配aaa,aaaaaa

a{3,}匹配aaa，aaaa，aaaaaa

## 例子

在leetcode上有shell分类，随便点开一题，发现是正则表达式的题目

>给定一个包含电话号码列表（一行一个电话号码）的文本文件 file.txt，写一个单行 bash 脚本输出所有有效的电话号码。
>
>你可以假设一个有效的电话号码必须满足以下两种格式： (xxx) xxx-xxxx 或 xxx-xxx-xxxx。（x 表示一个数字）
>
>你也可以假设每行前后没有多余的空格字符。
>
>示例：
>
>假设 file.txt 内容如下：
>
>987-123-4567
>123 456 7890
>(123) 456-7890
>你的脚本应当输出下列有效的电话号码：
>
>987-123-4567
>(123) 456-7890
>
>来源：力扣（LeetCode）
>链接：https://leetcode-cn.com/problems/valid-phone-numbers

首先当然是匹配行首到行尾，^和$不能少

三位数字怎么弄：```[0-9]{3}```

```^[0-9]{3}-[0-9]{3}-[0-9]{4}$|^(\([0-9]{3}\) [0-9]{3}-[0-9]{4})$```
当然也可以不同，下面截取一个leetcode网友的题解

```bash
cat file.txt | grep -P "^(\([0-9]{3}\)\s|[0-9]{3}-)[0-9]{3}-[0-9]{4}$"
```

![](https://img.mukewang.com/user/60cae86e00013d5806290466.jpg)



简单修改一下在支持re的idea中搜索```(\([0-9]{3}\)\s|[0-9]{3}-)[0-9]{3}-[0-9]{4}$```成功匹配到了正确的电话号码



# 第8章 UNIX文件系统的高级操作

## 8.1 重定向

- C语言程序一般会打开三个缺省文件，stdin、stdout、stderr，文件描述符分别是0,1,2。

- 在Unix系统中，文件是io的基本抽象。标准输入、标准输出、错误输出可以替换为其它文件。

输出重定向

`command > file`

`command >> file` 追加

标准输入重定向

`command < file`

`command << EOF` 标准输入，当碰到EOF字符串时，输入结束

标准错误输出重定向

`command 2> file` 将command的错误输出重定向到file文件

`command 2>> file` 追加重定向

```
ls > mydir.list
cat mydir.list //显示mydir.list

此时再
ls .. >> mydir.list
//将新的内容追加到mydir.list

rmdir ggg &>> mydir.list//将报错消息追加到mydir.list

cat mydir.list
!
anaconda3
CLionProjects
Downloads
examples.desktop
mydir.list
myfirst
snap

rmdir: 删除 'ggg' 失败: 没有那个文件或目录

```

为了提高效率，可以直接使用cat和>创建文件：`cat file1`

`cat file1 file2> file3`可以将file1和file2文件内容复制到file3中。

`cat file3 >> file4` 将file3追加到file4的末尾。



## 8.2 管道

shell将一个程序的标准输出作为另一个程序的标准输入，形成管道（pipeline）

`command A | command B`

注意两条命令之间是以一个匿名文件传输

单向通过，没有格式，以流的形式进行通信

例如，我想在查找`ls -l`的结果中以正则表达式搜索`s.*h`，可以执行

`ls -l|grep -e"s.*h"`

![image-20210615214626196](https://raw.githubusercontents.com/bachwv/picgo/master/image-20210615214626196.png)

### 8.2.1  Shell如何实现管道？



1.pipe()函数创建一个管道，两个文件描述符，一个输入，一个输出

2.fork()创建子进程

3.父进程关闭管道的输出端。

4.子进程dup2，将标准输入替换为管道输入。

5.子进程进一步关闭管道输入和输出。

6.父进程写完数据后，关闭管道输出。

7.子进程从父进程收到EOF，输入数据完毕。



## 8.3  文件操作

cp拷贝源文件成目标文件

| **短选项** | 长选项        | **功能**                   |
| ---------- | ------------- | -------------------------- |
| -b         | --backup      | 如果目标文件存在，创建备份 |
| -i         | --interactive | 如果目标文件存在，要求确认 |
| -r         | --recursive   | 将目录复制到新的目录       |
|            | --verbose     | 解释操作                   |
|            | --help        | 显示帮助页并退出           |



mv移动文件

| **短选项** | 长选项        | **功能**                   |
| ---------- | ------------- | -------------------------- |
| -b         | --backup      | 如果目标文件存在，创建备份 |
| -i         | --interactive | 如果目标文件存在，要求确认 |
| -f         | --force       | 强制移动，不要求确认       |
| -v         | --verbose     | 解释操作                   |
|            | --help        | 显示帮助页并退出           |
|            | --version     | 显示版本信息并退出         |

## 8.4 ln链接文件

用于为已存在的文件创建另外的名字（链接）。

假设有一个a.txt文件，想给他另一个名字b.txt

输入```$ sudo ln a.txt b.txt```

再查看一下目录```$ ls -li```

```
10878 -rw-r--r-- 2 endwsl endwsl    0 Apr 12 20:08 a.txt
10878 -rw-r--r-- 2 endwsl endwsl    0 Apr 12 20:08 b.txt
```



```
endwsl@LAPTOP-U1E6STIA:/home$ cat >>a.txt 
atxt
//修改一下a.txt的内容
endwsl@LAPTOP-U1E6STIA:/home$ cat b.txt //再去看b.txt的内容
atxt //发现竟然也是atxt
```



甚至ln命令不会创建新的i-node，而是引用已有i-node，增加引用计数。

ln –s符号链接，分配一个新的inode，内部记录指向原有文件。



## 8.5 其他wc,head,tail



 wc统计字数

| **短选项** | **长选项** | **功能**     |
| ---------- | ---------- | ------------ |
| -l         | --lines    | 统计行数     |
| -w         | --words    | 统计单词数量 |
| -c         | --chars    | 统计字符数量 |
|            | --help     | 帮助         |

```
$ wc -l mydir.list
19 mydir.list
$ wc -w mydir.list
23 mydir.list
$ wc -c mydir.list
215 mydir.list
```

head显示文件头部，缺省显示头部10行。

| **短选项** | **长选项** | **功能**           |
| ---------- | ---------- | ------------------ |
| -n         | --lines=n  | 显示头部n行        |
| -c         | --chars=n  | 显示头部n个字符    |
|            | --help     | 显示帮助页并退出   |
|            | --version  | 显示版本信息并退出 |

tail显示文件尾部，缺省是尾部10行，与head类似就不再列举出。

paste命令横向连接两个文件。缺省分隔符为TAB制表符。

| **短选项** | **长选项**     | **功能**           |
| ---------- | -------------- | ------------------ |
| -d  x      | --delimiters=x | 指定域分隔符       |
|            | --help         | 显示帮助页并退出   |
|            | --version      | 显示版本信息并退出 |



## 8.6 sed替换

| 选项            | 含义                                                         |
| --------------- | ------------------------------------------------------------ |
| -e 脚本命令     | 该选项会将其后跟的脚本命令添加到已有的命令中。               |
| -f 脚本命令文件 | 该选项会将其后文件中的脚本命令添加到已有的命令中。           |
| -n              | 默认情况下，sed 会在所有的脚本指定执行完毕后，会自动输出处理后的内容，而该选项会屏蔽启动输出，需使用 print 命令来完成输出。 |
| -i              | 此选项会直接修改源文件，要慎用。                             |

一个使用的例子：

我在使用群晖时发现：一旦ssd温度升高到61度就会引起自动关机,由于我的群晖没有风扇，对于ssd达到这个温度轻而易举，一个24小时工作的设备肯定不希望它经常关机，根据教程查看群晖的配置文件发现

```
admin@DiskStation:/usr/syno/etc.defaults$ cat scemd.xml | grep -E "61"
        <disk_temperature fan_speed="FULL" action="SHUTDOWN">61</disk_temperature>
        <disk_temperature fan_speed="FULL" action="SHUTDOWN">61</disk_temperature>
        <disk_temperature fan_speed="FULL"   action="SHUTDOWN">61</disk_temperature>
        <disk_temperature fan_speed="FULL"    
```

群晖的温度墙为61度，此时使用sed替换所有的61为70

```sudo sed -i"s/61/70/g" scemd.xml```

```
admin@DiskStation:/usr/syno/etc.defaults$ cat scemd.xml | grep -E "70"
action="SHUTDOWN">70</disk_temperature>
        <disk_temperature fan_speed="FULL" action="SHUTDOWN">70</disk_temperature>
        <disk_temperature fan_speed="FULL"   action="SHUTDOWN">70</disk_temperature>
        <disk_temperature fan_speed="FULL"   action="SHUTDOWN">70</disk_temperature>
```

这样就让温度墙设定为70度

（由于群晖基于的是freebsd，因此在群晖的控制面板打开ssh即可使用ssh client登陆，注意：SSH 仅支持属于 local administrators 群组的帐户登录系统。默认端口为22）

（尴尬的是改完温度墙以后，使用一段时间温度就会达到70°，只好去加了个风扇）

不过使用```s///g```对替换里面字符里面要是有路径的话就会很难受,所以可以用```s:::g```来表示同样的意思。

## 8.7 打开文件：grep命令

grep命令打开文件，在文件中以RE方式搜索字符串


| **短选项**   | **长选项**        | **功能**         |
| ------------ | ----------------- | ---------------- |
| -c           | --count           | 只显示匹配的行数 |
| -i           | --ignore-case     | 忽略大小写匹配   |
| -G           | --basic-regexp    | BRE，grep缺省    |
| -E           | --extended-regexp | ERE，egrep缺省   |
| -e  PATTERNS | --regexp=PATTERNS | 指定一个或多个RE |
| -v           | --invert-match    | 显示不匹配的行   |
| -n           | --line-number     | 输出行号         |
| -o           | --only-matching   | 只输出匹配的部分 |

## 8.8 find查找文件



| 选项             | 功能                           |
| ---------------- | ------------------------------ |
| -name filename   | 根据给定的filename查找文件。   |
| -size ± n        | 查找文件大小为n的文件          |
| -type file type  | 查找指定类型的文件             |
| -atime ± n       | 查找n天以前访问的文件          |
| -mtime ± n       | 查找n天以前修改的文件          |
| -newer filename  | 查找比filename更近期更新的文件 |
| -print           | 显示找到的每个文件的路径名     |
| -exec command\； | 对找到的文件执行command        |
| -ok command\；   | 在执行command之前要求确认      |

- -name选项实例：

  - -find.-name first.c-print[Return]  查找文件名为first.c的文件。

  - $find.-name "*.？"-print[Return] 查找文件名为点和单个字符结尾的文件。

- -size ± n选项：+表示大于，-表示小于。
- -type选项：
  - -b :  块特殊文件（如磁盘）
  - -c ：字符特殊文件（如终端）
  - -d ： 目录文件
  - -f ： 普通文件
- -emax

统计/usr/include/sys目录下的所有目录及子目录个数

```
find /usr/include/sys -type d|wc -l
```



查找epoll_wait函数在那个文件：
find /usr/include –name “*.h” -type f | xargs grep ‘epoll_wait’

搜索/usr/include目录中，引用EPOLLIN常数的头文件

```
find -name "*.h" -type f|xargs grep "EPOLLIN"./linux/eventpoll.h:#define EPOLLIN		0x00000001./x86_64-linux-gnu/sys/epoll.h:    EPOLLIN = 0x001,./x86_64-linux-gnu/sys/epoll.h:#define EPOLLIN EPOLLIN
```



在usr/include中查找文件名以.h结尾的所有普通文件。

```shell
find /usr/include -name "*.h"
```

## 8.9 文件系统

unix文件系统将每一个文件名与一个数字(inode)连接起来，并用文件的inode来标识每一个文件。

磁盘结构：

在unix先，磁盘是标准的块设备，unix的磁盘分为4个块

- 引导块

- 超级块 包含有关磁盘自身的信息

  - 磁盘的总块数
  - 空闲块数
  - 块的大小
  - 已使用的块数

- inode列表块

  保存inode列表，列表中的每一个表项是一个inode，有64字节存储空间。普通文件或者目录文件的inode包含文件在磁盘块的位置。特殊文件的inode包含标识外部设备的信息。除了以上，还有：

  - 文件访问权限（读写执行）
  - 文件属主和组id
  - 文件链接数
  - 文件最后修改时间
  - 文件最后访问时间
  - 每个普通文件和目录文件的块位置
  - 特殊文件的设备标识号

- 文件和目录块

  第二个inode包含根目录所在块的位置。创建目录时，系统自动创建两个表项：.（表示子目录）和..（表示父目录）



# 第9章 探索Shell

unix由内核和系统工具组成。内核是核心，所有直接与硬件通信的常规程序都集中在内核中。 

shell是用户和系统交流的工具，自身是一个应用程序。当用户登录到系统时shell被装入内存。

用户登录时，init（进程号1）拉起login，输入密码成功后，由login进程拉起shell进程

![image-20210412205628871](https://cdn.jsdelivr.net/gh/bachwv/picgo/image-20210412205628871.png)



对于大多数用户键入的命令，shell并不执行，它fork子进程来执行命令，shell等待wait子进程结束（等待SIGCHLD信号）。

shell的主要功能：

- 命令执行
- 文件名替换
- I/O重定向
- 管道：把简单程序连接到一起来完成一个较为复杂的任务。“|”就是管道操作符
- 环境控制：用户通过设定，可以变更主目录、命令提示符或工作环境
- 后台计算：shell的后台计算能力使用户能够在前台进行工作的同时在后台运行程序。
- shell脚本

## 9.1 显示消息：echo命令



echo命令输出字符串，```echo hello there```就会输出hello there

一般默认输出禁止换行

## 9.2 shell 变量

bash shell 用一个叫做环境变量(environment variable)的特性来存储有关shell会话和工作环境的信息。这项特性允许用户存储信息，以便程序或shell中运行的脚本能够轻松访问。这也是持久存储数据的一种简便方法。

UNIX支持两种变量:环境变量和局部变量。（shell变量是字符串）

- 环境变量：为系统所知道的变量名，通常由系统管理员定义。
- 局部变量：用户定义，并完全由用户控制。

### 9.2.1 显示和清除变量：set和unset命令

使用set命令可以查看当前使用的shell变量

使用echo显示变量的值。在这种情况下引用某个环境变量的时候，必须在变量前面 加上一个美元符（$）。

```
echo $HOME
```

在echo命令中，在变量名前加上$可不仅仅是要显示变量当前的值。它能够让变量作为命令 行参数。

```
ls $HOME
```

全局环境变量可用于进程的所有子shell。

unset可以清除不想要的变量，也可以用赋值语句来修改用户变量或者标准变量。注意：标准shell变量的改变是占时的，只用于当前会话，当下次登录时，还要重新进行设置。如果想要长久改变系统变量的值，可以把变量放到名为.profile的文件中。

### 9.2.2 标准 shell 变量

- HOME 变量：shell把用户主目录的完整路径赋值给变量HOME。
- IFS 变量：内部字段分隔符，用来用户输入的分隔命令。包括空格，tab，换行符。即IFS=$' \t\n' 。
- MAIL 变量：接收用户邮件文件的文件名。
- PATH 变量：shell在定位命令时所要查找的目录名。UNIX一般把可执行文件存在一个叫做bin的目录中。以下是我的键入shell后的结果：

```shell
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
```

## 9.3 其他元字符

### 9.3.1 重音符号

shell执行重音符号\`中的命令，并将命令的输出插入到命令行的相应位置中，也被称为命令替换符。

![image-20220616105949017](https://cdn.jsdelivr.net/gh/bachwv/picgo/image-20220616105949017.png)

### 9.3.2 括号

将几个命令放在括号里，可以编组。一个命令组可以像单条命令一样被重定向。

### 9.3.3 后台处理&

jobs命令列举后台执行的作业

## 9.4 其他UNIX工具

### 9.4.1 延时定时

`sleep`，让某个命令延缓一段时间执行。

### 9.4.2 显示PID

当程序运行在系统上时，我们称之为进程（process）。想监测这些进程，需要熟悉`ps`命令的 用法。ps命令能输出运行在系统上的所有程序的许多信息。

默认情况下，ps命令并不会提供那么多的信息,只显示PID,TTY,TIME,COMMAND

默认情况下，ps命令只会显示运行在当前控制台下的属于当前用户的进程。



| **选项** | **功能**                                           |
| -------- | -------------------------------------------------- |
| -a       | 显示所有进程，但不包括会话leader，不包括无终端进程 |
| -f       | 显示进程完整信息                                   |
| -e       | 显示所有进程                                       |
| -H       | 按照树型显示                                       |
| -j       | 按照job形式输出                                    |

### 9.4.3 kill命令

终止不想要的进程

根据执行情况的不同，kill发送给进程的信号范围可以取1-15.

### 9.4.4 分离输出

`tee`将命令结果显示到终端同时保存到指定文件中。

`sort new.list|tee new1.list`

### 9.4.5 文本排序

`sort`对文件内容按照字母或数字排序。

## 9.5 列出之前输入的命令

Bash在执行命令后，会在内存中记录所有使用的命令。当用户退出登录，所有命令保存在~/.bash_history文件中，history命令则列出到目前为止，执行的所有命令。使用这一功能可以使用用户已经键入过的命令，找到已经执行过的命令。

~/.bash_history记录的是到上次退出前的所有命令，会一直增加并保存，最终会变得非常大。想要重新记录history的话可以将其删除。

`fc`命令:列出、编辑和重复执行history命令列表文件的命令。

`fc first last` 先编辑从first到last的命令，然后执行

`fc –s cmd cmd`是history的命令编号，执行该编号任务

## 9.6 创建别名



`alias ll=‘ls –al’`设置`ll`为`ls -al`命令的别名。



# 第10章 Unix通信

UNIX提供了一组与其他用户通信的命令和工具。

## 10.1 通信方式

### 10.1.1 write命令

write命令可以发送消息给系统内其他的已经登陆的用户。另一个用户无论在干什么，消息都会出现在屏幕上。甚至在使用vi时，write消息也会显示在光标处。但仅仅是覆盖在屏幕上的消息，不会破坏用户正在编辑的任务。当然也可以使用mesg禁止终端接收来自write命令的消息。

### 10.1.2 显示新闻：news命令

用户可以使用news命令来看看系统正在做什么。news从系统news命令读出消息。默认显示news目录下用户还没有看过的所有文件。

| **选项** | 操作                                 |
| -------- | ------------------------------------ |
| -a       | 显示所有的新闻项，无论是新的还是旧的 |
| -n       | 仅仅列出新闻名                       |
| -s       | 显示当前新闻的总数                   |

### 10.1.3 广播消息：wall命令

wall(write all)命令给当前登录到系统上的所有用户发送消息。通常由系统管理员使用，用于通知用户一些紧急事件。

### 10.1.4 全双工通信：talk命令

talk命令与write相似，都用于用户与系统中已经登录的其他用户通信。输入talk和用户名，连接建立成功，两个用户就可以进行交谈了。这时，双方的终端屏幕上都将显示信息`[Connection established]`并响铃，同时屏幕被linux中talk命令程序以一条水平线分割为上下两部分，上半部分用来显示用户自己输入的内容，下半部分用来显示对方输入的内容。两个用户可以同时输入，他们输入的内容将会立即显示在双方的屏幕上。

在用户进行输入时，可按BACKSPACE见来更正前一个字符，也可按CTRL+w来删除一个完整的单词，或者用CTRL+U来删除一整行，另外，用户还可以通过按CTRL+L来刷新屏幕。如果要结束交谈，可由任何一方按下CTRL+C来中断连接，但在结束对话前最好道声“再见”，并等待对方回应。linux中talk命令程序结束时，在屏幕上将回显示一条信息：

`[Connection closing. Exiting]`
并非每次要求对方交谈都能成功，有时对方没有登录，则linux中talk命令程序提示信息：

`[Your party is not logged on]`
并退出；如果对方已登录，但因某种原因（如不是正在使用机器）没有响应，那么linux中talk命令程序将会每隔10秒钟给他发一条邀请信息，同时在自己的屏幕上显示：

`[Ringing your party again]`
如果用户不愿等待，则可以按CTRL+C终止linux中talk命令程序。还有的时候系统可能出现下面的信息：
`[Checking for invitation on caller’s machine]`
这说明双方的linux中talk命令程序不兼容，这时可以试试ntalk和ytalk命令，如果没有，就只好找系统管理员了。

如果用户在做某些紧急工作（如编辑邮件）时不希望被linux中talk命令的邀请打搅，他可以使用命令：`mesg n`来暂时拒绝交谈，这时如果有用户邀请他交谈，只能得到提示信息：`[Your party is refusing messages]`

## 10.2 电子邮件

mailx工具为用户提供电子邮件系统，可以给系统上其他用户发邮件，无论对方是否已经登录到系统。

当用户使用mailx读取文件时，它处于命令模式，该模式的命令提示符是问号。



| 命令         | 功能                                                        |
| ------------ | ----------------------------------------------------------- |
| !            | 让用户执行shell命令（shell转义）                            |
| cd directory | 切换到指定的目录direction，如果没有指定目录，则切换到主目录 |
| d            | 删除指定消息                                                |
| f            | 显示消息头行                                                |
| q            | 退出mail，并将消息从系统邮箱移去                            |
| h            | 显示当前消息头                                              |
| m users      | 给指定用户users发送邮件                                     |
| R messages   | 给消息messages发送者回复消息                                |
| r messages   | 给消息messages发送者和同一消息的其他所有接收者回复消息      |
| s messages   | 保存消息到filename文件                                      |
| t messages   | 显示指定消息messages                                        |
| u messages   | 恢复已删除的指定消息messages                                |
| x            | 退出mailx，不将消息从系统邮箱中移去                         |

mailx的~转义命令

| 命令        | 功能                                           |
| ----------- | ---------------------------------------------- |
| ~?          | 显示~转义命令列表                              |
| ~! command  | 在编辑邮件时，让用户调用指定的shell命令command |
| ~ e         | 调用编辑器                                     |
| ~ p         | 显示当前正编辑的消息                           |
| ~r filename | 读取filename文件                               |
| ~< filename | 读取filename文件                               |
| ~<! command | 执行指定命令command                            |
| ~v          | 调用默认编辑器vi                               |
| ~q          | 推出输入模式                                   |
| ~w filename | 将当前正编辑的消息写到filename文件中           |

# 第11章 GNU 工具链

## 11.1 Gnu工具链

Gnu toolchain是开发操作系统、应用程序的一套完整的程序和库，包括gcc、gdb、glibc：

## 11.2 gcc

是一族编译器，包括c、c++、go、java等

前端+后端

- .c为后缀的文件，C语言源代码文件；

- .a为后缀的文件，是由目标文件构成的档案库文件；
- .C、.cc或.cxx 为后缀的文件，是C++源代码文件；
- .h为后缀的文件，是程序所包含的头文件；
- .i 为后缀的文件，是已经预处理过的C源代码文件；
- .ii为后缀的文件，是已经预处理过的C++源代码文件；
- .m为后缀的文件，是Objective-C源代码文件；
- .o为后缀的文件，是编译后的目标文件；
- .s为后缀的文件，是汇编语言源代码文件；
- .S为后缀的文件，是经过预编译的汇编语言源代码文件。

C语言编译过程

- gcc -E hello.c -o hello.i

- gcc -S hello.i -o hello.s 
- gcc -c hello.s -o hello.o
- gcc -o hello hello.o

## 11.3 gdb

- gdb program

| 命令                     | 缩写 | 描述             |
| ------------------------ | ---- | ---------------- |
| list                     | l    | 打印当前位置源码 |
| break                    | b    | 设置断点         |
| run                      | r    | 运行程序         |
| step                     | s    | 单步，进入函数   |
| next                     | n    | 单步，不进入函数 |
| print                    | p    | 打印变量         |
| continue                 | c    | 继续运行         |
| backtrace                | bt   | 显示调用栈       |
| info threads             |      | 显示线程         |
| thread n                 |      | 切换线程         |
| set scheduler-locking on |      | 关闭线程调度     |

## 11.4 makefile

Makefile用于工程组织和编译，与常见的命令式语言不同，它是一种依赖推导语言。

Shell语言：变量定义+命令执行

Makefile：变量定义+依赖描述

显式规则与隐式规则

- %.o: %.c

- \$(COMPILE.c) \$(OUTPUT_OPTION) \$<

推导规则

- 检查目标和依赖文件的时间，如果依赖更新，则执行动作

- 显式规则 > 隐式规则

推导过程

- 动态规划

- 从target出发，枚举所有规则，直到依赖可达

## 11.5 cmake

cross platform make跨平台自动化建置系统。

Cmake vs Makefile

- Makefile的依赖推导不直观
- Cmake的语法设计采用命令式
- 跨平台，可以导出为makefile、sln等

Cmake在不同平台上生成不同的本地化脚本

- Linux下的Gnu Makefile
- Visual Studio的sln
- Google等ninja

Cmake管理的代码编译主要有两步：

- 利用cmake生成本地编译脚本

- 利用本地脚本编译程序

基本语法

- 定义工程

- 设置变量

- 添加可执行目标

- 添加递归目录

- 添加静态库、动态库

- 条件分支

- 定制命令和目标add_custom_command/add_custom_target

## 11.6 git

虽然之前学了下git，但学得不够深入，最近重新看了一下git的相关知识

Git 工作区、暂存区和版本库概念：

- **工作区：**就是你在电脑里能看到的目录。
- **暂存区：**英文叫 stage 或 index。一般存放在 **.git** 目录下的 index 文件（.git/index）中，所以我们把暂存区有时也叫作索引（index）。
- **版本库：**工作区有一个隐藏目录 **.git**，这个不算工作区，而是 Git 的版本库。

下面这个图展示了工作区、版本库中的暂存区和版本库之间的关系：

![img](https://www.runoob.com/wp-content/uploads/2015/02/1352126739_7909.jpg)

**git clone**、**git push**、**git add** 、**git commit**、**git checkout**、**git pull**

![img](https://www.runoob.com/wp-content/uploads/2015/02/git-command.jpg)

以前只会git push后面不加东西，然后在推送blog时出现了一些问题

命令格式如下：

```
git push <远程主机名> <本地分支名>:<远程分支名>
```

如果本地分支名与远程分支名相同，则可以省略冒号：

```
git push <远程主机名> <本地分支名>
```

 实例

以下命令将本地的 master 分支推送到 origin 主机的 master 分支。

```
$ git push origin master
```

相等于：

```
$ git push origin master:master
```

如果本地版本与远程版本有差异，但又要强制推送可以使用 --force 参数：

```
git push --force origin master
```

删除主机但分支可以使用 --delete 参数，以下命令表示删除 origin 主机的 master 分支：

```
git push origin --delete master
```

分支

想push时不影响原来的远程分支，怎么办？回退很麻烦，那怎么办？

创建分支命令：

```
git branch (branchname)
```

切换分支命令:

```
git checkout (branchname)
```

当你切换分支的时候，Git 会用该分支的最后提交的快照替换你的工作目录的内容， 所以多个分支不需要多个目录。

合并分支命令:

```
git merge 
```

你可以多次合并到统一分支， 也可以选择在合并之后直接删除被并入的分支。

开始前我们先创建一个测试目录：

```
$ mkdir gitdemo$ cd gitdemo/$ git initInitialized empty Git repository...$ touch README$ git add README$ git commit -m '第一次版本提交'[master (root-commit) 3b58100] 第一次版本提交 1 file changed, 0 insertions(+), 0 deletions(-) create mode 100644 README
```

------

### Git 分支管理

#### 列出分支

列出分支基本命令：

```
git branch
```

没有参数时，**git branch** 会列出你在本地的分支。

```
$ git branch* master
```

此例的意思就是，我们有一个叫做 **master** 的分支，并且该分支是当前分支。

当你执行 **git init** 的时候，默认情况下 Git 就会为你创建 **master** 分支。

如果我们要手动创建一个分支。执行 **git branch (branchname)** 即可。

```
$ git branch testing$ git branch* master  testing
```

现在我们可以看到，有了一个新分支 **testing**。

当你以此方式在上次提交更新之后创建了新分支，如果后来又有更新提交， 然后又切换到了 **testing** 分支，Git 将还原你的工作目录到你创建分支时候的样子。

接下来我们将演示如何切换分支，我们用 git checkout (branch) 切换到我们要修改的分支。

```
$ lsREADME$ echo 'runoob.com' > test.txt$ git add .$ git commit -m 'add test.txt'[master 3e92c19] add test.txt 1 file changed, 1 insertion(+) create mode 100644 test.txt$ lsREADME        test.txt$ git checkout testingSwitched to branch 'testing'$ lsREADME
```

当我们切换到 **testing** 分支的时候，我们添加的新文件 test.txt 被移除了。切换回 **master** 分支的时候，它们有重新出现了。

```
$ git checkout masterSwitched to branch 'master'$ lsREADME        test.txt
```

我们也可以使用 git checkout -b (branchname) 命令来创建新分支并立即切换到该分支下，从而在该分支中操作。

```
$ git checkout -b newtestSwitched to a new branch 'newtest'$ git rm test.txt rm 'test.txt'$ lsREADME$ touch runoob.php$ git add .$ git commit -am 'removed test.txt、add runoob.php'[newtest c1501a2] removed test.txt、add runoob.php 2 files changed, 1 deletion(-) create mode 100644 runoob.php delete mode 100644 test.txt$ lsREADME        runoob.php$ git checkout masterSwitched to branch 'master'$ lsREADME        test.txt
```

如你所见，我们创建了一个分支，在该分支的上移除了一些文件 test.txt，并添加了 runoob.php 文件，然后切换回我们的主分支，删除的 test.txt 文件又回来了，且新增加的 runoob.php 不存在主分支中。

使用分支将工作切分开来，从而让我们能够在不同开发环境中做事，并来回切换。

#### 删除分支

删除分支命令：

```
git branch -d (branchname)
```

例如我们要删除 testing 分支：

```
$ git branch* master  testing$ git branch -d testingDeleted branch testing (was 85fc7e7).$ git branch* master
```

#### 分支合并

一旦某分支有了独立内容，你终究会希望将它合并回到你的主分支。 你可以使用以下命令将任何分支合并到当前分支中去：

```
git merge$ git branch* master  newtest$ lsREADME        test.txt$ git merge newtestUpdating 3e92c19..c1501a2Fast-forward runoob.php | 0 test.txt   | 1 - 2 files changed, 1 deletion(-) create mode 100644 runoob.php delete mode 100644 test.txt$ lsREADME        runoob.php
```

以上实例中我们将 newtest 分支合并到主分支去，test.txt 文件被删除。

合并完后就可以删除分支:

```
$ git branch -d newtestDeleted branch newtest (was c1501a2).
```

删除后， 就只剩下 master 分支了：

```
$ git branch* master
```

#### 合并冲突

合并并不仅仅是简单的文件添加、移除的操作，Git 也会合并修改。

```
$ git branch* master$ cat runoob.php
```

首先，我们创建一个叫做 change_site 的分支，切换过去，我们将 runoob.php 内容改为:

```
<?phpecho 'runoob';?>
```

创建 change_site 分支：

```
$ git checkout -b change_siteSwitched to a new branch 'change_site'$ vim runoob.php$ head -3 runoob.php<?phpecho 'runoob';?>$ git commit -am 'changed the runoob.php'[change_site 7774248] changed the runoob.php 1 file changed, 3 insertions(+) 
```

将修改的内容提交到 change_site 分支中。 现在，假如切换回 master 分支我们可以看内容恢复到我们修改前的(空文件，没有代码)，我们再次修改 runoob.php 文件。

```
$ git checkout master
Switched to branch 'master'
$ cat runoob.php
$ vim runoob.php    # 修改内容如下
$ cat runoob.php
<?php
echo 1;
?>
$ git diff
diff --git a/runoob.php b/runoob.php
index e69de29..ac60739 100644
--- a/runoob.php
+++ b/runoob.php
@@ -0,0 +1,3 @@
+<?php
+echo 1;
+?>
$ git commit -am '修改代码'
[master c68142b] 修改代码
 1 file changed, 3 insertions(+)
```

现在这些改变已经记录到我的 "master" 分支了。接下来我们将 "change_site" 分支合并过来。

```
$ git merge change_site
Auto-merging runoob.php
CONFLICT (content): Merge conflict in runoob.php
Automatic merge failed; fix conflicts and then commit the result.

$ cat runoob.php     # 代开文件，看到冲突内容
<?php
<<<<<<< HEAD
echo 1;
=======
echo 'runoob';
>>>>>>> change_site
?>
```

我们将前一个分支合并到 master 分支，一个合并冲突就出现了，接下来我们需要手动去修改它。

```
$ vim runoob.php 
$ cat runoob.php
<?php
echo 1;
echo 'runoob';
?>
$ git diff
diff --cc runoob.php
index ac60739,b63d7d7..0000000
--- a/runoob.php
+++ b/runoob.php
@@@ -1,3 -1,3 +1,4 @@@
  <?php
 +echo 1;
+ echo 'runoob';
  ?>
```

在 Git 中，我们可以用 git add 要告诉 Git 文件冲突已经解决

```
$ git status -sUU runoob.php$ git add runoob.php$ git status -sM  runoob.php$ git commit[master 88afe0e] Merge branch 'change_site'
```

现在我们成功解决了合并中的冲突，并提交了结果。

以上文字大多数摘自runoob.com，我感觉是写得非常有条理了，另外介绍一个学习gitbranch的神奇的网站，无聊的时候可以练练手。

https://learngitbranching.js.org/

# 第12章 Shell编程

Shell是一种语言，bash、csh

- Unix的传统是提供基本的功能，由用户自行扩展，包括自己编写shell脚本

### 12.1.1 编写简单脚本

```
endwsl@LAPTOP-U1E6STIA:~$ cat <<EOF>> won.list> ls> -bash: warning: here-document at line 74 delimited by end-of-file (wanted `EOF')endwsl@LAPTOP-U1E6STIA:~$ cat won.listls
```

### 12.1.2 执行脚本

执行脚本 sh won.list :

````
endwsl@LAPTOP-U1E6STIA:~$ sh won.list-  ew  ew.list  goodstuff  new.list  vinew  won.list  xxxscriptendwsl@LAPTOP-U1E6STIA:~$
````

另一种方法：chmod改变文件权限，使其变成可执行

脚本工作原理

- loader程序加载脚本，发现不是elf可执行文件，返回错误

- bash收到错误，然后打开文件头部，发现是脚本

- 调用脚本执行



•基于兼容性考虑

- #! /bin/sh

- Debian上的/bin/sh符号链接指向dash

- dash对标准的兼容性更好

### 12.2.1 使用特殊字符

echo换行：`echo "\nhello\n"`

### 12.2.2 退出系统的方式

在shell脚本里写`exit`是没用的，因为shell会fork子进程来执行命令。

### 12.2.3 点命令

可以使用点命令来阻止shell创建子进程。

### 12.2.4 读取命令：read

从标准输入设备读取用户输入，并将值存入用户自定义变量中。



### 12.3.1 注释 #



### 12.3.2 变量

字符串类型，具体内容在前面讲过。

### 12.3.3 命令行参数

shell脚本可以从命令行最多读取10个命令行参数存入特殊变量，命令行参数是用户输入命令后所跟的数据项，通常用空格分隔。这些变量按顺序从1到9计数。

| **参数变量**                                                 |
| ------------------------------------------------------------ |
| $1-$9，${10}表示参数                                         |
| $0表示被调用脚本的名字                                       |
| $#表示参数个数                                               |
| $*将所有参数使用$IFS隔开，形成一个字符串                     |
| $@是每个参数一行，将参数隔开，实际上是多个字符串，可以用在for循环 |
| $$表示当前进程id                                             |

特殊变量

- $?表示进程退出状态

- ls -al hello

- echo $? 前面命令退出的状态



另外一个给变量赋值的方式是`set`

```set hello "I love bash" world```

```shell
endwsl@LAPTOP-U1E6STIA:~$ echo $0
-bash
endwsl@LAPTOP-U1E6STIA:~$ echo $#
3
endwsl@LAPTOP-U1E6STIA:~$ set hello "i love" world
endwsl@LAPTOP-U1E6STIA:~$ echo $#3   //3个参数hello 和"i love"和world
endwsl@LAPTOP-U1E6STIA:~$ echo $1hello
endwsl@LAPTOP-U1E6STIA:~$ echo $2i love bash
endwsl@LAPTOP-U1E6STIA:~$ echo $3world
endwsl@LAPTOP-U1E6STIA:~$ echo $* //$*和$@相似hello i love world
```

```shell
endwsl@LAPTOP-U1E6STIA:~$ echo $*hello i love world
endwsl@LAPTOP-U1E6STIA:~$ echo $@hello i love world
```



### 12.3.4 条件与测试



if-then-elif结构：

```
if条件; then command1elif command2 then command3 else command4fi
```

真或假：test命令

实际上，if语句中括住条件的方括号是test命令的一种特殊形式。

例子：

```shell
minatoxeon@OMEN:~$ cat eg_conditionechoecho "enter y or n:\c"read condif [ $cond = y ]then echo "you enter y"else echo "you not  enter n"fiechoexit 0minatoxeon@OMEN:~$ sh eg_conditionenter y or n:yyou enter yminatoxeon@OMEN:~$ sh eg_conditionenter y or n:llyou not  enter n
```

### 12.3.5 不同类型的判断

不单单是相等的判断，test可以进行多种类型的判断

| 操作符 | 例子    | 含义           |
| ------ | ------- | -------------- |
| -eq    | a -eq b | a是否等于b     |
| -ne    | a -ne b | a是否不等于b   |
| -gt    | a -gt b | a是否大于b     |
| -ge    | a -ge b | a是否大于大于b |
| -lt    | a -lt b | a是否小于b     |
| -le    | a -le b | a是否小于等于b |

test还可以比较字符串

## 

| **操作符** | **示例**           | **说明**           |
| ---------- | ------------------ | ------------------ |
| =          | “$STR1” = “STR2”   | 两个字符串是否相同 |
| !=         | “$STR1”  != “STR2” | 两个字符串是否不同 |
| -n         | -n  “$STR”         | 字符串不是null     |
| -z         | -z  “$STR”         | 字符串是null       |

注意：在引用变量做字符串测试时，一定要加引号

操作符两侧必须有空格

[ … ]中括号必须有空格``` [ "$VAR1" = "VAR3" ]```

文件



### 12.3.6 参数替换

用户可以检验参数的值并根据选项改变它的值。

格式为`${parameter:optionchar word}`

变量替换

| **替换操作**    | **功能**                                               |
| --------------- | ------------------------------------------------------ |
| ${VAR:-word}    | 如果变量不存在，返回word  #变量不会创建                |
| ${VAR:=word}    | 如果变量不存在，设置VAR变量为word，返回word            |
| ${VAR:?message} | 如果变量不存在，打印message，退出，但交互shell不会退出 |
| ${VAR:+word}    | 如果变量存在，返回word；否则返回null                   |

```
endwsl@LAPTOP-U1E6STIA:~$ echo ${VAR:-world} #变量不会创建worldendwsl@LAPTOP-U1E6STIA:~$ echo $VAR
```

`${var:?meg}`通常用来显示错误信息

## 12.4 算术表达式

### 12.4.1 算术运算：expr命令

在powershell里可以直接输入1+1，会得到2

但是在shell里直接输入1+1不会有结果，因为Shell会把1单作是字符串而不是变量，那么要想在shell里面计算1+1怎么办？

```
expr 1+1
```

expr提供数字和非数字的关系运算符

### 12.4.2 算术运算：let命令

let命令与expr命令类似，并可以相互替换。

let命令自动使用变量的值：

```shell
minatoxeon@OMEN:~$ x=100minatoxeon@OMEN:~$ let x=x+1minatoxeon@OMEN:~$ echo $x101
```

let命令的缩写：双括号`(())`

下面就是i++的经典问题

```
endwsl@LAPTOP-U1E6STIA:~$ i=4endwsl@LAPTOP-U1E6STIA:~$ echo $i4endwsl@LAPTOP-U1E6STIA:~$ echo $((i++)) $i4 5endwsl@LAPTOP-U1E6STIA:~$ echo $((++i)) $i6 6
```

## 12.5 循环结构

- Shell提供三种循环：for、while、until
- 循环与分支类似，都带有一定的结构，是shell语言的支持

### 12.5.1 for循环：for-in-done 结构

```
for variablein list-of-valuesdo	 commands    ...	 last-commanddone
```

例子：

```
endwsl@LAPTOP-U1E6STIA:~$ cat sum1.sh#! /bin/bashtotal=0for i in "$@"do        total=$(($total + $i))        printf "$i + "doneprintf "\b\b= $total"
```



### 12.5.2 while循环

直接上例子：

```
endwsl@LAPTOP-U1E6STIA:~$ cat sum.sh
#! /bin/bash
#这里的$#每经过一轮循环就会减1
#位置参数可以用shift命令左移
total=0
while [ $# -gt 0 ]; do
        total=$(($total + $1))
        printf "$1 + "
        shift
done
printf "\b\b= $total"
```

### 12.5.3 until循环

```
#! /bin/bash
total=0
until [ $# -le 0 ]; do
        total=$(($total + $1))
        printf "$1 + "
        shift
done
printf "\b\b= $total"
```



#### 逻辑连接

这里的&&和||和预想的会很不一样，举例如下：

`command1 && command2`当command1正确执行，才会执行command2 

相当于：

```python
if command1 :
    command2
```

`command1 || command2`，当command1执行错误，才会执行command2

```python
if !command1 :    command2
```

#### 代码分块

将多行命令用分号;隔开，再利用()将多条命令组合在一起

```
endwsl@LAPTOP-U1E6STIA:~$ (date ; echo $$)(date ; echo $$)+ dateMon 26 Apr 2021 09:07:31 PM CST+ echo 1717
```



算术表达式测试

- 利用$(())计算算术表达式
- 利用字符串比较
- `[ $((2+3)) = 5 ]; echo $?`
- `i=3; [ $((i+7)) = 10 ];echo $?`

#### 调试

替换处理后真实执行的指令，比如展开$$

```
endwsl@LAPTOP-U1E6STIA:~$ echo "hello world"hello worldendwsl@LAPTOP-U1E6STIA:~$ set -vxendwsl@LAPTOP-U1E6STIA:~$ echo "hello world"echo "hello world" #原始命令+ echo 'hello world' #替换处理后真实执行的指令hello world# 指令结果endwsl@LAPTOP-U1E6STIA:~$
```

# 

# 第13章 Shell脚本：编写应用程序

## 13.2 UNIX内核：信号

终止一个进程可以通过产生一个中断信号来终止进程。例如`Del`键、`Break`键和`Ctrl-c`键。

有几类不同的事件导致内核向进程发送信号。信号编号表明它们代表的事件。

| 信号编号 | 信号名 | 含义           |
| -------- | ------ | -------------- |
| 1        | 挂起   | 丢失终端连接   |
| 2        | 中断   | 按下任一中断键 |
| 3        | 退出   | 按下任一退出键 |
| 9        | 杀死   | 发出kill-9命令 |
| 15       | 终止   | 发出kill命令   |

**挂起信号**：信号1用来通知进程系统已经与终端失去联系。当用户终端和计算机的连线断开，或者电话线（用来调制解调器相连）断开时，产生该信号。在某些系统中，如果用户关闭终端，系统也会产生挂起信号。

**中断信号**：当按下任何一个中断键时，产生信号2。中断键可以是`Del`键、`Break`键或者`Ctrl-c`键。

**退出信号**：当按下`Ctrl-\`键时，产生信号3。在进程终止之前，将进行内存信息转储。

**终止信号**：信号9和15由kill命令产生。信号15是默认的信号。信号9和15都使收到信号的进程终止。

kill -l查看信号表

```shell
endwsl@LAPTOP-U1E6STIA:~$ kill -l 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR111) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+338) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+843) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+1348) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-1253) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-758) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-263) SIGRTMAX-1  64) SIGRTMAX
```



### 13.2.1 捕捉信号：`trap`命令

当进程接收到任何信号时，其默认处理功能是立即终止。使用trap命令可以改变进程的默认处理功能，执行指定的处理功能。

trap命令的格式：trap"optional commands"signal numbers

commands部分是可选的。如果有这一部分，当进程收到任一指定捕捉信号时，执行这些命令。

注意：trap指定的命令必须用单引号或者双引号括起来。

说明：1. 可以指定捕捉多个信号。

​			2.信号编号是与用户希望用trap命令捕捉的信号相关联的数字。

### 13.2.2 捕捉复位

当希望在脚本中的一部分捕捉信号，而另一部分不捕捉信号时，捕捉复位命令就很有用。

例如：

- `$trap " "2 3 15` 忽略中断、退出和终止信号，如果按下这些键中的任一个，脚本继续运行。
- `$trap 2 3 15`   复位指定的信号，就是恢复中断、退出和终止键。按下些键中的任一个，正在运行的脚本就会终止。

### 13.2.3 设置终端参数：stty命令

stty命令用来设置和显示终端属性。不带参数的stty命令显示指定的一组设置。用-a选项可以列出所有的终端设置。

•stty设定终端模式

- stty –echo禁止回显，输入口令时，同时也会把命令会先禁了
- stty echo打开回显，撤销上一步

## 13.3 对终端的进一步讨论

UNIX操作系统支持多钟终端类型，功能不限于清屏，还有粗字体、闪烁、下划线，等等。利用这些特性能使屏幕显示更有意义或更美观。

### 13.3.1 终端数据库：terminfo文件

terminfo数据库是一个文本文件，其中包括各种终端类型的描述。数据库里的每一类终端都有一个功能列表。

### 13.3.2 设置终端功能：tput命令

tput实用程序允许用户打印出任一功能的值。这样就可以在shell编程中使用终端的功能。

•tput向终端缓冲输出控制字符

•tput clear清屏

•tput cup row column移动光标到row行column列



终端功能的简单列表：

| 参数        | 功能                       |
| ----------- | -------------------------- |
| bel         | 回显终端的响铃字符         |
| blink       | 闪烁显示                   |
| bold        | 粗体显示                   |
| clear       | 清屏                       |
| cup *r* *c* | 将光标移到r行c列           |
| dlim        | 使显示变暗                 |
| ed          | 从光标位置到屏幕底清屏     |
| el          | 清除从光标位置到行末的字符 |
| smso        | 启动突显模式               |
| rmso        | 结束突显模式               |
| smul        | 启动下划线模式             |
| rmul        | 结束下划线模式             |
| rev         | 反色显示，白底上显示黑色   |
| sgr 0       | 关闭所有属性               |

## 13.4 其他命令

### 多路分支：case结构

当需要使用许多elif语句时，用case结构更好。

case、in和esac（case的反序）是保留字（关键字）。case和esac之间的语句称为case结构体。

shell执行case语句时，将变量的内容与每一个模式比较，知道发现一个匹配或者shell到达关键字esac。shell执行与匹配模式相关联的命令。默认情况用*)表示，必须是程序的最后一种情况。每一种情况用两个分号（；；）结束。

# 其他命令



磁盘命令

du

```
endwsl@LAPTOP-U1E6STIA:~$ df
Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/sdb       263174212    788056 248948000   1% /
tmpfs            6475860         0   6475860   0% /mnt/wsl
tools          209715196 192647796  17067400  92% /init
none             6473568         0   6473568   0% /dev
none             6475860         4   6475856   1% /run
none             6475860         0   6475860   0% /run/lock
none             6475860         0   6475860   0% /run/shm
none             6475860         0   6475860   0% /run/user
tmpfs            6475860         0   6475860   0% /sys/fs/cgroup
C:\            209715196 192647796  17067400  92% /mnt/c
D:\            289083388 253954812  35128576  88% /mnt/d
```

tar 

`tldr tar`

![image-20220616111745205](https://raw.githubusercontents.com/BachWV/PicGo/master/image-20220616111745205.png)

chown修改文件目录的owner,修改inode

chgrp修改文件目录的group
