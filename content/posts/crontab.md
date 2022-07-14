---
title: "Crontab"
date: 2022-07-14T17:15:13+08:00
draft: false
---



# 手把手教你如何利用 工具crontab执行定时脚本

## 介绍

Cron 是一个在 Unix 及类似操作系统上执行计划任务的程序。cron 使用户能够安排工作(命令或shell脚本)在特定时间、日期或间隔定期运行，通常用于系统的自动化维护或者管理。[摘自 [Wikipedia](https://en.wikipedia.org/wiki/zh:Cron)]

Cron 是一个守护进程，它根据来自命令crontab的输入运行计划任务。它的工作方式为，每分钟向定时表输入并检查用户有 cron 清单，以及是否有应该执行的工作。

**注意**
注意**crontab**既是计划工作清单的名字，也是编辑这一清单的命令。[摘自 [wiki.gentoo.org](https://wiki.gentoo.org/wiki/Cron)]

## 使用

crontab的使用文件做配置

这意味着你任务的描述在文件中

我们需要做的是写这个配置文件



配置文件基本格式

> 分 时 日 月 星期 命令

分 的值为0到59

时 的值为0到23

日 的值为1到31

月 的值为1到12

星期 值从0到6 ，0代表星期日

除了使用整数代表分、时、日、月，还可以设置范围

| 符号  |             描述             |
| :---: | :--------------------------: |
| ***** | 通配符，表示所有支持的时间值 |
| **,** |      用逗号分隔多个时间      |
| **-** |  连接两个数值，给出一个范围  |
| **/** |      指定一个周期或频率      |

例如 ：

```
*/5 9-16 * 1-5,9-12 1-5 ~/bin/i_love_cron.sh
```

将会在周内从早上 9 点到下午 4 点 55 分，每隔 5 分钟执行一次脚本 `i_love_cron.sh`，夏季除外（6月、7月和8月）。



除了以上定时，crontab在命令前还可以增加一些修饰词，以提供更细节的控制

```
@reboot 启动时
@yearly 每年一次
@annually ( 同 @yearly)
@monthly 每月一次
@weekly 每周一次
@daily 每天一次
@midnight (午夜，同 @daily)
@hourly 每小时一次
```

例如：

```
@reboot ~/bin/i_love_cron.sh
```

将在启动时执行脚本 `i_love_cron.sh`。



写完文件以后，我们通过`crontab filename`即可添加此配置,此会覆盖之前添加的旧的配置文件，可以使用`crontab -l`查看已经存在的配置文件

如果你想修改配置，使用`crontab -e`可以编辑此配置，默认情况下，将使用vi编辑器打开配置文件

如果你想要移除crontabs可以使用`crontab -r`

```
crontab [-u user] file
        crontab [ -u user ] [ -i ] { -e | -l | -r }
                (default operation is replace, per 1003.2)
        -e      (edit user's crontab)
        -l      (list user's crontab)
        -r      (delete user's crontab)
        -i      (prompt before deleting user's crontab)
```

## 例子

接下来就是手把手教学

#### 例子1

我需要每天一个6点半的闹钟,应该按此编辑配置文件

```
6 30 echo"ring_ring_ring"
```

#### 例子2

我需要每1分钟执行报时程序，将此时时间追加写入到/root/date_time

```
* * * * * date>>/root/date_time
```

运行10分钟后查看/root/date_time

```shell
$cat /root/date_time
Thu Jul 14 17:41:01 CST 2022
Thu Jul 14 17:42:02 CST 2022
Thu Jul 14 17:43:01 CST 2022
Thu Jul 14 17:44:01 CST 2022
Thu Jul 14 17:45:01 CST 2022
Thu Jul 14 17:46:01 CST 2022
Thu Jul 14 17:47:01 CST 2022
Thu Jul 14 17:48:01 CST 2022
```

发现运行正常

#### 例子3

我需要每1分钟执行报时程序，这个报时程序是一段 Python 脚本,位置在/root/py_datetime，将此时时间追加写入到/root/date_time_py

```
* * * * * python /root/py_datetime >>/root/date_time_py
```
Python 脚本内容为

```python
from datetime import datetime
print(datetime.now())
```

运行10分钟后查看

```shell
$cat /root/date_time_py
2022-07-14 18:12:01.871340
2022-07-14 18:13:02.029239
2022-07-14 18:14:01.179830
2022-07-14 18:15:01.333957
2022-07-14 18:16:01.463118
2022-07-14 18:17:01.591877
2022-07-14 18:18:01.735284
2022-07-14 18:19:01.863682
2022-07-14 18:20:02.010490
```

#### 例子4

我需要每1分钟执行date报时程序，并每小时执行python报时程序，即有两个任务，配置文件可以写成这样

```
* * * * * date>>/root/date_time
0 * * * * python /root/py_datetime >>/root/date_time_py
```

每小时也可以简写为

```
@hourly  python /root/py_datetime >>/root/date_time_py
```



#### 例子5

我需要每天的午夜 0 点 20 分, 2 点 20 分, 4 点 20 分....执行 echo "haha"：

```
20 0-23/2 * * * echo "haha"
```

更多例子

```
30 4 echo "四点半了。"
0 22 echo "晚上十点了。"
30 15 25 12 echo "现在是圣诞节下午三点半。"
30 3 * * * echo "每天早上三点半提醒我。"
0 * * * * echo "新的一个小时到来了。"
0 6 1,15 * * echo "每月1号和15号的早上六点。"
0 6 * * 2,3,5 echo "周二三四的早上六点。"
59 23 * * 1-5 echo "周内每天的最后一分钟。"
0 */2 * * * echo "每两个小时。"
0 20 * * 4 echo "周四的晚上八点。"
0 20 * * Thu echo "周四的晚上八点。"
*/15 9-17 * * 2-5 echo "周内朝九晚五的每一刻钟。"
@yearly echo "新年好！"
```

如果你还不会配置时间，可以访问

https://crontab.guru/

## 进阶

### 处理任务中的错误

cron 会记录 *stdout* 和 *stderr* 的输出并尝试通过 `sendmail` 命令发送邮件给用户。如果 Cronie 未找到 `/usr/bin/sendmail`，则会禁用邮件通知。要发送邮件到用户的 spool，需要在系统上运行一个 smtp 守护进程，例如 [opensmtpd](https://archlinux.org/packages/?name=opensmtpd)。也可以安装提供 sendmail 命令的软件包，然后配置成通过外部邮件服务器发送邮件。或者使用 `-m` 选项将错误记录到日志并通过定制的脚本进行处理。

#### 使用 ssmtp 的例子

ssmtp 是一个仅包含发送功能的 sendmail 模拟器，可以从本地计算机向 smtp 服务器发送邮件。尽管目前已经没有活跃维护者，这个程序依然是发送邮件的最简单方式。不需要运行守护进程，配置可以简单到只需在一个配置文件中编辑三行即可（如果你的主机是受信任的，可以通过你的邮件服务提供商转发未经认证的邮件）。ssmtp 无法收取邮件、展开别名或管理队列。

安装 [ssmtp](https://aur.archlinux.org/packages/ssmtp/)AUR，安装时会创建链接 `/usr/bin/sendmail` 指向 `/usr/bin/ssmtp`。安装后编辑 `/etc/ssmtp/ssmtp.conf` 配置文件。详情请参考 [ssmtp](https://wiki.archlinux.org/title/SSMTP)，到 `/usr/bin/sendmail` 的软链接可以确保 [S-nail](https://wiki.archlinux.org/title/S-nail) 等提供 `/usr/bin/mail` 的程序可以无需修改直接使用。

安装配置完成后重启 `cronie` 以确保 cronie 能够检测到新配置的 `/usr/bin/sendmail` 命令。



### 默认编辑器

要修改默认编辑器，请在 shell 初始化脚本中定义 `EDITOR` 环境变量，如[环境变量](https://wiki.archlinux.org/title/Environment_variables)所述。

作为普通用户，需要使用 `su` 代替 `sudo` 来正确拉取环境变量：

```
$ su -c "crontab -e"
```

如果希望给这个命令取别名，因为 su 会在一个新启动的子 shell 中启动，为了防止一些以外的发生，需要用 `printf` 加一个任意字符串，来提醒你仍然在 root 下运行：

```
alias scron="su -c $(printf "%q " "crontab -e")"
```

### 确保排他性

如果您有可能运行很久的任务（比如说变化很多或者网速突然变慢，备份可能会偶尔运行很长时间），那么 `flock`（[util-linux](https://archlinux.org/packages/?name=util-linux)）可以确保 cron 任务在同一时间点只有一个运行。

```
  5,35 * * * * /usr/bin/flock -n /tmp/lock.backup /root/make-backup.sh
```



参考资料

https://wiki.gentoo.org/wiki/Cron

https://wiki.archlinux.org/title/Cron  
