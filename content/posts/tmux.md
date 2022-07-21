---
title: "Tmux"
date: 2022-07-20T11:00:02+08:00
draft: false
---



简单记住一下 tmux的基本使用，因为自己记性不行

新建会话 `tmux new -s "name"`

退出会话 `ctrl+b d`或`tmux detach`

进入某会话`tmux a -t "name"`

查看所有会话 `tmux ls`

杀死`tmux kill-session -t "name"|id`

切换会话 `tmux switch -t "name"|id`



上下分窗口 `ctrl+b d`







```
Ctrl+b d：分离当前会话。
Ctrl+b s：列出所有会话。
Ctrl+b $：重命名当前会话。

Ctrl+b  再按上下左右键切换窗口
Ctrl+b  %:左右分窗口  "：上下分窗口
Ctrl+b  d:退出当前窗口
Ctrl+b  [:进行上下翻页，q取消翻页

Ctrl+b {：当前窗格与上一个窗格交换位置。
Ctrl+b }：当前窗格与下一个窗格交换位置。
Ctrl+b Ctrl+o：所有窗格向前移动一个位置，第一个窗格变成最后一个窗格。
Ctrl+b Alt+o：所有窗格向后移动一个位置，最后一个窗格变成第一个窗格。
Ctrl+b x：关闭当前窗格。 # exit
Ctrl+b !：将当前窗格拆分为一个独立窗口。
Ctrl+b z：当前窗格全屏显示，再使用一次会变回原来大小。
Ctrl+b Ctrl+<arrow key>：按箭头方向调整窗格大小。
Ctrl+b q：显示窗格编号。
————————————————
版权声明：本文为CSDN博主「仰望星空的小随」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/sui_152/article/details/121650341
```

