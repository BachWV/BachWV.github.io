---
title: "Zerotie"
date: 2022-02-23T15:50:21+08:00
draft: false
---



# 使用zerotie建立局域网

最近不知道怎么了，某米ac2100的ipv6防火墙开不了，导致只能用frps去连接群晖，太慢了。[详情点击这里]({{< relref "群晖frp.md" >}})

于是又想尝试zerotie

群晖上的操作比较简单，官网上说的很详细

https://docs.zerotier.com/devices/synology/

## 1.首先添加虚拟网卡

Write script to `/usr/local/etc/rc.d/tun.sh` that will setup `/dev/net/tun` on startup

`echo -e '#!/bin/sh -e \ninsmod /lib/modules/tun.ko' > /usr/local/etc/rc.d/tun.sh`

Set executable permissions on script

`chmod a+x /usr/local/etc/rc.d/tun.sh`



Run script once to create a TUN

```
/usr/local/etc/rc.d/tun.sh
```


Check for the TUN

```
ls /dev/net/tun

/dev/net/tun
```

*If you experience trouble getting the TUN to work check out*
## 2.去群晖官方套件中心添加docker
## 3.启动容器
Make directory to store ZeroTier's identity and config
```
mkdir /var/lib/zerotier-one
```
Make Docker container called zt (Repo: zerotier/zerotier-synology)
```
docker run -d           \
  --name zt             \
  --restart=always      \
  --device=/dev/net/tun \
  --net=host            \
  --cap-add=NET_ADMIN   \
  --cap-add=SYS_ADMIN   \
  -v /var/lib/zerotier-one:/var/lib/zerotier-one zerotier/zerotier-synology:latest
```

## 4.添加网络
Previous versions of our package contained a GUI, however this is no longer the case and it is for the better. The CLI can be used as follows:

View node status

```docker exec -it zt zerotier-cli status```
Join your network

```docker exec -it zt zerotier-cli join 你的网络id```
Authorize the NAS on your network. Then view the network status:

docker exec -it zt zerotier-cli listnetworks
Show running container (optional)

```docker ps```
Enter the container (optional)

```docker exec -it zt bash```

j接下来就是让win本加入这个网络，官网下载安装包，点join network就行了

在官网就能看到两个设备的ip了，

速度也不是很快，300KBps吧
