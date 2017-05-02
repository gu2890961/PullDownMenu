//
//  TestViewController3.m
//  PullDownMenuProject
//
//  Created by apple on 2017/5/2.
//  Copyright © 2017年 gupeng. All rights reserved.
//
extern NSString * const UpdateMenuTitleNote;
#import "TestViewController3.h"

@interface TestViewController3 ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger selectIndex;
}
/** tab */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *array;
@end

@implementation TestViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}



- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
    }
    return _tableView;
}
- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray arrayWithObjects:@"智能排序",@"离我最近",@"好评优先",@"人气最高", nil];
    }
    return _array;
}
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        _normalColor = RGB(73, 73, 73);
//        _selectColor = RGB(0, 202, 183);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.tintColor = [UIColor colorWithRed:0 green:202/255.0 blue:183/255.0 alpha:1.0];
        
    }
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    if (selectIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:202/255.0 blue:183/255.0 alpha:1.0];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1.0];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectIndex == indexPath.row) {
        
    }
    else{
        NSInteger oldIndex = selectIndex;
        selectIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0],indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateMenuTitleNote object:self userInfo:@{@"title":[self.array objectAtIndex:selectIndex]}];
    });
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
