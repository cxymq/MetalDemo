//
//  Shaders.metal
//  3MetalRender2DTriangle Shared
//
//  Created by Qi Wang on 2019/9/24.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
	float4 position [[position]];
	float4 color;
} RasterizerData;

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
								   constant WQQVertex *vertices [[buffer(WQQVertexInputIndexVertices)]],
								   constant vector_uint2 *viewportSizePointer[[buffer(WQQVertexInputIndexViewportSize)]]) {
	RasterizerData out;
	
	float2 pixelSpacePosition = vertices[vertexID].position.xy;
	
	vector_float2 viewportSize = vector_float2(*viewportSizePointer);
	
	out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
	
	out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
	
	out.color = vertices[vertexID].color;
	
	return out;
	
}


fragment float4 fragmentShader(RasterizerData in [[stage_in]]) {
	return in.color;
}
