---
layout: post
title: FridaNSLogger
description: ""
headline: ""
categories: tech
tags: 
  - 技术
  - iOS逆向
comments: true
mathjax: null
featured: false
published: true

---


## FridaNSLogger ##

FridaNSLogger可以在Frida中将日志信息通过socket连接发送至Mac端查看。
Mac端日志查看工具 `FridaNSLoggerViewer` 基于 [NSLogger](https://github.com/fpillet/NSLogger) 修改实现。
项目地址 [https://github.com/neil-wu/FridaNSLogger](https://github.com/neil-wu/FridaNSLogger)

<!--more-->  

### 特点 ###

* 可以在Frida TypeScript代码中直接发送日志消息；
* 支持 string 和 binary 类型日志消息；
* 支持简单的断线重连；
* 完备的Mac端日志查看器FridaNSLoggerViewer（支持日志分级，过滤，保存等）；


### 快速使用 ###

1. 在Mac端启动日志查看器FridaNSLoggerViewer，默认监听 127.0.0.1:50010 ，并获取该Mac系统内网IP(比如192.168.2.10)

2. 在Frida TypeScript工程中引用：
```TypeScript
import { Logger } from "./logger";
import { swapInt64 } from "./logger";

// 连接到局域网内的FridaNSLoggerViewer，注意修改IP。
// 如果Frida脚本
const logger = new Logger('192.168.2.10', 50010);
logger.logStr('helloworld'); //发送string类型日志

const testS64 = new Int64('0x0102030405060708');
const testBuf = Memory.alloc(8).writeS64( swapInt64(testS64) ).readByteArray(8);
logger.logBinary(testBuf as ArrayBuffer); //发送binary类型日志
```

FridaNSLoggerViewer 效果如下图：
<figure>
	<img src="{{ site.url }}/images/article/FridaNSLoggerViewer.png"></a>
</figure>


### 原理 ###

Frida脚步内作为client，利用Frida的 SocketConnection 接口，将日志编码后发送；
FridaNSLoggerViewer作为socket服务端，可监听局域网内多个client发来的连接。NSLogger原有实现需要加密后的socket数据，FridaNSLoggerViewer对其修改，去掉了加密，支持 raw tcp packet.


新加入的client默认第一条消息发送设备信息，包含Frida版本，系统版本等信息。后续每条日志打包为一个LogMessage发送。

NSLogger接收的单个二进制数据包格式为：
``` C
uint32_t    totalSize        //(total size for the whole message excluding this 4-byte count)
uint16_t    partCount        //(number of parts below)
[repeat partCount times]:
    uint8_t        partKey        //the part key
    uint8_t        partType    //(string, binary, image, int16, int32, int64)
    uint32_t    partSize    //(only for string, binary and image types, others are implicit)
    .. `partSize' data bytes
```
举例：
一个LogMessage的数据包拆分如下：
``` Text
00000073 //totalSize，占4byte。数值为整个包的字节数减去4，即后续部分长度
000a //0xa=10 parts，2byte，有多少个parts
0104 00000000 5e13fedb //01=PART_KEY_TIMESTAMP_S, 04=PART_TYPE_INT64
0304 00000000 00011402 //03=PART_KEY_TIMESTAMP_US
0400 00000008 54687265 61642036  //PART_KEY_THREAD_ID   
0003 00000003 // PART_KEY_MESSAGE_TYPE  PART_TYPE_INT32 
1500 00000001 31 //0x15=21,PART_KEY_CLIENT_VERSION
1400 0000000f 4e534c6f 67676572 54657374 417070 // 0x14=20,PART_KEY_CLIENT_NAME 
1900 00000008 6950686f 6e652058 //0x19=25=PART_KEY_UNIQUEID
1700 00000004 31322e32 //0x17=23=PART_KEY_OS_VERSION
1600 00000003 694f53 //0x16=22=PART_KEY_OS_NAME
1800 00000006 6950686f6e65 //0x18=24=PART_KEY_CLIENT_MODEL
```

(完) 
(原创文章，转载请注明出处)
