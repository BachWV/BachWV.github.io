---
title: "git 局域网同步"
date: 2024-08-27T16:29:49+08:00
draft: false
---
A电脑共享git仓库目录(`C:\Users\xxx\Desktop\code\cpp-httplib`)的文件夹，将文件夹权限更改为Everyone读取写入

![image-20240827162949843](https://r2.csapp.fun/2024/08/image-20240827162949843.png)

比如A的ip是100.74.215.22，共享cpp-httplib的目录（该目录下存在.git）

![image-20240827162807944](https://r2.csapp.fun/2024/08/image-20240827162807944.png)

在另一台电脑B上，命令行输入一下命令，即可克隆（如果是在A电脑的其他目录，可以输入`git clone file:///C:\Users\xxx\Desktop\code\cpp-httplib`  )

```bash
git clone file://100.74.215.22/cpp-httplib
```

![image-20240827163233102](https://r2.csapp.fun/2024/08/image-20240827163233102.png)

在B电脑克隆后的目录中，可以看到.git/config文件可以看到远端增加了一个局域网能访问的远端位置(如果是在A电脑的其他目录，`url = file:///C:\Users\xxx\Desktop\code\cpp-httplib `)：

![image-20240827163821442](https://r2.csapp.fun/2024/08/image-20240827163821442.png)

一般来说他是一个git服务器的地址，比如

```txt
[remote "origin"]
	url = https://github.com/yhirose/cpp-httplib.git
	fetch = +refs/heads/*:refs/remotes/origin/*
```



此时，B电脑可以对该仓库进行一些更改，比如创建一个分支LJL，做一个提交

![image-20240827164926561](https://r2.csapp.fun/2024/08/image-20240827164926561.png)

再推回远端仓库`git push origin LJL`这个origin即是上面截图红框圈起的别名，也就是向A电脑的远端推送LJL分支。

推送一个新分支显然是一个无害的操作，可以顺利进行。



**注意**，如果你想要在B电脑的master分支更新一次提交然后推送到A电脑，同时远端（A电脑）的HEAD指针也在master分支。B电脑提交master分支更新A电脑的HEAD指针，这是不被允许的。git会拒绝push到A电脑

![image-20240827165618158](https://r2.csapp.fun/2024/08/image-20240827165618158.png)

如果想解除限制，可以在A电脑的目录下，`git config --local receive.denyCurrentBranch ignore`，

![image-20240827165716319](https://r2.csapp.fun/2024/08/image-20240827165716319.png)

它的作用等价于在A电脑的.git/config文件添加`[receive] denyCurrentBranch = ignore `这两行

```
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = https://github.com/yhirose/cpp-httplib.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
	vscode-merge-base = origin/master

[receive]
	denyCurrentBranch = ignore
```

B电脑就可以更新A电脑的HEAD指针了，当然如果A电脑工作区有内容没有保存，会造成混乱。试了一下远端会暂存一次更改，再用新的HEAD覆盖，确实挺混乱的。



