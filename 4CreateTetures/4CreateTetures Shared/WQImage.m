//
//  WQImage.m
//  4CreateTetures iOS
//
//  Created by Qi Wang on 2020/7/9.
//  Copyright © 2020 Qi Wang. All rights reserved.
//

#import "WQImage.h"
#include <simd/simd.h>

@implementation WQImage

- (instancetype)initWithTgaFileAtLocation:(NSURL *)url {
	self = [super init];
	if (self) {
		// 首先判断文件格式
		NSString *fileExtension = url.pathExtension;
		if (!([fileExtension caseInsensitiveCompare:@"tga"] == NSOrderedSame)) {
			NSLog(@"文件不是 tga 格式！！！");
			return nil;
		}
		// TGAHeader 的结构
		typedef struct __attribute__ ((packed)) TGAHeader {
			uint8_t  IDSize;         // Size of ID info following header
            uint8_t  colorMapType;   // Whether this is a paletted image
            uint8_t  imageType;      // type of image 0=none, 1=indexed, 2=rgb, 3=grey, +8=rle packed

            int16_t  colorMapStart;  // Offset to color map in palette
            int16_t  colorMapLength; // Number of colors in palette
            uint8_t  colorMapBpp;    // Number of bits per palette entry

            uint16_t xOrigin;        // X Origin pixel of lower left corner if tile of larger image
            uint16_t yOrigin;        // Y Origin pixel of lower left corner if tile of larger image
            uint16_t width;          // Width in pixels
            uint16_t height;         // Height in pixels
            uint8_t  bitsPerPixel;   // Bits per pixel 8,16,24,32
            union {
                struct
                {
                    uint8_t bitsPerAlpha : 4;
                    uint8_t topOrigin    : 1;
                    uint8_t rightOrigin  : 1;
                    uint8_t reserved     : 2;
                };
                uint8_t descriptor;
            };
		} TGAHeader;

		// 读取文件数据
		NSError *err;
		NSData *fileData = [[NSData alloc] initWithContentsOfURL:url options:0x0 error:&err];
		if (!fileData) {
			NSLog(@"无法打开 tga 文件：%@", err.localizedDescription);
			return nil;
		}
		// bytes 返回连续内存区域的指针
		TGAHeader *tgaInfo = (TGAHeader *)fileData.bytes;
		if(tgaInfo->imageType != 2) {
			NSLog(@"仅支持 non-compressed BGR(A) TGA 文件");
			return nil;
		}
		if(tgaInfo->colorMapType) {
			NSLog(@"不支持带有 colorMapType 的 tga 文件");
			return nil;
		}
		if(tgaInfo->xOrigin || tgaInfo->yOrigin) {
			NSLog(@"不支持 non-zero Origin 的 tga 文件");
			return nil;
		}

		// 定义变量 srcBytesPerPixel，每个像素的字节数
		NSUInteger srcBytesPerPixel;
		if (tgaInfo->bitsPerPixel == 32) {
			srcBytesPerPixel = 4;
			if (tgaInfo->bitsPerAlpha != 8) {
				NSLog(@"仅支持 32 位像素并且 8 位透明度的 tga 文件");
				return nil;
			}
		} else if (tgaInfo->bitsPerPixel == 24) {
			srcBytesPerPixel = 3;
			if (tgaInfo->bitsPerAlpha != 0) {
				NSLog(@"仅支持 24 位像素的 tga 文件");
				return nil;
			}
		} else {
			NSLog(@"仅支持 32 和 24 位像素的 tga 文件");
			return nil;
		}

		_width = tgaInfo->width;
		_height = tgaInfo->height;
		// 此处直接 * 4，而不是 srcBytesPerPixel，因为所有的图像都要处理成 32-bit 来处理
		NSUInteger dataSize = _width * _height * 4;

		NSMutableData *newData = [[NSMutableData alloc] initWithLength:dataSize];
		// 原图片大小 = 文件字节数 + tga header 大小 + IDSize
		uint8_t *srcImgData = ((uint8_t *)fileData.bytes + sizeof(TGAHeader) + tgaInfo->IDSize);
		uint8_t *dstImgData = newData.mutableBytes;

		for (int y = 0; y < _height; y++) {
			// 判断是否从 top 开始
			NSUInteger srcRow = (tgaInfo->topOrigin) ? y : _height - 1 - y;
			for (int x = 0; x < _width; x++) {
				// 判断是否从 right 开始
				NSUInteger srcColumn = (tgaInfo->rightOrigin) ? _width - 1 - x : x;
				NSUInteger srcPixelIndex = srcBytesPerPixel * (srcRow * _width + srcColumn);
				NSUInteger dstPixelIndex = 4 * (_width * y + x);
				// 将原文件复制到目标文件
				dstImgData[dstPixelIndex + 0] = srcImgData[srcPixelIndex + 0];
				dstImgData[dstPixelIndex + 1] = srcImgData[srcPixelIndex + 1];
				dstImgData[dstPixelIndex + 2] = srcImgData[srcPixelIndex + 2];
				if (tgaInfo->bitsPerAlpha == 32) {
					dstImgData[dstPixelIndex + 3] = srcImgData[dstPixelIndex +3];
				} else {
					dstImgData[dstPixelIndex + 3] = 255;
				}
			}
		}
		_data = newData;
	}
	return self;
}

@end
