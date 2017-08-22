# BackgroundLocation
后台持续定位，并间隔时间内向服务器上传定位信息工具

### 使用前准备
* 1.需在项目配置中开启如下权限

![image](https://github.com/longitachi/BackgroundLocation/blob/master/screenshot/setting.jpeg)
* 2.在info.plist中添加 `NSLocationAlwaysAndWhenInUseUsageDescription` 及 `NSLocationWhenInUseUsageDescription`

### 使用
```objc
#import "LocationTool.h"

[[LocationTool shareInstance] setUploadInterval:60];
[[LocationTool shareInstance] startLocation];
```

### 效果图
![image](https://github.com/longitachi/BackgroundLocation/blob/master/screenshot/foreground.png)
![image](https://github.com/longitachi/BackgroundLocation/blob/master/screenshot/background.jpg)

![image](https://github.com/longitachi/BackgroundLocation/blob/master/screenshot/background1.jpg)
![image](https://github.com/longitachi/BackgroundLocation/blob/master/screenshot/lock.jpg)

### 后言
由于截图是在位置不变的情况下进行的测试，位置不变，定位回调会间隔有点长，可能不会每60s（所设置的时间间隔）就回调一次， 但是如果在室外位置移动的情况及设置 `_locManager.desiredAccuracy = kCLLocationAccuracyBest;` 的情况下，
几乎可以达到每秒定位回调成功一次。
