---
title: "kaggle"
date: 2022-09-12T22:00:12+08:00
draft: false
---


kaggle的经历因为人工智能应用与挑战课程。这门课根据比赛排名来确定部分平时分数。

一个给宠物照片打分的比赛，所以咱们有队友。

## 项目概况简介

**竞赛题目：**PetFinder.my – Pawpularity Contest

**竞赛类型：**Research Code Competition

**开始时间：**2021.9.23

**结束时间：**2022.1.6

**竞赛地址：**https://www.kaggle.com/c/petfinder-pawpularity-score/

**竞赛内容：**

PetFinder.my是一个宠物收容网站。用户上传宠物的照片使用https://www.petfinder.my/cutenessmeter 的方法来预测宠物照片的受欢迎程度。

**要求：**

分析原始图像和元数据来预测宠物照片的“Pawpularity”。 对于测试集中的每个，预测目标图片的Pawpularity

**结果：**

截至22年1月1日，排名为46/3027，RSME为17.7948，有几率获得银牌

![img](https://s2.loli.net/2022/09/12/5nLQVDAFsTytJkh.jpg)





我们使用的是swin_large_patch4_window7_224_22kto1k（开源预训练模型）

swin是微软亚洲研究院去年3月提出的transformer，通过引入CNN中常用的层次化构建方式构建层次化Transformer以及引入locality思想解决transformer迁移至CV上的scale和分辨率的问题

![image-20220912230441358](https://s2.loli.net/2022/09/12/b26u1H5OeGnoNcq.png)

接下来就是调参了，最后的结果还是很不错滴。

| **模型及参数**                                               | **RMSE** |               **排名** |
| ------------------------------------------------- | ------------------- | -------- |
| **决策树模型**                                               | 20.48770  | 1929     |
| **RAPIDS SVR Boost**                                         | 18.02751 | 762      |
| **Swin transformer模型Batch size=32，n fold=10** | 17.94193  | 411      |
| **Batch  size=8，n fold=5**                          | 17.90508  | 291      |
| **Batch size=8，n fold=8**                           | 17.83858   | 106      |
| **Batch size=8，n fold=7**                           | 17.81823   | 66       |
| **Batch size=8，n fold=7更改seed**          | 17.79984 | 46       |

好吧，transform不是用在nlp的吗？怎么能做cv了？

先复习一下Transformer吧

Attention is all you need.

Input->Encoders -> Decoders ->Output

![image-20220913002229648](https://s2.loli.net/2022/09/13/ipegXqBlhcJIFnL.png)

encoder 部分：

![image-20220913002801696](https://s2.loli.net/2022/09/13/mQYJiO374BCcWX8.png)

输入部分

- embedding
- 位置嵌入

### 位置编码

为什么需要位置编码？

以rnn为例，需要时序关系，需要单词之间的先后顺序。

位置编码公式

$$PE_{pos,2i}=\sin(pos/1000^{2i/d_{model}})$$

$$PE_{pos,2i}=\cos(pos/1000^{2i/d_{model}})$$



-------------
更多内容正在施工中