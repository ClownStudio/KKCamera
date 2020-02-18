//
//  EffectItemView.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/18.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EffectItemView.h"
#import "ProManager.h"

@implementation EffectItemView{
    UIImageView *_imageView;
    UIImageView *_lockView;
    UILabel *_label;
    BOOL _isSelected;
    NSDictionary *_content;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isSelected = NO;
        self.isAward = NO;
        self.isPurchase = YES;
        [self setUserInteractionEnabled:YES];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [_imageView setUserInteractionEnabled:YES];
        [self addSubview:_imageView];
        
        _lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kk_lock"]];
        CGRect temp = _lockView.frame;
        temp.origin.x = frame.size.width - temp.size.width - 2;
        temp.origin.y = 2;
        _lockView.frame = temp;
        [_lockView setHidden:YES];
        [self addSubview:_lockView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        [_label setFont:[UIFont systemFontOfSize:12]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setUserInteractionEnabled:YES];
        [self addSubview:_label];
    }
    return self;
}

- (void)setItemSelected:(BOOL)isSelect{
    if (_isSelected == isSelect) {
        return;
    }
    _isSelected = isSelect;
    if (_isSelected) {
        [_imageView setImage:[UIImage imageNamed:[_content objectForKey:@"iconSelected"]]];
        [_label setBackgroundColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"color_selected"]]]];
        [_label setTextColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"fontColorSelected"]]]];
    }else{
        [_imageView setImage:[UIImage imageNamed:[_content objectForKey:@"icon"]]];
        [_label setBackgroundColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"color"]]]];
        [_label setTextColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"fontColor"]]]];
    }
}

- (void)setItemWithData:(NSDictionary *)dict{
    _content = dict;
    if([@1 isEqual:[dict objectForKey:@"isPurchase"]]){
        self.isPurchase = YES;
    }else{
        if ([dict objectForKey:@"productCode"] == nil || [@"" isEqualToString:[dict objectForKey:@"productCode"]] || [ProManager isProductPaid:[dict objectForKey:@"productCode"]] || [ProManager isProductPaid:ALL_PRODUCT_ID] || [ProManager isProductPaid:YEAR_ID] || [ProManager isProductPaid:MONTH_ID]) {
            self.isPurchase = YES;
        }else{
            self.isPurchase = NO;
        }
    }
    [_lockView setHidden:self.isPurchase];
    self.isAward = [@"YES" isEqualToString:[dict objectForKey:@"isAward"]]? YES : NO;
    [_imageView setImage:[UIImage imageNamed:[_content objectForKey:@"icon"]]];
    [_label setBackgroundColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"color"]]]];
    [_label setTextColor:[UIColor colorWithString:[NSString stringWithFormat:@"{%@}",[_content objectForKey:@"fontColor"]]]];
    [_label setText:[_content objectForKey:@"name"]];
}

@end
