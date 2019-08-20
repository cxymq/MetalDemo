//
//  Renderer.m
//  2MetalKitAndRenderingSetup Shared
//
//  Created by Qi Wang on 2019/8/20.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import <simd/simd.h>

#import "Renderer.h"


@implementation Renderer
{
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        _device = view.device;
		_commandQueue = [_device newCommandQueue];
    }

    return self;
}


#pragma mark------ MTKViewDelegate
//更新视图内容
- (void)drawInMTKView:(nonnull MTKView *)view
{
	//创建渲染过程描述符
	MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
	if (descriptor == nil) {
		return;
	}
	
	//从命令队列中获取命令缓冲区
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	
	//通过渲染过程描述符获取渲染命令编码器
	id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];

	//立即结束，达到清除可绘制对象的目的
	[commandEncoder endEncoding];
	
	//获取当前视图的可绘制对象
	id<MTLDrawable> drawable = view.currentDrawable;
	//绘制完成时，请求呈现
	[commandBuffer presentDrawable:drawable];
	//提交
	[commandBuffer commit];
}

//更改视图大小
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
	
}


@end
