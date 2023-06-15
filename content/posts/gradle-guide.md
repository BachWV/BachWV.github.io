---
title: "Gradle使用指南"
date: 2023-06-14T12:00:00+08:00
---
Gradle是我碰都不愿意碰的东西，从Android项目开始，我对这玩意就没有好印象，留下一堆配置文件，在我的环境里就run不起来，我只想run一下看看效果，为什么要下一版gradle-7.4-all.zip，你就不能做到向前兼容？
我的~\.gradle\wrapper\dists\gradle-7.4-all里面有4个不同文件名的文件夹，里面都是同一个东西，我不知道为什么同样的东西被下了四次。

既然gradle这么折磨难用，但短时间还没有东西能把它淘汰，所以只能硬着头皮学下去了。

gradle是什么？官方的解释是：Gradle是一个基于Apache Ant和Apache Maven概念的项目自动化建构工具。它使用一种基于Groovy的特定领域语言来声明项目设置，而不是传统的XML。但是我觉得这个解释并不好，因为我不知道Apache Ant和Apache Maven是什么，所以我也不知道gradle是什么。

对于Android项目，项目目录下都会有一个gradle目录，里面有一个wrapper目录，jar是用来下载特定版本的gradle的，对于Android项目来说，不同项目可能锚定在不同的gradle版本，这就导致了你会有无数不同版本的gardle并存。gradle-wrapper.properties是配置去哪找对应的分发版本，然后帮你下载到~/.gradle/wrapper/dists中，并且产生一串奇怪的目录名，Gradle对应版本下载完成之后，Gradle Wrapper的使命基本完成了，真™笑死，占了一个大文件夹只为了你下载分发的gradle，欺负你们不会自己下载gradle。不能忍，必须所有项目共用一个gradle，指定use local gradle distribution，什么，你说gardle不能保证兼容性，不同项目共用一个gradle会有意想不到的问题，那咋办，忍着，谁让这gradle如此垃圾呢。

接下来终于到重头戏了，到达坑贼多的构建环节。

还没学会，等我更新
