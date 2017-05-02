//
//  PullDownMenuView.m
//  PullDownMenuProject
//
//  Created by apple on 2017/5/2.
//  Copyright © 2017年 gupeng. All rights reserved.
//
//设置颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGB(r,g,b) RGBA(r,g,b,1.0)
//默认高度 44
#define KMenuHeight 44
//线条高度
#define KLineHeight 1/[UIScreen mainScreen].scale

#import "PullDownMenuView.h"
#import "MenuButton.h"

// 更新下拉菜单标题通知名称
NSString * const UpdateMenuTitleNote = @"UpdateMenuTitleNote";

@interface PullDownMenuView ()
{
    UIButton *lastButton;
}
/** topView */
@property (nonatomic, strong) UIView *topView;
/** 下拉菜单所有按钮 */
@property (nonatomic, strong) NSMutableArray *menuButtons;
/** 下拉菜单所有控制器 */
@property (nonatomic, strong) NSMutableArray *controllers;
/** 下拉菜单每列高度 */
@property (nonatomic, strong) NSMutableArray *colsHeight;
/** 蒙层背景按钮 */
@property (nonatomic, strong) UIButton *bgView;

@end

@implementation PullDownMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self menuViewConfig];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self menuViewConfig];
    }
    return self;
}

/** 配置*/
- (void)menuViewConfig {
    // default config
    _normalColor = RGB(73, 73, 73);
    _selectColor = RGB(0, 202, 183);
    _titleFont = [UIFont systemFontOfSize:14];
    //线条颜色
    _separateLineColor = RGB(220.f, 220.f, 220.f);

    _separateLineTopMargin = 10;
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(KMenuHeight);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNot:) name:UpdateMenuTitleNote object:nil];
    
}

- (void)dealWithNot:(NSNotification *)note {
    if (![self.controllers containsObject:note.object]) {
        return;
    }
    // 获取列
    NSInteger col = [_controllers indexOfObject:note.object];
    
    // 获取对应按钮
    UIButton *btn = self.menuButtons[col];
    
    // 隐藏下拉菜单
    [self backViewClick:self.bgView];
    
    // 获取所有值
    NSArray *allValues = note.userInfo.allValues;
    
    // 不需要设置标题,字典个数大于1，或者有数组
    if (allValues.count > 1 || [allValues.firstObject isKindOfClass:[NSArray class]]) return ;
    
    // 设置按钮标题
    [btn setTitle:allValues.firstObject forState:UIControlStateNormal];
    
}

- (void)setDataSource:(id<PullDownMenuViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self setUPSubView];
}
#pragma mark - 下拉菜单功能
// 删除之前所有数据,移除之前所有子控件
- (void)clear
{
    [self.menuButtons removeAllObjects];
    [self.controllers removeAllObjects];
    [self.colsHeight removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

// 配置数据
- (void)setUPSubView
{
    // 删除之前所有数据,移除之前所有子控件
//    [self clear];
    
    // 没有数据源，直接返回
    if (self.dataSource == nil) return;
    
    // 判断之前是否添加过,添加过就不添加了
    if (self.menuButtons.count) return;
    
    
    // 判断有没有实现numberOfColsInMenu:
    if (![self.dataSource respondsToSelector:@selector(numberOfColsInMenu:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"未实现（numberOfColsInMenu:）" userInfo:nil];
    }
    
    // 判断有没有实现pullDownMenu:buttonForColAtIndex:
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:titleForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"pullDownMenu:buttonForColAtIndex:）" userInfo:nil];
    }
    
    // 判断每一列控制器的方法是否实现
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:viewControllerForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"pullDownMenu:viewControllerForColAtIndex:这个方法未实现）" userInfo:nil];
        return;
    }
    
    // 判断每一列控制器的方法是否实现
    if (![self.dataSource respondsToSelector:@selector(pullDownMenu:heightForColAtIndex:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"pullDownMenu:heightForColAtIndex:这个方法未实现）" userInfo:nil];
        return;
    }
    
    // 获取有多少列
    NSInteger cols = [self.dataSource numberOfColsInMenu:self];
    
    // 没有列直接返回
    if (cols == 0) return;
    
    UIView * tempView = nil;
    UIView * tempButton= nil;
    UIView *superView = self.topView;
    CGFloat padding = 5.0f;
    // 添加按钮和分割线
    for (NSInteger col = 0; col < cols; col++) {
        
        // 获取按钮
        MenuButton *menuButton = [self setMenuButtonWith:[self.dataSource pullDownMenu:self titleForColAtIndex:col]];
        menuButton.tag = 2333+col;
        [self.topView addSubview:menuButton];
        
        // 添加按钮
        [self.menuButtons addObject:menuButton];
        
        // 保存所有列的高度
        CGFloat height = [self.dataSource pullDownMenu:self heightForColAtIndex:col];
        [self.colsHeight addObject:@(height)];
        
        // 保存所有子控制器
        UIViewController *vc = [self.dataSource pullDownMenu:self viewControllerForColAtIndex:col];
        [self.controllers addObject:vc];
        UIView *separateLine = nil;
        if (cols>1 && col<cols-1) {
            separateLine = [[UIView alloc] init];
            separateLine.backgroundColor = _separateLineColor;
            [self.topView addSubview:separateLine];
            [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(KLineHeight);
                make.top.offset(_separateLineTopMargin);
                make.bottom.offset(-_separateLineTopMargin);
            }];
            
        }
        //添加约束
        if (col == 0) {
            [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(superView).offset(padding);
                make.top.bottom.equalTo(superView);
                make.right.equalTo(separateLine?separateLine.mas_left:superView).offset(-padding);

            }];

        }
        else if (col == cols-1){
            [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(tempView.mas_right).offset(padding);
                make.top.bottom.equalTo(superView);
                make.right.equalTo(superView).offset(-padding);
                make.width.equalTo(tempButton.width);
            }];
        }
        else {
            [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(tempView.mas_right).offset(padding);
                make.top.bottom.equalTo(superView);
                make.right.equalTo(separateLine.mas_left).offset(-padding);
                make.width.equalTo(tempButton.width);
            }];
        }
        tempView = separateLine;
        tempButton = menuButton;
    }
   
    // 添加底部LineView
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = _separateLineColor;
    [self.topView addSubview:bottomView];
    [bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(superView);
        make.height.equalTo(KLineHeight);
    }];
}

- (MenuButton *)setMenuButtonWith:(NSString *)title {
    // 获取按钮
    MenuButton *menuButton = [MenuButton buttonWithType:UIButtonTypeCustom];
    [menuButton setTitleColor:_normalColor forState:UIControlStateNormal];
    [menuButton setTitleColor:_selectColor forState:UIControlStateSelected];
    UIImage *normalImage = [[UIImage imageNamed:@"arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [menuButton setImage:normalImage forState:UIControlStateNormal];
    [menuButton setTitle:title forState:UIControlStateNormal];
    menuButton.titleLabel.font = _titleFont;
    menuButton.selected = NO;
    [menuButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return menuButton;
}

BOOL isAnimating;
#pragma mark - action
- (void)btnClick:(UIButton *)btn {
    if (isAnimating) {
        return;
    }
    btn.selected = !btn.selected;
    if (lastButton && lastButton != btn) {
        lastButton.selected = NO;
    }
    lastButton = btn;
    
    NSInteger index = btn.tag-2333;
    UIView *superView = self.superview;
    
    if (lastButton.isSelected) {
        if (!self.bgView.superview) {
            self.bgView.alpha = 1.0;
            [superView addSubview:self.bgView];
            [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.topView.bottom);
                make.left.right.bottom.equalTo(superView);
            }];
        }
        [self.bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        // 添加对应子控制器的view
        UIViewController *vc = self.controllers[index];
        UIView *theView = vc.view;
        // 设置内容的高度
        CGFloat height = [self.colsHeight[index] floatValue];
        [self.bgView addSubview:theView];
        [theView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.bgView);
            make.height.equalTo(height);
        }];
        
    }
    else {
        isAnimating = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.bgView removeFromSuperview];
            isAnimating = NO;
        }];
    }
}
//点击背景
- (void)backViewClick:(UIButton *)btn {
    [self dismiss];
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}
- (NSMutableArray *)menuButtons {
    if (!_menuButtons) {
        _menuButtons = [NSMutableArray array];
    }
    return _menuButtons;
}

- (NSMutableArray *)controllers {
    if (!_controllers) {
        _controllers = [NSMutableArray array];
    }
    return _controllers;
}
- (NSMutableArray *)colsHeight {
    if (!_colsHeight) {
        _colsHeight = [NSMutableArray array];
    }
    return _colsHeight;
}
- (UIButton *)bgView {
    if (!_bgView) {
        _bgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [_bgView addTarget:self action:@selector(backViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgView;
}

/** 隐藏下拉菜单 */
- (void)dismiss {
    if (lastButton) {
       lastButton.selected = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
    }];
}
/** 刷新 */
- (void)reload {
    
}

#pragma mark - 界面销毁
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
