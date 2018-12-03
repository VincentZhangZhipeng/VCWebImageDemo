//
//  VCCache.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger, VCCacheOptions) {
	VCCacheOptionsNone = 0,
	VCCacheOptionsMemeory,
	VCCacheOptionsDisk,
};
NS_ASSUME_NONNULL_BEGIN

@interface VCCache : NSObject
+ (id)sharedCache;
@property(nonatomic, assign) VCCacheOptions cacheOption;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (void)saveToLocal:(NSData *)data andKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
