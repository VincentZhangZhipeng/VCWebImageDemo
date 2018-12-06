//
//  DemoCell.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/12/3.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *customImageView;
@end

NS_ASSUME_NONNULL_END
