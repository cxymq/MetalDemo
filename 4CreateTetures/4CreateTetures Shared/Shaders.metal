//
//  Shaders.metal
//  4CreateTetures Shared
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct {
	float4 position [[position]];
	float2 textureCoordinate;
} RasterizerData;

// 顶点函数
vertex RasterizerData vertexShader (uint vertexID [[ vertex_id ]],
									constant WQVertex *vertexArray [[ buffer(WQVertexInputIndexVertices) ]],
									constant vector_uint2 *viewportSizePointer [[ buffer(WQVertexInputIndexViewPortSize) ]]) {
	RasterizerData out;
	float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
	float2 viewportSize = float2(*viewportSizePointer);
	out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
	out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
	out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
	return out;
}

// 光栅函数
fragment float4 simplingShader (RasterizerData in [[stage_in]],
								texture2d<half> colorTexture [[texture(WQTextureIndexBaseColor)]]) {
	constexpr sampler textureSimple (mag_filter :: linear, min_filter :: linear);
	const half4 colorSimple = colorTexture.sample(textureSimple, in.textureCoordinate);
	return float4(colorSimple);
}


