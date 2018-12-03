//
//  UIImageView+VCWebImage.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/13.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "UIImageView+VCWebImage.h"
#import "VCWebImageDownloadManager.h"

@implementation UIImageView (VCWebImage)
- (void)vc_webImageWithURL:(NSURL *)url Completion:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock {
	__weak typeof(self) weakSelf = self;
	[[VCWebImageDownloadManager sharedManager] downloadImageWithURL:url CompletionBlock:^(NSError *error, BOOL finieshed, UIImage *image) {
		__strong typeof(self)strongSelf = weakSelf;
		if (!error && image) {
			dispatch_async(dispatch_get_main_queue(), ^{
				strongSelf.image = image;
			});
			if (completionBlock) {
				completionBlock(error, finieshed, image);
			}
		} else {
			if (completionBlock) {
				completionBlock(error, finieshed, nil);
			}
		}
		
	} andProgressBlock:	 ^(NSError* error, float progress, float total, UIImage *image) {
		if (progressBlock) {
			__strong typeof(self)strongSelf = weakSelf;
			strongSelf.image = image;
			progressBlock(nil, 0, 0, image);
		}
	}];
}
@end
