//
//  AGMEAGLVideoView.h
//  AGMRenderer
//
//  Created by LSQ on 2020/10/5.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AGMBase/AGMBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGMEAGLVideoView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setMirror:(bool)mirror;

- (void)setRenderMode:(AGMRenderMode)renderMode;

- (void)renderFrame:(id <AGMVideoFrame>)frame;

@end

NS_ASSUME_NONNULL_END
