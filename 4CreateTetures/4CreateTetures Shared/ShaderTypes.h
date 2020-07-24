//
//  ShaderTypes.h
//  4CreateTetures Shared
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
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
typedef enum WQVertexInputIndex {
	WQVertexInputIndexVertices = 0,
	WQVertexInputIndexViewPortSize = 1,
} WQVertexInputIndex;

typedef enum WQTextureIndex {
	WQTextureIndexBaseColor = 0
} WQTextureIndex;

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} WQVertex;

#endif /* ShaderTypes_h */

