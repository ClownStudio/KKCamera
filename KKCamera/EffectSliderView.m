//
//  EffectSliderView.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/16.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EffectSliderView.h"
#import "CustomSlider.h"

@implementation EffectSliderView{
    UILabel *_label;
    CustomSlider *_slider;
    UIButton *_confirmBtn;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setText:@"50%"];
        [self addSubview:_label];
        
        _slider = [[CustomSlider alloc] initWithFrame:CGRectMake(40, 0, 150, 35)];
        [_slider setUserInteractionEnabled:YES];
        [_slider setThumbImage:[UIImage imageNamed:@"kk_slider_circle"] forState:UIControlStateNormal];
        [_slider setMaximumValue:100];
        [_slider setMinimumValue:0];
        [_slider setValue:50];
        [self addSubview:_slider];
        
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(190, 0, 35, 35)];
        [_confirmBtn setImage:[UIImage imageNamed:@"kk_slider_done"] forState:UIControlStateNormal];
        [_confirmBtn setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_confirmBtn];
    }
    return self;
}

@end
