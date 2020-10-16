//
//  AGMCapturerVideoConfig.h
//  AGMCapturer
//
//  Created by LSQ on 2020/10/5.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, AGMVideoPixelFormat) {
    /** BGRA */
    AGMVideoPixelFormatBGRA   = 0,
    /** NV12. This is fullrange. */
    AGMVideoPixelFormatNV12   = 1,
};

/** Video buffer type */
typedef NS_ENUM(NSInteger, AGMVideoBufferType) {
    /** Use a pixel buffer to transmit the video data. */
    AGMVideoBufferTypePixelBuffer = 0,
    /** Use texture to transmit the video data.*/
    AGMVideoBufferTypeTexture     = 1,
};



NS_ASSUME_NONNULL_BEGIN

@interface AGMCapturerVideoConfig : NSObject
+ (instancetype)defaultConfig;
/** Video frame per second. 3<=fps<=30 Defaule value is 15 fps.*/
@property (nonatomic, assign) NSUInteger fps;
/** Video preview resolution. Defaule value is AVCaptureSessionPreset640x480*/
@property (nonatomic, assign) AVCaptureSessionPreset sessionPreset;
/** Camera  position. Defaule value is AVCaptureDevicePositionFront*/
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
/** Output format of buffer. Defaule value is AGMVideoPixelFormatNV12*/
@property (nonatomic, assign) AGMVideoPixelFormat pixelFormat;
/** AGMVideoCameraDelegate output buffer type. Defaule is cvpixelbuffer*/
@property (nonatomic, assign) AGMVideoBufferType videoBufferType;
@end

NS_ASSUME_NONNULL_END
