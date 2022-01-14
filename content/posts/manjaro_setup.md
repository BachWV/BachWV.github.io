---
title: "Manjaro Setup"
date: 2022-01-13T22:57:54+08:00
draft: false
---

Manjaro 的一些安装经验吧

首先进bios，解除security，然后进boot menu，把首选启动项改成uefi
进入u盘安装
然后是分区，我先在windows压缩D盘空了60G空间，在manjaro里面把这个空间给它


软件方面是飞书，用pacman下载yay，然后yay feishu安装5.2版本的飞书
debtop实在是没有成功解包，debtop还是从github上clone了原仓库，yay也是clone原仓库下来的

第二个是输入法

三步走



```sudo pacman -S fcitx
sudo pacman -S fcitx-configtool
sudo pacman -S fcitx-gtk2 fcitx-gtk3
sudo pacman -S fcitx-qt4 fcitx-qt5
sudo pacman -S fcitx-sogoupinyin
```
这样是不行的，因为fcitx-sogoupinyin在pacman上找不到，还得用yay fcitx-spigoupinyin
最后
`sudo echo -e "export GTK_IM_MODULE=fcitx\n export QT_IM_MODULE=fcitx\n export XMODIFIERS=@im=fcitx" >>~/.xprofile`
就完事，因为需要`~/.xprofile`配置文件，然后重启就好了


第三个是tim，这个只能通过wine来达到最好的体验，注意要调分辨率，
`env WINEPREFIX="$HOME/.deepinwine/Spark-TIM" deepin-wine5 winecfg`
在弹出的窗口中改dpi，我觉得2k屏改成200dpi左右比较合适

