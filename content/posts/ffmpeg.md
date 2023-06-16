---
title: "ffmpeg"
date: 2022-08-22T22:00:12+08:00
---
今天有人放着Premium Pro不用，执意要使用ffmpeg剪视频，这种症状一看就是被Fabrice Bellard冲昏了头脑，先是qemu然后就入坑了ffmpeg。

因为自己的需求比较简单，不需要精确贴图的位置，不需要调色，就是简简单单的cut和加字幕，这就很好符合了大道至简思想，也只需要两段代码就能实现剪辑工作。
## 安装
我是用的是winget包管理安装，只需要`winget install ffmpeg`然后直接YYYY。这样不用配置环境变量啥的。

当然之前是使用wsl2上的apt包管理安装的，`sudo apt install ffmpeg`可能还需要一些依赖。
## 怎么cut
剪辑，顾名思义，就是剪出一个视频片段，

`ffmpeg -i todo.flv -ss 02:03:24 -to 02:07:41 output.flv`

这里使用`-i`指定待剪辑的文件，`-ss`指明片段的起始时间02:03:24就是2小时3分钟24秒了

`-to`指明片段的结尾，02:07:41就是2小时7分钟41秒了，可见输出的视频应该是4分17秒的片段。最后的output.flv写在最后，表示输出的文件名。
## 怎么加字幕
首先，我们可以使用一些工具获得srt字幕文件。当然你也可以手打
```
1
00:00:10,430 --> 00:00:12,220
哪里有彩虹告诉我

2
00:00:13,690 --> 00:00:17,320
能不能把我的愿望还给我

3
00:00:19,320 --> 00:00:23,550
为什么天这么安静
```
接下来重要的参数就是字幕样式了。
srt字幕需要使用subtitles滤镜，
，通过force_style设置样式，比如字体，颜色，字幕边框，以及位置。
PrimaryColour为字幕颜色，

注意它使用的不是我们常见的RGB颜色，而是BGR，你可以理解成RGB的B和R调换了顺序。比如你想要\#74a9b4，这里就变成了b4a974，有点奇怪但是这点转换人脑就可以做到

outlineColour就是边框颜色。
```
ffmpeg -i output.flv -vf "subtitles=output.srt:force_style='fontname=MicrosoftYaHeiUI, 
FontSize=30,PrimaryColour=&H00b4a974,
outlineColour=&Hffffff,outline=1'" -c:v libx264 output-srt-color-white-2.flv
```

这就完成了我们的全部需求了。



如果想控制导出大小，比如某演示视频需要提交20M以内文件，可以加上`-fs 20M`的参数。ffmpeg的命令行是很复杂的，以至于没有人能hold得住为它做一个GUI，对于一开始的我来说，使用搜索引擎寻找guide博客是很花时间的。当然我也找到一个做的比较好的[guide]([FFmpeg.guide - One stop solution to all things FFmpeg](https://ffmpeg.guide/?utm_source=hackernewsletter&utm_medium=email&utm_term=show_hn))

现在，我们有了GPT，感觉是可以把这部分的搜索给替代了。
