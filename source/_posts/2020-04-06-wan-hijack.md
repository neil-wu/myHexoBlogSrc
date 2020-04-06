---
title: 谁动了我的宽带？记一次HTTP劫持的发现过程
date: 2020-04-06 14:07:43
categories: tech
tags: net
---

日常遇到的劫持一般为DNS劫持，可在路由器里强制指定公共DNS解决。本文记录了自己家用宽带HTTP劫持的发现过程。相比DNS劫持，HTTP劫持更为流氓，解决起来也比较棘手。
<!--more--> 

近来在家上网时，iPhone Safari网页里经常弹出“在手机淘宝中打开连接吗？”的提示框，如下图：
<figure>
    <img src="{{ site.url }}/images/article/wanhijack/hijack.png" style="width:200px;"/>
</figure>
作为一名iOS码农，很自然的知道这是网页在调用淘宝app的 URL Scheme tbopen:// ，这是干什么的呢？当然是淘宝客的推广链接，点了之后打开淘宝去领券，如果你按提示下单了，推广者就能拿到返利。问题在于，网页为什么会发出这种请求，结合当前网站是http的，隐隐觉得可能是被劫持了。下面记录一下排查过程。

### 谁在劫持 ###

先说一下环境，家里宽带是联通百兆，路由器华硕AC86U,刷的梅林（仅开启虚拟内存插件），路由器直接拨号，且当时安装条件限制，家里没有光猫，接线员直接接到了一楼的交换机上。

1. 是网站自己挂的广告吗？
在Wi-Fi下，每次用Safari隐身模式反复访问截图里这个网站，仍会出现这个提示，概率大概30%-40%。切换手机联通4G网络，移动4G，则一次都不会出现。换用电脑Safari和Chrome，也一次不会出现。
结论：仅在iPhone手机端Wi-Fi环境才会出现

2. 是路由器刷的梅林固件导致的吗？
翻箱倒柜找出了以前买的 TPLink-WR700n，就是下图这个小路由器（简直是神器，小巧玲珑，AP和Router模式任意切换），设置好拨号账号密码后换掉华硕继续测试，震惊了，劫持弹窗仍然存在。
<figure>
    <img src="{{ site.url }}/images/article/wanhijack/wr700n.png" style="width:200px;"/>
</figure>
结论：梅林没问题，只能是运营商的锅了。

### 怎样劫持 ###
由于梅林里已经设置DNS为114，排除了DNS劫持。确定是运营商的接入点的问题，接下来就是看看它究竟是怎么劫持的。这里使用Charles抓包iPhone（还没必要祭出Wireshark大杀器）具体设置不在这里讲了，在百度里随机访问网页，待出现劫持时，停止记录，开始分析记录日志。从后往前，找出返回数据里包含 tbopen 的请求。不出意外，很容易就发现了：
<figure>
    <img src="{{ site.url }}/images/article/wanhijack/charles.png"/>
</figure>

原请求为 `http://static.geetest.com/static/js/fullpage.8.9.3.js` ，经过确认，`https://www.geetest.com/`极验，是业界提供安全与风控解决方案的平台，不可能返回 tbopen 这样的数据的。在Charles里复制此http请求的curl命令出来，使用阿里云VPS里进行访问，获取到的则为真实的JS内容。

```
curl -H 'Host: static.geetest.com' -H 'Accept: */*' -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' -H 'Accept-Language: zh-cn' -H 'Referer: http://pass.52pk.com/' --compressed 'http://static.geetest.com/static/js/fullpage.8.9.3.js'
```
使用自己的Mac重放这个curl命令，还是有很高几率被劫持。进一步，修改此请求的User-Agent字段，去掉手机标识符，仅保留为Safari，继续重放，则不会出现被劫持。同时，注意到发生劫持后，有个新的同样的js请求发出，url里多了个参数 `utm_id=1024001`，会返回正确的JS内容，这样做的目的，猜测可能是为了区分请求，好让真正的JS能正常返回不影响网页加载，否则可能出现劫持后再被劫持，无法加载出正确的JS内容。

`至此，整个劫持的过程大致清晰了：联通的接入点会根据UA过滤出移动设备中的http JS请求，然后一定几率返回劫持后的伪JS内容，在里面嵌入淘宝客推广链接。`

劫持的JS内容如下，里面有淘宝客推广链接，建议阿里妈妈的相关人士解决一下？

``` JavaScript
var u = "http://static.geetest.com/static/js/fullpage.8.9.3.js";

function loadjs(a, cla) {
    var c = document.createElement("script");
    c.setAttribute("type", "text/javascript");
    c.setAttribute("src", a);
    if (typeof cla === "string") {
        c.setAttribute("class", cla)
    }
    c.setAttribute("charset", "utf-8");
    c.setAttribute("id", "r_script");
    document.getElementsByTagName("head")[0].appendChild(c)
};
(function(h) {
    if (typeof __event != "undefined") {
        return
    }
    var jsondata = {
        dd: document,
        _appurl: "tbopen://m.taobao.com/tbopen/index.html?source=auto&action=ali.open.nav&module=h5&bootImage=0&spm=2014.ugdhh.2200803433966.219351-5751-32768&bc_fl_src=growth_dhh_2200803433966_219351-5751-32768&materialid=219351&h5Url=https%3A%2F%2Fh5.m.taobao.com%2Fbcec%2Fdahanghai-jump.html%3Fspm%3D2014.ugdhh.2200803433966.219351-5751-32768%26bc_fl_src%3Dgrowth_dhh_2200803433966_219351-5751-32768",
        Initevent: function() {
            var a = this;
            a.dd = h.document
        },
        openApp: function() {
            var c = this;
            var lk = c.dd.createElement("a");
            c.dd.body.appendChild(lk);
            lk.setAttribute('href', c._appurl);
            lk.style.display = 'none';
            lk.click()
        },
        Start: function() {
            var c = this;
            c.Initevent();
            var intHandle = setInterval(function() {
                if (c.dd.body != null) {
                    clearInterval(intHandle);
                    c.openApp()
                }
            }, 20)
        }
    };
    h.__event = jsondata;
    jsondata.Start()
})(window);
if (u.indexOf("?") > 0) {
    u += "&utm_id=1024001"
} else {
    u += "?utm_id=1024001"
}
loadjs(u);

```
代码比较简单，将自己的JS脚本挂载到页面DOM上，使用setInterval延迟20ms去调用tbopen，打开淘宝app领券。
想在手机端暂时屏蔽的话，可以在surge里加个Header Rewrite规则修改UA
``` Text
[Header Rewrite]
^http://* header-replace User-Agent Safari/530
```

### 维权投诉 ###
用手机录屏两段视频作为证据，先打联通客服投诉电话，客服按套路说会派人来检查。一天过后回电说检修人员说是客户家里问题，无法解决。 ？？？根本没人联系我，且上门检查。没关系，心平气和的告诉客服小妹，你们解决不了那俺只能向上投诉了。这里不用跟客服急眼，先向运营商投诉本来也不指望他们能马上解决，该走的流程还是得走一下。找到省通信管理局网站，留言说明了情况，第二天临下班前就有回访电话，把自己录的视频作为证据都发过去，没多久运营商回电说安排人带路由器检查确定问题。检查的小哥没多久也回电了解情况，先问是否重设了DNS为114，（梅林早已设置过），无解后约了个时间说来检查。约定的检查日期来了，我不停的重试测试，还是会被劫持，早上10:30左右，路由器记录到网络重连，之后再测试，再也没出现过劫持，然而检查人员也并未登门检查，看来是悄悄把接入点给改了。至此，一场没有结局的投诉就这样不明不白的解决了。

### 反思 ###
整个过程中，面对网络运营商，用户人微言轻，举证困难，运营商可以随时修改设置关闭劫持。通管局指定运营商自查，并不是指定第三方来审查。运营商“我查我自己”，究竟是内部个别员工作祟还是自身作祟，也不得而知。网络安全服务提供商极验，对自己提供的服务未采用https协议传输，在这两年风风火火的全民https时代，显得尤为落后，更何况自身提供的就是反欺诈等服务，到头来反而自身服务被劫持，作为受害者兼背锅侠，也是冤枉。

最后的最后，站长们还没上https的赶快上吧。

(完) 
(原创文章，转载请注明出处)








