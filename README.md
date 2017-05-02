# PullDownMenu
仿美团下拉搜索菜单框架封装
# 前言
这个控件比较常用，至少目前公司三个项目都用到了这个下拉菜单,是时候封装分享一下了。觉的不错的麻烦点个喜欢，三克油。控件布局使用的有名的第三方约束工具Masonry，如果项目中已经导入的话就不要再次导入了，不然会报错。
> #  注：Masonry配置，一般在pch文件

```
// 定义这个常量，就可以不用在开发过程中使用"mas_"前缀。
#define MAS_SHORTHAND
// 定义这个常量，就可以让Masonry帮我们自动把基础数据类型的数据，自动装箱为对象类型。
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>

```
# demo效果：

![pulldownMenue.gif](http://upload-images.jianshu.io/upload_images/1071689-77bdd45704a50d80.gif?imageMogr2/auto-orient/strip)

# 1.创建下拉菜单并设置代理
```
 menuView = [PullDownMenuView new];
    menuView.dataSource = self;
    [self.view addSubview:menuView];
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.size.height+20);
    }];

```
# 2.添加所有下拉菜单对应的子控制器

为什么要这样设计? 因为每个app对应的下拉菜单不确定，所以交给各个开 发者决定，下拉菜单的界面。
```
- (NSArray *)viewControlls {
    if (!_viewControlls) {
        _viewControlls = @[[NSClassFromString(@"TestViewController1") new],
                           [NSClassFromString(@"TestViewController2") new],
                           [NSClassFromString(@"TestViewController3") new],
                           [NSClassFromString(@"TestViewController2") new]];
    }
    return _viewControlls;
}
- (void)setUPChildVC {
    for (UIViewController *vc in self.viewControlls) {
        [self addChildViewController:vc];
    }
}
```
# 3.实现PullDownMenu数据源方法
```
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
```
# 4.【更新菜单标题,需要发送通知给我】

为什么要这样设计？解耦，自己的控制器中就不需要导入我的框架的头文件了，侵入性不大。

# 【更新菜单标题步骤】

1.把 【extern NSString * const UpdateMenuTitleNote;】这行代码拷贝到自己控制器中，这个在PullDownMenuView.h中

2.在选中标题的方法中，发送以下通知
[[NSNotificationCenter defaultCenter] postNotificationName:UpdateMenuTitleNote object:self userInfo:@{@"title":cell.textLabel.text}];

+ 3.1 postNotificationName：通知名称 =>【UpdateMenuTitleNote】

+ 3.2 object:谁发送的通知 =>【self】(当前控制器)

+ 3.3 userInfo:选中标题信息 => 可以多个key,多个value,没有固定的，因为有些界面，需要勾选很多选项，key可以随意定义。

+ 3.4 底层会自动判定，当前userInfo有多少个value,如果有一个就会直接更新菜单标题，有多个就会更新，满足大部分需求。

+ 3.5 发出通知，会自动弹回下拉菜单
> 可以参考TestViewController3中代码

```
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
```
[简书详情](http://www.jianshu.com/p/69a4ffcd24c5)

