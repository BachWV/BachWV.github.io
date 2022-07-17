---
title: "一个艰难的找bug过程"
date: 2022-07-18T00:17:23+08:00
draft: false
toc: true
---





### 尝试一

重启



### 尝试二

回退，既然我没有问题，那就是引入的脚本的问题

我想到了之前只引入评论的的http://blog.junling.xyz/test.html

这个怎么丝毫没有问题啊

想到用浏览器的开发者工具

![image](https://user-images.githubusercontent.com/21078868/179396866-0c54dc79-56d3-462c-a9a7-ce55d9d27532.png)

这时我找到waline的讨论区，有人遇到和我一样的问题

https://github.com/walinejs/waline/discussions/735

看看它是这么解决的



![image-20220717233112043](https://raw.githubusercontent.com/bachwv/picgo/master/image-20220717233112043.png)

好家伙，直接解决出现问题的人，换了个评论系统不就完了



### 尝试三

看看别人是怎么在客户端引入waline的，先是找到了一个hugo的主题next:https://github.com/elkan1788/hugo-theme-next，抄一遍他的代码，怎么不管用？

```js
{{ if and (.Site.Params.Comment.Enable) (eq .Site.Params.Comment.Module "Waline") }}
<!-- Waline -->
<script type="text/javascript">
  const locale = {
    placeholder: '{{ i18n "CommentPh" | safeHTML }}'
  };
  $(function(){
    if (detectIE()>0) {
      $.getScript(document.location.protocol+'//unpkg.com/@waline/client@1.6.0/dist/Waline.min.js', function(){
         new Waline({
          el: '#wcomments', 
          visitor: true,
          emoji: [], 
          wordLimit: '200', 
          uploadImage: false,
          locale, 
          requiredMeta: ['nick', 'mail'], 
          serverURL: "{{ .Site.Params.Comment.WalineSerURL }}", 
          lang: "{{ .Page.Lang }}"
        });
      });      
    } else {
      $('#wcomments').html('{{ i18n "UnComment" }}');
    }
  });
</script>
<!-- Waline -->
{{end }}
```

我们只要简单修改一下

原来是我的环境变量错了，他的配置是params.toml我的是config.toml问题不大，参考官方文档改写config.toml，和script.html怎么我的评论都没了，初步判定是找不到#waline这个div，因为这个div在别的html文件里，



### 尝试四

索性咱们再搭一个博客



### 反思：

仍然迷惑不解的地方：为什么昨天突然挂了

对js不够了解
