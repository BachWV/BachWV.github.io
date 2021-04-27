---
title: "搭建与发布blog"
date: 2021-04-27T21:50:40+08:00
draft: false
---

来源https://sspai.com/post/59904

利用github + hugo 搭建轻量化的blog ，非常有用的教程！

#### 1. 安装 Git 和 Go

使用Hugo前需要安装[Git](https://git-scm.com/) 和 [Go](https://golang.org/dl/) 语言开发环境，点击对应网址下载安装包即可。

#### 2. 安装Hugo

网上存在很多用工具安装的方式，我这里讲述一个我认为最简单的方式，不用涉及太多的代码（本方法针对pc）。

（1）在Hugo的[官网](https://github.com/gohugoio/hugo/releases)中选择想要的版本下载zip，将其中的hugo.exe文件解压到想要的地方，比如 `C:\Hugo\bin`。

（2）将Hugo添加到Windows的环境变量 `PATH`中。

![img](https://cdn.sspai.com/2020/04/09/06c8b0c6d15bd4bfdf8ba25925aacbd4.gif)

（3）添加完`PATH`后，打开Git Bash 输入 `hugo version` 出现`hugo static site generator`相关信息表示安装完成。

![img](https://image-1301586523.cos.ap-shanghai.myqcloud.com/20200409131219.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

#### 3. 生成博客

（1）打开Git Bash 输入`hugo new site "你的文件名字"`，便可以生成一个用于存放博客的文件夹。

![img](https://image-1301586523.cos.ap-shanghai.myqcloud.com/20200409131452.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

（2）安装主题。

不同于hexo，hugo没有自带主题，所以建立完文件夹后要导入主题文件。导入主题方式和hexo相似，可以用`git clone` 的方式，也可以到相应主题的github中下载zip文件然后解压到自己博客的`themes`文件夹中。

推荐几个主题：[Pure](https://themes.gohugo.io/hugo-theme-pure/)、[Even](https://themes.gohugo.io/hugo-theme-even/)、[Coder](https://themes.gohugo.io/hugo-coder/)

官网主题库：[Hugo Themes](https://themes.gohugo.io/)

（3）配置文件

Hugo配置文件放置在源文件下，并且支持三种格式：toml，yaml，yml。这个配置文件可以直接从主题文件中的exampleSite 里copy到博客文件夹下，然后进行修改。

- 注意点1：有些主题没有提供相应的配置文件，得进行自己修改，不建议选用这类主题。
- 注意点2：配置文件中要确保里面的主题名字和你themes文件夹中相应的主题文件夹名字一样，比如我的主题是pure，那么配置文件里的theme = pure，并且themes 文件夹中也有一个pure的文件夹。这是为了保证工具能依据名字找到相应的主题文件。

![img](https://cdn.sspai.com/2020/04/09/c82da3311e318983133f24173ef33c0f.gif)

（4）生成博文

在 Git Bash 中输入 `hugo new posts/xxxx.md`，这时候就会在文件夹 `content/posts`形成你要的markdown文件，打开进行编辑即可。

![img](https://cdn.sspai.com/2020/04/09/7b5e340c2da79b4bd26ea7f1852a1ecd.gif)

（5）渲染查看效果

在博客文件夹中打开Git Bash，输入 `hugo server`，然后打开 http://localhost:1313/ 来查看效果。注意，markdown文件中的 `front matter` 部分有一个`draft` 参数，如果`draft`设置为`true` 则可正常渲染，如果设置为`false`则不予以渲染。相应的如果想查看全部效果则输入`hugo server -D` 表示将草稿文件也进行渲染。

#### 4. 代码托管

这里主要以GitHub 作为代码托管，假定你已经建立了一个xxx.github.io的一个仓库。官方提供了三四种[上传方式](https://gohugo.io/hosting-and-deployment/hosting-on-github/)，本文采用生成docs的方式进行部署，个人认为这种方式比较简单明了。

（1）修改配置文件。在配置文件config.toml中添加`publishDir = docs`，其他格式的配置文件类似。

（2）打开Git Bash，输入`hugo`，就会发现博客文件中出现了docs文件夹，这是因为hugo将网页的信息都存储在docs里，而不是public中。

（3）在博客文件夹中，打开Git Bash，依次输入以下代码（注意 git remote add 后跟随自己github的对应地址）：

```
git remote add origin  https://github.com/xxxxx/xxxx.github.io.git
git add .
git commit -m "first commit"
git push -u origin master
```

（4）在GitHub对应的仓库设置中，将Github Pages source改成branch/docs 。

![img](https://image-1301586523.cos.ap-shanghai.myqcloud.com/20200409140359.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

（5）这时候点击网址会发现内容已经成功渲染了，但是跳转连接出现问题，这是因为我们没有在配置文件中的`baseURL`中更新我们未来发布的网址链接。因此我们将GitHub Pages 对应的网址进行复制然后添加到配置文件的第一个 `baseURL`中，重新进行第二步和第三步即可。

