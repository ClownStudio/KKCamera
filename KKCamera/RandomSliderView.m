//
//  RandomSliderView.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/31.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "RandomSliderView.h"

@implementation RandomSliderView{
    UILabel *_label;
    UIButton *_confirmBtn;
    UIButton *_randomBtn;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _randomBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 110, frame.size.height)];
        [_randomBtn.layer setMasksToBounds:YES];
        [_randomBtn.layer setCornerRadius:frame.size.height/2];
        [_randomBtn.layer setBorderWidth:1];
        [_randomBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_randomBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_randomBtn setTitle:NSLocalizedString(@"AUTO", nil) forState:UIControlStateNormal];
        [_randomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_randomBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_randomBtn addTarget:self action:@selector(onRandom:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_randomBtn];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(125, 0, 35, 35)];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setText:@"50%"];
        [self addSubview:_label];
        
        self.slider = [[CustomSlider alloc] initWithFrame:CGRectMake(170, 0, frame.size.width - 225, 35)];
        [self.slider setUserInteractionEnabled:YES];
        [self.slider setMaximumValue:1];
        [self.slider setMinimumValue:0];
        [self.slider setValue:1];
        [self.slider setThumbImage:[UIImage imageNamed:@"kk_slider_circle"] forState:UIControlStateNormal];
        //滑杆左侧颜色
        self.slider.minimumTrackTintColor = [UIColor whiteColor];
        //滑杆右侧颜色
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        [self.slider setValueChangedBlock:^{
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(randomSliderValueChanged:)]) {
                [self->_label setText:[NSString stringWithFormat:@"%d%%",(int)((self->_slider.value)*100)]];
                [self->_delegate randomSliderValueChanged:self.slider.value];
            }
        }];
        [self addSubview:self.slider];
        
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 45, 0, 35, 35)];
        [_confirmBtn setImage:[UIImage imageNamed:@"kk_slider_done"] forState:UIControlStateNormal];
        [_confirmBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_confirmBtn addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmBtn];
    }
    return self;
}

-(void)reset{
    [_label setText:@"100%"];
    [self.slider setValue: 1];
}

-(void)dealloc{
    [self.slider removeObserver:self forKeyPath:@"value"];
}

-(IBAction)onRandom:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(randomForEffect)]) {
        [_delegate randomForEffect];
    }
}

-(IBAction)onConfirm:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(randomConfirm)]) {
        [_delegate randomConfirm];
    }
}

@end
