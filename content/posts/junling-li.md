---
title: "junling.li"
date: 2022-08-09T16:00:12+08:00
draft: false
---

今天心血来潮注册了junling.li

?? copilot 已经如此智能了吗？

![smart-copilot](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_17-50-15.png)

整个过程很顺利，首先是尝试了一家 瑞士的注册商叫 [metanet](https://www.metanet.ch)，我嫌他太慢了，而且没有能付chz的卡。冲浪时看到 https://jun.li/tech/202.html 下面的评论，发现 https://gandi.net可以注册，而且可以支付宝，有中文页面，遂付了98大洋注册。

之后改一下默认dns到dnspod.cn,

?? 过于智能了

![smart-copilot](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_17-59-12.png)

就遇到了当初一样的备案问题，先不说备案的要花时间和精力，`.li.`能不能备案都是一个问题，所以想到了

?? 
![smart-copilot](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_18-02-44.png)

看来copilot提供的解决方案简单粗暴。
事实上我想用 vercel 加速 Github pages，这样

??听君一席话??
![smart-copilot](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_18-08-00.png)

这样就直接把 junling.li cname到 vercel给的域名或者a记录到vercel服务器ip，就跳过了备案。

vercel的操作远远比我想的要简单，添加github仓库
![](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_18-13-37.png)

自动选择hugo，点击部署
![](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/Snipaste_2022-08-09_18-14-31.png)

设置a记录，结束！

整个过程不超过5分钟

至此，Blog 已经“一键”搬到 junling.li了，还免去了配置ssl证书

在junling.xyz过期以后，咱也能通过 junling.li在找到我了。

历史：

本文最初选择的metanet.ch的.ch是瑞士的顶级域名，ch是取自这个瑞士的拉丁文名字Confoederatio Helvetica (Helvetic (Swiss)Confederation)（所有瑞士的硬币上都标有这个名字）。瑞士使用最广泛的语言是德语，所以发我的邮件都是德语，hhh。瑞士3w平方千米，人口约870w，东南是阿尔卑斯山脉，铁路里程5000km，有世界上最长的隧道。因为马前卒今天恰巧说到了瑞士。

.li是列支敦士登的顶级域名，160.5平方公里，人口3w，是澳门的1/10，人口不及中国一个镇。按理说不值得我关心，但还是挺有意思的：
2011年，列支敦士登决定将允许出租整个国家，每晚租金是4万英镑（约42.5万人民币）。该国的临时“拥有者”会在议会仪式上得到一把象征性的钥匙，然后就可以使用土地，甚至调用当地警察。 

盘点历史买过的域名
 uest.xyz 2021-3-15 godaddy
 lijunling.xyz 2019-08-25 阿里云	
bestboyofuestc.xyz 2019-08-24 阿里云（万网
IAMAPPALLED.TODAY 2017-8-17 godaddy
