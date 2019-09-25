//
//  Renderer.h
//  3MetalRender2DTriangle Shared
//
//  Created by Qi Wang on 2019/9/24.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import <MetalKit/MetalKit.h>

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

