//
//  PCSelectView.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCSelectView.h"

@implementation PCSelectView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.0f, 5.0f, frame.size.width - 10.0f, frame.size.height - 10.0f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.image = image;
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(frame.size.width - 28.0f, 0.0f, 28.0f, 28.0f);
        [_deleteButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_imageView];
        [self addSubview:_deleteButton];
    }
    return self;
}

- (void)deleteAction
{
    [UIView animateWithDuration:0.2f animations:^{
        _deleteButton.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(selectViewDidDeleteAction:)]) {
            [self.delegate selectViewDidDeleteAction:self];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
