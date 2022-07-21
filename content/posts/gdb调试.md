---
title: "Gdb调试"
date: 2021-09-28T15:35:49+08:00
draft: false
tags: ["gdb",
"C++"]
---

今天尝试使用gdb调试，相比ide的调试没那么容易好上手

对于一个cpp文件

```
g++ test.cpp -o test -g
```

记得一定要在编译时带-g参数，编译完成以后，使用gdb+生成可执行文件进行调试



![image-20210928151948226.png](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/HOKRY8kWrajiShQ.png)

`l`可以查看需要 调试的文件

![image-20210928152039520.png](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/lMpTUvSawgQHy2R.png)

`b 4`表示在第4行设置断点

`r`程序就会运行到断点处

`display i`表示显示变量i的值

`n`表示运行下一行

![image-20210928152442778.png](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/cW4Ym5NItdKlDak.png)

基本的就到这里，剩下的就慢慢探索吧

1. list/l 命令 可以使用list/l命令查看程序，方便我们添加断点时查看信息。

list+lineNumber(中间有空格) list 打印函数名称为Function的函数上下文的源程序 list 输出当前行后面的代码 list -显示当前行前面的代码

1. run/r命令 在gdb中运行程序使用run命令.也可以设置程序运行参数。pwd命令用于显示当前所在目录。
2. break/b命令 break < function > 在进入指定的函数function时既停止运行，C++中可以使用class::function或function(type, type)格式来指定函数名称 break < lineNumber> 在指定的代码行打断点 break +offset/break -offset 在当前行的前面或后面的offset行打断点，offset为自然数 break filename:lineNumber 在名称为filename的文件中的第lineNumber行打断点 break filename:function 在名称为filename的文件中的function函数入口处打断点 break *address 在程序运行的内存地址处打断点 break 在下一条命令处停止运行 break … if < condition> 在处理某些循环体中可使用此方法进行调试，其中…可以是上述的break lineNumber、break +offset/break -offset中的参数，其中condition表示条件，在条件成立时程序即停止运行，如设置break if i=100表示当i为100时程序停止运行。 查看断点时，也可以使用info命令如info breakpoints [n]、info break [n]其中n 表示断点号来查看断点信息。
3. 逐步调试命令 next < count>。单步跟踪，如果有函数调用不会进入函数，如果后面不加count表示一条一条的执行，加count表示执行后面的count条指令， step < count>。单步跟踪，如果有函数调用则进入该函数（进入该函数前提是此函数编译有Debug信息）,与next类似，其不加count表示一条一条执行，加上count表示自当前行开始执行count条代码指令 set step-mode.set step-mode on用于打开step-mode模式，这样在进行单步跟踪时，程序不会因为没有debug信息而不停止运行，这很有利于查看机器码，可以通过set step-mode off关闭step-mode模式 finish。运行程序直到当前函数完成并打印函数返回时的堆栈地址和返回值及参数值等信息。 until。运行程序直到退出循环体 stepi(缩写si)和nexti(缩写ni)。stepi和nexti用于单步跟踪一条及其指令，一条程序代码有可能由数条机器指令完成，stepi和nexi可以单步执行机器指令。
4. continue/c命令 当程序遇到断点停止运行后可以使用continue命令恢复程序的运行到下一个断点或直到程序结束。
5. print命令 请查看：https://blog.csdn.net/linuxheik/article/details/17380767
6. watch命令 watch命令一般来观察某个表达式(变量也可视为一种表达式)的值是否发生了变化，如果由变化则程序立即停止运行，其具体用法如下：

watch < expr> 为表达式(变量)expr设置一个观察点一旦其数值由变化，程序立即停止运行 rwatch < expr> 当表达式expr被读时，程序立即停止运行 awatch < expr> 当表达式expr的值被读或被写时程序立即停止运行 info watchpoints 列出当前所设置的所有观察点

1. return命令 如果在函数中设置了调试断点，在断点后还有语句没有执行完，这个时候我们可以使用return命令强制函数忽略还没有执行的语句并返回。可以直接使用return命令用于取消当前函数的执行并立即返回函数值，也可以指定表达式如 return < expression>那么该表达式的值会被作为函数的返回值。
2. info命令 info命令可以用来在调试时查看寄存器、断点、观察点和信号等信息。其用法如下：

info registers:查看除了浮点寄存器以外的寄存器 info all-registers: 查看所有的寄存器包括浮点寄存器 info registers < registersName>:查看指定寄存器 info break: 查看所有断点信息 info watchpoints: 查看当前设置的所有观察点 info signals info handle: 查看有哪些信号正在被gdb检测 info line: 查看源代码在内存中的地址 info threads: 可以查看多线程

1. finish命令  执行完当前的函数。

run(缩写r)和quit(缩写q)分别可以开始运行程序和退出gdb调试

whatis或ptype显示变量的类型

bt显示函数调用路径 ———————————————— 版权声明：本文为CSDN博主「lyz_cs」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。 原文链接：https://blog.csdn.net/qq_26399665/article/details/81165684
