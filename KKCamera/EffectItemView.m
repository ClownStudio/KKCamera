//
//  EffectItemView.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/18.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EffectItemView.h"

@implementation EffectItemView{
    UIImageView *_imageView;
    UILabel *_label;
    BOOL _isSelected;
    NSDictionary *_content;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isSelected = NO;
        [self setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [_imageView setUserInteractionEnabled:YES];
        [_imageView addGestureRecognizer:tap];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        [_label setFont:[UIFont systemFontOfSize:12]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setUserInteractionEnabled:YES];
        [_label addGestureRecognizer:tap];
        [self addSubview:_label];
    }
    return self;
}

- (void)onTap{
    [self setItemSelected:YES];
}

- (void)setItemSelected:(BOOL)isSelect{
    [self refreshItemSelect];
    _isSelected = isSelect;
}

- (void)refreshItemSelect{
    if (_isSelected) {
        return;
    }
    [_imageView setImage:[UIImage imageNamed:[_content objectForKey:@"iconselected"]]];
    [_label setBackgroundColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"colorselected"]]]];
    [_label setTextColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"fontColorselected"]]]];
}

- (void)setItemWithData:(NSDictionary *)dict{
    _content = dict;
    [_imageView setImage:[UIImage imageNamed:[_content objectForKey:@"icon"]]];
    [_label setBackgroundColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"color"]]]];
    [_label setTextColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"fontColor"]]]];
}

@end
