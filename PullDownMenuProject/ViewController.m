//
//  ViewController.m
//  PullDownMenuProject
//
//  Created by apple on 2017/5/2.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import "ViewController.h"
#import "PullDownMenuView.h"

@interface ViewController () <PullDownMenuViewDataSource,UITableViewDelegate,UITableViewDataSource>
{
    PullDownMenuView *menuView;
}
/** 标题文字 */
@property (nonatomic, strong) NSArray *titleArr;
/** vcs */
@property (nonatomic, strong) NSArray *viewControlls;
@property (nonatomic , strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleDone target:self action:@selector(next)];
    self.navigationItem.title = [self.navigationController.viewControllers count]>1?[NSString stringWithFormat:@"第%zd个",[self.navigationController.viewControllers count]-1]:@"ROOT_VC";
    
    menuView = [PullDownMenuView new];
    menuView.dataSource = self;
    [self.view addSubview:menuView];
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.size.height+20);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuView.bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
     [self setUPChildVC];

}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.hidden ? 0:49, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.hidden ? 0:49, 0);
        _tableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return arc4random()%50+2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)next {
    UIViewController *vc = [self.class new];
//    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUPChildVC {
    for (UIViewController *vc in self.viewControlls) {
        [self addChildViewController:vc];
    }
}
#pragma mark - PullDownMenuDataSource
// 返回下拉菜单多少列
- (NSInteger)numberOfColsInMenu:(PullDownMenuView *)pullDownMenu {
    return self.viewControlls.count;
}

// 返回下拉菜单每列按钮标题
- (NSString *)pullDownMenu:(PullDownMenuView *)pullDownMenu titleForColAtIndex:(NSInteger)index {
    return [self.titleArr objectAtIndex:index];
}

// 返回下拉菜单每列对应的控制器
- (UIViewController *)pullDownMenu:(PullDownMenuView *)pullDownMenu viewControllerForColAtIndex:(NSInteger)index {
    return [self.viewControlls objectAtIndex:index];
}

// 返回下拉菜单每列对应的高度
- (CGFloat)pullDownMenu:(PullDownMenuView *)pullDownMenu heightForColAtIndex:(NSInteger)index {
    if (index == 0) {
        return 233;
    }
    else if (index == 1){
        return 200;
    }
    else if (index == 2){
        return 44*4;
    }
    return 250;
}

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"全部",
                      @"附近",
                      @"智能排序",
                      @"刷选"];
    }
    return _titleArr;
}
- (NSArray *)viewControlls {
    if (!_viewControlls) {
        _viewControlls = @[[NSClassFromString(@"TestViewController1") new],
                           [NSClassFromString(@"TestViewController2") new],
                           [NSClassFromString(@"TestViewController3") new],
                           [NSClassFromString(@"TestViewController2") new]];
    }
    return _viewControlls;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)dealloc {
    NSLog(@"delloc");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    NSLog(@"did rotated to new Orientation, view Information %@", self.view);
    [menuView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.size.height+20);
    }];
}

@end
