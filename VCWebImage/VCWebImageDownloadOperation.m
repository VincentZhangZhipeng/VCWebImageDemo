//
//  VCWebImageDownloadOperation.m
//  VCWebImage
//
//  Created by ZHANG Zhipeng on 2018/11/10.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCWebImageDownloadOperation.h"
#import "VCMarco.h"
#import "VCImageDecoder.h"
#import "VCImageProgressDecoder.h"
#import "VCCache.h"

@interface VCWebImageDownloadOperation()<NSURLSessionDataDelegate, NSURLSessionDelegate>
@property (nonatomic, getter=isCancelled, assign) BOOL cancelled;
@property (nonatomic, getter=isExecuting, assign) BOOL executing;
@property (nonatomic, getter=isFinished, assign) BOOL finished;
@property (nonatomic, strong)VCImageProgressDecoder *progressDecoder;
@property (nonatomic, strong) NSMutableArray<VCCompletionBlock> *completionBlocks;
@property (nonatomic, strong) NSMutableArray<VCProgressBlock> *progressBlocks;
//@property (nonatomic, copy) VCCompletionBlock completionHandler;
//@property (nonatomic, copy) VCProgressBlock progressBlock;
@end

@implementation VCWebImageDownloadOperation {
	NSMutableData *_responseData;
	dispatch_semaphore_t _lock;
	NSURLSession *_session;
	float _totalBytes;
	NSURL *_url;
	VCImageDecoder *_decoder;
	dispatch_queue_t _imageIOQueue;
}
@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (BOOL)isAsynchronous {
	return true;
}

- (instancetype)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		_responseData = [[NSMutableData alloc] init];
		_lock = dispatch_semaphore_create(1);
		_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
		_url = url;
		_decoder = [[VCImageDecoder alloc] init];
		_shouldDecode = true;
		_imageIOQueue = dispatch_queue_create("vc_image_io_queue", DISPATCH_QUEUE_CONCURRENT);
		self.progressDecoder = [[VCImageProgressDecoder alloc] init];
		self.progressBlocks = [NSMutableArray array];
		self.completionBlocks = [NSMutableArray array];
	}
	return self;
}

# pragma mark - public: add operation
- (void)addTaskWithCompletionBlock:(VCCompletionBlock)completionBlock andProgressBlock:(VCProgressBlock)progressBlock {
	if (completionBlock) {
		[self.completionBlocks addObject:completionBlock];
	}
	if (progressBlock) {
		[self.progressBlocks addObject:progressBlock];
	}
}

- (void)start {
	LOCK(_lock);
	self.finished = NO;
	self.executing = YES;
	UNLOCK(_lock);
	// 使用NSURLRequestUseProtocolCachePolicy会存在本地缓存
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.timeoutInterval ? self.timeoutInterval : DBL_MAX];
	NSURLSessionTask *task = [_session dataTaskWithRequest:request];
	[task resume];
}

- (void)cancel {
	LOCK(_lock);
	self.cancelled = true;
	self.finished = true;
	self.executing = false;
	self.completionBlocks = nil;
	self.progressBlocks = nil;
	UNLOCK(_lock);
	[_session invalidateAndCancel];
}

- (void)done {
	LOCK(_lock);
	self.finished = true;
	self.cancelled = false;
	self.executing = false;
	self.completionBlocks = nil;
	self.progressBlocks = nil;
	UNLOCK(_lock);
	[_session invalidateAndCancel];
}

- (void)dealloc {
	NSLog(@"%@  dealloc",[self description]);
}

#pragma mark - private apis
- (void)setFinished:(BOOL)finished {
	[self willChangeValueForKey:@"isFinished"];
	_finished = finished;
	[self didChangeValueForKey:@"isFinished"];
	
}

- (void)setCancelled:(BOOL)cancelled {
	[self willChangeValueForKey:@"isCancelled"];
	_cancelled = cancelled;
	[self didChangeValueForKey:@"isCancelled"];
}

- (void)setExecuting:(BOOL)executing {
	[self willChangeValueForKey:@"isExecuting"];
	_executing = executing;
	[self didChangeValueForKey:@"isExecuting"];
}


#pragma mark - URLSessionTask
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
	NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
	NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
	if (statusCode > 400 || statusCode == 301) {
		disposition = NSURLSessionResponseCancel;
	}
	_totalBytes = response.expectedContentLength;
	completionHandler(disposition);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
	if (error) {
		[self cancel];
	}
}

//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//	SecTrustRef trust = nil;
//	NSURLCredential *credetial = [[NSURLCredential alloc] initWithTrust: trust];
//	completionHandler(challenge, trust);
//}

# pragma mark - URLSessionDataTaskDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
	[_responseData appendData:data];
	if (self.progressBlocks.count == 0 || !self.shouldProgressDecode) return;
	__weak typeof(self) weakSelf = self;
	dispatch_async(_imageIOQueue, ^{
		__strong typeof(self) strongSelf = weakSelf;
		@autoreleasepool {
			NSData *data = [strongSelf -> _responseData copy];
			[strongSelf.progressDecoder updateSource: data];
			dispatch_async(dispatch_get_main_queue(), ^{
				for (VCProgressBlock block in strongSelf.progressBlocks){
					block(nil, strongSelf->_responseData.length / strongSelf->_totalBytes, strongSelf->_totalBytes, [strongSelf.progressDecoder image]);
				}
			});
		}
	});
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	if (!error) {
		if (_shouldDecode) {
			@autoreleasepool {
				__weak typeof(self) weakSelf = self;
				NSData *data= [_responseData copy];
				UIImage *image = [UIImage imageWithData: data];
				dispatch_async(_imageIOQueue, ^{
					__strong typeof(self) strongSelf = weakSelf;
					CGImageRef cgImage = [strongSelf->_decoder decodeImage:image];
					UIImage *newImage = [UIImage imageWithCGImage:cgImage];
					for (VCCompletionBlock block in strongSelf.completionBlocks) {
						block(error, true, newImage);
					}
					[[VCCache sharedCache] setObject:image forKey:strongSelf->_url.absoluteString];
					[self done];
				});
			}
			
		} else {
			@autoreleasepool {
				UIImage *image = [UIImage imageWithData: _responseData];
				for (VCCompletionBlock block in self.completionBlocks) {
					block(error, true, image);
				}
				[[VCCache sharedCache] setObject:image forKey:_url.absoluteString];
				[self done];
			}
		}
	} else {
		for (VCCompletionBlock block in self.completionBlocks) {
			block(error, false, nil);
		}
	}
}

@end
