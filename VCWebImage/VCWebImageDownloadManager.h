//
//  VCWebImageDownloadManager.h
//  VCWebImage
//
//  Created by ZHANG Zhipeng on 2018/11/11.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCMarco.h"
#import "VCCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCWebImageDownloadManager : NSObject
@property (nonatomic, assign) VCCacheOptions cacheOption;
+ (instancetype)sharedManager;
- (void)downloadImageWithURL:(NSURL *)url CompletionBlock:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock;
- (void)cancelAllOperations;
@end

NS_ASSUME_NONNULL_END
