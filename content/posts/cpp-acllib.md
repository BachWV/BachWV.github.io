---
title: "Cpp Acllib"
date: 2022-07-28T00:55:59+08:00
---

今天开始整理一下大学的一些项目

首先看的是一个俄罗斯方块的实现，这应该是我大学以来的第一个项目

那个时候，我c语言还是刚入门，还没写明白if-else，还不知道什么是编译，什么是链接，却能借助visual studio通过简单的点点操作，基于翁恺的acllib库跑一个图形程序，我自己都佩服我自己。

现在知道了汇编，操作系统，回来 再看看这个实验。

很久很久以前，在一个遥远的银河系，有一个小男孩，它写的俄罗斯方块的所有源代码，都写在一个文件里。

源.cpp->src.cpp

一眼钉真，鉴定visual studio已经过时，作为GNU社区的忠实拥护者，怎么能使用msvc这种编译器。

编译！

```
gcc src.cpp
c:/mingw/bin/../lib/gcc/mingw32/9.2.0/../../../../mingw32/bin/ld.exe: C:\Users\Charon\AppData\Local\Temp\ccxKdSbR.o:acllib.c:(.text+0x1b74): undefined reference to `__mingw_free'
c:/mingw/bin/../lib/gcc/mingw32/9.2.0/../../../../mingw32/bin/ld.exe: C:\Users\Charon\AppData\Local\Temp\ccxKdSbR.o:acllib.c:(.text+0x1be8): undefined reference to `mciSendStringA@16'
c:/mingw/bin/../lib/gcc/mingw32/9.2.0/../../../../mingw32/bin/ld.exe: C:\Users\Charon\AppData\Local\Temp\ccxKdSbR.o:acllib.c:(.text+0x1c31): undefined reference to `mciSendStringA@16'
collect2.exe: error: ld returned 1 exit status
```

一长串报错，当时的我一定会看懵了，这啥啊。但是现在的我不一样了，一眼鉴定是链接器的问题，acllib.c里的`mciSendString()`函数原型没找到，也就是编译以后，有一个call mciSendString ()函数，跳转到未知地址。链接器这时候就懵了，这啥啊，没见过啊，给他链接啥地址啊，然后就报错了。

解决也很简单，-l把他找到函数原型就好了。那问题来了，在哪？

搜索引擎，启动！

有人告诉我devcpp使用acllib库应该这样用

>1，新建项目—>Windows application—>C项目–>输入项目名称
>2，将acllib.c和acllib.h文件拷贝到创建的项目目录
>3，菜单栏–>项目–>项目属性–>参数–>链接–>加入库文件，如下：（Dev C++具体目录以安装时为准）
>
>32位下，库文件是：
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libwinmm.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libmsimg32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libkernel32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libuser32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libgdi32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libole32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/liboleaut32.a”
>
>“C:/Program Files/Dev-Cpp/MinGW32/lib/libuuid.a”
>
>64位下，库文件是：
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libwinmm.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libmsimg32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libkernel32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libuser32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libgdi32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libole32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/liboleaut32.a
>
>C:/Program Files/Dev-Cpp/MinGW64/x86_64-w64-mingw32/lib/libuuid.a
>
>如果出现“undefined reference to TransparentBlt ”这个错误，两个解决方案：
>打开acllib.c，找到“TransparentBlt”所在的行，把整行注释掉；
>打开工程配置，找到编译器选项，加入-DWINVER=0x0500。
>————————————————
>版权声明：本文为CSDN博主「sandonz」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
>原文链接：https://blog.csdn.net/sandonz/article/details/118385519

虽然很奇怪，为什么gcc不能给我自动引用呢？

```
gcc acllib.c src.cpp -lwinmm -DWINVER=0x0501 -o src
```

尝试使用devcpp

按照上述方法配置，手动添加LIBS

偷看makefile.win

```
# Project: Project2
# Makefile created by Dev-C++ 5.5.3

CPP      = g++.exe
CC       = gcc.exe
WINDRES  = windres.exe
OBJ      = acllib.o main.o
LINKOBJ  = acllib.o main.o
LIBS     = -L"C:/Program Files (x86)/Dev-Cpp/MinGW32/lib" ....

BIN      = Project2.exe
CXXFLAGS = $(CXXINCS) -g3 -DWINVER=0x0500
CFLAGS   = $(INCS) -g3
RM       = rm -f

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

clean: clean-custom
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CC) $(LINKOBJ) -o $(BIN) $(LIBS)

acllib.o: acllib.c
	$(CC) -c acllib.c -o acllib.o $(CFLAGS)

main.o: main.cpp
	$(CC) -c main.cpp -o main.o $(CFLAGS)

```

还是报错，就跟没引入lib一样



尝试clion打开，

在函数名上按下ctrl，函数原型在C:\MinGW\include\mmsystem.h里面，那么动态链接库在lib里为啥不给我链上？

看了一波了cmakelist

```
cmake_minimum_required(VERSION 3.20)
project(RU)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "-DWINVER=0x0500")
add_executable(RU src.cpp acllib.c)
```

还是报错

```
C:/Users/Charon/Desktop/code/RU/acllib.c:816: undefined reference to `mciSendStringA@16'
c:/mingw/bin/../lib/gcc/mingw32/9.2.0/../../../../mingw32/bin/ld.exe: CMakeFiles\RU.dir/objects.a(acllib.c.obj): in function `playSound':
C:/Users/Charon/Desktop/code/RU/acllib.c:828: undefined reference to `mciSendStringA@16'
c:/mingw/bin/../lib/gcc/mingw32/9.2.0/../../../../mingw32/bin/ld.exe: CMakeFiles\RU.dir/objects.a(acllib.c.obj): in function `stopSound':
C:/Users/Charon/Desktop/code/RU/acllib.c:835: undefined reference to `mciSendStringA@16'
collect2.exe: error: ld returned 1 exit status
```







最后的最后:

突然看到acllib的git repo好像由sample，那例子能不能运行呢？

我直接一个clone，一个make，好家伙，给的例子研究一下

```makefile
SRC = ..\..\src\acllib.c
INCLUDE_DIR = ..\..\src
LIB = gdi32 ole32 oleaut32 uuid winmm msimg32

all : keyboard mouse_move mouse_click image clock char src

keyboard :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@
	
mouse_move :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@
	
mouse_click :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@

image :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@
	
clock :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@
	
char :
	gcc $(SRC) $@.c -I$(INCLUDE_DIR) $(LIB:%=-l%) -DWINVER=0x0501 -o $@
```

好像这么一瞬间，我已经完全懂了，我就看懂了makefile，多么简单明了，比cmakelist.txt好读多了。



```
gcc acllib.c src.cpp -lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lmsimg32 -DWINVER=0x0501 -o src
```

其实和刚开始的差不多，感谢makefile，



复盘了一下，看到devcpp添加lib是多余的，只要在参数加`-lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lmsimg32`才是关键，我之前只加了`-lwinmm`所以还是报错

```
mingw32-make -nB
```

搞定！

虽然很简单的一个项目，和b站小学生写操作系统没法比

还是说明一下啊



![image-20220728141017067](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/image-20220728141017067.png)

根据以上流程图和游戏操作，本阶段的介绍分三个部分：

**1）** **基本图形的存储与绘制**

**2）** **下落定时与键盘控制**

**3）** **图形界面和音效设计**

下面将就这三个方面做分别说明

**1）** **基本图形的存储与绘制**

俄罗斯方块有5类19种不同的图形，分别为1字形（2种），Z字形（4种），T字形（4种），L字形（8种），田字形（1种），每类之间可以通过旋转对称得到，每次生成图形时要使用这19种图形来绘制。本游戏使用一个三维数组Graphics[19][4][4]来存储该图形，19对应编号，两个4对应4*4矩阵。0代表空，1代表黑块。

例如

![img](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/clip_image002.jpg)对应

0 0 0 0

0 1 0 0

0 1 0 0

1 1 0 0

绘图时，使用循环语句遍历4*4数组，当值为1时，在适当位置（下文会详细说明这个适当位置）绘制正方形，这里使用ACLLIB库中提供的rectangle命令绘制矩形。

所有图形保存在TXT文件中，可以通过改变TXT文件中的值获得任何你想要的形状，每次运行时使用文件操作读取所有的19种图形。对于已经下落的图形，使用二维数组allPixel[30][15]存储像素点，如图所示建立坐标系：

![image-20220728141157276](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/image-20220728141157276.png)

30对应y轴，15对应x轴

数组值为1对应黑块，值为0对应空。初始值全为0。绘图时，遍历allPixel数组，遇到1时使用ACLLIB库中提供的rectangle命令在相应位置绘制矩形。

 

**2****）下落定时与键盘控制**

**下落定时：**考虑到俄罗斯方块匀速下落，本游戏使用ACLLIB库提供的定时器来控制下落，用整型变量x，y记录每一个下落的方块的位置，初始位置为上方正中，4*4矩形左上方点在整个坐标系的位置，每隔300ms，刷新一次界面（清屏并对已存在的和正在下落的方块进行重绘）

每次下落（达到300ms）将y的加1，并且对下方进行预判断，如果方块下方存在障碍或者达到最底行，停止移动并将该方块的值写入allPixel中。

**键盘控制：**每次按下按键时，触发keyEvent事件，对应改变bool变量的值。本游戏设计5个有交互的键。

**左右键**：先对移动后的图形是否遇到障碍进行预判断，如果遇到边界或者碰到已经存在的方块，则不移动，否则移动（变更x的值）。

**上键**：则改变俄罗斯方块的形状（在同一类中改变，比如L形变成倒L），这里使用随机数决定下一个图形是什么形状，注意这里也需要判断是否变形后遇到障碍，如果有，则不变形。

**下键**：加速，改变计时器为50ms，刷新时间缩短到50ms，下落速度达到原来的6倍。

**空格键**：长按暂停游戏；

松开空格键继续。

**3****）图形界面和音效设计**

本游戏操作界面如下：

左侧框中为正在下落的方块和已经下落的方块，右侧为计分和提示文字

![img](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/clip_image002.jpg)

计分和等级功能：每下降一个方块加1分，每消去一行方块升1级。并播放升级音效。如果方块堆积到达顶部，则显示游戏结束。

 

\3. 核心算法的详细设计与实现

下面列举本游戏的核心算法：

 

**判断障碍算法：**在每次左右移动时，需要判断是否遇到障碍，拿右移的代码举例，该判断算法的步骤如下：

![img](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/clip_image004.jpg)

当收到键盘请求isToRight==true后，首先设置布尔变量isReach值为false，对下落的方块的4*4矩阵进行遍历，如果某一位置为1，进行下一步判断：移动后的位置是否超出右侧边界？移动后的位置是否有已知方块？

只要有一个回答是，则说明有障碍，无法移动，标记isReach为true，结束循环。当遍历结束后isReach仍然为false，即中间一次没有被标记，则说明右移后没有障碍，可以放心移动，令位置变量x加1。

```c
void isMoveRight() {
	if (isToRight) {
		isToRight = false;
		 isReach = false;
		for (int i = 0; i < 4; i++)
			for (int j = 0; j < 4; j++) {
				if (Graphic[num][i][j]) {
					if ( j+1+x >= Width || allPixel[y + i][x + 1 + j]) {
						isReach = true;
						break;
					}
				}
			}
	if (!isReach) x++;
	}
}
```

**绘制正在下落的俄罗斯方块图形：**

绘制俄罗斯方块图像是本游戏的基础，需要正在下落的坐标参数x,y和图形序号参数num（初始num由随机数确定），对确定序号num的三维数组Graphic进行遍历，若(0,1)处值为1，x=3,y=4则将该点绘制到整个窗口的(20+4 * pixelWidth, 4* pixelWidth)位置，为了让整个窗口居中的统一在x轴增加了20。代码如下

for (int i = 0; i < 4; i++) {

​       for (int j = 0; j < 4; j++) {

​           if (Graphic[num][i][j]) {

​              rectangle(20+(j + x) * pixelWidth, (i + y) * pixelWidth, 20+(j + 1 + x) * pixelWidth, (i + 1 + y) * pixelWidth);

​           }

​       }

   }

绘制已经存在的像素点与此大同小异。

**判断某一行是否填满方块：**对allPixel每一行的值进行遍历，如果某一行全为0，即为满格，此时播放音效并升级，再将上面多行的各值向下平移一行，这里代码较为简单，不再贴出。
