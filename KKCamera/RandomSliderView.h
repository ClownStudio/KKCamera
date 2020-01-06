//
//  RandomSliderView.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/31.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSlider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RandomSliderViewDelegate;
@interface RandomSliderView : UIView

@property (nonatomic,strong) CustomSlider *slider;
@property (nonatomic,assign) id<RandomSliderViewDelegate> delegate;
-(void)reset;

@end

@protocol RandomSliderViewDelegate <NSObject>

- (void)randomSliderValueChanged:(CGFloat)value;
- (void)randomForEffect;
- (void)randomConfirm;

@end

NS_ASSUME_NONNULL_END
