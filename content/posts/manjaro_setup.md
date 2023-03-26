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

Matlab R2016b安装
参考https://www.cnblogs.com/lvchaoshun/p/9746155.html安装
和https://blog.csdn.net/weixin_42598278/article/details/113562238更换中文字体



wps:

```
yay wps-office-cn
```

注意，安装以后可能会出现字体发虚的问题

### KDE下dpi不对称导致的字体模糊

wps office默认设置dpi为96。但是当kde DPI非96时，会强制修改wps的dpi导致字体模糊

此时只需要在wps（包括wps,wps文字，wps表格，wps演示，wpsPDF）的desktop文件中第四行的Exec添加QT_SCREEN_SCALE_FACTORS=1 即可。如：

```
Exec= env QT_SCREEN_SCALE_FACTORS=1 /usr/bin/wps %U
Exec= env QT_SCREEN_SCALE_FACTORS=1 /usr/bin/wpp %F
```

https://wiki.archlinux.org/title/WPS_Office_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)



最近22/5/15看到一篇挺不错的安装配置教程，分享一下。话说我自己已经回到Windows了

https://www.freesion.com/article/71911164761/

