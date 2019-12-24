//
//  EffectSliderView.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/16.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSlider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EffectSliderViewDelegate;

@interface EffectSliderView : UIView

@property (nonatomic,strong) CustomSlider *slider;
@property (nonatomic,assign) id<EffectSliderViewDelegate> delegate;

@end

@protocol EffectSliderViewDelegate <NSObject>

- (void)effectSliderValueChanged:(CGFloat)value;
- (void)effectCancel;
- (void)effectConfirm;

@end

NS_ASSUME_NONNULL_END


