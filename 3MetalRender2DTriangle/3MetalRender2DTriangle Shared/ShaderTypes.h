//
//  ShaderTypes.h
//  3MetalRender2DTriangle Shared
//
//  Created by Qi Wang on 2019/9/24.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, WQQVertexInputIndex)
{
    WQQVertexInputIndexVertices = 0,
    WQQVertexInputIndexViewportSize  = 1,
};

typedef struct
{
    vector_float2 position;
    vector_float4 color;
} WQQVertex;

#endif /* ShaderTypes_h */

