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
#import "VCTableViewData.h"

@interface ViewController ()<UITableViewDelegate, UIScrollViewDelegate>
//@property (nonatomic, strong) NSMutableArray<NSString *> * images;
@property (nonatomic, strong)VCTableViewData *tableViewData;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *indexToReload;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.tableViewData = [[VCTableViewData alloc]init];
	self.tableView.estimatedRowHeight = 44;
	self.indexToReload = [[NSMutableArray alloc] init];
	self.tableView.dataSource = self.tableViewData;
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


//# pragma mark - TableViewDelegate & dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.tableViewData tableView:tableView heightForRowAtIndexPath:indexPath];
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
