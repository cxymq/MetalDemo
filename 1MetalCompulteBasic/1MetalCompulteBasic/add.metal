//
//  add.metal
//  1MetalCompulteBasic
//
//  Created by Qi Wang on 2019/7/31.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
///在GPU上计算
kernel void add_arrays(device const float *inA,
					   device const float *inB,
					   device float *result,
					   uint index [[thread_position_in_grid]]) {
	
	result[index] = inA[index] + inB[index];
}
