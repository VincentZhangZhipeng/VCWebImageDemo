//
//  VCImageDecoder.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/14.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCImageDecoder : NSObject
- (CGImageRef)decodeImage:(UIImage *)image;
- (NSData *)encodeImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
