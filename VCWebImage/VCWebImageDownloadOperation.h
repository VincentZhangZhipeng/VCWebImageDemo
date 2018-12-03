//
//  VCWebImageDownloadOperation.h
//  VCWebImage
//
//  Created by ZHANG Zhipeng on 2018/11/10.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCMarco.h"
//NS_OPTIONS(NSUInteger, VCCachePolicy) {
//	VCCachePolicyMemory = 0,
//	VCCachePolicyDisk,
//	VCCachePolicyNone
//};


NS_ASSUME_NONNULL_BEGIN

@interface VCWebImageDownloadOperation : NSOperation
@property (nonatomic, assign) BOOL shouldDecode;
@property (nonatomic, assign) BOOL shouldProgressDecode;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
- (instancetype)initWithURL:(NSURL *)url;
- (void)addTaskWithCompletionBlock:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock;
@end

NS_ASSUME_NONNULL_END
