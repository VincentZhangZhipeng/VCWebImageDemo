//
//  VCCache.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCCache.h"
#import "VCMemoryCache.h"
#import "VCDiskCache.h"
#import "VCImageDecoder.h"

@implementation VCCache {
	dispatch_queue_t _cacheQueue;
}

+ (id)sharedCache {
	static VCCache* _cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_cache = [[VCCache alloc] initWithCacheOption:VCCacheOptionsDisk];
	});
	return _cache;
}

- (id)initWithCacheOption:(VCCacheOptions)cacheOption {
	if (self=[super init]) {
		_cacheOption = cacheOption;
		_cacheQueue = dispatch_queue_create("vc.cache.queue", DISPATCH_QUEUE_CONCURRENT);
	}
	return self;
}

- (void)setObject:(id)object forKey:(id)key {
	switch (_cacheOption) {
		case VCCacheOptionsDisk:
			[[VCDiskCache sharedManager] setObject:object forKey:key];
			[[VCMemoryCache sharedCache] setObject:object forKey:key];
//			dispatch_async(_cacheQueue, ^{
//				[[VCMemoryCache sharedCache] setObject:object forKey:key];
//			});
			break;
		case VCCacheOptionsMemeory:
			[[VCMemoryCache sharedCache] setObject:object forKey:key];
			break;
		default:
			[self saveToLocal:object andKey:key];
			break;
	}
}

- (id)objectForKey:(id)key {
	id object;
	switch (_cacheOption) {
		case VCCacheOptionsDisk:
			object = [[VCMemoryCache sharedCache] objectForKey:key];
			if (object) {
				break;
			}
			object =[UIImage imageWithData: [[VCDiskCache sharedManager] searchObjectForKey:key]];
			break;
		case VCCacheOptionsMemeory:
			object = [[VCMemoryCache sharedCache] objectForKey:key];
			break;
		default:
			break;
	}
	return object;
}

- (void)removeObjectForKey:(id)key {
	switch (_cacheOption) {
		case VCCacheOptionsDisk:
			[[VCMemoryCache sharedCache] removeObjectForKey:key];
			[[VCDiskCache sharedManager] removeObjectForKey:key];
		case VCCacheOptionsMemeory:
			[[VCMemoryCache sharedCache] removeObjectForKey:key];
			break;
		default:
			break;
	}
}

- (void)saveToLocal:(NSData *)data andKey:(NSString *)key {
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *akey = [[key componentsSeparatedByString:@"/"] lastObject];
	
	NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:akey];  // 保存文件的名称
	BOOL result =[data writeToFile:filePath atomically:YES]; // 保存成功会返回YES
	if (result == YES) {
		NSLog(@"%@ 保存成功", filePath);
	}
}
@end
