#import "AGMImageProgram.h"
#import "AGMImageFramebuffer.h"
#import "AGMImageFramebufferCache.h"

#define AGMImageRotationSwapsWidthAndHeight(rotation) ((rotation) == kAGMImageRotateLeft || (rotation) == kAGMImageRotateRight || (rotation) == kAGMImageRotateRightFlipVertical || (rotation) == kAGMImageRotateRightFlipHorizontal)

typedef NS_ENUM(NSUInteger, AGMImageRotationMode) {
	kAGMImageNoRotation,
	kAGMImageRotateLeft,
	kAGMImageRotateRight,
	kAGMImageFlipVertical,
	kAGMImageFlipHorizonal,
	kAGMImageRotateRightFlipVertical,
	kAGMImageRotateRightFlipHorizontal,
	kAGMImageRotate180
};

@interface AGMImageContext : NSObject

@property(readonly, nonatomic) dispatch_queue_t contextQueue;
@property(readwrite, retain, nonatomic) AGMImageProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;
@property(readonly) AGMImageFramebufferCache *framebufferCache;

+ (void *)contextKey;
+ (AGMImageContext *)sharedImageProcessingContext;
+ (dispatch_queue_t)sharedContextQueue;
+ (AGMImageFramebufferCache *)sharedFramebufferCache;
+ (void)useImageProcessingContext;
- (void)useAsCurrentContext;
+ (void)setActiveShaderProgram:(AGMImageProgram *)shaderProgram;
- (void)setContextShaderProgram:(AGMImageProgram *)shaderProgram;
+ (GLint)maximumTextureSizeForThisDevice;
+ (GLint)maximumTextureUnitsForThisDevice;
+ (GLint)maximumVaryingVectorsForThisDevice;
+ (BOOL)deviceSupportsOpenGLESExtension:(NSString *)extension;
+ (BOOL)deviceSupportsRedTextures;
+ (BOOL)deviceSupportsFramebufferReads;
+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;

- (void)presentBufferForDisplay;
- (AGMImageProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

- (void)useSharegroup:(EAGLSharegroup *)sharegroup;

// Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;

@end
