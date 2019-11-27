//
//  PCFilterView.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/21.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCFilterView.h"

@implementation PCFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapGesture];
        
        _imageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height - 15.0f)];
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0f, frame.size.height - 15.0f, frame.size.width - 10, 15.0f)];
        _titleLabel.font = [UIFont systemFontOfSize:10.0f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    if (_selected) {
        return;
    }
    self.selected = !_selected;
    if ([self.delegate respondsToSelector:@selector(filterViewDidSelectedStatusChange:)]) {
        [self.delegate filterViewDidSelectedStatusChange:self];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    [UIView animateWithDuration:0.2f animations:^{
        if (_selected) {
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }
        else {
            self.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)setFilterName:(NSString *)filterName
{
    _filterName = [filterName copy];
    _titleLabel.text = _filterName;
}

@end
