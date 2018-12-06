//
//  VCTableViewData.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/13.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCTableViewData.h"
#import "UIImageView+VCWebImage.h"
#import <UIKit/UIKit.h>
#import "DemoCell.h"

@interface VCTableViewData()<UITableViewDataSource>
@property (nonatomic, assign) NSInteger sections;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, strong) NSArray *dataSources;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *heights;
@end

@implementation VCTableViewData
- (id)init {
	NSMutableArray *array = [NSMutableArray array];
	for (int i = 0; i < 30; i++) {
		[array addObject:@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3812692777,2422717531&fm=27&gp=0.jpg"];
		[array addObject:@"http://img3.cache.netease.com/photo/0005/2014-01-04/9HNATC4M0AI90005.jpg"];
		[array addObject:@"http://mmbiz.qpic.cn/mmbiz/PwIlO51l7wuFyoFwAXfqPNETWCibjNACIt6ydN7vw8LeIwT7IjyG3eeribmK4rhibecvNKiaT2qeJRIWXLuKYPiaqtQ/0"];
		[array addObject:@"https://i.rtings.com/images/reviews/tv/vizio/m-series-2015/m-series-2015-upscaling-4k-large.jpg"];
	}
	return [self initWithDataSource:array];
}

- (id)initWithDataSource:(NSMutableArray *)dataSource {
	if (self = [super init]) {
		self.dataSources = [dataSource copy];
		self.heights = [[NSMutableArray alloc] init];
		
	}
	return self;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = [self.heights[indexPath.row] floatValue];
	return height ? height : tableView.estimatedRowHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections ? self.sections : 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demoCell"];
	if (!cell) {
		cell = [[DemoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demoCell"];
	}
	
	if (tableView.dragging || tableView.decelerating) {
		return cell;
	}
	
	cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
		//		[self loadImageWithCell:indexPath];
	NSURL *url = [NSURL URLWithString:self.dataSources[indexPath.row]];
	[cell.customImageView vc_webImageWithURL:url Completion: ^(NSError *error, BOOL finished, UIImage *image) {
		//		NSLog(@"finish");
	} andProgressBlock: ^(NSError* error, float progress, float total, UIImage *image){
		//		NSLog(@"progress is %f", progress);
	}];
	return cell;
}

@end
