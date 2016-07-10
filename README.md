# BJNotification
[![CocoaPods](https://img.shields.io/cocoapods/v/BJNotification.svg)](https://img.shields.io/cocoapods/v/BJNotification.svg)
[![twitter](https://img.shields.io/badge/twitter-@beijiahiddink-blue.svg?style=flat)](https://twitter.com/beijiahiddink)          
[![weibo](https://img.shields.io/badge/weibo-@beijiahiddink-green.svg?style=flat)](http://weibo.com/u/3788698095)
[![mail](https://img.shields.io/badge/mail-@beijiahiddink-pink.svg?style=flat)](mailto://wangxu@beijiahiddink.com)

## 什么是BJNotification
本项目高仿`NSNotification`框架。

## 如何安装
### CocoaPods
```ruby
platform :ios, '7.0'

target 'TargetName' do
pod 'BJNotification', '~> 1.0'
end
```
### 手动安装
```ruby
git clone https://github.com/beijiahiddink/BJNotification.git
open BJNotification
```
## 该怎样去使用
使用方式大体与`NSNotification`使用类似，整个框架是线程安全的。
### 通知注册方法
```objective-c
[[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];
```

### 通知发送方法
```objective-c
[[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:nil];
```

### 清理注册人
```objective-c
[[BJNotificationCenter defaultCenter] removeObserver:self];
```

## 最后
喜欢本项目的可以给我[加星](https://github.com/beijiahiddink/BJNotification/stargazers)哦！

## License
BJNotification is released under the MIT license. See [LICENSE](LICENSE) for details  