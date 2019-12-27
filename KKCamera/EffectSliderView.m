//
//  EffectSliderView.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/16.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EffectSliderView.h"

@implementation EffectSliderView{
    UILabel *_label;
    UIButton *_confirmBtn;
    UIButton *_cancelBtn;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, 35, 35)];
        [_cancelBtn setImage:[UIImage imageNamed:@"kk_slider_cancel"] forState:UIControlStateNormal];
        [_cancelBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        
        self.slider = [[CustomSlider alloc] initWithFrame:CGRectMake(75, 0, frame.size.width - 165, 35)];
        [self.slider setUserInteractionEnabled:YES];
        [self.slider setThumbImage:[UIImage imageNamed:@"kk_slider_circle"] forState:UIControlStateNormal];
        [self.slider setCustomSliderValueChangedBlock:^{
//            [self->_label setText:[NSString stringWithFormat:@"%.0f%%",self.slider.value]];
            if (self.delegate && [self->_delegate respondsToSelector:@selector(effectSliderValueChanged:)]) {
                [self.delegate effectSliderValueChanged:self.slider.value];
            }
        }];
        [self addSubview:self.slider];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 90, 0, 35, 35)];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
        
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 45, 0, 35, 35)];
        [_confirmBtn setImage:[UIImage imageNamed:@"kk_slider_done"] forState:UIControlStateNormal];
        [_confirmBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_confirmBtn addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmBtn];
    }
    return self;
}

-(IBAction)onCancel:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(effectCancel)]) {
        [_delegate effectCancel];
    }
}

-(IBAction)onConfirm:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(effectConfirm)]) {
        [_delegate effectConfirm];
    }
}

@end
