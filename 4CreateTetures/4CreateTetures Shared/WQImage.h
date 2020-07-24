//
//  WQImage.h
//  4CreateTetures iOS
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WQImage : NSObject

// 根据 tga 文件地址初始化
- (instancetype)initWithTgaFileAtLocation:(NSURL *)url;

// 像素级的宽和高
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

// 图片 data
@property (nonatomic, strong) NSData *data;

@end

NS_ASSUME_NONNULL_END
