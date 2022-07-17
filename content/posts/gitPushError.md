---
title: "git 指南"
date: 2022-07-11T19:37:54+08:00
draft: false
lastmod:
---

# git push到别人的分支如何回退



## 1.备份战场

建立新分支

`git branch imsb`



## 2.掩耳盗铃

回退

`git checkout yuanfenzhi`

`git log找到那一串 commit代码`

`git reset --hard 一长串commit回退`



```
--mixed 
不删除工作空间改动代码，撤销commit，并且撤销git add . 操作
这个为默认参数,git reset --mixed HEAD^ 和 git reset HEAD^ 效果是一样的。

--soft  
不删除工作空间改动代码，撤销commit，不撤销git add . 

--hard
删除工作空间改动代码，撤销commit，撤销git add . 
--hard HEAD commitid可以回到哪次提交
--hard HEAD^ 表示最近一次提交
```

## 3.暗度陈仓



``git push --force``

 要用force因为push的版本小于远程仓库的版本

这样别人就察觉不到你push错了
