---
layout: post
title: 关于AutoLayout中的margin
description: ""
headline: ""
categories: tech
tags: 
  - 技术
  - 前端
  - iOS
comments: true
mathjax: null
featured: false
published: true
imagefeature: bg/bg_maple.jpg

---
在做UI适配的时候，发现个别view定义的leading和trailling margin在iPhone 6 plus下会有一点间隙（4pt），其他则正常，记录一下这个问题的原因。

<!--more--> 

### 问题描述：###

在IB里向一个空的ViewController中添加一个UIView对象，拖动左右边界对齐父视图，如下图：
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-1.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-1.png"></a>
</figure>


添加leading and trailing space约束，（同时添加个居中约束，高度约束，）如下图：
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-2.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-2.png"></a>
</figure>

可以看到结果如下：
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-3.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-3.png"></a>
</figure>

可以看到IB设置的约束值为-16，(如果在这里将其改为0，IB会提示该View需要更新size，更新后在IB里会看到左右边距)。

使用-16的约束值，运行，在iPhone5s下表现正常，如下图：
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-4.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-4.png"></a>
</figure>

iPhone 6 plus的运行结果如下图，可以看到左右的边距：
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-5.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-5.png"></a>
</figure>

### 为什么同样的约束，在plus下会出现这样的结果呢？因为`layoutMargins`

### 关于layoutMargins ###

iOS8后，UIView 有个属性 `var layoutMargins: UIEdgeInsets`,用来指定该View的subview同其edge的间距。AutoLayout使用margins来放置内容。
默认的值为8pt。

如果一个View是ViewController的rootview，系统会自动设置和管理margins，top和bottom margins被设置为0pt，left和right的值根据当前的`size class`（文末简单介绍一下size class）不同而不同，可能取值为16或者20pt(iPhone6 plus, iPad)，你不能修改这些值。

所以，你知道iPhone 6 plus下那个4pt的间隙是怎么来的了吧。

当在一个空的ViewController里添加一个新UIView时，我们通过拖拽添加的约束会提示为类似：`Leading Space To Contrainer Margin`。而往一个UIView添加新的View，然后对其设置约束，会提示：`Leading Space To Contrainer`（这时候是到edge）。

如果想要将`Leading Space To Contrainer Margin`设置为edge对齐，可以这样操作：双击编辑该约束，如下图所示，取消掉 `Relative to margin`
<figure>
	<a href="{{ site.url }}/images/article/autolayout/autolayout-margin-6.png"><img src="{{ site.url }}/images/article/autolayout/autolayout-margin-6.png"></a>
</figure>

参考Apple的文档:  [Editing Auto Layout Constraints](https://developer.apple.com/library/ios/recipes/xcode_help-IB_auto_layout/chapters/EditingConstraintAttributesintheAttributesInspector.html)

附录：size class 简单说明

Size Class 的作用是将不同尺寸的屏幕进行分类处理。对于宽度和高度而言，都有三种情况：紧凑 (Compact) 、任意 (Any) 、 正常 (Regular) ，所以一共有9个类别.

参考说明： [Size Classes](http://onevcat.com/2014/07/ios-ui-unique/)

(完)

