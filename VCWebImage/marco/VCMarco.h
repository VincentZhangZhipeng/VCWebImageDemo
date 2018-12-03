//
//  VCMarco.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/12.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER)
#define UNLOCK(lock) dispatch_semaphore_signal(lock)

typedef enum : NSUInteger {
	VCCachePolicyMemory,
	VCCachePolicyNone,
	VCCachePolicyDisk,
} VCCachePolicy;

typedef void(^VCCompletionBlock)(NSError* error, BOOL finieshed, UIImage *image);
typedef void(^VCProgressBlock)(NSError* error, float progress, float total, UIImage *image);

NS_ASSUME_NONNULL_BEGIN

@interface VCMarco : NSObject

@end

NS_ASSUME_NONNULL_END
