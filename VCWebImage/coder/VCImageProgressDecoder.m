//
//  VCImageProgressDecoder.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/18.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCImageProgressDecoder.h"
#import "VCMarco.h"

@implementation VCImageProgressDecoder {
	CGImageSourceRef _imageSource;
	BOOL _final;
}

- (void)updateSource:(NSData *)data {
	if (_final) return;
	@synchronized (self) {
		if (!_imageSource) {
			_imageSource = CGImageSourceCreateIncremental(NULL);
			if (_imageSource) CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef) data, false);
		} else {
			CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef) data, false);
		}
		if (CGImageSourceGetStatus(_imageSource) == kCGImageStatusComplete) {
			_final = true;
			CFRelease(_imageSource);
		} else {
			[self createIamgeWithData:data];
		}
	}
}

- (void)createIamgeWithData:(NSData *)data {
	if (!_imageSource) return;
	CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
	if (imageRef) {
		self.image = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
	}
}

- (void)dealloc {
	NSLog(@"progress decoder dealloc");
}

@end
