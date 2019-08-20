//
//  MetalAdder.h
//  1MetalCompulteBasic
//
//  Created by Qi Wang on 2019/7/31.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)prepareData;
- (void)sendComputeCommand;

@end

NS_ASSUME_NONNULL_END
