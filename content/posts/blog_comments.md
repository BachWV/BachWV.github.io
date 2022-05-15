---
title: "Blog_comments"
date: 2022-05-15T16:58:12+08:00
draft: false
---

blog评论一直没做，这次终于不嫌麻烦开整了。

我选用的是waline，主要是用户评论时不需要登录，而且好看。

部署指南参见 https://waline.js.org/guide

我用的是hugo搭建的blog，html引入就只能自己试试了。

在\themes\hugo-theme-tokiwa\layouts\partials下找到page-footer.html

加上

```html
 <script src="https://unpkg.com/@waline/client@v2/dist/waline.js"></script>
 <link
   rel="stylesheet"
   href="https://unpkg.com/@waline/client@v2/dist/waline.css"
 />

<script>
  Waline.init({
    el: '#waline',
    serverURL: 'https://waline-66tg5wuyr-bachwv.vercel.app',
  });
</script>
```

即可。



评论系统：https://waline-66tg5wuyr-bachwv.vercel.app/

评论管理：https://waline-66tg5wuyr-bachwv.vercel.app/ui

