---
title: "Github Actions"
date: 2022-07-16T21:11:48+08:00
draft: false
---

# 起因

最近想到我还有一个用于记录生活的 Hexo 博客需要更新

由于代码在Windows上，而我有时候在manjaro上写作，同步就是一个问题。Git仓库上是`hexo d`直接deploy上去的（因为不想让你们看到md文件）

当然这种问题一般再建一个分支代码，或者咱干脆再建一个 Private 仓库，用 Github Actions 帮助我们构建并提交到另一个仓库，这样本地甚至都不需要node环境（node_modules里面1万多个小文件真让人大头，随机读写爆炸，PMR杀手），这样我们甚至能把github当做hexo前端。

说干就干

# Github actions

我们先了解一下Actions

相当于一个虚拟vps，你可以使用它的Windows，linux，macOS环境跑任意的程序，比如某校每天需要定时体温打卡，你有一段Python脚本需要定时执行，上一篇中推荐了cron，当然你可能不放心自己的机子会不会出故障，相比之下github服务器出故障的概率就小很多，就算Github遇到像哔哩哔哩的SLB挂了的情况，也丝毫不影响定时Actions的执行。又比如你需要构建Android应用没有环境，需要构建flutter应用没有flutter环境，需要构建Swift应用而又没有mac，都可以使用Actions。



Github以你的仓库的.github/workflow目录下的yml文件为指示，按照该yml文件指示的执行。

一个workflow可以创建一个或多个job，job都是并发执行的并不是按照申明的先后顺序执行的， 如果多个job 之间存在依赖关系，那么你可能需要使用 needs 。

一个job可以有一个或多个step，每个step可以执行多条命令。

新建一个仓库，将本地的hexo文件夹内容push上去。再新建一个workflow，具体将在下面例子中解释。

```yml
# workflow name
name: Hexo Blog CI

# master branch on push, auto run
on: 
  push: #触发条件push GitHub Actions 也支持外部事件触发，或者定时运行。
    branches:
      - master
      
jobs:
  build: 
    runs-on: ubuntu-latest # 运行在最新版本Ubuntu
        
    steps:
    # check it to your workflow can access it
    # from: https://github.com/actions/checkout
    - name: Checkout Repository master branch
      uses: actions/checkout@master # 表示使用别人预先设置好的actions
      
    # from: https://github.com/actions/setup-node  
    - name: Setup Node.js 12.x 
      uses: actions/setup-node@master 
      with:
        node-version: "12.x" # 这个是steps可能需要的参数，node版本12.x
    
    - name: Setup Hexo Dependencies # 装一波hexo-cli
      run: |
        npm install hexo-cli -g
        npm install --force
    
    - name: Setup Deploy Private Key # 设置私钥 600=11000000B
      env:
        HEXO_DEPLOY_PRIVATE_KEY: ${{ secrets.HEXO_DEPLOY_PRIVATE_KEY }} #env给step配置环境变量
      run: |
        mkdir -p ~/.ssh/
        echo "$HEXO_DEPLOY_PRIVATE_KEY" > ~/.ssh/id_rsa 
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan github.com >> ~/.ssh/known_hosts
        
    - name: Setup Git Infomation
      run: | 
        git config --global user.name 'yourname' 
        git config --global user.email 'youremail'
    - name: Deploy Hexo 
      run: |
        hexo clean
        hexo generate 
        hexo deploy

```



这时需要我们把私钥写入HEXO_DEPLOY_PRIVATE_KEY这个环境变量。

在仓库设置settings的secrets里新建actions变量，注意，这里的名称要填`HEXO_DEPLOY_PRIVATE_KEY`

![image-20220716230625530](https://raw.githubusercontent.com/BachWV/PicGo/master/image-20220716230625530.png)

这样提交到仓库就不需要密码了，Windows、linux的私钥一般在~/.ssh/id_rsa里。

到此就配置结束了，每次 push 都会触发actions，我们可以在actions里查看运行情况

![image-20220716230657527](https://raw.githubusercontent.com/BachWV/PicGo/master/image-20220716230657527.png)

# 问题

### 问题1

action执行失败卡在deploy

```
 fatal: could not read Username for 'https://github.com': No such device or address
FATAL {
  err: Error: Spawn failed
```

这个问题太奇怪；我一直以为是我用户名没打对，或者私钥错了，最后发现是仓库要用

git@github.com而不能用https://github.com

```yml
deploy:
  type: git
  repo: git@github.com:username/repo.git #true
  repo: https://github.com/username/repo.git #false
```



### 问题2

`hexo deploy`是强制推送的，会覆盖我原来的提交，这样我似乎在Hexo pages仓库只有两个提交记录，一个是init，一个是最新的提交

当执行 `hexo deploy` 时，Hexo 会将 `public` 目录中的文件和目录推送至 `_config.yml` 中指定的远端仓库和分支中，并且**完全覆盖**该分支下的已有内容。

哦，但是我的CNAME去哪了，把`ls pubilc`加入jobs检查CNAME是在public里面啊。

然后看到官方文档

>此外，如果您的 Github Pages 需要使用 CNAME 文件**自定义域名**，请将 CNAME 文件置于 `source` 目录下，只有这样 `hexo deploy` 才能将 CNAME 文件一并推送至部署分支。

温馨提示：如非必要，别用--force



### 扩展

上一期提到了crontab这个工具，workflow也支持时间触发，使用的语法，就是上一期提到的POSIX cron语法

You can use `on.schedule` to define a time schedule for your workflows. You can schedule a workflow to run at specific UTC times using [POSIX cron syntax](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html#tag_20_25_07). Scheduled workflows run on the latest commit on the default or base  branch. The shortest interval you can run scheduled workflows is once  every 5 minutes.

This example triggers the workflow every day at 5:30 and 17:30 UTC:

```yaml
on:
  schedule:
    # * is a special character in YAML so you have to quote this string
    - cron:  '30 5,17 * * *'
```

甚至可以支持更复杂的情况：

A single workflow can be triggered by multiple `schedule` events. 

You can access the schedule event that triggered the workflow through the `github.event.schedule` context. This example triggers the workflow to run at 5:30 UTC every Monday-Thursday, but skips the `Not on Monday or Wednesday` step on Monday and Wednesday.

```yaml
on:
  schedule:
    - cron: '30 5 * * 1,3'
    - cron: '30 5 * * 2,4'

jobs:
  test_schedule:
    runs-on: ubuntu-latest
    steps:
      - name: Not on Monday or Wednesday
        if: github.event.schedule != '30 5 * * 1,3'
        run: echo "This step will be skipped on Monday and Wednesday"
      - name: Every time
        run: echo "This step will always run"
```

https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
