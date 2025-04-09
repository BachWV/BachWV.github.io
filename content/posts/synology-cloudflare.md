---
title: 群晖外网访问终极篇 Cloudflare隧道
date: 2023-06-15T12:00:00+08:00
---
终于到这个终极篇了，作为外网访问的最后一篇，我要介绍的是Cloudflare隧道，这个隧道是Cloudflare的一个0元付费服务，相当于一个反向代理，省去配置证书的麻烦。

使用非常简单，部署不超过3分钟。cf也给出了详细的教程。https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

cloudflare注册账号，添加域名，添加DNS解析，添加隧道，

docker 运行或者 systemd守护，cf配置一下域名，搞定。




