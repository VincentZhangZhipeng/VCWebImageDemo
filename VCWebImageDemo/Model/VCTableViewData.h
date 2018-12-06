//
//  VCTableViewData.h
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/13.
//  Copyright © 2018 zzp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCTableViewData : NSObject<UITableViewDataSource>
- (id)initWithDataSource:(NSMutableArray *)dataSource NS_DESIGNATED_INITIALIZER;

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
