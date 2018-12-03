//
//  ViewController.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/12.
//  Copyright © 2018 zzp. All rights reserved.
//

/**
 * 优化方向：https://blog.csdn.net/liyunxiangrxm/article/details/75174401
 **/

#import "ViewController.h"
#import "UIImageView+VCWebImage.h"

@interface DemoCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *customImageView;
@end

@implementation DemoCell
@end

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> * images;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *indexToReload;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *heights;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.images = [NSMutableArray array];
	for (int i = 0; i < 30; i++) {
		[self.images addObject:@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3812692777,2422717531&fm=27&gp=0.jpg"];
		[self.images addObject:@"http://img3.cache.netease.com/photo/0005/2014-01-04/9HNATC4M0AI90005.jpg"];
		[self.images addObject:@"http://mmbiz.qpic.cn/mmbiz/PwIlO51l7wuFyoFwAXfqPNETWCibjNACIt6ydN7vw8LeIwT7IjyG3eeribmK4rhibecvNKiaT2qeJRIWXLuKYPiaqtQ/0"];
		[self.images addObject:@"https://i.rtings.com/images/reviews/tv/vizio/m-series-2015/m-series-2015-upscaling-4k-large.jpg"];
	}
	self.tableView.estimatedRowHeight = 44;
	self.indexToReload = [[NSMutableArray alloc] init];
//	self.heights = [[NSMutableArray alloc] init];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


# pragma mark - TableViewDelegate & dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = [self.heights[indexPath.row] floatValue];
	return height ? height : tableView.estimatedRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demoCell"];
	if (!cell) {
		cell = [[DemoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demoCell"];
	}
	cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
	if (self.tableView.dragging || self.tableView.decelerating) {
		return cell;
	} else {
//		[self loadImageWithCell:indexPath];
		NSURL *url = [NSURL URLWithString:self.images[indexPath.row]];
		[cell.customImageView vc_webImageWithURL:url Completion: ^(NSError *error, BOOL finished, UIImage *image) {
			//		NSLog(@"finish");
		} andProgressBlock: ^(NSError* error, float progress, float total, UIImage *image){
			//		NSLog(@"progress is %f", progress);
		}];
	}

	return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self reloadTableView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self reloadTableView];
}

- (void)reloadTableView {
	for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

@end
