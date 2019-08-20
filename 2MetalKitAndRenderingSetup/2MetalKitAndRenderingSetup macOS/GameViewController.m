//
//  GameViewController.m
//  2MetalKitAndRenderingSetup macOS
//
//  Created by Qi Wang on 2019/8/20.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

#import "GameViewController.h"
#import "Renderer.h"

@implementation GameViewController
{
    MTKView *_view;

    Renderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_view = [[MTKView alloc] initWithFrame:CGRectMake(60, 60, 450, 200) device:MTLCreateSystemDefaultDevice()];
	[self.view addSubview:_view];

	_view.enableSetNeedsDisplay = YES;
	
	_view.clearColor = MTLClearColorMake(0.5, 0.5, 1.0, 0.5);

    _renderer = [[Renderer alloc] initWithMetalKitView:_view];

    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];

    _view.delegate = _renderer;
}

@end
