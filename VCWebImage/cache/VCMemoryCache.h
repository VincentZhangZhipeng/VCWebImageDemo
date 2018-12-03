//
//  VCMemoryCache.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCMemoryCache : NSObject
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;
+ (id)sharedCache;
@end

NS_ASSUME_NONNULL_END
