---
title: "Compiler"
date: 2022-05-28T18:38:04+08:00
draft: false
---

-   语义分析semantic analyzer

    -   类型检查

    -   自动类型转换

-   中间代码生成

-   代码优化

-   代码生成

-   符号表管理

-   将多个步骤合并成趟pass

面向对象主要思想：

1.  数据抽象

2.  特性的继承

针对计算机体系结构的优化

-   并行

指令集的并行

-   内存层次结构

x86体系虽具有CISC指令集，但这个处理器本身实现中使用了很多为RISC机器发展得到的思想，使用高性能x86机器的最有效的方法是仅使用它的简单指令

程序翻译

-   二进制翻译

将一个机器的二进制代码翻译成另一个机器的二进制代码

比如Rosstta和Loongarch

-   硬件合成

## 1.6 程序语言基础

### 静态和动态的区别

编译时刻决定：静态策略 static
运行时决定：动态策略


Java中static的例子。

变量是用于存放数据值的某个内存位置的名字。这里static指的并不是变量的作用域，而是编译器确定用于存放被声明变量的内存位置的能力。比如`public static int x`使得

成为一个类变量，也就是说不管创建多少个这个类对象，只存在一个这个x的拷贝。如果没有这个static声明，那么这个类的每个对象都有自己存放x的位置，编译器无法在运行时预先确定所有这些位置。
即变量和值的关联是是随着位置改变的。

### 1.6.3 静态作用域和块结构

c语言提供块结构来限制作用域

### 1.6.4 显示访问控制

public private protected可以由子类访问

### 1.6.5 动态作用域

这里给了一个宏的例子

### 1.6.6 参数传递机制

本节将讨论实在参数（调用过程中使用的参数）和形式参数（在过程中使用的参数）关联起来的。

- 值调用
  相当于传一个拷贝
- 引用调用
  传递一个引用（指针）使得可以改变对象的值。Java中可能一个对象很大，拷贝的代价是高昂额，Java在解决数组，字符串和其他对象的参数传递问题的方法仅仅是复制这些对象的引用
- 名调用 algol 60

### 1.6.7 别名

alias

# 2 一个简单的语法制导翻译器

## 2.1引言

在2.2给出一个广泛使用的方法来描述语法：上下文无关文法或BNF(Backus-Naur)范式.
在2.3节中，将介绍一种面向文法的翻译技术，即语法制导翻译syntax-directed translation.
语法扫描将在2.4节中介绍
2.5节将给出从中缀翻译到后缀表达式，只考虑加减号分割的数位序列。
2.6节介绍词法单元（由多个字符组成的标识符）
2.8节将介绍一个构造语法树的方法
![](../../../obsidian/Course/Screenshot_20220321_105255.png)

## 2.2 语法定义

一个例子：`if(expr) statement else statement`
我们用stmt代表语句`stmt -> if (expr) stmt else stmt`
箭头可以读有如下形式，这样的规则成为产生式（production），向if被成为终结符 terminal 像expr和stmt这样的变量表示终结符号序列，被称为非终结符nonterminal

### 2.2.1文法定义

一个上下文无关文法由下面四个元素组成

1. 一个终结符号集合，有时又称“**词法单元**”，终结符号是该文法所定义的语言的基本符号的集合。
2. 一个非终结符号集合，它们有时又称“**语法变量**”，每个非终结符号表示一个终结符号串的集合
3. 一个产生式集合，其中每一个产生式包括一个称为产生式头部的非终结符号，一个箭头，和一个称为产生式体的由终结符号及非终结符号组成的序列。产生式主要用来表示某个构造的某种书写形式。
4. 指定一个非终结符号为开始符号

数字，+，-，while都是终结符号。比如9-5+7这个例子，两个数位之间必须出现+或-，我们把这样的表达式称为“由+，-号分隔的数位序列”
此文法的产生式包括：

> list->list+digit
> list->list-digit
> list->digit
> digit->0|1|2|3|4|5|6|7|8|9

以非终结符号list为头部的三个产生式可以等价得组合为：

>list->list+digit|list-digit|digit
>根据我们的习惯，该文法的终结符号包括以下符号：
>\+ \- 1 2 3 4 5 6 7 8 9

该文法的非终结符号是斜体名字list和digit。因为list的产生式首先被列出，所以我们知道list是该文法的开始符号。
如果某个nonterminal是某个productive的头部，我们就说该产生式是该nontermial的产生式。
一个终结符号串是由0个或多个






# 第二章 数据类型

数据类型实质上是对存储器中所存储的数据进行的抽象，它包含了一组值的集合和一组操作。

## 2.2 内部类型

一、特点 

1. 内部类型反映了基本的硬件特性
2. 内部类型标识共用某些操作的数据对象的抽象表示（整型表示能实现+-
   \*/ 等定点操作的数据对象的集合）
   二、内部类型的优越性
3. 基本表示的不可见性
   - 基本位串如35+9=34的基本表示为00011001+00001001=00100010
   - 优点：
     - 导致不同的程序设计风格
     - 可写性
     - 可读性
     - 可修改性
4. 编译时能检查变量使用的正确性
   进行静态编译检查，如非法运算，形实参类型匹配
5. 编译时可以确定无二义性的操作
   多态
6. 精度控制

## 2.3 用户定义类型

### 1.笛卡尔积

N个集合相乘，每一个集合取1个
在COBOL和PASCAL 称为记录
ALGOL 称为结构


### 2. 有限映射

在高级语言中通常体现为数组构造，值域由下标选择
编译时绑定 ：静态数组
对象建立时绑定：动态数组
对象处理时绑定


### 3. 序列

串是众所周知的序列，其成分类型为字符，顺序文件的思路也来自序列的概念
串操作一般有4组 连接、首项选取、尾项选取、子串

### 4. 递归

如果数据类型T包含属于同一类型T 的成分，那么类型T称为递归类型
指针是建议递归数据对象的重要手段
单链表、二叉树、树

### 5. 判定或 discriminated union

是一种选择对象结构的机制，规定在两个不同选择对象之间作出适当的选择，每一选择对象结构称为变体Variant

c和algol中的union联合

> union不同于struct，`union {int a;char b;} u1` 表示变量u1是一个union，它的值是int类型的a或char类型的b，sizeof(u1)会得到int

pascal和ada中的变体

### 6.幂集

类型T的元素的所有子集的集合，称为幂集
它们的操作是集合的操作，例如联合，与，以及测试某个元素是否在一个集合中

![Pasted image 20220405173620](https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220405173620.png)
可以通过以上六种机制定义复杂的数据对象（新的类型)
新的类型可以通过非显式的方式说明

# 第三章

## 语句级控制结构


### 顺序

顺序运算符`;`或者`begin ... end`

### 选择

`if...else...`或者 `switch... case`

选择结构会引起二义性

### 循环

计数器制导 `for`

条件制导`while`

## 单元级控制结构

规定程序单元之间控制流程的机制

### 显示调用

调用方式
	由调用语句使用被调用单元的名字来进行调用；调用语句将控制转向被调用单元，被调用单元执行完后，将控制返回调用单元；
参数传递：参数的两种绑定方式

- 位置绑定
- 关键字绑定
  副作用：对局部环境的修改



### 

# 第四章 程序语言设计

1.  语言的定义

    -   语法

    -   文法

2.  文法 定义语言语法的形式化规则

 文法分类

      1. 0型文法
         短结构文法
      2. 1型文法
      3. 2型文法
      4. 3型文法
   5. 语言的设计 介绍设计高级语言的一般知识和方法

# 第五章 编译概述

基本概念：宿主语言

编写编译器的语言：宿主语言；源语言、目标语言、宿主语言通常是不同的语言

如果编译器是用源语言编写的，则称该编译程序是自编译的

# 词法分析

-   介绍词法分析的过程

-   讨论词法分析器的设计和实现

-   介绍实现词法分析器的主要工具：状态转换图

基本字(关键字)，

标识符 identifier

，常数，运算符+-=<>，界符;()

输出：二元式 符号的种别 符号自身的<token-name,attribute-value>

对于界符和运算符，一符一种，即每个符号对于一个编码

基本字可分为一种，也可以一符一种

标识符一类一种

# 第七章 Syntax analysis

自上而下的语法分析

递归下降分析法与预测分析法

语法分析器的功能：对经过词法分析得到的符号串，按文法规则进行判断，看它能否构成准确的句子，如果是 不正确的句子，给出准确的错误信息，对正确的句子，给出其语法树syntax tree

自顶向下，从分析树的顶部向底部构造分析树，可以看成是文法开始符号推导出词串w的过程

最左推导，总是选择每个句型的最左非终结符进行替换。与之相反的逆过程叫做最右规约。

最右推导。最左规约。自底向上的分析中，总是采用最左规约的方式，因此把最左规约称为规范规约，最右推导称为规范推导。

最左推导和最右推导具有唯一性。

自顶向下通用的分析形式：递归下降分析
但是不一定每次都正确识别（同一非终结符的多个候选式存在共同前缀），因此需要回溯，降低效率。为了避免这个问题，有了预测分析法。
预测分析是递归下降分析技术的一个特例，通过在输入中向前看固定个数（通常为1)符号来选择正确的A-产生式
可以对某些文法构造出向前看k个输入符号的预测分析器，该类文法有时也称为LL(k)文法类

文法转换 如何改造文法使之适合自顶向下的文法分析
文法的问题：1.需要回溯 2.无限递归

含有$$A->A \alpha$$ 形式产生式的文法是直接左递归的
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327172234.png" alt="Pasted image 20220327172234" style="zoom:50%;" />

消除直接左递归$A -> A \alpha| \beta$

<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327172510.png" alt="Pasted image 20220327172510" style="zoom:50%;" />

按照这种方法，我们可以对如下例子消除直接左递归

E->E+T|T 我们将+T看成$\alpha$ ,T看成$\beta$
因此有 E->TE' E'->+TE'|$\epsilon$
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327173209.png" alt="Pasted image 20220327173209" style="zoom: 50%;" />
消除左递归是要付出代价的--引进了一些非终结符和空产生式

消除间接左递归
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327174557.png" alt="Pasted image 20220327174557" style="zoom:33%;" />
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327174620.png" alt="Pasted image 20220327174620" style="zoom:33%;" />
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327174746.png" alt="Pasted image 20220327174746" style="zoom: 50%;" />



这里应该给出一个例子的
E->E+T|T
T->F|T\*F
F->(E)|i

其消除左递归以后是这样的：

我们先改写T->F|T\*F
T->FT'
T'=\*FT'|$\epsilon$
再改写E->E+T|T
E->TE'
E'=+TE'|$\epsilon$

这个例子应该很经典
扩充BNF范式的表达会更加清晰

E->T{+T}
T->F{\*F}
F->I|(E)




预测分析的LL(1)文法

S_ 文法 简单的确定性文法：

1. 每个产生式的右部都以终结符开始
2. 同一非终结符的各个候选式的首终结符都不同。
   比如上面一个ppt中的例子
3. S_ 文法不包含空产生式

如果文法中包含空产生式，会出现什么问题呢
这个例子没有说清楚，所以也不知道引入follow集解决了什么问题

SELECT集：表达式的可选集是指 可以用该产生式进行推导时对应的输入符号的集合

<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327195832.png" alt="Pasted image 20220327195832" style="zoom:33%;" />
q_文法不允许右部以非终结符开始，所以我们还需要功能更加强大的文法


串首终结符集，

>串首终结符:串首第一个符号，并且是终结符



<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327203357.png" alt="Pasted image 20220327203357" style="zoom:33%;" />
FIRST(\alpha)



<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327213226.png" alt="Pasted image 20220327213226" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327215321.png" alt="Pasted image 20220327215321" style="zoom:33%;" />

FIRST集是针对表达式左边的，
Follow集是针对一个非终结符或者终结符的右边可以紧跟着什么，特别地，可以跟着$

根据FIRST FOLLOW集就可以得到select集

所以我们要牢记SELECT集的定义：
SELECT集：表达式的可选集是指 可以用该产生式进行推导时对应的输入符号的集合

select集是针对表达式的，一般说就是表达式左边的FIRST集不含空串；如果直接表达式右边推出空，那遇到什么时可以用这条推出空的表达式呢？则是该表达式左边的Follow集，当紧跟着follow后面的token时，需要空串，这条表达式意味着这直接推没了，这条表达式奉献了自己成就了左式的follow集。
<img src="https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220327221212.png" alt="Pasted image 20220327221212" style="zoom:33%;" />

预测分析法
表驱动
下推栈 预测分析表 控制程序

非LL(1)文法：并非所有文法G都可以被改写成LL(1)文法，即使提取左公因子和消除左递归后，也不是LL(1)文法。
即预测分析表中的某个项有多重入口，此时只能改写文法或者不用预测分析法


# 第八章 自下而上的语法分析

算符优先分析法
LR分析法

核心概念：
短语： $$S^+ -> \alpha A $$
（句型的）短语：
给定一个句型，其语法分析树中的每一棵子树的边缘称为该句型的一个短语

直接短语：
如果子树只有父子两代结点，那么这棵子树的边缘成为该句型的一个直接短语

![Pasted image 20220401232735](https://raw.githubusercontent.com/BachWV/PicGo/master/Pasted%20image%2020220401232735.png)
直接短语一定是某个产生式的右部，产生式的右部不一定是给定句型的直接短语

句柄：最左直接短语

算符优先分析法：一种直观、简单、有效的方法，适合于表达式的分析；但不严格按照最左归约进行，不是规范归约。

算符文法：如果一个文法的任何产生式都不含两个或两个以上的相连的非终结符，且不含$\epsilon$产生式，则称该文法为算符文法。

算法优先文法：如果算符文法G的任何两个终结符之间的关系至多只有<,=,>中的一个优先关系，则称该文法为算符优先文法。

优先关系表：记录文法G中的所有终结符之间的优先关系

素短语：文法G某句型的一个短语$\alpha$是素短语，当且仅当它至少含有一个终结符，且除它自身之外不再含更小的素短语；
最左素短语：在具有多个素短语的句型中处于最左边的那个素短语；

FIRSTVT
LASTVT

LR分析法 第一个难点
LR分析法是一种自下而上的分析方法，其功能强大，适用于一大类文法；它在自左向右扫描输入串的同时，能及时发现输入串的错误，并能准确指出错误的位置。LR的意思是指自左向右扫描，自下而上归约。

LR分析器主要有两部分组成：一个总控程序和一张分析表；总控程序对所有文法都是一样的，且易于实现。不同文法的LR分析器的不同体现在不同的分析表上。

LR分析法的种类

1. LR(0)分析法 使用LR(0)分析表，基础
2. SLR分析法 简单，有效，实用
3. 规范LR分析法 分析能力强大
4. LALR分析法 能力介于2-3之间

规范归约的特点：
归约符号串总是在栈顶；
句柄之后的待入栈符号串总是终结符；
规范句型（由规范推导推出的句型）在符号栈中的符号串是规范句型的前缀；


必经节点，不需掌握

## 循环优化

1. 代码外提
2. 强度削弱
3. 删除归纳不变量

## 目标代码生成

三地址码的代码生成方法
`x:=y op z`
mov y,R_i
op R_i,z
寄存器分配


循环中的寄存器分配