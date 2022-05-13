---
title: "Junling.xyz"
date: 2022-02-13T23:55:00+08:00
draft: false
---

今天Godaddy告诉我uest.xyz还有一个月就到期了，让我付100新加坡元续费一年。这钱对学生党岂不是天价。遵循打一枪换一炮的理念，回撤去wawei云注册了junling.xyz
总得能通过新域名访问到github pages吧，我一个滑铲，用waweicloud解析添加一个cname记录，然后error！


原来我当年使用A记录解析到GitHub的服务器
 185.199.108.153
 185.199.109.153
 185.199.110.153
 185.199.111.153
不能再添加cname了，只能通过隐性链接的方式

然后wawei云告诉我
```
# 是否支持显性/隐性URL转发功能？
更新时间：2021/02/09 GMT+08:00

云解析服务暂不支持显性URL以及隐性URL转发功能。
```

哭泣，还是得dnspods，这时候，腾讯就像是我的救星。

我又仔细一搜，发现GitHub page也可以添加cname记录解析到bachwv.github.io
我一个滑铲，发现wawei云会显示cname记录和mx记录冲突，关键是他还不告诉你和谁冲突了

https://support.huaweicloud.com/dns_faq/dns_faq_016.html



华为云修改dns在域名信息里面，改ns记录没效的，太隐蔽了。

等了两个小时才生效。

然后dnspods就可以同时设置mx和cname记录了

接下来为uest.xyz设置隐性显性url能访问了捏，但是我还没没备案，所以还不行，只能等下个月域名失效了

https://github.community/t/redirect-multiple-domains-to-one-github-pages-site/10903/4