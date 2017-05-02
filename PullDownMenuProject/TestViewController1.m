//
//  TestViewController1.m
//  PullDownMenuProject
//
//  Created by apple on 2017/5/2.
//  Copyright © 2017年 gupeng. All rights reserved.
//
extern NSString * const UpdateMenuTitleNote;
#import "TestViewController1.h"

@interface TestViewController1 ()<UITableViewDelegate,UITableViewDataSource>
/** left */
@property (nonatomic, strong) UITableView *leftTableView;
/** right */
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic , strong) NSMutableArray *dataArr;
/** select index */
@property (nonatomic, assign) NSInteger firstIndex;
@end

@implementation TestViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    [self.view addSubview:self.leftTableView];
    [self.view addSubview:self.rightTableView];
    [self.leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view);
        make.right.equalTo(self.rightTableView.left).offset(-1.0/[UIScreen mainScreen].scale);
    }];
    [self.rightTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.view);
        make.width.equalTo(self.leftTableView).multipliedBy(2.2);
    }];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        NSArray *arr = @[@"语文",@"数学",@"英语",@"高数",@"数字电路",@"模拟电路",@"微积分",@"马克思",@"毛概"];
        for (NSInteger i = 0; i<arr.count; i++) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:[arr objectAtIndex:i] forKey:@"title"];
            NSMutableArray *theArr = [NSMutableArray array];
            for (NSInteger j = 0; j<arc4random()%30; j++) {
                NSMutableDictionary *theDic = [NSMutableDictionary dictionary];
                [theDic setValue:[NSString stringWithFormat:@"%@%zd",arr[i],j+1] forKey:@"name"];
                [theDic setValue:@(0) forKey:@"isSelect"];
                [theArr addObject:theDic];
            }
            [dict setValue:theArr forKey:@"list"];
            [_dataArr addObject:dict];
        }
    }
    return _dataArr;
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _rightTableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
    }
    return _rightTableView;
}

#pragma mark UITableViewDataSource and UITableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = [self.dataArr objectAtIndex:self.firstIndex];
    if (tableView == self.leftTableView) {
        return self.dataArr.count;
    }
    return [dict[@"list"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.tintColor = [UIColor colorWithRed:0 green:202/255.0 blue:183/255.0 alpha:1.0];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    NSDictionary *dict = [self.dataArr objectAtIndex:self.firstIndex];
    //左边的tab
    if (tableView == self.leftTableView) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"title"];
        if (self.firstIndex == indexPath.row) {
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:202/255.0 blue:183/255.0 alpha:1.0];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    //右边的tab
    else {
        cell.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        NSDictionary *dic = [dict[@"list"] objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic objectForKey:@"name"];
        if ([dic[@"isSelect"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:202/255.0 blue:183/255.0 alpha:1.0];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leftTableView) {
        self.firstIndex = indexPath.row;
        NSArray *arr = [[self.dataArr objectAtIndex:self.firstIndex] objectForKey:@"list"];
        if (arr.count == 0) {
            for (NSDictionary *dict in self.dataArr) {
                for (NSDictionary *theDic in dict[@"list"]) {
                    [theDic setValue:@(0) forKey:@"isSelect"];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateMenuTitleNote object:self userInfo:@{@"title":[[self.dataArr objectAtIndex:self.firstIndex] objectForKey:@"title"]}];
        }
        [self.leftTableView reloadData];
        [self.rightTableView reloadData];
    }
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
         NSDictionary *theDic = [[[self.dataArr objectAtIndex:self.firstIndex] objectForKey:@"list"] objectAtIndex:indexPath.row];
        if (![theDic[@"isSelect"] boolValue]) {
            for (NSInteger i = 0; i<self.dataArr.count; i++) {
                NSDictionary *dict = [self.dataArr objectAtIndex:i];
                for (NSInteger j = 0; j<[dict[@"list"] count]; j++) {
                    NSDictionary *dic = [dict[@"list"] objectAtIndex:j];
                    if (i == self.firstIndex && j == indexPath.row) {
                        [dic setValue:@(1) forKey:@"isSelect"];
                    }
                    else
                        [dic setValue:@(0) forKey:@"isSelect"];
                }
            }
            
            [tableView reloadData];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateMenuTitleNote object:self userInfo:@{@"title":theDic[@"name"]}];
        });
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    NSLog(@"释放了");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
