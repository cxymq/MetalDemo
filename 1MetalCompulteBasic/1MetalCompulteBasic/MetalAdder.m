//
//  MetalAdder.m
//  1MetalCompulteBasic
//
//  Created by Qi Wang on 2019/7/31.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import "MetalAdder.h"
#import <Metal/Metal.h>

const unsigned int arrayLength = 1 << 8;
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalAdder {
	//GPU的精简抽象
	id<MTLDevice> _mDevice;
	
	//计算管道状态
	id<MTLComputePipelineState> _mAddFunctionPSO;
	
	//命令队列
	id<MTLCommandQueue> _mCommandQueue;
	
	//保存数据的缓冲区
	id<MTLBuffer> _mBufferA;
	id<MTLBuffer> _mBufferB;
	id<MTLBuffer> _mBufferResult;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device {
	if (self = [super init]) {
		_mDevice = device;
		
		NSError *error = nil;
		
		//Xcode默认编译 .metal 文件为 Metal库
		id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
		if (defaultLibrary == nil) {
			NSLog(@"未发现默认库");
			return nil;
		}
		
		id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
		if (addFunction == nil) {
			NSLog(@"未发现该方法");
			return nil;
		}
		
		_mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
		if (_mAddFunctionPSO == nil) {
			NSLog(@"创建管道状态对象失败：%@", error);
			return nil;
		}
		
		_mCommandQueue = [_mDevice newCommandQueue];
		if (_mCommandQueue == nil) {
			NSLog(@"未发现命令队列");
			return nil;
		}
		
	}
	return self;
}

- (void)prepareData {
	//缓冲区分配内存大小，共享模式，CPU 和 GPU 都可访问
	_mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
	_mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
	_mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
	
	[self generateRandomFloatData:_mBufferA];
	[self generateRandomFloatData:_mBufferB];
}

//为缓冲区生成随机数
- (void)generateRandomFloatData:(id<MTLBuffer>)buffer {
	float *dataPtr = buffer.contents;
	
	for(unsigned long index = 0; index < arrayLength; index++) {
		dataPtr[index] = (float)rand() / (float)(RAND_MAX);
	}
}

- (void)sendComputeCommand {
	//用命令队列创建命令缓冲区
	id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
	assert(commandBuffer != nil);
	
	//创建计算编码器,用于 将命令编写进 缓冲区
	id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
	assert(commandEncoder != nil);
	
	[self encodeAddCommand:commandEncoder];
	
	//命令编写完毕，结束编码
	[commandEncoder endEncoding];
	
	//命令缓冲区 提交到 队列
	[commandBuffer commit];
	
	//等待完成
	[commandBuffer waitUntilCompleted];
	
}

//编写命令
- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)encoder {
	//为编码器设置计算管道状态对象, 管道状态在初始化时生成，简单理解从 .metal 文件中获取函数，相当于设定编码器的规则（个人理解）
	[encoder setComputePipelineState:_mAddFunctionPSO];
	
	//相当于对函数的参数赋值，代表前三个参数，第四个 index 会自动生成
	[encoder setBuffer:_mBufferA offset:0 atIndex:0];
	[encoder setBuffer:_mBufferB offset:0 atIndex:1];
	[encoder setBuffer:_mBufferResult offset:0 atIndex:2];
	
	//确定网格大小,arrayLength 网格宽度， 1 网格高度， 1 网格深度，1D（线性）
	MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
	
	//计算线程组的大小
	NSUInteger threadCount = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
	if (threadCount > arrayLength) {
		//最大值如果比数组还大，没必要那么大
		threadCount = arrayLength;
	}
	MTLSize threadgroupSize = MTLSizeMake(threadCount, 1, 1);
//	MTLSize threadgroupSize = MTLSizeMake(512, 1, 1);
	
	[encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
	
}

@end
