#import "AGMImageFilter.h"

@interface AGMVideoAdapterFilter : AGMImageFilter
{
    GLint transformMatrixUniform, orthographicMatrixUniform;
    AGMMatrix4x4 orthographicMatrix;
}

// You can either set the transform to apply to be a 2-D affine transform or a 3-D transform. The default is the identity transform (the output image is identical to the input).
@property (nonatomic, assign) CGAffineTransform affineTransform;

// This applies the transform to the raw frame data if set to YES, the default of NO takes the aspect ratio of the image input into account when rotating
@property (nonatomic, assign) BOOL ignoreAspectRatio;

// Invert the video frame output from the front camera to mirror, which defaults to YES.
@property (nonatomic, assign) BOOL isMirror;

@end
