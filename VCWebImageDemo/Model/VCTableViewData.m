//
//  VCTableViewData.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/13.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCTableViewData.h"
#import <UIKit/UIKit.h>

@interface VCTableViewData()<UITableViewDataSource>
@property (nonatomic, assign) NSInteger sections;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, strong) NSArray *dataSources;
@end

@implementation VCTableViewData
- (id)init {
	return [self initWithDataSource:[NSMutableArray array]];
}

- (id)initWithDataSource:(NSMutableArray *)dataSource {
	if (self = [super init]) {
		self.dataSources = [dataSource copy];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.rowIndex;
}

// FIXME: to do
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[UITableViewCell alloc] init];
}

@end
