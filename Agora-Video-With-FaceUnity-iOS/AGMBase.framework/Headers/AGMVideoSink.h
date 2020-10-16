//
//  AGMVideoSink.h
//  AgoraRtmpStreamingKit
//
//  Created by LSQ on 2019/11/7.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGMVideoFrame.h"
#import "AGMImageFramebuffer.h"
#import "AGMImageContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AGMVideoSink <NSObject>
/**
 This method is no longer in use.
 */
- (void)onFrame:(AGMVideoFrame *)videoFrame DEPRECATED_MSG_ATTRIBUTE("use onTextureFrame:frameTime: instead");

- (void)onTextureFrame:(AGMImageFramebuffer *)textureFrame
             frameTime:(CMTime)time;



@optional
/** Should be called by the source when it discards the frame due to rate limiting. */
- (void)onDiscardedFrame;
@end

NS_ASSUME_NONNULL_END
