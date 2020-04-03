---
layout: post
title: Swift中的weak和unowned reference
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
date: 2015-09-04

---

Swift是使用ARC来自动管理内存，这对开发者提供了便利，但从OC时代引入ARC以来，就一直面临着一个问题：循环引用。使用不当造成的循环引用，会导致内存无法释放，为解决这个问题，swift引入了weak和unowned两个关键字。当然，值类型是不涉及循环引用的问题，所以ARC仅仅应用于类的实例。

在编码时一般会出现两种情况的循环引用：1. 普通对象的循环强引用 2. 函数或闭包间的循环引用。 第一种情况相对比较容易发现，第二种情况更隐蔽，在使用的闭包时会无意间引入。

<!--more--> 

### 1. 普通对象的循环强引用（比如设置delegate） ### 

看以下代码片段：

``` swift

class People
{
    var name: String = ""
    var pet: Dog? = nil

    deinit {
        println("People deinit")
    }
}
class Dog
{
    var people: People? = nil
    deinit {
        println("Dog deinit")
    }
}
var me = People()
me.name = "john"

var pet = Dog()
pet.people = me

me.pet = pet

```

在Xcode项目中运行（Playground自身会持有变量，不能在其中做这个测试）。可以看到并没有任何一个deinit被执行，me和pet互相持有了对方，造成了循环引用。

如果我们在使用结束后，把me.pet=nil或者pet.people=nil，都会打破循环引用，各自对象均可以释放。但实际开发中这个置为nil的操作很容易遗漏，随着项目的复杂，排查难度会越来越大。

这种情况下，使用弱引用（ weak reference），声明为 `weak var people: People? = nil`,使之并不保持对所指对象的强持有，因此并不阻止ARC对引用实例的回收。这个特性保证了引用不成为强引用循环的一部分。

思考一下：这里可不可以修改为 `unowned var people: People? = nil` ??? （文末给出说明）


### 2. 函数或闭包间的循环引用 ### 

看以下代码片段：

``` swift
Alamofire.request(.GET,
                  "http://httpbin.org/get",
                  parameters: ["foo": "bar"])
         .response { (request, response, data, error) in
                     self.doSomething()
                   }
```

这里使用Alamofire的一个简单使用来做说明，我们使用Alamofire来向服务器发送请求，在响应中，调用当前ViewController实例的doSomething（更新UI啊，保存数据等操作）。一切看起来似乎很正常，当这个Viewcontroller被pop或者dismiss后，惊讶的发现其deinit函数没有执行。

由于Swift中的闭包是引用类型（也就是说，当定义一个函数(闭包)常量或变量时，实际上定义的是一个指向函数(闭包)的引用。这意味着如果指定一个闭包给两个不同的常量或变量，则这两个常量和变量将引用同一个函数(闭包)）。在以上代码执行时，该类的实例self生成了一个对response闭包的引用，而该闭包中，又引用了self实例，所以导致最后该实例没有释放。

解决方法是使用 捕获列表：`[unowned self]  (request, response, data, error) in` 。捕获列表中的每个元素都是由weak或者unowned关键字和实例的引用（如self）成对组成。每一对都在方括号中，通过逗号分开。


### 如何选择使用weak或unowned ### 

回答上面提出的问题：不能使用`unowned var people: People? = nil`

简单来说：被标记为 weak 的变量一定需要是optional 值, unowned 不能是optional。

Apple 给我们的建议是如果能够确定在访问时不会已被释放的话，尽量使用 unowned，如果存在被释放的可能，那就选择用 weak。weak友好一些，在引用的内容被释放后，标记为 weak 的成员将会自动地变成 nil。

在实例的生命周期中，如果某些时候引用没有值，那么弱引用可以阻止循环强引用。如果引用总是有值，则可以使用无主引用，在无主引用中有描述。
弱引用必须被声明为变量，表明其值能在运行时被修改，不能被声明为常量。



推荐阅读：

[内存管理，WEAK 和 UNOWNED](http://swifter.tips/retain-cycle/)

[Swift闭包一：闭包基础概念](http://southpeak.github.io/blog/2014/06/27/ios-swift-closures/)

(完)









