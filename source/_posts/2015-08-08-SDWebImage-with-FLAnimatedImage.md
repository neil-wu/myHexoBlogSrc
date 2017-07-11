---
layout: post
title: SDWebImage中使用FLAnimatedImage来播放gif
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
#modified: 2015-7-19
imagefeature: bg/bg_maple.jpg

---
[SDWebImage](https://github.com/rs/SDWebImage) 对gif图片的支持不是非常好，我们可以在其项目的讨论区看到大家的吐槽( [Drop our GIF support and integrate a 3rd party solution #945](https://github.com/rs/SDWebImage/issues/945))。我简单修改了几处源码，使用 [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage)来显示gif图片。SDWebImage 仍用作默认的图片加载和缓存，只是在需要显示gif图片时，改用FLAnimatedImage。

<!--more--> 

对源码的修改和如何使用，看这个 [Demo](https://github.com/neil-wu/SDImageCacheWithGifDemo)

操作步骤：

### 1. 屏蔽SDWebImage显示gif图片的代码 ###

修改文件 `UIImage+MultiFormat.m`的第22-26行代码(行数可能有误差)，注释掉这部分代码，如下：

``` swift

+ (UIImage *)sd_imageWithData:(NSData *)data {
    UIImage *image;
    /*
    //注释掉这里
    NSString *imageContentType = [NSData sd_contentTypeForImageData:data];
    if ([imageContentType isEqualToString:@"image/gif"]) {
        image = [UIImage sd_animatedGIFWithData:data];
    }*/
    if (0) { //然后添加此if
    }
#ifdef SD_WEBP

```

### 2. 修改SDImageCache.h，将如下函数设为公有 ###

在SDImageCache.h里，添加 
`- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key;` 声明。该函数已经实现，这里只是将其公有，以便我们能获取到gif图片数据，传给FLAnimatedImage来使用。


### 3. 显示图片时判断是否需要使用FLAnimatedImage ###

直接看代码吧：


``` swift
if imgurlstring.hasSuffix(".gif") {
    //we use NSData from the cache
    var data = SDWebImageManager.sharedManager().imageCache.diskImageDataBySearchingAllPathsForKey(imgurlstring)
    var img = FLAnimatedImage(animatedGIFData: data!)
    var imgview = FLAnimatedImageView(frame: CGRectMake(0, 0, self.baseview.frame.width, self.baseview.frame.height))
    imgview.animatedImage = img
    imgview.contentMode = UIViewContentMode.ScaleAspectFit
    self.baseview.addSubview(imgview)
} else {
    var pngview = UIImageView(image: image)
    pngview.frame = CGRectMake(0, 0, self.baseview.frame.width, self.baseview.frame.height)
    pngview.contentMode = UIViewContentMode.ScaleAspectFit
    self.baseview.addSubview(pngview)
}

```

或者直接下载这个 [Demo](https://github.com/neil-wu/SDImageCacheWithGifDemo) 来看效果。:]

(完)

