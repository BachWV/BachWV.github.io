---
title: "Synology"
date: 2022-05-13T19:55:45+08:00
draft: false
---

今天送走了一台j1900主机，上面部署过黑群晖，也花了很久才调教成一个顺手的群晖。
我给群晖的定义是一个更智能的云盘，首要的任务是文件的保存同步和共享。

而首先需要解决的问题是

## 外网访问

在没有公网IP的情况下，我总结了4种方法。

1. [洗白]({{< relref "从黑群晖走向白.md" >}})
2. [frp]({{< relref "群晖frp.md" >}})
3. [zerotier]({{< relref "zerotier.md" >}})
4. 公网ipv6+ddns

## 云盘

群晖提供了各种方式访问群晖的文件。

SMB 局域网共享

WEBDAV 挂载成网盘

FTP/SFTP 最广泛的文件传输协议


最近发现的一个很好用的支持多种存储的目录文件列表程序Alist，可以直接使用docker构建

## 其他服务

### 笔记 NoteStation

笔记可以直接从印象笔记转移，是相当不错的功能。也有桌面和手机端的APP，手机端除了有些bug，功能挺全的。

原本对于笔记的要求就是简单，查看方便，保存100年，加上私密性。Note Station足够了。

### 下载

bt，电驴应有尽有。

### 百度网盘

可以同步百度网盘，Google网盘啥的，很强大。

### Docker

方便管理各种docker应用，反正就是无限可能。

### Chat

私密聊天，吊打微信，多用户，多频道。不过好像没有手机端app

### Drive

同步云盘，手机公测 的新APP可以同步微信聊天记录和文件夹。

### Photo

手机APP挺稳定的，无论备份多少东西都不会被杀后台，将50G的照片放在群晖上，手机随时查看，属于是我的小米云平替了。

### Movie

iPad客户端体验捉急，用了一次就不用了。

其他的话由于群晖也是在bsd基础上开发的，也可以正常用很多linux-x86的应用，比如gcc,java,node,python,群晖套件也就相当于包管理工具了。

群晖官方的应用服务的质量良莠不齐，不过可能是我还在dsm6，没有体验过dsm7，有些就一直是老版本。



手机APP

群晖助手，这是第三方写的，很好用，更新也很及时。可以直接打开视频，可以用android官方共享接口上传文件。

官方叫群晖管家，也能凑合用。









