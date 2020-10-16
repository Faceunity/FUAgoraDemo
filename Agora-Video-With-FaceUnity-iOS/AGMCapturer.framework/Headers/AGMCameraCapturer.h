//
//  AGMCameraCapturer.h
//  AGMCapturer
//
//  Created by LSQ on 2020/10/5.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AGMBase/AGMBase.h>
#import "AGMCapturerVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN
@protocol AGMVideoCameraDelegate <NSObject>
@optional
- (void)didOutputVideoFrame:(id <AGMVideoFrame>)frame;
@end


@interface AGMCameraCapturer : NSObject

/** Control cameraPosition, default front */
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
/** Video preview resolution. */
@property (nonatomic, assign) AVCaptureSessionPreset sessionPreset;
/** Specifies the recommended settings for use with an AVAssetWriterInput. */
@property (nonatomic, strong, readonly) NSDictionary *videoCompressingSettings;

@property (nonatomic, weak) id<AGMVideoCameraDelegate> delegate;

- (instancetype)initWithConfig:(AGMCapturerVideoConfig *)config;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/** Start video pixelbuffer camera. */
- (BOOL)start;
- (void)stop;
- (void)dispose;
#if TARGET_OS_IPHONE
/**
 Switches between front and rear cameras.
 */
-(void)switchCamera;
#endif

- (void)setExposurePoint:(CGPoint)point inPreviewFrame:(CGRect)frame;

- (void)setISOValue:(float)value;

@end

NS_ASSUME_NONNULL_END
