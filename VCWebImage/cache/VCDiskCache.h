//
//  VCCacheManager.h
//  VedioVIPHelper
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^VCSerchBlock)(NSData *data);
typedef void(^VCDeleteBlock)(BOOL finished);

NS_ASSUME_NONNULL_BEGIN

@interface VCDiskCache : NSObject
+ (id)sharedManager;
- (NSData *)searchObjectForKey:(NSString *)key;
- (BOOL)deleteObjectForKey:(NSString *)key;
- (void)deleteObjectForKey:(NSString *)key completionBlock:(VCDeleteBlock)block;
- (void)searchObjectForKey:(NSString *)key completionBlock:(VCSerchBlock) block;
- (void)insertData:(NSData *)data forKey:(NSString *)key completionBlock:(VCDeleteBlock)block;
- (NSMutableArray<NSData *> *)searchObjects;
- (void)setObject:(id)object forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
