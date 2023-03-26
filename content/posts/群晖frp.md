---
title: "frp内网穿透"
date: 2021-11-10T16:58:12+08:00
draft: false
categories: ["tech"]
---


前几天被群晖官方从阿尔及利亚区强制迁回中国，导致需要手机号验证，验证完了以后会显示序列号冲突，得拍视频提交工单才能解除冲突，才能使用easyconnect，这令我十分不爽。一怒之下注销了群晖的号，打算自己弄。

由于我没有公网ip，又不想弄花生壳，teamviewer，所以我得想办法解决公网访问的问题。




下面介绍借助frp实现内网穿透。

frp分为客户端和服务端两个部分，服务器上使用的是frps，群晖上使用的是frpc。

在客户端开端口，然后群晖的frpc连接上服务器上的frps就可以了。

下面是手把手教学：

## 服务器端

如果你有一台闲置的Linux服务器，而且有公网ip，在打开防火墙以后，按照一下方法操作
如果你没有，也可以使用免费的一些frp服务器https://frp.wlphp.com/，这样你就可以跳过服务器配置的过程了。直接 [跳转到群晖上操作](#客户端)


### 下载
在https://github.com/fatedier/frp/releases中找到需要下载的文件,比如我想下载0.37.0的linux的x86平台的frp，就可以这么写：

```shell
# wget -O frp https://github.com/fatedier/frp/releases/download/v0.37.0/frp_0.37.0_linux_amd64.tar.gz
```
解压：
```shell
# tar -xvzf frp
```

可以看到这些文件：
```shell
# ls
frpc           frpc.ini  frps           frps.ini    systemd
frpc_full.ini  frpc.log  frps_full.ini  LICENSE
```

接下来就是配置服务器端文件frps.ini

```
[common]
bind_port = 7000
#通讯端口，用于和客户端内网穿透传输数据的端口，可自定义
bind_udp_port = 7001
#UDP通讯端口，用于点对点内网穿透
kcp_bind_port = 7000
#用于KCP协议UDP通讯端口，在弱网环境下传输效率提升明显，但是会有一些额外的流量消耗。设置后frpc客户端须设置protocol = kcp
vhost_http_port = 80
#http监听端口，注意可能和服务器上其他服务用的80冲突，比如centos有些默认有Apache，可自定义
vhost_https_port = 443
#https监听端口，可自定义
dashboard_port = 7500
#通过浏览器查看 frp 的状态以及代理统计信息展示端口，可自定义
dashboard_user = admin
#信息展示面板用户名
dashboard_pwd = admin
#信息展示面板密码
log_max_days = 7
#最多保存多少天日志
token = xxxxxx
#这就是与客户端连接的token啦
privilege_allow_ports = 1-65535
#端口白名单，为了防止端口被滥用，可以手动指定允许哪些端口被使用
max_pool_count = 100
#每个内网穿透服务限制最大连接池上限，避免大量资源占用，可自定义
authentication_timeout = 0
#frpc 所在机器和 frps 所在机器的时间相差不能超过 15 分钟，因为时间戳会被用于加密验证中，防止报文被劫持后被其他人利用,单位为秒，默认值为 900，即 15 分钟。如果修改为 0，则 frps 将不对身份验证报文的时间戳进行超时校验。国外服务器由于时区的不同，时间会相差非常大，这里需要注意同步时间或者设置此值为0
log_file = frps.log
log_level = info
```
实际上没有必要配置这么多，bind_port = 7000和token就够了。
下一步运行就可以了，这里用后台运行的指令
```shell
# nohup ./frps -c frps.ini &
```
可以在服务器ip:7500端口看到frps的运行状态，至此，服务器端的配置就完成了。

## 客户端

首先，得用ssh登录群晖。如果你没有用过ssh登录过，可以进入群晖控制面板，找到终端机和SNMP，点击启动SSH功能，设定你的端口（默认22）
![image-20211109174257597.png](https://raw.githubusercontents.com/bachwv/picgo/master/DMHVvjpmkCgzoaT.png)



点击应用。

接下来使用你顺手的ssh登录就可以了。利用admin账号和密码登录（注意admin账号登录进去以后还要用`sudo -i`，不然没有权限）
![image-20211109174413962.png](https://raw.githubusercontents.com/bachwv/picgo/master/4NkOdg1Q5DtIYXl.png)


找到一个顺手的 目录，比如home，利用同样的命令 [下载](#下载)


这时，我们关注的是frpc.ini这个配置文件
```shell
[common]
server_addr = xxx.xxx.xxx.xxx 
#frps服务端地址
server_port = 7000
#frps服务端通讯端口，客户端连接到服务端内网穿透传输数据的端口
token = xxxxxxx
#特权模式密钥，客户端连接到FRPS服务端的验证密钥
log_file = frpc.log
#日志存放路径
log_level = info
#日志记录类别,可选：trace, debug, info, warn, error
log_max_days = 7
#日志保存天数
login_fail_exit = false
#设置为false，frpc连接frps失败后重连，默认为true不重连
protocol = kcp
#KCP协议在弱网环境下传输效率提升明显，但是对frps会有一些额外的流量消耗。服务端须先设置kcp_bind_port = 7000，www.yourdomain.com服务端已设置支持

[nas]
#穿透服务名称,可以随便起,不能和其他已建立的相同
type = tcp
#穿透协议类型，可选：tcp，udp，http，https，stcp，xtcp，这个设置之前必须自行搞清楚应该是什么
local_ip = 127.0.0.1
#本地监听IP，可以是本机IP，也可以是本地的局域网内某IP，例如你的局域网是互通的，你可以在路由器上安装frpc，然后local_ip填的内网其他机器ip，这样也可以把内网其他机器穿透出去
local_port = 5000
#本地监听端口，通常有ssh端口22，远程桌面3389等等,就是把本机的多少端口转发出去
use_compression = true
#对传输内容进行压缩，可以有效减小 frpc 与 frps 之间的网络流量，加快流量转发速度，但是会额外消耗一些 cpu 资源
use_encryption = true
#将 frpc 与 frps 之间的通信内容加密传输
remote_port = 5009
#即远程对应你客户端的端口，不能和别的重合

```
下一步在frp目录下新建一个启动脚本`start.sh`，让群晖每次开机时运行这一个脚本


```
nohup /home/frp/frpc -c /home/frp/frpc.ini >/dev/null 2>&1 &
```

解释一下为什么要这么写：

>/dev/null
>这条命令的作用是将标准输出1重定向到/dev/null中。 /dev/null代表linux的空设备文件，所有往这个文件里面写入的内容都会丢失，俗称“黑洞”。那么执行了>/dev/null之后，标准输出就会不再存在，没有任何地方能够找到输出的内容。

2>&1
这条命令用到了重定向绑定，采用&可以将两个输出绑定在一起。这条命令的作用是错误输出将和标准输出同用一个文件描述符，说人话就是错误输出将会和标准输出输出到同一个地方。

linux在执行shell命令之前，就会确定好所有的输入输出位置，并且从左到右依次执行重定向的命令，所以>/dev/null 2>&1的作用就是让标准输出重定向到/dev/null中（丢弃标准输出），然后错误输出由于重用了标准输出的描述符，所以错误输出也被定向到了/dev/null中，错误输出同样也被丢弃了。执行了这条命令之后，该条shell命令将不会输出任何信息到控制台，也不会有任何信息输出到文件中。

接下来，回到群晖的控制台，在控制面板的计划任务中
![ds](https://raw.githubusercontents.com/bachwv/picgo/master/synology-crontab.png)
新建任务,事件为开机
![](https://s2.loli.net/2022/09/06/fYPhLojxJ1eQZNc.png)
在任务设置中填写：
bash /home/frp/start.sh
重启群晖
就可以在服务器的7500看到刚刚登录进来的群晖。

输入服务器ip:端口（在frpc.ini中设置的remote端口），即可看到你的设备啦。
![屏幕截图 2021-11-10 173901.jpg](https://raw.githubusercontents.com/bachwv/picgo/master/synology-zhangwei.jpg)
如果你不嫌烦+不怕死，你也可以把群晖的22端口映射出去。

当然，如果你有远程桌面，tomcat，nginx的需求都可以用这种方法，对我来说frp取代teamviewer和花生壳是完全可以的。

