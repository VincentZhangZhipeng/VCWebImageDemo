//
//  VCWebImageDownloadManager.m
//  VCWebImage
//
//  Created by ZHANG Zhipeng on 2018/11/11.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCWebImageDownloadManager.h"
#import "VCWebImageDownloadOperation.h"
#import "VCMarco.h"

@implementation VCWebImageDownloadManager {
	NSMapTable *_progressingOperations;
	dispatch_semaphore_t _operationsLock;
	NSOperationQueue *_downloadQueue;
}

+ (instancetype)sharedManager {
	static VCWebImageDownloadManager* _sharedManger;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManger = [[VCWebImageDownloadManager alloc] init];
	});
	return _sharedManger;
}

- (id)init {
	if (self = [super init]) {
		_progressingOperations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
		_operationsLock = dispatch_semaphore_create(1);
		_cacheOption = VCCacheOptionsDisk;
		_downloadQueue = [[NSOperationQueue alloc]init];
		_downloadQueue.maxConcurrentOperationCount = 2;
	}
	
	return self;
}

# pragma mark - public methods
- (void)downloadImageWithURL:(NSURL *)url CompletionBlock:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock {
	LOCK(_operationsLock);
	UIImage *image = [[VCCache sharedCache] objectForKey:url.absoluteString];
	if (image) {
		if (completionBlock) {
			completionBlock(nil, true, image);
		}
	} else {
		VCWebImageDownloadOperation *operation = [_progressingOperations objectForKey:url];
		if (!operation) {
			operation = [[VCWebImageDownloadOperation alloc]initWithURL:url];
			operation.shouldProgressDecode = true;
			[_progressingOperations setObject:operation forKey:url];
		}
		if (![_downloadQueue.operations containsObject:operation]) {
			[_downloadQueue addOperation:operation];
		}
		[operation addTaskWithCompletionBlock:completionBlock andProgressBlock:progressBlock];
	}
	UNLOCK(_operationsLock);
	
}

- (void)cancelAllOperations {
	[_downloadQueue cancelAllOperations];
	LOCK(_operationsLock);
	[_progressingOperations removeAllObjects];
	_downloadQueue = [[NSOperationQueue alloc]init];
	UNLOCK(_operationsLock);
}

@end
