//
//  Renderer.m
//  4CreateTetures Shared
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
//

@import simd;
@import MetalKit;

#import <simd/simd.h>
#import <ModelIO/ModelIO.h>

#import "Renderer.h"
#import "WQImage.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "ShaderTypes.h"

@implementation Renderer {
	id<MTLDevice> _device;
	id<MTLTexture> _texture;
	// 保存顶点数据的缓冲区
	id<MTLBuffer> _vertices;
	// 每个顶点缓冲区的顶点数
	NSUInteger _numVertices;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLCommandQueue> _commandQueue;

	vector_uint2 _viewportSize;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if(self) {
        _device = view.device;
		NSURL *imgUrl = [[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"tga"];
		_texture = [self loadTextureUsingWQImage:imgUrl];

		// 设置一个 MTLBuffer，带有纹理坐标的顶点
		static const WQVertex quadVertices[] = {
			{ { 250, -250}, { 1.f, 1.f } },
			{ { -250, -250}, { 0.f, 1.f } },
			{ { -250, 250}, { 0.f, 0.f } },
			
			{ { 250, -250}, { 1.f, 1.f } },
			{ { -250, 250}, { 0.f, 0.f } },
			{ { 250, 250}, { 1.f, 0.f } },
		};
		// 初始化一个顶点缓冲区
		_vertices = [_device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
		_numVertices = sizeof(quadVertices) / sizeof(WQVertex);

		// 加载 shaders
		id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
		id<MTLFunction> vertexFun = [defaultLibrary newFunctionWithName:@"vertexShader"];
		id<MTLFunction> fragmentFun = [defaultLibrary newFunctionWithName:@"simplingShader"];

		// 设置描述符
		MTLRenderPipelineDescriptor *pipDesc = [[MTLRenderPipelineDescriptor alloc] init];
		pipDesc.label = @"Texturing Pipeline";
		pipDesc.vertexFunction = vertexFun;
		pipDesc.fragmentFunction = fragmentFun;
		pipDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat;

		NSError *error = NULL;
		_pipelineState = [_device newRenderPipelineStateWithDescriptor:pipDesc error:&error];
		_commandQueue = [_device newCommandQueue];
    }
    return self;
}

- (id<MTLTexture>)loadTextureUsingWQImage:(NSURL *)url {
	WQImage *img = [[WQImage alloc] initWithTgaFileAtLocation:url];
	// 初始化 textureDescriptor
	MTLTextureDescriptor *desc = [[MTLTextureDescriptor alloc] init];
	// 像素格式，每个像素有 RGBA，每个 channel 是 8-bit
	desc.pixelFormat = MTLPixelFormatBGRA8Unorm;
	desc.width = img.width;
	desc.height = img.height;
	// 1. 创建 MTLTexture
	id<MTLTexture> texture = [_device newTextureWithDescriptor:desc];
	// 每行字节数
	NSUInteger bytesPerRow = 4 * img.width;
	// 将要复制的 data 范围
	MTLRegion region = {
		{ 0, 0, 0 },
		{ img.width, img.height, 1}
	};
	// 2. 将 img 数据复制到 texture
	[texture replaceRegion:region mipmapLevel:0 withBytes:img.data.bytes bytesPerRow:bytesPerRow];
	return texture;
}

- (void)_loadMetalWithView:(nonnull MTKView *)view {
    
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
	// 创建新 buffer
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	commandBuffer.label = @"MyCommand";

	// 获得 RenderPassDescriptor
	MTLRenderPassDescriptor *renderDesc = view.currentRenderPassDescriptor;
	if (renderDesc != nil) {
		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderDesc];
		renderEncoder.label = @"MyRenderEncoder";
		// 设定区域、管道状态等等
		[renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
		[renderEncoder setRenderPipelineState:_pipelineState];
		[renderEncoder setVertexBuffer:_vertices offset:0 atIndex:WQVertexInputIndexVertices];
		[renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:WQVertexInputIndexViewPortSize];
		[renderEncoder setFragmentTexture:_texture atIndex:WQTextureIndexBaseColor];
		// 画三角形
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
		[renderEncoder endEncoding];
		[commandBuffer presentDrawable:view.currentDrawable];
	}
	// 提交到 GPU
	[commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
	_viewportSize.x = size.width;
	_viewportSize.y = size.height;
}

@end
