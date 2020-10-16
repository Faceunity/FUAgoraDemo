//
//  AGMYUVHelper.hpp
//  AGMBase
//
//  Created by LSQ on 2019/12/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#ifndef AGMYUVHelper_hpp
#define AGMYUVHelper_hpp

#include <stdio.h>
#include <vector>
#include "libyuv.h"

using namespace libyuv;

namespace agora_module {
class YUVHelper {
    
public:
    // Helper function for directly converting and scaling NV12 to I420. The Y-plane
    // will be scaled directly to the I420 destination, which makes this faster
    // than separate NV12->I420 + I420->I420 scaling.
    void NV12ToI420Scale(const uint8_t* src_y, int src_stride_y,
                         const uint8_t* src_uv, int src_stride_uv,
                         int src_width, int src_height,
                         uint8_t* dst_y, int dst_stride_y,
                         uint8_t* dst_u, int dst_stride_u,
                         uint8_t* dst_v, int dst_stride_v,
                         int dst_width, int dst_height);
    
    void I420ToBGRA(const uint8 *src_y, int src_stride_y,
                    const uint8 *src_u, int src_stride_u,
                    const uint8 *src_v, int src_stride_v,
                    uint8 *dst_argb, int dst_stride_argb,
                    int width, int height);
    
    void I420ToARGB(const uint8 *src_y, int src_stride_y,
                    const uint8 *src_u, int src_stride_u,
                    const uint8 *src_v, int src_stride_v,
                    uint8 *dst_argb, int dst_stride_argb,
                    int width, int height);
    
    void I420Scale(const uint8* src_y, int src_stride_y,
                   const uint8* src_u, int src_stride_u,
                   const uint8* src_v, int src_stride_v,
                   int src_width, int src_height,
                   uint8* dst_y, int dst_stride_y,
                   uint8* dst_u, int dst_stride_u,
                   uint8* dst_v, int dst_stride_v,
                   int dst_width, int dst_height);
    
    // Helper function for scaling NV12 to NV12.
    // If the |src_width| and |src_height| matches the |dst_width| and |dst_height|,
    // then |tmp_buffer| is not used. In other cases, the minimum size of
    // |tmp_buffer| should be:
    //   (src_width/2) * (src_height/2) * 2 + (dst_width/2) * (dst_height/2) * 2
    void NV12Scale(uint8_t* tmp_buffer,
                   const uint8_t* src_y, int src_stride_y,
                   const uint8_t* src_uv, int src_stride_uv,
                   int src_width, int src_height,
                   uint8_t* dst_y, int dst_stride_y,
                   uint8_t* dst_uv, int dst_stride_uv,
                   int dst_width, int dst_height);
    
    int I420ToNV12(const uint8_t* src_y, int src_stride_y,
                   const uint8_t* src_u, int src_stride_u,
                   const uint8_t* src_v, int src_stride_v,
                   uint8_t* dst_y, int dst_stride_y,
                   uint8_t* dst_uv, int dst_stride_uv,
                   int width, int height);
    
    int I420Rotate(uint8_t *src_yuv, uint8_t *dst_yuv,
                   int width,int height,
                   RotationMode rotationMode);
    
    int I420Rotate(const uint8* src_y, int src_stride_y,
                   const uint8* src_u, int src_stride_u,
                   const uint8* src_v, int src_stride_v,
                   uint8* dst_y, int dst_stride_y,
                   uint8* dst_u, int dst_stride_u,
                   uint8* dst_v, int dst_stride_v,
                   int src_width, int src_height,
                   RotationMode mode);
    
    int I420Mirror(const uint8 *src_y, int src_stride_y,
                   const uint8 *src_u, int src_stride_u,
                   const uint8 *src_v, int src_stride_v,
                   uint8 *dst_y, int dst_stride_y,
                   uint8 *dst_u, int dst_stride_u,
                   uint8 *dst_v, int dst_stride_v,
                   int width, int height);
    
    int I420RotateAndClip(const uint8* src_frame, size_t src_size,
                          uint8* dst_y, int dst_stride_y,
                          uint8* dst_u, int dst_stride_u,
                          uint8* dst_v, int dst_stride_v,
                          int crop_x, int crop_y,
                          int src_width, int src_height,
                          int crop_width, int crop_height,
                          enum RotationMode rotation,
                          uint32 format);
        
private:
    std::vector<uint8_t> tmp_uv_planes_;
};
}


#endif /* AGMYUVHelper_hpp */
