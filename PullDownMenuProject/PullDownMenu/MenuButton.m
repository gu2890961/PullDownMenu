//
//  MenuButton.m
//  PullDownMenuProject
//
//  Created by apple on 2017/5/2.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#import "MenuButton.h"

@interface MenuButton ()
{
    BOOL isSelect;
    BOOL hasChange;
}
@end
@implementation MenuButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected {
    isSelect = selected;
    if (selected) {
        hasChange = YES;
        self.tintColor = [self titleColorForState:UIControlStateSelected];
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.transform = CGAffineTransformMakeRotation(-M_PI);
        }];
        
    }
    else {
        self.tintColor = [self titleColorForState:UIControlStateNormal];
        if (hasChange) {
            [UIView animateWithDuration:0.3 animations:^{
                
//                self.imageView.transform = CGAffineTransformRotate(self.transform, -2*M_PI);
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (BOOL)isSelected {
    return isSelect;
}

//图片靠右边
- (void)setRightspacing:(CGFloat)spacing
{
    //    self.backgroundColor = [UIColor redColor];
    CGFloat imageWidth = self.imageView.image.size.width;
    
    CGFloat labelWidth = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width-imageWidth, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size.width+2;
    CGFloat buttom = 0;
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        buttom = 2;
    }
    self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, buttom, -(labelWidth + spacing/2));
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + spacing/2), 0, imageWidth + spacing/2);
    self.contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, spacing/2);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setRightspacing:2];
}

@end
