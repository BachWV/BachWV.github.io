---
title: "Gdb调试"
date: 2021-09-28T15:35:49+08:00
draft: false
tags: ["GNU"]
---

今天尝试使用gdb调试，相比ide的调试没那么容易好上手

对于一个cpp文件

```
g++ test.cpp -o test -g
```

记得一定要在编译时带-g参数，编译完成以后，使用gdb对生成可执行文件进行调试



![gdb-1.png](https://s2.loli.net/2022/09/06/WkF1jnztKqLQm46.png)

`l`可以查看需要 调试的文件

![gdb-2.png](https://s2.loli.net/2022/09/06/JoIYdxrSvMFzVea.png)

`break/b 4`表示在第4行设置断点

`break filename:< function >`  在名称为filename的文件中的function函数入口处打断点 break *address 在程序运行的内存地址处打断点 

`run/`程序就会运行到断点处

`display i`表示显示变量i的值

`next/n 1`表示运行下一行

`si`会进入函数内部 

![gdb-3.png](https://s2.loli.net/2022/09/06/menLWoN3iwqIOtr.png)

`layout asm`

`layout src`

`list/l 3 ` 可以使用list/l命令查看程序，方便我们添加断点时查看信息。

1. break … if < condition> 在处理某些循环体中可使用此方法进行调试，其中…可以是上述的break lineNumber、break +offset/break -offset中的参数，其中condition表示条件，在条件成立时程序即停止运行，如设置break if i=100表示当i为100时程序停止运行。 

2. 查看断点时，也可以使用info命令如info breakpoints [n]、info break [n]其中n 表示断点号来查看断点信息。

   好像不能在内联汇编里面打断点

   

3. 逐步调试命令 next < count>。单步跟踪，如果有函数调用不会进入函数，如果后面不加count表示一条一条的执行，加count表示执行后面的count条指令， step < count>。单步跟踪，如果有函数调用则进入该函数（进入该函数前提是此函数编译有Debug信息）,与next类似，其不加count表示一条一条执行，加上count表示自当前行开始执行count条代码指令 set step-mode.set step-mode on用于打开step-mode模式，这样在进行单步跟踪时，程序不会因为没有debug信息而不停止运行，这很有利于查看机器码，可以通过set step-mode off关闭step-mode模式 finish。运行程序直到当前函数完成并打印函数返回时的堆栈地址和返回值及参数值等信息。 until。运行程序直到退出循环体 stepi(缩写si)和nexti(缩写ni)。stepi和nexti用于单步跟踪一条及其指令，一条程序代码有可能由数条机器指令完成，stepi和nexi可以单步执行机器指令。

4. continue/c命令 当程序遇到断点停止运行后可以使用continue命令恢复程序的运行到下一个断点或直到程序结束。

5. print/p 显示指定变量 

6. `p $rax`查看寄存器请查看：https://blog.csdn.net/linuxheik/article/details/17380767

7. watch命令 watch命令一般来观察某个表达式(变量也可视为一种表达式)的值是否发生了变化，如果由变化则程序立即停止运行，其具体用法如下：watch < expr> 为表达式(变量)expr设置一个观察点一旦其数值由变化，程序立即停止运行 rwatch < expr> 当表达式expr被读时，程序立即停止运行 awatch < expr> 当表达式expr的值被读或被写时程序立即停止运行 info watchpoints 列出当前所设置的所有观察点

8. return命令 如果在函数中设置了调试断点，在断点后还有语句没有执行完，这个时候我们可以使用return命令强制函数忽略还没有执行的语句并返回。可以直接使用return命令用于取消当前函数的执行并立即返回函数值，也可以指定表达式如 return < expression>那么该表达式的值会被作为函数的返回值。

9. info命令 info命令可以用来在调试时查看寄存器、断点、观察点和信号等信息。其用法如下：

`info registers`:查看除了浮点寄存器以外的寄存器 

`info all-registers`: 查看所有的寄存器包括浮点寄存器 

`info registers < registersName>`:查看指定寄存器 

`info break`: 查看所有断点信息 info watchpoints: 查看当前设置的所有观察点 info signals info handle: 查看有哪些信号正在被gdb检测 info line: 查看源代码在内存中的地址 info threads: 可以查看多线程



finish命令  执行完当前的函数。

run(缩写r)和quit(缩写q)分别可以开始运行程序和退出gdb调试

whatis或ptype显示变量的类型

bt显示函数调用路径



回到过去`record full`



## 查看内存

  使用examine（简写x）来查看内存地址中的值。语法：
  x/
  n、f、u是可选的参数。
  （1）n 是一个正整数，表示显示内存的长度，也就是说从当前地址向后显示几个地址的内容。
  （2）f 表示显示的格式，参见上面。如果地址所指的是字符串，那么格式可以是s，如果地十是指令地址，那么格式可以是i。
  （3）u 表示从当前地址往后请求的字节数，如果不指定的话，GDB默认是4个bytes。u参数可以用下面的字符来代替，b表示单字节，h表示双字节，w表示四字 节，g表示八字节。当我们指定了字节长度后，GDB会从指内存定的内存地址开始，读写指定字节，并把其当作一个值取出来。
eg:

  x/3uh 0x54320 ：从内存地址0x54320读取内容，h表示以双字节为一个单位，3表示三个单位，u表示按十六进制显示。
