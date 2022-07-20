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
