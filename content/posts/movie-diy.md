---
title: Movie and Book
date: 2023-05-10T16:58:12+08:00
lastmod: 2024-05-01T16:58:12+08:00
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

重新构建一下，你也能拥有如此炫酷的页面啦。

2023-12-26 update: 把分类时的观影日期改为上映的日期。没想到json对字符串的比较如此鲁棒，只改了一个数字

-------------------

## 2024-05-01 update: 大更新，将数据和页面分离。

此时可以通过csv文件添加电影，不需要通过Github Actions定时更新仓库。也就是说，原本hugo通过模板解析csv文件生成html，现在只浏览器通过js动态解析csv文件生成html。这样就不需要每几个小时更新一次仓库了。
本工作是在gpt4和通义千问的帮助下完成的。
让ai找了一个js库，papaparse，可以很方便地解析csv文件。
```js
    async function fetchAndParseCSV(url) {
      const response = await fetch(url);
      const csvText = await response.text();
      const config = { header: true }; // 假设CSV文件首行为列名
      const movies = Papa.parse(csvText, config).data; // 返回解析后的二维数组，每行一个数组
      return movies;
    }
```
hugo模板每一个range都是一个电影，下面对于csv的每一行，生成一串div的html就好了，再找到合适的地方塞进去
```html
movieDiv.innerHTML = `
    <div class="sc-hKFxyN HPRth" style="height:190px" >
    <a rel="link" href="${movie.url}" target="_blank">
    <div class="lazyload-wrapper ">
        <img class="lazy entered loaded" data-src="${movie.poster}" referrer-policy="no-referrer" loading="lazy" alt="${movie.title}" width="150" height="220" data-ll-status="loaded" src="${movie.poster}">
    </div>
    </a>
    </div>
    <div class="sc-iCoGMd kMthTr">${movie.title}</div>
    <div class="sc-fujyAs eysHZq">
    ${starsHtml} 
    <span class="sc-pNWdM iibjPt">${movie.star}</span>
    </div>          
`;
```
还用ai解决了一个评论只显示30个字，点开显示全部的问题，这是一直想做的需求。通义没有准确理解我的意思。而gpt4一下就get到要点，顺利给出了代码。
```js
    function createCommentElement(comment) {
      // 创建一个包裹元素
      const commentWrapper = document.createElement('div');
      commentWrapper.classList.add('sc-gtsrHT', 'dvtjjf');

      // 检查评论长度
      if (comment.length > 30) {
        // 显示截断的评论加上“显示更多”按钮
        const shortComment = document.createTextNode(`"${comment.substring(0, 30)}..." `);
        const moreLink = document.createElement('a');
        moreLink.href = '#';
        moreLink.textContent = '显示更多';

        // 点击“显示更多”时的事件处理
        moreLink.addEventListener('click', function(event) {
          event.preventDefault(); // 阻止链接默认行为
          // 替换为完整评论
          commentWrapper.textContent = `"${comment}"`;
        });

        // 将文本和链接添加到包裹元素
        commentWrapper.appendChild(shortComment);
        commentWrapper.appendChild(moreLink);
      } else {
        // 如果评论不超过30个字符，则直接显示
        commentWrapper.textContent = `"${comment}"`;
      }
      return commentWrapper;
    }
```
遇到最困难也是最花时间的地方，就是把电影评分，也就是五颗星星画出来。hugo模板是每个星星是涂上颜色的css还是没涂，当然html也很简单，不过我用ai生成这段代码时走了一些弯路。
```js
      // 创建星星评分的HTML
        let starsHtml = '';

        for (let star = 0; star <= 4; star += 1) {
          const starClass = movie.star > star ? 'lhtmRw' : 'gaztka';
          starsHtml += `
            <svg viewBox="0 0 24 24" width="24" height="24" class="sc-dlnjwi ${starClass}">
              <path fill="none" d="M0 0h24v24H0z"></path>
              <path fill="currentColor" d="M12 18.26l-7.053 3.948 1.575-7.928L.587 8.792l8.027-.952L12 .5l3.386 7.34 8.027.952-5.935 5.488 1.575 7.928z"></path>
            </svg>
          `;
        }
```

最后还遇到了csv的跨域问题，改一下nginx配置就好了。
```nginx
server {
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
 
    if ($request_method = 'OPTIONS') {
        return 204;
    }

}
```
我不懂当今前端是怎么用vue或者react框架的，但是这样也没写几行代码也满足了我的需求，我很满意。



