BJNotification                                   
--
###本项目高仿NSNotification    
![image](https://github.com/beijiahiddink/beijiahiddink.github.io/blob/gh-pages/matter/BJNotification.gif)
####1. 通知注册方法
```objective-c
[[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];
```
####2. 通知发送方法
```objective-c
[[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:nil];
```
####3. 清理注册人
```objective-c
[[BJNotificationCenter defaultCenter] removeObserver:self];
```
<br>
> ####喜欢此demo可以点击上面右侧的 Star 哦，变成 Unstar 就可以了！ :stuck_out_tongue_winking_eye:

<br>
-----                
                                      
