//
//  VCImageDecoder.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/14.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCImageDecoder.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>

static inline CGColorSpaceRef VCGColorSpace(){
	static CGColorSpaceRef colorspaceRef;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		colorspaceRef = CGColorSpaceCreateDeviceRGB();
	});
	return colorspaceRef;
}

@implementation VCImageDecoder

BOOL hasAlpha(CGImageRef image) {
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image);
	BOOL hasAlpha = NO;
	// ios有rgb有5种，存在alpha的有以下四种
	if (alphaInfo == kCGImageAlphaLast ||
		alphaInfo == kCGImageAlphaFirst ||
		alphaInfo == kCGImageAlphaPremultipliedLast ||
		alphaInfo == kCGImageAlphaPremultipliedFirst
		) {
		hasAlpha = YES;
	}
	return hasAlpha;
}

- (CGImageRef)decodeImage:(UIImage *)image {
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host; // 字节顺序，包含了大端机和小端机的情况
	bitmapInfo |= hasAlpha(image.CGImage) ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast;
	/***
	 ** CGBitmapContextCreate(void * __nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef cg_nullable space, uint32_t bitmapInfo)
	 **
	 ** bitsPerComponent是每个颜色通道包含的字节数，选择8，bytesPerRow是每行o有几个字节，0代表apple底层会自动计算，且进行字节对齐
	 ***/
	CGContextRef contextRef = CGBitmapContextCreate(NULL, image.size.height, image.size.width, 8, 0, VCGColorSpace(), bitmapInfo);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
	CGImageRef newImage = CGBitmapContextCreateImage(contextRef);
	CFRelease(contextRef);
	return newImage;
}

- (NSData *)encodeImage:(UIImage *)image {
	NSData *imageData;
	if (hasAlpha(image.CGImage)) {
		imageData = UIImagePNGRepresentation(image);
	} else {
		imageData = UIImageJPEGRepresentation(image, 0.9);
	}
	return imageData;
}

- (void)dealloc
{
	NSLog(@"%@ dealloc", [self description]);
}
@end
