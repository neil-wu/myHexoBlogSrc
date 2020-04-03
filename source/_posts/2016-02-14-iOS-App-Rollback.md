---
layout: post
title: 如何使用iTunes下载App Store旧版iOS app
description: ""
headline: ""
categories: tech
tags: 
  - 技术
  - 教程
comments: true
mathjax: null
featured: false
published: true
date: 2016-02-14

---
旧版本iOS app下载方法

[(English Version Here) How to download legacy versions of iOS apps](https://hiraku.tw/2015/12/4140/)

<!--more-->  

### 前言 ###

1、本教程需要一定的技术、耐心及英语水平，请结合自身情况后考虑是否尝试

2、教程针对Windows系统，Mac也可通过类似步骤成功

3、文中使用 Fiddler 为抓包工具，如有自己熟悉的抓包工具也可换用

4、由于抓包代理的特殊性，不建议下载过大App（300M以上），容易卡（也没有其他什么影响，就是会卡）

5、演示使用版本：iTunes 12.3.1.23，Fiddler 2.6.0.5

[视频演示地址](biliplus.com/itunes_rollback.htm)

以下为操作步骤：

### 准备 ###

1、没装iTunes和不会用iTunes的App Store的先去补习

2、[下载Fiddler](www.telerik.com/download/fiddler)，Win8以上用户建议Fiddler for .NET4（其实两个版本没啥大区别，就是Win8自带.NET4）

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/1.png"><img src="{{ site.url }}/images/article/ipa_rollback/1.png"></a>
</figure>

### 步骤 ###

本文以下载QQ 5.9.1版为例：

1、打开`Fiddler`，选择菜单栏`Tools-Fiddler Options`，HTTPS选项卡，勾选`Decrypt HTTPS traffic`，弹出窗口点`Yes`，新弹出安装证书窗口选择“是”

【注意不要关闭Fiddler】

【安装证书失败或打开iTunes无法加载页面请至底部】

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/2.png"><img src="{{ site.url }}/images/article/ipa_rollback/2.png"></a>
</figure>

2、打开iTunes（如之前已打开请关闭iTunes重新打开），搜索想下载的App（本文以下载QQ 5.9.1版为例）

3、点击下载，等右上角出现箭头后删除下载（选中下载按两次delete）

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/3.png"><img src="{{ site.url }}/images/article/ipa_rollback/3.png"></a>
</figure>

4、返回Fiddler将还在下载的项目删除（仅为了节省网速）

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/4.png"><img src="{{ site.url }}/images/article/ipa_rollback/4.png"></a>
</figure>

5、在该删除的下载项上方找到域名为 `p32-buy.itunes.apple.com`，url开头为`/WebObjects/MZBuy.woa`的请求，切换右侧至`Inspectors`选项卡，并点击中间的黄色块`(Response is encoded and may require decoding before inspection. Click here to transform.)`
（编辑：域名可能不同，重点在于找到`/WebObjects/MZBuy.woa`）

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/5.png"><img src="{{ site.url }}/images/article/ipa_rollback/5.png"></a>
</figure>

6、保存该请求（右键请求-Save-Response-Response Body）【注意如果没有点黄色方块将会保存一个乱码文件】

7、打开保存的xml文件（系统默认一般是IE打开），向下翻动找到softwareVersionExternalIdentifiers并伴随着一大串“<integer>xxxxxxxxxx</integer>”的项目

【说明：此处为该App自第一个版本起每个版本在app store中的版本id，从后向前即为最新到最老】

【另，iOS9开始的App Thining会导致同一个app版本有多个版本id，具体差异我没有试，如果安装出现问题可以换一个版本id试】

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/6.png"><img src="{{ site.url }}/images/article/ipa_rollback/6.png"></a>
</figure>

8、回到Fiddler，右键之前那个`MZBuy`的请求，`Replay-Reissue and Edit`，编辑右侧上方`appExtVrsId`下方数字为对应版本id（此处直接使用QQ 5.9.1版本id 813463229），点击绿色按钮，切换至黄色块下方最右侧"XML"视图，下拉至图中位置查看app版本，不断重复本步骤直至找到需要下载的版本【期间如果无法正常获取即为请求已经过期，重新执行3-4步然后使用新的请求进行编辑重发操作】

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/7.png"><img src="{{ site.url }}/images/article/ipa_rollback/7.png"></a>
</figure>

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/8.png"><img src="{{ site.url }}/images/article/ipa_rollback/8.png"></a>
</figure>

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/9.png"><img src="{{ site.url }}/images/article/ipa_rollback/9.png"></a>
</figure>

9、确认需要下载的版本id后，先在iTunes中重新进行一次搜索或点进app详情页（使“正在下载”按钮恢复），然后开启拦截模式`【菜单栏Rules-Automatic Breakpoints-Before Requests】`，然后返回iTunes点击下载。回到Fiddler里面应该会有几个红色图标的请求，同样，找到`MZBuy.woa`（如果是Tunnel to先直接点绿色按钮放行），右侧编辑版本id为需要下载的版本id【不是Replay编辑】，然后关闭拦截模式`【菜单栏Rules-Automatic Breakpoints-Disabled】`，点击绿色按钮发送请求

`（梳理步骤：开启拦截->点下载->如果有Tunnel To放行后等带内容的请求出现->关闭拦截->编辑请求并发送）`

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/10.png"><img src="{{ site.url }}/images/article/ipa_rollback/10.png"></a>
</figure>

其他红色的请求也可以一并放行，也可不管，这都不重要）

10、您点的旧版本App已经开始下载啦

<figure>
	<a href="{{ site.url }}/images/article/ipa_rollback/11.png"><img src="{{ site.url }}/images/article/ipa_rollback/11.png"></a>
</figure>


`（下载过程中需要保持Fiddler和iTunes一同打开，不可关闭）`

接下来该干啥干啥，爱用哪个助手就用哪个助手安装就可以啦


### 补充：Fiddler根证书补安装 ###

1、Fiddler菜单栏Tools-Fiddler Options，HTTPS选项卡

2、下方的Export Root Certificate to Desktop【151221更新：更新Fiddler到2.6.1.5后发现按钮换位置了，右侧Action-Export Root Certificate to Desktop】

3、桌面上会有一个“FiddlerRoot.cer”文件，右键安装证书

4、在第二步中安装证书位置选择第二个并点击“浏览”

5、选择“信任的根证书存储”(Trusted Root Certification Authorities)（我用的英文系统不太记得官方翻译，大概就这个意思）

6、一路下一步

[原帖](http://bbs.feng.com/forum.php?mod=viewthread&tid=10125110&page=1#pid156307133)

(完)

