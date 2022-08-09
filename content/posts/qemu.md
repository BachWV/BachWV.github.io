---
title: "Qemu"
date: 2022-07-28T14:05:38+08:00
draft: true
---

qemu入门

报错

# QEMU

QEMU是一款开源的模拟处理器，课程使用它来进行X86仿真。强烈建议使用MIT提供的魔改版。

```shell
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
```

模拟一下loongson

```
qemu-system-loongarch64 \
          -nographic \
          -serial mon:stdio \
          -m 1024 \
          -kernel vmlinuz \
          -initrd build/initramfs.cpio.gz \
          -append "console=ttyS0 quiet acpi=off"
   BOOTROM=0x110000000 SIMPLEVGA=800x600-16:0x0e800000 ./qemu-system-loongarch64 -M ls2k -bios ./gzrom.bin -kernel ./vmlinuz  -serial stdio -m 4096 -s -monitor tcp::1235,server,nowait -netdev user,id=n1,net=10.20.41.0/24,host=10.20.41.50,tftp=/srv/tftp/  -device pci-synopgmac,netdev=n1 -usb -smp 1 
   
```



## 编译QEMU

代码可能比较老了，编译中会出现一些问题。

configure

缺少ninja:`apt install ninja-build`

中间可能会遇到各种报错，此处引用大佬的博客（提及的问题我大部分都遇到了）：

> 1. 问题1：
>    1. 出现：`ERROR: Python not found. Use --python=/path/to/python`
>    2. 解决：添加`--python=python3`，还是不行提示`Note that Python 3 or later is not yet supported`。安装python2.7，然后使用`--python=python2.7`选项。
> 2. 问题2：
>    1. 出现：`ERROR: pkg-config binary 'pkg-config' not found`
>    2. 解决：执行`apt-get install -y pkg-config`
> 3. 问题3：
>    1. 出现：`ERROR: zlib check failed. Make sure to have the zlib libs and headers installed.`
>    2. 解决：执行`sudo apt-get install zlib1g-dev`
> 4. 问题4：
>    1. 出现：`ERROR: glib-2.12 gthread-2.0 is required to compile QEMU`
>    2. 解决：`sudo apt-get install libglib2.0-dev`
> 5. 问题5：
>    1. 出现：`ERROR: pixman >= 0.21.8 not present.`
>    2. 解决：`sudo apt-get install libpixman-1-dev`
> 6. 问题6：
>    1. 出现：`vl.c: In function ‘main’: vl.c:2778:5: error: ‘g_mem_set_vtable’ is deprecated [-Werror=deprecated-declarations] g_mem_set_vtable(&mem_trace); ^ In file included from /usr/include/glib-2.0/glib/glist.h:32:0, from /usr/include/glib-2.0/glib/ghash.h:33, from /usr/include/glib-2.0/glib.h:50, from vl.c:59: /usr/include/glib-2.0/glib/gmem.h:357:7: note: declared here void g_mem_set_vtable (GMemVTable *vtable); ^ cc1: all warnings being treated as errors rules.mak:57: recipe for target 'vl.o' fai·led make: *** [vl.o] Error 1`
>    2. 解决：QEMU源码根目录下的Makefile文件最后加上一行 QEMU_CFLAGS+=-w优化

如果遇到`undefined reference to 'major'`，在报错的源文件中添加`#include <sys/sysmacros.h>`

```
   ./qemu-system-loongarch64 -cdrom ~/loongarchlinux-2022.06.22.1-loongarch64.iso -device qemu-xhci,id=xhci -device qemu-xhci,id=verylongson -device usb-kbd,bus=xhci.0 -device usb-mouse,bus=verylongson.0 -vnc :0 -m 1g -vga virtio -boot a -bios ~/QEMU_EFI.fd
```



![image-20220731212512960](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/image-20220731212512960.png)
