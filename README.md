BJNotification                                   
=========
本项目高仿NSNotification    
![image](https://github.com/beijiahiddink/beijiahiddink.github.io/blob/gh-pages/matter/BJNotification.gif)
###通知注册方法
```objective-c
[[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];
```
###通知发送方法
```objective-c
[[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:nil];
```
###注意
清理注册人时跟NSNotification不完全相同，不能写在dealloc方法里，防止清理失败，推荐写在：
```objective-c
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BJNotificationCenter defaultCenter] removeObserver:self];
}
```
代码存在很多不足，欢迎各位道友指正！
-----                
                                      
