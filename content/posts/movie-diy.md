---
title: Movie and Book
date: 2023-05-10T16:58:12+08:00
---
为你的静态站点添加一个观影页面
![](https://s2.loli.net/2023/05/18/vW2XouUbzfEKxGc.png)
效果如 https://junling.li/movies/ 所示，这是不是也很酷。只需要在自己的豆瓣账号上为自己喜欢的电影评分，即可自动同步到影单，这也太酷辣。


使用git管理的好处是，文件修改的[历史记录](https://github.githistory.xyz/BachWV/BachWV.github.io/blob/master/csv/douban/movie.csv)能够轻易查看， 顺着时间轴来就能看到添加历史，我超，非常符合我对未来的想象，科技并带着趣味

借助这个 https://imnerd.org/doumark.html 提到的工具，可以将豆瓣的评分导出为csv文件，然后再将csv文件放到自己的github仓库中，就可以了。
如何实现自动化，使用Github Actions，每小时的第30分钟执行一下脚本，查看豆瓣数据有没有更新。

还记得怎么写**每小说的30分钟执行一下脚本**，可以去复习[crontab]({{< relref "posts/crontab.md" >}}) 或者直接在（https://crontab.guru/#30_*_*_*_*）里看一下。

有了定时更新的csv文件，那我们怎么把csv解析成html页面呢？

Hugo作为静态网页生成工具，早就为你想到了这一点，参考[Hugo文档](https://gohugo.io/templates/data-templates/) 只需要`{{ $dataC := getCSV "separator" "url" }}`一下，即可获得csv里的数据。使用`{{index $movie 5}}`即可获得csv文件第五列的数据。

具体过程见[movies.html](https://github.com/BachWV/BachWV.github.io/blob/master/themes/hugo-theme-tokiwa/layouts/_default/movies.html)

重新构建一下，你也能拥有如此炫酷的页面啦




