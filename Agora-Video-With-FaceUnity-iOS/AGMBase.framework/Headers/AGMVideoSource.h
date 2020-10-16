//
//  AGMVideoSource.h
//  AgoraRtmpStreamingKit
//
//  Created by LSQ on 2019/11/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGMVideoSink.h"
#import "AGMImageContext.h"
#import "AGMImageFramebuffer.h"

NS_ASSUME_NONNULL_BEGIN



#ifdef __cplusplus
extern "C" {
#endif
dispatch_queue_attr_t AGMImageDefaultQueueAttribute(void);
void AGMRunSyncOnVideoProcessingQueue(void (^block)(void));
void AGMRunAsyncOnVideoProcessingQueue(void (^block)(void));
void AGMRunSyncOnContextQueue(AGMImageContext *context, void (^block)(void));
void AGMRunAsyncOnContextQueue(AGMImageContext *context, void (^block)(void));
#ifdef __cplusplus
};
#endif

@interface AGMVideoSource : NSObject {
    AGMImageFramebuffer *outputFramebuffer;
    
    NSMutableArray *targets, *targetTextureIndices;
    
    CGSize inputTextureSize, cachedMaximumOutputSize, forcedMaximumSize;
    
    BOOL overrideInputSize;
    
    BOOL allTargetsWantMonochromeData;
    BOOL usingNextFrameForImageCapture;
}
@property(readwrite, nonatomic) AGMTextureOptions outputTextureOptions;
@property(nonatomic, copy) void(^frameProcessingCompletionBlock)(AGMVideoSource*, CMTime);

/**
 Returns an array of the current sinks.
 */
- (NSArray*)allSinks;
/**
 Adds a sink to receive notifications when new frames are available.
 */
- (void)addVideoSink:(id<AGMVideoSink>)sink;
/**
 Removes a sink. The target will no longer receive notifications when new frames are available.
 */
- (void)removeVideoSink:(id<AGMVideoSink>)sink;
- (AGMImageFramebuffer *)framebufferForOutput;
- (void)removeOutputFramebuffer;
@end

NS_ASSUME_NONNULL_END
