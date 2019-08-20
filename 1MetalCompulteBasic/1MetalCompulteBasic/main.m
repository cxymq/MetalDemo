//
//  main.m
//  1MetalCompulteBasic
//
//  Created by Qi Wang on 2019/7/31.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"

const unsigned int arrayLength2 = 1 << 8;

void add_arrays(const float *inA,
				const float *inB,
				float *result,
				int length) {
	for (int i = 0; i < length; i++) {
		result[i] = inA[i] + inB[i];
	}
}

void generateRandomFloatData(float *inA) {
	for(unsigned long index = 0; index < arrayLength2; index++) {
		inA[index] = (float)rand() / (float)(RAND_MAX);
	}
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		
		//此处比较时间没有意义，数据太少
		NSLog(@"CPU计算开始......");
		float inA[arrayLength2];
		float inB[arrayLength2];
		float inResult[arrayLength2];
		generateRandomFloatData(inA);
		generateRandomFloatData(inB);
		
		add_arrays(inA, inB, inResult, arrayLength2);
		
		NSLog(@"CPU计算结束......");
		
		NSLog(@"GPU计算开始......");
		id<MTLDevice> device = MTLCreateSystemDefaultDevice();
		
		MetalAdder *metalAddr = [[MetalAdder alloc] initWithDevice:device];
		[metalAddr prepareData];
		[metalAddr sendComputeCommand];
		NSLog(@"GPU计算结束......");
		
	}
	return 0;
}
