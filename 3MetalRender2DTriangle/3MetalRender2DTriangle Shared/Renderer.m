//
//  Renderer.m
//  3MetalRender2DTriangle Shared
//
//  Created by Qi Wang on 2019/9/24.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import <simd/simd.h>
#import <ModelIO/ModelIO.h>

#import "Renderer.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "ShaderTypes.h"

@implementation Renderer
{
    id <MTLDevice> _device;
	
    id <MTLCommandQueue> _commandQueue;
	
    id <MTLRenderPipelineState> _pipelineState;
	
	vector_uint2 _viewportSize;

}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
		NSError *error;
		_device = view.device;
		
		//加载 .metal 文件，并且取出对应的函数
		id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
		id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
		id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
		
		//配置管道描述符 用于创建 管道状态
		MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
		pipelineDescriptor.label = @"Simple Pipeline";
		pipelineDescriptor.vertexFunction = vertexFunction;
		pipelineDescriptor.fragmentFunction = fragmentFunction;
		pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
		
		_pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
		
		NSAssert(_pipelineState, @"Failed to created pipeline state: %@", error);
		
		//h创建命令队列
		_commandQueue = [_device newCommandQueue];
    }

    return self;
}


#pragma mark------ MTKViewDelegate
//更改视图大小
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
	_viewportSize.x = size.width;
	_viewportSize.y = size.height;
}

//更新视图内容
-(void)drawInMTKView:(MTKView *)view {
	static const WQQVertex triangleVertices[] = {
		// 2d 位置，     RGBA 颜色
		{{ 250, -250}, {1, 0, 0, 1}},
		{{-250, -250}, {0, 1, 0, 1}},
		{{   0, 250}, {0, 0, 1, 1}},
	};
	
	//为每个渲染过程到当前绘制对象 创建 新的命令缓冲池
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	commandBuffer.label = @"MyCommand";
	
	//从view的绘制纹理中获取 渲染过程描述符
	MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
	if (renderPassDescriptor != nil) {
		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		renderEncoder.label = @"MyRenderEncoder";
		
		//设置绘制对象可绘制的区域
		[renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0}];
		
		[renderEncoder setRenderPipelineState:_pipelineState];
		
		//传递数据
		[renderEncoder setVertexBytes:triangleVertices length:sizeof(triangleVertices) atIndex:WQQVertexInputIndexVertices];
		[renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:WQQVertexInputIndexViewportSize];
		
		//绘制图形
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
		
		[renderEncoder endEncoding];
		
		//请求呈现
		[commandBuffer presentDrawable:view.currentDrawable];
		
	}
	
	//命令提交到GPU
	[commandBuffer commit];
	
	
}


@end
