---
title: "Zeller"
date: 2022-01-03T00:57:54+08:00
draft: false
tags: [                   
    "Leetcode",
   "Easy"
]
---

蔡勒公式
$$ {\displaystyle w=\left(y+\left[{\frac {y}{4}}\right]+\left[{\frac {c}{4}}\right]-2c+\left[{\frac {26(month+1)}{10}}\right]+day-1\right){\bmod {7}}}$$
公式中的符号含义如下：

w：{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
c：$${\frac {year}{100}}$$；
y：$$year \bmod {100}$$

注意：month的取值范围为3至14，如果月份数是1、2月要看作上一年的13、14月来计算，比如2000年2月29日要看作1999年的14月29日来计算



>#### [1185. 一周中的第几天](https://leetcode-cn.com/problems/day-of-the-week/)
>
>给你一个日期，请你设计一个算法来判断它是对应一周中的哪一天。
>
>输入为三个整数：`day`、`month` 和 `year`，分别表示日、月、年。
>
>您返回的结果必须是这几个值中的一个 `{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}`。
>
> 
>
>**示例 1：**
>
>```
>输入：day = 31, month = 8, year = 2019
>输出："Saturday"
>```
>
>**示例 2：**
>
>```
>输入：day = 18, month = 7, year = 1999
>输出："Sunday"
>```
>
>**示例 3：**
>
>```
>输入：day = 15, month = 8, year = 1993
>输出："Sunday"
>```
>
>

```java
class Solution {
    public String dayOfTheWeek(int day, int month, int year) {
        String []ans={"Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
        if(month<=2){
            month+=12;
            year--;
        }
        int y=year%100,c=year/100; 
        int week=y+y/4+c/4-2*c+26*(month+1)/10+day-1+70;
        return ans[week%7];
    }
}
```

