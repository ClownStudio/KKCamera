//
//  CustomSlider.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/16.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomSlider : UISlider

@property(nonatomic, copy) void(^valueChangedBlock)(void);

@end

NS_ASSUME_NONNULL_END
