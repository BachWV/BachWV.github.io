---
title: "我的BB && memos改造"
date: 2025-04-09T16:41:56+08:00
draft: false
---
我的BB也就是左边，可以用来写一些小笔记，或者一些想法。当然他还有一些问题，没有达到理想状态。

![](https://r2.csapp.fun/2025/04/20250409200058.png)
今天将memos的存储从本地移到了Cloudflare R2上，因为对怕阿里云服务器到期忘记续费，导致数据丢失。所以将自己所有的数据都迁移到Cloudflare的S3存储桶上。

很简单，官方给出了[教程](https://www.usememos.com/docs/advanced-settings/cloudflare-r2)，只要把服务器映射的文件夹一整个搬到Cloudflare设置的目录就行了。


他会自动在s3存储或者本地寻找asserts附件。

尝试把sqlite数据库文件也放到Cloudflare上，结果发现爆炸了。
```log
2025/04/09 09:00:30 ERROR failed to migrate database !BADKEY="SQL logic error: no such table: migration_history (1)\nfailed to find migration history\ngithub.com/usememos/memos/store/db/sqlite.(*DB).Migrate\n\t/backend-build/store/db/sqlite/migrator.go:49\nmain.init.func1\n\t/backend-build/bin/memos/main.go:54\ngithub.com/spf13/cobra.(*Command).execute\n\t/go/pkg/mod/github.com/spf13/cobra@v1.8.0/command.go:987\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\t/go/pkg/mod/github.com/spf13/cobra@v1.8.0/command.go:1115\ngithub.com/spf13/cobra.(*Command).Execute\n\t/go/pkg/mod/github.com/spf13/cobra@v1.8.0/command.go:1039\nmain.Execute\n\t/backend-build/bin/memos/main.go:104\nmain.main\n\t/backend-build/bin/memos/main.go:194\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:271\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1695"
---
Server profile
version: 0.20.1
data: /var/opt/memos
dsn: /var/opt/memos/memos_prod.db
addr: 
port: 5230
mode: prod
driver: sqlite
frontend: true
---
```

看来sqlite文件还得定期备份。

看来今天得好好整一下memos了。我发现之前memos的网页是使用vercel反向代理的，会有一些跨域的小问题，现在改成 cloudflare的 [tunnel]({{< relref "posts/synology-cloudflare.md" >}})了。


## 美化

现在的ui还是23年8月抄immmm的，有点丑了，还好他更新了新的静态前端https://immmmm.com/memobbs-app/
只不过memos要降级18.0.2，这个简单，`docker pull ghcr.io/usememos/memos:0.18.2`
按照他教程的步骤，搞定以后的效果是这样啦。
![](https://r2.csapp.fun/2025/04/20250409195900.png)

还留下一个问题，Post Links侧边栏一直在最下方，和当时movies一样，花了1小时也没办法解决，看起来是css冲突了。到现在还是没有解决好。
