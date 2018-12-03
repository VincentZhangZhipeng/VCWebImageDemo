//
//  VCImageProgressDecoder.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/18.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCImageProgressDecoder : NSObject
@property (nonatomic, strong) UIImage *image;

//- (void)createIamgeWithData:(NSData *)data;
- (void)updateSource:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
