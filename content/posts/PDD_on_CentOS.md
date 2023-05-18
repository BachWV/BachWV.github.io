---
title: "部署PDD项目"
date: 2021-12-12T23:56:31+08:00
draft: false
---

部署pdd

拼夕夕是一个对标拼多多的网络商城,构建的源码在:

https://github.com/SoftwareEngineeringStormtrooper/PingTaoduo/

这是软件工程的课程项目。

1.CentOS安装jdk 

``` 
yum install java-1.8.0-openjdk.x86_64
```


会自动配置环境变量


2.安装tomcat

安装目录```/usr/local/tomcat```

和win下配置一模一样，i了i了

3.安装mysql
有点复杂
https://www.cnblogs.com/zhulei2/p/13912167.html
关于密码要改一下策略

``` sql
SHOW VARIABLES LIKE 'validate_password%';

set global validate_password.length=1;
grant all privileges on *.* to 'user02'@'%' with grant option; 
create user user02@'%' identified by '2077';
```



远程连接： ``` GRANT ALL PRIVILEGES ON *.*TO 'root'@'%';```

4.打war包
idea中build->build artifacts
https://blog.csdn.net/money_yao/article/details/91435188
移到webapp试了可以
注意\conf\Catalina\localhost中加入命名为shopimage.xml完成虚拟文件夹创建

```xml
<Context docBase="C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\shopimage"/>
```

注意在tomcat运行过程中，webapps下面的war文件是热部署的，不需要重启tomcat，并且.war文件不能删除，否则项目无法打开。

目前已知问题：用户登录以后的订单list的sql语句有问题，目测是CentOS下Mysql8.0的锅
查询用户表很慢，不知道什么原因
