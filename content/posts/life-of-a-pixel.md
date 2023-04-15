---
title: "Life of a Pixel"
date: 2023-4-8
draft: false
---
今天在B站看到一个up讲浏览器的前世今生，我平时不会轻易评价一个技术视频讲得好不好，深入了就没有受众，浅显易懂才符合大众的口味。但是这个视频和Life of a Pixel相比，属于是一个班门弄斧了。所以我还是想要吹一下Life of a Pixel。
![](https://s2.loli.net/2023/04/08/g7kcMOwznGtYIBd.png)

*The system is very complicated,and the design doc is tended to assume that you already knew a lot of stuffs*

让我们跟着Steve Kobes，了解web内容是怎么渲染成像素的吧。


# 我们要渲染什么
当然是网页啦
包括html,css,js，还有一些图片视频什么的，就这么多啦。

当然考虑到受众，还是解释一下这些东西是什么。

html是一种标记语言，比如
```html
<p>hello world</p>
```
这就是一段最简单的代码啦，带尖括号的p标识了hello world是一个段落

css是控制样式的
```

```
#
- 以上内容适用于Chrome 版本 69.0.3445