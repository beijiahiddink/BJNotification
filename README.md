##BJNotification                        
![build](https://img.shields.io/badge/iOS-7.0-yellow.svg)           
![version](https://img.shields.io/badge/version-v1.0-blue.svg)
[![weibo](https://img.shields.io/badge/weibo-@beijiahiddink-green.svg)](http://weibo.com/u/3788698095)
[![mail](https://img.shields.io/badge/mail-@beijiahiddink-pink.svg)](mailto://wangxu@beijiahiddink.com)

###什么是BJNotification
本项目高仿NSNotification框架。

###该怎样去使用
使用方式大体与NSNotification使用类似。
####通知注册方法
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];

####通知发送方法
    [[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:nil];

####清理注册人
    [[BJNotificationCenter defaultCenter] removeObserver:self];

###最后
喜欢本demo的可以给我[加星](https://github.com/beijiahiddink/BJNotification/stargazers)哦!

###License
The MIT License (MIT)

Copyright (c) 2013-2016 beijiahiddink (<https://github.com/beijiahiddink/BJNotification>)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.   