//
//  Renderer.h
//  4CreateTetures Shared
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
//

#import <MetalKit/MetalKit.h>

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

