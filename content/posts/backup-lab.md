---
title: 一个不知名的备份打包程序
date: 2023-05-12
---
使用古老的Java Swing框架


实现功能：
- 文件类型支持(Java文件接口，支持软链接，硬链接)
我们使用File类来与操作系统交互。对软链接特殊处理
- 元数据支持（属主、时间权限）
这里的实现同样是使用File类。我们将文件的创建时间、最后修改时间、属主等元数据打包至新文件结构字段中，解包时先创建新文件完成所有解包解密操作，最后修改创建时间，保证last modified time与源文件一致。
- 自定义备份
文件名过滤，指定备份文件位置。
- 压缩解压
我们将打包后的文件看作字节流，对字节出现频率构建Huffman树对文件进行压缩，
- 打包解包 ：将目录下文件按照规则写入同一个文件。
加密解密：使用自定义的映射函数实现
- 实时备份：Java WatchService监听目录变化。
图形界面：Java Swing
- 网络备份：将备份后的本地文件一键上传至网盘 ，借助Alist开源项目实现存放到商业网盘如百度网盘、阿里网盘。

- 构建了跨系统运行的jar包。
- 提供了dockerfile构建脚本，在docker hub提供了测试镜像，并借助x11vnc项目实现docker的GUI展示。
可以使用`docker pull bachwv/docker-desktop:zh_CN`命令下载镜像。

项目目录 https://github.com/BachWV/backup


![demo_wslg](https://s2.loli.net/2022/11/17/MF7LErvhaoye5SD.png)



## 功能

整体功能为备份指定文件夹并还原。

备份过程分为以下几步：

1. 打包（`sourceDir -> sourceDir.pack` ）：将指定文件夹下的文件（普通文件、目录和软链接）打包，可以通过创建 `.bakignore` 文件指定需要过滤的文件。打包目录中如果多个硬链接指向同一份数据，那么该数据只会打包一次，并且还原时也只还原一份，并建立多个指向它的硬链接。
2. 压缩（`sourceDir.pack -> sourceDir.pack.huff`）：使用 Huffman 压缩算法进行压缩。
3. 加密（`sourceDir.pack.huff -> sourceDir.pack.huff.enc` ）：使用一个简单的带混淆机制的加密算法进行加密。

还原过程就是上面过程反过来。

上传至网盘，当然是公共目录。http://120.24.176.162:5244/aliyun/pantest

## 编译运行

本项目使用 Maven 构建。
编译：

```shell
mvn compile
```

运行:

```shell
java -jar backup_lab.jar
```
## docker 运行环境

本项目使用的运行环境 已上传至docker hub

```shell
docker pull bachwv/docker-desktop:zh_CN
```

构建参考
https://github.com/BachWV/x11vnc-desktop/
的zh_CN分支，并使用Github Action打包，直接使用dockerfile打包可能出现问题

使用`python init_desktop.py`运行docker（挂载当前目录至docker中的~/shared目录，在docker中使用`java -jar backup_lab.jar`运行本软件 ）

![image-20221117163256291](https://s2.loli.net/2022/11/17/FSWDYUKEZHPeqIb.png)
