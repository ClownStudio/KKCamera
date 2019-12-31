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
        _randomBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 90, frame.size.height)];
        [_randomBtn.layer setMasksToBounds:YES];
        [_randomBtn.layer setCornerRadius:frame.size.height/2];
        [_randomBtn.layer setBorderWidth:1];
        [_randomBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_randomBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_randomBtn setTitle:@"AUTO RANDOM" forState:UIControlStateNormal];
        [_randomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_randomBtn];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 35, 35)];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setText:@"50%"];
        [self addSubview:_label];
        
        self.slider = [[CustomSlider alloc] initWithFrame:CGRectMake(145, 0, frame.size.width - 200, 35)];
        [self.slider setUserInteractionEnabled:YES];
        [self.slider setThumbImage:[UIImage imageNamed:@"kk_slider_circle"] forState:UIControlStateNormal];
        [self.slider addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 45, 0, 35, 35)];
        [_confirmBtn setImage:[UIImage imageNamed:@"kk_slider_done"] forState:UIControlStateNormal];
        [_confirmBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_confirmBtn addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmBtn];
        
        [self.slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([@"value" isEqualToString:keyPath]) {
        [_label setText:[NSString stringWithFormat:@"%d%%",(int)((_slider.value - _slider.minimumValue)/(_slider.maximumValue - _slider.minimumValue)*100)]];
    }
}

-(void)dealloc{
    [self.slider removeObserver:self forKeyPath:@"value"];
}


-(IBAction)onChange:(id)sender{
    [_label setText:[NSString stringWithFormat:@"%d%%",(int)((_slider.value - _slider.minimumValue)/(_slider.maximumValue - _slider.minimumValue)*100)]];
    if (self.delegate && [self->_delegate respondsToSelector:@selector(randomSliderValueChanged:)]) {
        [self.delegate randomSliderValueChanged:self.slider.value];
    }
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
