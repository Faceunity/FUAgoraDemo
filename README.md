# FUAgoraDemo 快速接入文档

FUAgoraDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪、虚拟道具功能 和 声网 SDK的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯实时音视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**

**运行前先下载声网SDK**

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在  RoomViewController.m  中添加头文件，并创建页面属性

```C
#import <FUAPIDemoBar/FUAPIDemoBar.h>

@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `demoBarDidSelectedItem:` 切换贴纸 和 `demoBarBeautyParamChanged` 更新美颜参数。

```C
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 231 - 50, self.view.bounds.size.width, 231)];
        
        NSLog(@"---------%@",NSStringFromCGRect(_demoBar.frame));
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

```

#### 实现UI事件回调

```C
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}
```



### 三、在 `initUI ` 中初始化 SDK  并将  demoBar 添加到页面上

```C
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
```

### 四、外部滤镜

在类RoomViewController.m,添加声网采集回调self.faceUnityFilter.didCompletion

```C
self.faceUnityFilter.didCompletion = ^(CVPixelBufferRef  _Nonnull pixelBuffer, CMTime timeStamp, AGMVideoRotation rotation) {
        
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

        CFAbsoluteTime startRenderTime = CFAbsoluteTimeGetCurrent();

        [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
        
        CFAbsoluteTime renderTime = (CFAbsoluteTimeGetCurrent() - startRenderTime);
        // push pixelBuffer to agora server
        [weakSelf.consumer consumePixelBuffer:pixelBuffer withTimestamp:timeStamp rotation:rotation];
        
    };
```



### 五、推流结束时需要销毁道具

销毁道具需要调用以下代码

```C
[[FUManager shareManager] destoryItems];
```



#### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](<https://github.com/Faceunity/FULiveDemo/blob/master/docs/iOS_Nama_SDK_%E9%9B%86%E6%88%90%E6%8C%87%E5%AF%BC%E6%96%87%E6%A1%A3.md>)

