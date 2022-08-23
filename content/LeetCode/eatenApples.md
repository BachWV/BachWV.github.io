---
title: "Merry Christmas"
date: 2021-12-24T19:55:00+08:00
draft: false
---


>#### [1705. 吃苹果的最大数目](https://leetcode-cn.com/problems/maximum-number-of-eaten-apples/)
>
>难度中等
>
>有一棵特殊的苹果树，一连 `n` 天，每天都可以长出若干个苹果。在第 `i` 天，树上会长出 `apples[i]` 个苹果，这些苹果将会在 `days[i]` 天后（也就是说，第 `i + days[i]` 天时）腐烂，变得无法食用。也可能有那么几天，树上不会长出新的苹果，此时用 `apples[i] == 0` 且 `days[i] == 0` 表示。
>
>你打算每天 **最多** 吃一个苹果来保证营养均衡。注意，你可以在这 `n` 天之后继续吃苹果。
>
>给你两个长度为 `n` 的整数数组 `days` 和 `apples` ，返回你可以吃掉的苹果的最大数目*。*
>
>
>
>**示例 1：**
>
>```
>输入：apples = [1,2,3,5,2], days = [3,2,1,4,2]
>输出：7
>解释：你可以吃掉 7 个苹果：
>- 第一天，你吃掉第一天长出来的苹果。
>- 第二天，你吃掉一个第二天长出来的苹果。
>- 第三天，你吃掉一个第二天长出来的苹果。过了这一天，第三天长出来的苹果就已经腐烂了。
>- 第四天到第七天，你吃的都是第四天长出来的苹果。
>```
>
>**示例 2：**
>
>```
>输入：apples = [3,0,0,0,0,2], days = [3,0,0,0,0,2]
>输出：5
>解释：你可以吃掉 5 个苹果：
>- 第一天到第三天，你吃的都是第一天长出来的苹果。
>- 第四天和第五天不吃苹果。
>- 第六天和第七天，你吃的都是第六天长出来的苹果。
>```
>
>
>
>**提示：**
>
>- `apples.length == n`
>- `days.length == n`
>- `1 <= n <= 2 * 104`
>- `0 <= apples[i], days[i] <= 2 * 104`
>- 只有在 `apples[i] = 0` 时，`days[i] = 0` 才成立

4个月之前尝试过这一题，然后失败了，趁着圣诞节，再吃一颗苹果吧。



本题给了两个数组，一个是每天生成的苹果数量apples[i]，另一个是那天生成苹果的腐烂日期days[i]。

很自然地，如果某一天想吃苹果，那么苹果必定没有腐烂，如果有一个表或者其他的什么东东能告诉我苹果有没有腐烂就好了。

这时想到键值对，对于每天生成的苹果，记录一个腐烂截止日期，再记录苹果数。再将这个键值对排序，每次取最近腐烂但是还没腐烂的苹果吃。

这就需要小根堆了，Java中是[优先队列]({{< ref "/posts/优先队列.md" >}})。

具体实现上，分为两个阶段，在小于n（n是apples数组的长度）的日子里，每天产生苹果，将其入队，并且看看有没有腐烂的苹果，将其出队，再看看有没有能吃到的苹果，把它吃掉；大于n的日子，由于不产生苹果，就只有清理腐烂的苹果和吃苹果这两件事要做了。

```java
public static int eatenApples(int[] apples, int[] days) {

        PriorityQueue<int[]> q = new PriorityQueue<>(new Comparator<int []>() {
            @Override
            public int compare(int[] o1, int[] o2) {
                return o1[0] - o2[0];
            }
        });
        int len=apples.length;
        int eat=0;
        int []nn;
        for(int i=0;i<len;i++){
            if(apples[i]!=0) {
                q.add(new int[]{i+days[i]-1,apples[i]});
               // System.out.println("add"+q.peek()[0]+" "+q.peek()[1]);
            }
            
            while(!q.isEmpty()&&(q.peek()[0]<i||q.peek()[1]<=0)){
                System.out.println("poll "+q.peek()[0]+" "+q.peek()[1]);
                q.poll();//清理过期苹果and小于0的苹果数
            }
            //eat
            if(!q.isEmpty()){
                nn=q.poll();

                nn[1]--;
                eat++;
                q.add(nn);
                //System.out.println("i="+i+" eat="+eat+" nn[0]="+nn[0]+" nn[1]="+nn[1]+" "+q);
            }
        }
        for(int i=len;!q.isEmpty();i++) {
            while(!q.isEmpty()&&(q.peek()[0]<i||q.peek()[1]<=0)){
               // System.out.println("poll "+q.peek()[0]+" "+q.peek()[1]);
                q.poll();//清理过期苹果and小于0的苹果数
            }
            //eat
            if(!q.isEmpty()){
                nn = q.poll();
                nn[1]--;
                eat++;
                q.add(nn);
            }
        }
        return eat;
    }

```



| 遥远遥远的以后 会不会有人知道我

| 在这个寂寞的星球 曾这样的活过

| 遥远遥远的以后 天长和地久的尽头

| 应该没有人能抢走 我永远的感动



![img](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fy.gtimg.cn%2Fmusic%2Fphoto_new%2FT023R750x750M000000WAmM8047hmV.jpg%3Fmax_age%3D2592000&refer=http%3A%2F%2Fy.gtimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642940486&t=1e74bb359b4dca6fb9d3898341b70b96)



| 活着不多不少 幸福刚好够用

| 活着其实很好 再吃一颗苹果
