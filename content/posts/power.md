---
title: "UESTC-电费查询"
date: 2022-09-02T22:09:23+08:00
---

众所周知，四川在今年夏天遭受了严重的缺电危机。为了保障居民用电，许多工业企业停电长达一周，写字楼、地铁也关了空调。春熙路关闭了外灯。

某高校的寝室电费高达10元/每天。作为留守儿童，常常50元的电费5天就用完了。每个月的额度根本不够用。

前几天在微信公众号乱逛的时候，发现了一个查询UESTC寝室用电量的接口。相比于支付宝仅仅能查询余额，多了一个查询用电量的功能。

https://wx.uestc.edu.cn/oneCartoon/index.html?code=9fa9fa82ac76ea8d9703c948f4f6eba7


当然查询也非常的简单，只需要
用Chrome的开发者工具，来看看点下搜索键以后发生了什么。

~向[这个url](https://wx.uestc.edu.cn/power/oneCartoon/list)发送了一个post请求~，body为"roomCode=cep4NgTh7AgzjAeoLsMElQ=="
当然这个编号是经过加密的。

**2024-11-29** 该接口已经被弃用，以下内容均无效。我立刻又发现了一个接口：https://eportal.uestc.edu.cn/qljfwapp/sys/lwUestcDormElecPrepaid/dormElecPrepaidMan/queryRoomInfo.do

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
`Content-Type: application/x-www-form-urlencoded; charset=UTF-8`这一行是有用的，它指明了body的编解码格式。

body只有一个
`roomCode=cep4NgTh7AgzjAeoLsMElQ==`

这一个加密是怎么来的，已经迷糊了我一天了？

当然我们可以不用管，直接看看服务器返回我们什么：
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

![power-3.png](https://s2.loli.net/2022/09/06/5IXfiNeCapFMxHK.png)

这个项目还是有遗憾的地方，目前roomcode的构建方式还知道，只能通过开发者工具看看前端计算的roomcode。目前来说，这个机器人只能查询咱们寝室的电费。实在是太逊了。

但是经过一天的猜想和学习。

我学废了nodejs，可以直接用node发送请求
```js
function SendRequest(datatosend) {
    function OnResponse(response) {
        var data = '';

        response.on('data', function(chunk) {
           
             
            data += chunk; //Append each chunk of data received to this variable.
        });
        response.on('end', function() {
            
            var jsonParsed = JSON.parse(data);
           // console.log(data);
            var vals=jsonParsed['data']
            var roomName=vals['roomName']
            var dl=vals['sydl']
            var je=vals['syje']
            console.log("房间号："+roomName+"\n剩余电量："+dl+"kWh\n剩余金额："+je+"元"); //Display the server's response, if any.
        });
    }

    var request = http.request(urlparams, OnResponse); //Create a request object.

    request.write(datatosend); //Send off the request.
    request.end(); //End the request.

}
SendRequest("roomCode="+crynum); //Execute the function the request is in.
}
```

既然nodejs入门了（不是），那我们是不是能看懂加密的过程了

我灵机一动，看到index.js里roomCode

`{roomcode:_0x477250[_0x33e7('0x213','zw!i')](encrypt,_0x1e1aee)}`

虽然我啥都不知道它干了啥，但是在控制台上输入encrypt("120335")，然后就给我打印了`cep4NgTh7AgzjAeoLsMElQ==`

这真是振奋人心的好结果。当然我也找到了函数原型，嗯谁能看懂？

```js
function encrypt(_0x461dd2) { var _0xc95c0 = {};
 _0xc95c0[_0x33e7('0x1e7', 'W[(T')] = _0x33e7('0x1c9', '3iDq');
  var _0x2c854d = _0xc95c0; 
  var _0x29656e = CryptoJS[_0x33e7('0x362', 'x3AB')][_0x33e7('0x14a', 'MQfJ')][_0x33e7('0x217', 'e$AE')](_0x2c854d[_0x33e7('0x20c', 'B9iG')]); 
  var _0x113ce7 = CryptoJS[_0x33e7('0x289', 'wvF(')][_0x33e7('0x299', 'b7w3')][_0x33e7('0x12f', '66GX')](_0x461dd2); 
  var _0x5c922b = CryptoJS[_0x33e7('0x24d', 'U&UX')][_0x33e7('0x90', 'gln^')](_0x113ce7, _0x29656e, { 
    'mode': CryptoJS[_0x33e7('0x130', 'gln^')][_0x33e7('0x13f', 'MQfJ')], 
    'padding': CryptoJS[_0x33e7('0xd8', '[0J^')][_0x33e7('0x2f', 'n$4Y')] 
    }); 
  return _0x5c922b[_0x33e7('0x243', 'jc)R')](); 
} 
```

经过我好几天的逆向(实际上是一晚上)
```js
function encrypt(_0x461dd2) { var _0xc95c0 = {};

  var _0x29656e = CryptoJS['enc']['Utf8']['parse']('wxUESTCpowerqwer'); 
  var _0x113ce7 = CryptoJS['enc']['Utf8']['parse'](_0x461dd2); 
  var _0x5c922b = CryptoJS['AES']['encrypt'](_0x113ce7, _0x29656e, { 
    'mode': CryptoJS['mode']['ECB'], 
    'padding': CryptoJS['pad']['Pkcs7'] 
    }); 
  return _0x5c922b['toString'](); 
} 
```
其实就是crypto-js的第一个示例代码,aseKey是'wxUESTCpowerqwer'，有了密钥能做的事情就很多了
```js
const CryptoJS  = require('crypto-js');
function cryptoEncryption(aseKey,message){ //aseKey为密钥（必须为：8/16/32位），message为要加密的密文
  var encrypt = CryptoJS.AES.encrypt(message,CryptoJS.enc.Utf8.parse(aseKey),{
    mode:CryptoJS.mode.ECB,
    padding:CryptoJS.pad.Pkcs7
  }).toString();
  return encrypt
}
var aseKey = 'wxUESTCpowerqwer' 
var encrpytText = "120335";

console.log(cryptoEncryption(aseKey,encrpytText)); //调用加密方法
```
把上述解密和发送post请求合并为一个js文件，添加控制台传入参数，这就很优雅。甚至我们添加了错误处理（警觉）。
![power-wx.png](https://s2.loli.net/2022/09/06/IXYHkhSaOtcZTD9.png)
咱们是否可以通过公众号提供接口，为广大成电水友提供查询服务？

在我飞速阅读了微信公众号平台的文档以后，

使用 Python 快速踩坑（不是),快速起了一个web server。


接收用户输入，经过简单判断是否为房间号，再fork-exec运行nodejs，

微信公众平台的接口可比QQ机器人稳定多了。打通了这一过程还是有不少坑的。

只需要向公众号的后台发送房间号，就可以看到电费使用情况了。

![power-node.jpg](https://s2.loli.net/2022/09/06/86oSvPNWcJH4f97.jpg)

欢迎关注我在微信平台的号哦（疯狂引流

![](https://s2.loli.net/2021/12/04/9waly3vRBjW7Y28.jpg)

附上python
```
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import requests
import json
import time
import os
import urllib


def send_power(msgs):
    aseKey = 'wxUESTCpowerqwer' 
    try:
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', #Specifying to the server that we are sending JSON 
        }
        key = "wxUESTCpowerqwer"

        def aes_ecb_encrypt(plaintext):
            cipher = AES.new(key.encode(),AES.MODE_ECB)
            return b64encode(cipher.encrypt(pad(plaintext.encode(),16)))


        def aes_ecb_decrypt(ciphertext):
            cipher = AES.new(key.encode(),AES.MODE_ECB)
            return unpad(cipher.decrypt(b64decode(ciphertext.encode())),16).decode()
        print(msgs)
        encryptStr=aes_ecb_encrypt(msgs)
        print(encryptStr)
        ss=str(encryptStr, encoding = "utf-8")  
        send_msg="roomCode="+urllib.parse.quote(ss)
        
        print(send_msg)
        #response = requests.post('https://api.openai.com/v1/chat/completions', headers=headers, json=json_data,timeout=14.2)
        response = requests.post('https://wx.uestc.edu.cn/power/oneCartoon/list', headers=headers, data=send_msg,timeout=4.2)
        response_parse = json.loads(response.text)
        data=response_parse["data"]
        roomName=data['roomName']
        dl=data['sydl']
        je=data['syje']
        return "房间号："+roomName+"\n剩余电量："+dl+"kWh\n剩余金额："+je+"元" 
    except Exception as e:
        print(e)
        return '请求超时，请稍后再试！'
```