---
title: "UESTC-电费余额"
date: 2022-08-31T22:09:23+08:00
---

众所周知，四川在今年夏天遭受了严重的缺电危机。为了保障居民用电，许多工业企业停电长达一周，写字楼、地铁也关了空调。春熙路关闭了外灯。

某高校的寝室电费高达10元/每天。作为留守儿童，常常50元的电费5天就用完了。每个月的额度根本不够用。

今天在微信公众号乱逛的时候，发现了一个查询UESTC寝室用电量的接口。相比于支付宝仅仅能查询余额，多了一个查询用电量的功能。

https://wx.uestc.edu.cn/oneCartoon/index.html?code=9fa9fa82ac76ea8d9703c948f4f6eba7



当然查询也非常的简单，只需要
用Chrome的开发者工具，来看看点下搜索键以后发生了什么。

向[这个url](https://wx.uestc.edu.cn/power/oneCartoon/list)发送了一个post请求，body为"roomCode=cep4NgTh7AgzjAeoLsMElQ=="
当然这个编号是经过加密的。

我试了BASE64,BASE62,BASE100都不是，查看源码发现一个power.js，发现里面内置了各种加密的库。

前端的这个加密index.js是混淆过的，由于我前端也没会多少，很难看出是怎么调用power.js的。虽然不影响咱们查询需要的房间号，但源码之上无事可做可真让人难受。

下一步吧，做一个自动化的查询工具，帮我们自动发送post请求就好。

查看一下请求头(Header)

```
OST /power/oneCartoon/list HTTP/1.1
Accept: application/json, text/javascript, */*; q=0.01
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9
Connection: keep-alive
Content-Length: 37
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Cookie: UM_distinctid=182cfbdf0487ee-0cb4448310dd45-26021d51-240000-182cfbdf04913f3; iPlanetDirectoryPro=bclskTTZD3XboNv2eZmD6l
Host: wx.uestc.edu.cn
Origin: https://wx.uestc.edu.cn
Referer: https://wx.uestc.edu.cn/oneCartoon/index.html?code=9fa9fa82ac76ea8d9703c948f4f6eba7&account=2019081305013
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36
X-Requested-With: XMLHttpRequest
sec-ch-ua: "Chromium";v="104", " Not A;Brand";v="99", "Google Chrome";v="104"
sec-ch-ua-mobile: ?0
sec-ch-ua-platform: "Windows"
```

通过我简单的二分发现只有
```Content-Type: application/x-www-form-urlencoded; charset=UTF-8```这一行是有用的，它指明了body的编解码格式。

body只有一个
`roomCode=cep4NgTh7AgzjAeoLsMElQ==`

看看服务器返回我们什么：
```json
{
    "data":{
        "retcode": "0",
        "areaId": null,
        "buiId": "43",
        "roomId": "7240",
        "roomName": "120335",
        "sydl": "75.05",
        "syje": "40.26",
        "msg": "查询成功"
    },
    "httpCode": 200,
    "msg": "请求成功",
    "timestamp": 1661950340964
}
```
算得上是非常好读了，sydl是还剩多少度电，syje是还剩多少钱。

作为Java用户。下面就是用熟练的方式发送这个请求。

咱们上一次在matu的[怎么有人用码图啊]({{< relref "怎么有人用码图啊.md" >}})中使用了jsoup，这次我们用OKhttp这个库来试试。

核心代码如下：没有考虑到出错处理，请大家轻拍。

```java
public static Response ppp(String url) throws IOException {

        //创建OkHttpClient对象
        OkHttpClient client = new OkHttpClient();
        RequestBody requestBody=RequestBody.create("roomCode=cep4NgTh7AgzjAeoLsMElQ%3D%3D",MediaType.parse("application/x-www-form-urlencoded; charset=UTF-8"));
        //创建Request
        Request request = new Request.Builder()
                .url(url)//访问连接
                .post(requestBody)
                .addHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")
                .build();
        //创建Call对象
        Call call = client.newCall(request);
        //通过execute()方法获得请求响应的Response对象
        Response response = call.execute();
        return response;
}
 public static String dianfei() throws IOException {
        Response r = OkHttpUtils.ppp("https://wx.uestc.edu.cn/power/oneCartoon/list");
        String ans = r.body().string();
        JSONObject ele = new JSONObject(ans);
        JSONObject data = ele.getJSONObject("data");
        try {
            String syje = data.getString("syje");
            String sydl = data.getString("sydl");
            return "Last count:" + syje + "CNY\n Last power:" + sydl + "kwh";
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }
```

作为一个mirai机器人选手，自然少不了通过群聊的方式查询功能。

我们在qq群聊中监听查询请求（这里直接指定群聊），调用上述函数，即可完成实时查询电费。以下是效果：

![效果图](https://charon-pic.oss-cn-hangzhou.aliyuncs.com/QQ%E5%9B%BE%E7%89%8720220831211457.png)

这个项目还是有遗憾的地方，目前roomcode的构建方式还知道，只能通过开发者工具看看前端计算的roomcode。目前来说，这个机器人只能查询咱们寝室的电费。实在是太逊了。不然咱直接在公众号做一个接口，就叫成电查电费。