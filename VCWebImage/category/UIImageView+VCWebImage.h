//
//  UIImageView+VCWebImage.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/13.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCMarco.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (VCWebImage)
- (void)vc_webImageWithURL:(NSURL *)url Completion:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock;
@end

NS_ASSUME_NONNULL_END
