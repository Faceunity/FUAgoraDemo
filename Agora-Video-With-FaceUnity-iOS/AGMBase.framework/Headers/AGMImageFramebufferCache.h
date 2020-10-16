#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "AGMImageFramebuffer.h"

@interface AGMImageFramebufferCache : NSObject

// Framebuffer management
- (AGMImageFramebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize textureOptions:(AGMTextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;
- (AGMImageFramebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize onlyTexture:(BOOL)onlyTexture;
- (void)returnFramebufferToCache:(AGMImageFramebuffer *)framebuffer;
- (void)purgeAllUnassignedFramebuffers;
- (void)addFramebufferToActiveImageCaptureList:(AGMImageFramebuffer *)framebuffer;
- (void)removeFramebufferFromActiveImageCaptureList:(AGMImageFramebuffer *)framebuffer;

@end
